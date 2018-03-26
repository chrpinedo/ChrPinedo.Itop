# ChrPinedo.Itop Powershell Module

ChrPinedo.Itop is a minimal Powershell Module for the REST API of [iTop CMDB](https://sourceforge.net/projects/itop).

## Features

Query of some objects of the iTop CMDB:
- *VirtualMachine*
- *ApplicationSolution*
- *Organization*
- *Contact*
- *Person*
- *Team*

## Installation

The recommended way to install this module is via [PowerShell Gallery](https://www.powershellgallery.com/packages/ChrPinedo.Itop).

## Usage

For example, to obtain a list of virtual machines in production state:

```powershell
$Uri = 'https://itop.example.com/webservices/rest.php?version=1.3'
$Cred = Get-Credential -Username admin
$ProductionVMs = Get-VirtualMachine -Uri $uri -Credential $Cred -Status production 
```
