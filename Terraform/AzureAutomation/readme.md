# Azure Automation with Terraform

## Introduction
This Terraform project demonstrates the usage of Terraform to manage Azure Automation. It sets up an Azure Resource Group, an Azure Automation Account, and an Automation Runbook. The Runbook is scheduled to execute daily at midnight, according to the timezone defined in the Terraform script (in this case, Europe/Paris). 

As part of the demonstration, two PowerShell modules are also imported to show how to manage PowerShell modules with Terraform. These modules are not specifically required for the project and are provided just as an example.

## Project Structure
The project is organized into several Terraform files each having a specific purpose:

1. `main.tf`: Contains the Terraform code to create the Azure Resource Group, the Azure Automation Account, and the Automation Runbook.
2. `locals.tf`: Defines local variables such as timezone, start and end times for the daily schedule.
3. `provider.tf`: Configures the Azure provider.
4. `modules.tf`: Demonstrates how to manage PowerShell modules with Terraform. These modules are not needed for the project itself, it is just an example.
5. `variables.tf`: Contains customizable variables like the Resource Group name and the Automation Account name.

## Resources Created
1. Azure Resource Group
2. Azure Automation Account
3. Automation Runbook (PowerShell based)
4. Azure Automation Schedule (Runs daily at midnight)
5. PowerShell Modules (Example only, not needed for the project)

## Pre-requisites
1. [Terraform](https://www.terraform.io/downloads.html) installed on your machine.
2. An active Azure subscription.

## Usage
1. Clone this repository to your local machine.
2. Navigate to the directory where the Terraform files are located.
3. Run `terraform init` to initialize your Terraform workspace.
4. Run `terraform plan` to view the resources that will be created.
5. Run `terraform apply` to create the resources in Azure.

Please ensure to replace the variable values in `variables.tf` as per your requirements.

## Important Notes
- The Automation Runbook's PowerShell script is loaded from a local file named "DeleteOldBlobVersions.ps1". Make sure this file exists in your project directory.
- The PowerShell modules, `Microsoft.Graph.Authentication` and `Microsoft.Graph.Users`, are imported from specific URIs. Ensure these URIs are valid and accessible. These modules are included just as an example and are not specifically required for the project.

**Disclaimer:** This script is provided without any warranty. Always test your scripts in a test environment before running them in production.
