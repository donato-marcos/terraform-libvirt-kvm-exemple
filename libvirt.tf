terraform {
  required_version = ">= 1.11.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = ">= 0.9.1"
    }
  }
}

provider "libvirt" {
  # Conexão local
  uri = "qemu:///system"

  # Conexão remota
  #uri = "qemu+ssh://kharma@192.168.0.16/system?keyfile=/home/mdonato/.ssh/id_rsa"
}

resource "libvirt_volume" "rocky_base" {
  name = "rocky-9-base.qcow2"
  pool = "default"

  target = {
    format = {
      type = "qcow2"
    }
  }

  create = {
    content = {
      url = "/home/mdonato/vm/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
    }
  }
}

resource "libvirt_volume" "rocky_disk" {
  name = "rocky-vm.qcow2"
  pool = "default"

  target = {
    format = {
      type = "qcow2"
    }
  }

  capacity = 50 * 1024 * 1024 * 1024

  backing_store = {
    path = libvirt_volume.rocky_base.path
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_cloudinit_disk" "rocky_seed" {
  name           = "rocky-cloudinit"
  user_data      = file("user-data.yaml")
  meta_data      = file("meta-data.yaml")
  network_config = file("network-config.yaml")
}

resource "libvirt_volume" "rocky_seed_iso" {
  name = "rocky-cloudinit.iso"
  pool = "default"

  create = {
    content = {
      url = libvirt_cloudinit_disk.rocky_seed.path
    }
  }
}

resource "libvirt_network" "virt_network" {
  name      = "teste"
  autostart = true

  forward = {
    mode = "nat"
  }
  domain = {
    name = "teste"
  }
  ips = [
    {
      address = "10.0.0.1"
      prefix  = "24"

      dhcp = {
        ranges = [
          {
            start = "10.0.0.20"
            end   = "10.0.0.30"
          }
        ]
      }
    },
    #{
    #  family  = "ipv6"
    #  address = "fd00:11::1"
    #  prefix  = 64
    #
    #  dhcp = {
    #    ranges = [
    #      {
    #        start = "fd00:11::100"
    #        end   = "fd00:11::1ff"
    #      }
    #    ]
    #  }
    #}
  ]
}

resource "libvirt_domain" "virt_domain" {
  name                = "opentofu-rocky-teste"
  current_memory_unit = "MiB"
  current_memory      = 512
  memory_unit         = "MiB"
  memory              = 768
  vcpu                = 2
  type                = "kvm"
  running             = true

  os = {
    type            = "hvm"
    type_arch       = "x86_64"
    type_machine    = "q35"
    firmware        = "efi"
    loader          = "/usr/share/edk2/ovmf/OVMF_CODE_4M.secboot.qcow2"
    loader_format   = "qcow2"
    loader_readonly = "yes"
    loader_secure   = "yes"
    loader_type     = "pflash"
  }

  features = {
    acpi = true
    apic = {
      eoi = "on"
    }
    smm = {
      state = "on"
    }
    vm_port = {
      state = "off"
    }
  }

  cpu = {
    mode = "host-passthrough"
  }

  clock = {
    timer = [
      {
        name        = "rtc"
        tick_policy = "catchup"
      },
      {
        name        = "pit"
        tick_policy = "delay"
      },
      {
        name    = "hpet"
        present = "no"
      }
    ]
  }

  pm = {
    suspend_to_mem = {
      enabled = "no"
    }
    suspend_to_disk = {
      enabled = "no"
    }
  }

  devices = {

    disks = [
      {
        driver = {
          name    = "qemu"
          type    = "qcow2"
          discard = "unmap"
        }
        source = {
          volume = {
            pool   = libvirt_volume.rocky_disk.pool
            volume = libvirt_volume.rocky_disk.name
          }
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
        boot = {
          order = 1
        }
      },
      {
        device = "cdrom"
        driver = {
          name = "qemu"
          type = "raw"
        }
        source = {
          volume = {
            pool   = libvirt_volume.rocky_seed_iso.pool
            volume = libvirt_volume.rocky_seed_iso.name
          }
        }
        target = {
          dev = "sda"
          bus = "sata"
        }
      }
    ]

    interfaces = [
      {
        source = {
          network = {
            network = libvirt_network.virt_network.name
          }
        }
        model = {
          type = "virtio"
        }
        wait_for_ip = {
          timeout = 120
          source  = "lease"
        }
      }
    ]

    consoles = [
      {
        type = "pty"
        target = {
          type = "serial"
        }
      }
    ]

    channels = [
      {
        source = {
          unix = {
            mode = "bind"
          }
        }
        target = {
          type = "virtio"
          virt_io = {
            name = "org.qemu.guest_agent.0"
          }
        }
      },
      {
        source = {
          spice_vmc = true
        }
        target = {
          virt_io = {
            name = "com.redhat.spice.0"
          }
        }
      }
    ]

    inputs = [
      {
        type = "tablet"
        bus  = "usb"
      }
    ]

    tpms = [
      {
        model = "tpm-crb"
        backend = {
          emulator = {
            version = "2.0"
          }
        }
      }
    ]

    graphics = [
      {
        spice = {
          auto_port = true
          image = {
            compression = "off"
          }
        }
      }
    ]

    sounds = [
      {
        model = "ich9"
      }
    ]

    videos = [
      {
        model = {
          type    = "virtio"
          primary = "yes"
          heads   = 1
        }
      }
    ]

    redir_devs = [
      {
        bus = "usb"
        source = {
          spice_vmc = true
        }
      },
      {
        bus = "usb"
        source = {
          spice_vmc = true
        }
      }
    ]

    rngs = [
      {
        model = "virtio"
        backend = {
          random = "/dev/urandom"
        }
      }
    ]

  }
}
