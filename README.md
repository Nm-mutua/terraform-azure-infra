# 🚀 Terraform Azure Virtual Machine Infrastructure

This project provisions a complete Azure infrastructure using Terraform, including:

- Azure Resource Group  
- Virtual Network & Subnet  
- Network Security Group (NSG) and rules  
- Public IP and Network Interface  
- Ubuntu Linux Virtual Machine  
- Cloud-init for VM configuration via `customdata.tpl`  
- Docker Engine pre-installed for containerized workloads  

---

## 📁 Project Structure

.
├── main.tf # Main Terraform configuration
├── variables.tf # Declares input variables
├── osx.tfvars # Variable values (used with -var-file)
├── .gitignore # Files/directories to ignore in Git
├── .terraform.lock.hcl # Dependency lock file for Terraform
├── terraform-output.png # Screenshot of Azure portal output
├── README.md # Project documentation


---

## ⚙️ Getting Started

### ✅ Prerequisites

- Terraform v1.4+
- Azure CLI
- SSH (Cloud-init)
- Ubuntu 20.04 LTS

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

✅ Installed Docker Engine on Ubuntu 20.04 LTS
🛠️ Verified installation using: docker --version
📦 Purpose: Prepares the VM for container-based workloads (optional future expansion)
📜 Installed via cloud-init script defined in customdata.tpl
📂 All configurations handled through ansible/playbook.yml

### CI/CD with GitHub Actions

This project is designed for future integration with GitHub Actions. Planned automation steps include:

**Terraform**: `terraform fmt` `validate` , and `test`
**Ansible linting**: Ensure playbook syntax and best practices
**SSH deployment**: Deploy playbook to Azure VM using CI pipeline
**Security Scans** Use `tfsec` and `ansible-lint` for code scanning
**Apache Setup & Hardening**:
  ✅ Installed Apache Web Server using Ansible playbook
  📄 Apache configured to serve a default index.html page
  🔐 Hardened with UFW (Allow 22, 80), Fail2Ban
  📂 All configurations handled through ansible/playbook.yml

📸 ## Screenshot
Terraform output after applying the configuration on Azure:

### Planned Enhancements (Roadmap)

 🔧[x] Integrate Ansible to configure Apache and harden the VM
 🔐 []Secure credentials using Azure Key Vault
 📊 []Enable Azure Monitor and Log Analytics
 🛡️ [x]Harden VM with UFW, Fail2Ban, and best security practices
 ⚙️ []Automate with GitHub Actions CI/CD
 📦 []Use Terraform modules to organize infrastructure

 👤 Author
GitHub Profile: Nm-mutua
