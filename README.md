# 🚀 Terraform Azure Virtual Machine Infrastructure

This project provisions a complete Azure infrastructure using Terraform, including:

- Azure Resource Group  
- Virtual Network & Subnet  
- Network Security Group (NSG) and rules  
- Public IP and Network Interface  
- Ubuntu Linux Virtual Machine  
- Cloud-init for VM configuration via `customdata.tpl`  
- Automated server configuration and hardening with Ansible (see [Apache Setup & Hardening](#apache-setup--hardening))  

---

## 📁 Project Structure

```
.
├── main.tf                       # Main Terraform configuration
├── variables.tf                  # Declares input variables
├── osx.tfvars                    # Variable values (used with -var-file)
├── .gitignore                    # Files/directories to ignore in Git
├── .terraform.lock.hcl           # Dependency lock file for Terraform
├── README.md                     # Project documentation

├── screenshots/                  # Screenshots and visual references
│   └── terraform-output.png      # Screenshot of Azure portal output

├── ansible/                      # Ansible configuration directory
│   ├── playbook.yml              # Ansible playbook to configure Apache & harden the VM
│   ├── inventory.ini             # Inventory file listing the target VM
│   ├── roles/                    # Ansible roles (modular configuration)
│   │   ├── apache/               # Role: Install & configure Apache
│   │   ├── security/             # Role: Harden VM with UFW, Fail2Ban
│   │   └── docker/               # (Optional) Role: Install & configure Docker
│   └── group_vars/
│       └── all.yml               # Global variables for Ansible

├── scripts/                      # Shell scripts (optional)
│   └── install_ansible.sh        # Script to install Ansible on control node

└── templates/
    └── customdata.tpl            # Cloud-init script for VM provisioning
```

## ⚙️ Getting Started

### ✅ Prerequisites

- Terraform v1.4+
- Azure CLI
- SSH (Cloud-init)
- Ubuntu 20.04 LTS
- Ansible v2.10+
- Python 3
- GitHub Actions

### ▶️ Usage

```bash
terraform fmt                        # Format code
terraform validate                   # Check for syntax errors
terraform init                       # Initialize the directory
terraform plan                       # Preview the changes
terraform apply -auto-approve        # Apply changes
```

### Post-Deployment Configuration

After successful provisioning with Terraform, the following configuration was performed on the Azure VM (mtc-vm):

- ✅ Installed Docker Engine on Ubuntu 20.04 LTS
- 🛠️ Verified installation using: docker --version
- 📦 Purpose: Prepares the VM for container-based workloads (optional future expansion)
- 📜 Installed via cloud-init script defined in [`customdata.tpl`](./customdata.tpl)
- 📂 All configurations handled through ansible/playbook.yml

### CI/CD with GitHub Actions

This project is designed for future integration with GitHub Actions. Planned automation steps include:

- **Terraform**: `terraform fmt` `validate` , and `test`
- **Ansible linting**: Ensure playbook syntax and best practices
- **SSH deployment**: Deploy playbook to Azure VM using CI pipeline
- **Security Scans** Use `tfsec` and `ansible-lint` for code scanning
- **Apache Setup & Hardening**:
  - ✅ Installed Apache Web Server using Ansible playbook
  - 📄 Apache is configured to serve a default index.html page
  - 🔐 Hardened with UFW (Allow 22, 80), Fail2Ban
  - 📂 All configurations handled through ansible/playbook.yml

## 📸 Screenshots

### Terraform output after applying the configuration on Azure:
![Terraform Output showing Azure resources](./terraform-output.png)

### Ansible Playbook Run Output
![Ansible Playbook Run](screenshots/ansible-playbook-run.png)

### Apache2 Service Running
![Apache2 Service Status](screenshots/apache2-service-status.png)

### Apache2 Ubuntu Default Page
![Apache2 Ubuntu Default Page](screenshots/apache2-ubuntu-default-page.png)

### Fail2Ban SSH Jail Status
![Fail2Ban SSH Jail Status](screenshots/fail2ban-ssh-jail-status.png)


### Planned Enhancements (Roadmap)

- 🔧 [x] Integrate Ansible to configure Apache and harden the VM
- 🛡️ [x]Harden VM with UFW, Fail2Ban, and best security practices
- 🔐 [ ]Secure credentials using Azure Key Vault
- 📊 [ ]Enable Azure Monitor and Log Analytics
- ⚙️ [ ]Automate with GitHub Actions CI/CD
- 📦 [ ]Use Terraform modules to organize infrastructure

 👤 Author
GitHub Profile: [**Nm-mutua**](https:github.com/Nm-mutua).

## Credits
This project is inspired by the [FreeCodeCamp Terraform on Azure tutorial](https://www.youtube.com/watch?v=V53AHWun17s&list=WL&index=4)

