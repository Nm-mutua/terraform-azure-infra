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
├── main.tf # Main Terraform configuration (VM, Key Vault, Secret)
├── variables.tf # Declares input variables
├── osx.tfvars # Variable values (used with -var-file)
├── outputs.tf # Terraform output values (e.g. public IP, client_id)
├── .gitignore # Files/directories to ignore in Git
├── .terraform.lock.hcl # Dependency lock file for Terraform
├── README.md # Project documentation

├── screenshots/ # Screenshots and visual references
│ ├── terraform-output.png # Terraform output showing Azure resources
│ ├── Ansible_Playbook_Run.png # Ansible playbook execution output
│ ├── Apache2_Service_Status.png # Apache2 systemctl service status
│ ├── Apache2_Ubuntu_Default_Page.png # Default Apache2 welcome page
│ ├── Fail2Ban_SSH_Jail_Status.png # Fail2Ban jail status confirming protection
│ ├── Terraform_Plan.png # Terraform plan before applying
│ ├── Terraform_Apply.png # Terraform apply showing successful resource creation
│ ├── Keyvault_Secret_Success.png # Confirmation that secret was created
│ ├── Keyvault_Secret_Detail.png # Secret version, name, and status
│ └── Keyvault_Access_Policy.png # Access policy with secret permissions

├── ansible/ # Ansible configuration directory
│ ├── playbook.yml # Ansible playbook to configure Apache & harden the VM
│ ├── inventory.ini # Inventory file listing the target VM
│ ├── roles/ # Ansible roles (modular configuration)
│ │ ├── apache/ # Role: Install & configure Apache
│ │ ├── security/ # Role: Harden VM with UFW, Fail2Ban
│ │ └── docker/ # (Optional) Role: Install & configure Docker
│ └── group_vars/
│ └── all.yml # Global variables for Ansible

├── scripts/ # Shell scripts (optional)
│ └── install_ansible.sh # Script to install Ansible on control node

└── templates/
└── customdata.tpl # Cloud-init script for VM provisioning
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
- Azure Key Vault
- GitHub for version control

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

### 🔐 Secure Credentials with Azure Key Vault using Terraform
This section demonstrates how I used Terraform to deploy an Azure Key Vault instance and securely store a secret.

## 🚀 Steps

1. Define Key Vault in Terraform
   - I used the azurerm_key_vault resource to deploy Key Vault and attach proper access policies for my Service Principal.

2. Add Access Policy
   - The policy grants permission to get, list, and set secrets (see screenshot).

3. Inject Secret via Terraform
   - I created a sample secret (e.g., a database password) using the azurerm_key_vault_secret resource.

4. Verify Key Vault Deployment
   - After running terraform apply, the Key Vault and its secret were successfully provisioned.
       - ✅ Plan phase:
       - ✅ Apply phase:

5. Secret Confirmed in Azure Portal
   - The secret was successfully created and stored securely.
       - ✅ Success toast:
       - 🔍 Secret details:

## ✅ Outcome
    - This demo shows how sensitive data (such as API keys or passwords) can be securely managed using Infrastructure as Code and Azure-native services, aligning with DevOps and security best practices.

## 📡 Azure Monitor Agent (AMA) + Data Collection Rule (DCR) Setup

This section documents the configuration of **Azure Monitor Agent (AMA)** and **Data Collection Rules (DCR)** to collect guest OS metrics and Syslog data from the Azure Linux VM (`mtc-vm`).  
The setup was fully automated using **Terraform**.

### 🎯 Purpose
- Enable **guest-level monitoring** for system metrics and logs
- Forward **Syslog** and performance counters to **Azure Log Analytics Workspace**
- Provide centralized observability for VM health and security events

---

### 🛠 Steps

1. **Azure Log Analytics Workspace Provisioned**  
   - Created in Terraform to store logs and metrics.
   - Linked to the VM via DCR.

2. **Azure Monitor Agent Installed on VM**  
   - AMA installed automatically during Terraform apply.
   - Visible under VM → Extensions in Azure Portal.

3. **Data Collection Endpoint (DCE) Created**  
   - Acts as the ingestion point for VM telemetry.
   - Configured in Terraform.

4. **Data Collection Rule (DCR) Configured**  
   - Collects Syslog from facilities: `auth`, `cron`, `daemon`, `kern`, `syslog`, `user`
   - Captures performance counters for CPU, memory, disk, and network.

5. **DCR Association with VM**  
   - Binds the VM to the DCR so logs/metrics flow into the workspace.

6. **Verification in Azure Portal**  
   - Queries run in Log Analytics confirmed Syslog and performance data ingestion.

### 📊 Verification Queries

**Syslog Query:**
```kusto

Syslog
| where TimeGenerated > ago(30m)
| sort by TimeGenerated desc

**Performance Counters Query:**
```kusto

Perf
| where TimeGenerated > ago(30m)
| summarize avg(CounterValue) by Computer, ObjectName, CounterName
| order by Computer, ObjectName, CounterName

```

✅ Outcome:
This configuration enables end-to-end monitoring for the VM, providing both platform metrics and guest OS logs, all automated through Terraform and integrated into Azure Monitor.

## 📸 Screenshots

### Terraform output after applying the configuration on Azure:
![Terraform Output showing Azure resources](screenshots/terraform-output.png)

### Ansible Playbook Run Output
![Ansible Playbook Run](screenshots/Ansible_Playbook_Run.png)

### Apache2 Service Running
![Apache2 Service Status](screenshots/Apache2_Service_Status.png)

### Apache2 Ubuntu Default Page
![Apache2 Ubuntu Default Page](screenshots/Apache2_Ubuntu_Default_Page.png)

### Fail2Ban SSH Jail Status
![Fail2Ban SSH Jail Status](screenshots/Fail2Ban_SSH_Jail_Status.png)

### Terraform Plan before Applying
![Terraform Plan Output](screenshots/Terraform_Plan.png)

### Terraform Output after Applying the Configuration on Azure
![Terraform Apply Output](screenshots/Terraform_Apply.png)

### Azure Key Vault Secret Created Successfully
![Azure Key Vault Secret Created](screenshots/Keyvault_Secret_Success.png)

### Azure Key Vault Secret Details Page
![Azure Key Vault Secret Details](screenshots/Keyvault_Secret_Detail.png)

### Azure Key Vault Access Policy Assigned
![Azure Key Vault Access Policy](screenshots/Keyvault_Access_Policy.png)

### Azure Log Analytics Workspace Created
![Azure Log Analytics Workspace Installed](screenshots/Azure_Log_Analytics_Workspace_Installed.png)

### Azure Monitor Agent Installed on Linux VM
![Azure Monitor Linux Agent Installed](screenshots/Azure_Monitor_Linux_Agent_Installed.png)

### Terraform Output — Workspace Created
![Terraform Output - Workspace](screenshots/Azurerm_Log_Analytics_Workspace_Apply_Output.png)

### Terraform Output — Data Collection Endpoint Created
![Terraform Output - DCE](screenshots/Azurerm_Monitor_Data_Collection_Endpoint_Apply_Output.png)

### Terraform Output — Data Collection Rule Created
![Terraform Output - DCR](screenshots/Azurerm_Monitor_Data_Collection_Rule_Apply_Output.png)

### Terraform Output — DCR Association Created
![Terraform Output - Association](screenshots/Azurerm_Monitor_Data_Collection_Rule_Association_Apply_Output.png)

### Data Collection Endpoint Configured
![DCE Configured](screenshots/Data_Collection_Endpoint_Configured.png)

### Data Collection Rule Configured
![DCR Configured](screenshots/Data_Collection_Rule_Configured.png)

### VM Associated with DCR**
![VM Associated](screenshots/Mtc_VM_Associated_With_DCR.png)

### Syslog Logs Collected
![Syslog Logs](screenshots/Syslog_Logs_Populated.png)

### Performance Logs Collected
![Performance Logs](screenshots/Perf_Logs_Populated.png)

### Syslog Performance Counters Configured**
![Syslog Perf Counters](screenshots/Syslog_Perf_Counters_Configured.png)

### Planned Enhancements (Roadmap)

- 🔧 [x] Integrate Ansible to configure Apache and harden the VM
- 🛡️ [x]Harden VM with UFW, Fail2Ban, and best security practices
- 🔐 [x]Secure credentials using Azure Key Vault
- 📊 [ ]Enable Azure Monitor and Log Analytics
- ⚙️ [ ]Automate with GitHub Actions CI/CD
- 📦 [ ]Use Terraform modules to organize infrastructure

 👤 Author
GitHub Profile: [**Nm-mutua**](https:github.com/Nm-mutua).

## Credits
This project is inspired by the [FreeCodeCamp Terraform on Azure tutorial](https://www.youtube.com/watch?v=V53AHWun17s&list=WL&index=4)

