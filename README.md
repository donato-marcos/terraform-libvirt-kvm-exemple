# Terraform Libvirt KVM – Basic Example

This repository contains the **basic and essential** configuration files required to provision a virtual machine using **Terraform + Libvirt/KVM**, leveraging **cloud-init** for initial setup. It represents the **seed of a modular project** that later evolved into [Projeto-Terraform-Libvirt-KVM](https://github.com/donato-marcos/Projeto-Terraform-Libvirt-KVM).

## 🌟 Overview

This example demonstrates how to create a **Rocky Linux** VM with:

* Network configuration via cloud-init
* SSH key-based authentication
* Pre-installed packages
* Initial system configuration

It is ideal for **labs, quick testing, and prototyping** before migrating to a fully modular architecture.

## 📁 Main Files

| File                  | Description                                       |
| --------------------- | ------------------------------------------------- |
| `network-config.yaml` | Network configuration (DHCP for IPv4/IPv6)        |
| `meta-data.yaml`      | Instance metadata (hostname, instance-id)         |
| `user-data.yaml`      | User configuration (password, packages, commands) |
| `libvirt.tf.txt`      | Terraform configuration to provision the VM       |

## 🛠️ Prerequisites

* **Libvirt/KVM** installed and running (`libvirtd`)
* **Terraform** version >= 1.11.0
* **`dmacvicar/libvirt` provider** version >= 0.9.1
* **Base image** of Rocky Linux (or another distribution) in the specified directory

## 🚀 How to Use

1. **Clone the repository**:

   ```bash
   git clone https://github.com/seu-usuario/terraform-libvirt-kvm-exemple.git
   cd terraform-libvirt-kvm-exemple
   ```

2. **Configure the files**:

   * Update paths in `libvirt.tf.txt` to point to your images
   * Customize `user-data.yaml` according to your requirements

3. **Provision the VM**:

   ```bash
   terraform init
   terraform apply
   ```

4. **Access the VM**:

   ```bash
   ssh aluno@<VM-IP>
   ```

## 🌐 Directory Structure

```
.
├── network-config.yaml    # Network configuration
├── meta-data.yaml         # Instance metadata
├── user-data.yaml         # User configuration
└── libvirt.tf             # Terraform configuration
```

## 🔄 Customization

1. **To change the operating system**:

   * Replace `Rocky-9-GenericCloud-Base.latest.x86_64.qcow2` with another image
   * Adjust `user-data.yaml` according to the distribution

2. **To add more network interfaces**:

   * Configure networking in `libvirt.tf`
   * Update `network-config.yaml` to include new interfaces

3. **To enable IPv6**:

   * Uncomment the IPv6 section in `libvirt.tf`
   * Properly configure addresses in `network-config.yaml`

## 💡 Lab Tips

* Use `wait_for_ip` to ensure the VM is ready before proceeding
* Keep cloud-init templates in a separate directory for reuse
* For more complex labs, migrate to the [full modular architecture](https://github.com/donato-marcos/Projeto-Terraform-Libvirt-KVM)

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a branch for your changes
3. Submit a pull request

## 📜 License

This project is licensed under the **MIT License** – see the [LICENSE](LICENSE) file for details.

> This is the **starting point** for building virtualized infrastructures with Terraform and Libvirt. Use it as a foundation for creating labs, testing environments, and demo systems.
