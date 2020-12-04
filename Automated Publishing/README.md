# Automated Publishing PSO

## Disclaimer

THE SAMPLE CODE ON THIS REPOSITORY IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.

THE USAGE OF THIS SAMPLE IS AT YOUR OWN RISK AND THERE IS NO SUPPORT RELATED TO IT.

## Description
The Automated Publishing PSO provides a set of predefinded workflows to automate the creation of common neutral output format. 
The current workflows are:
* Creation of a PDF from AutoCAD DWGs, Inventor drawings (DWG and IDW)
* Creation of DXFs from AutoCAD DWGs, Inventor drawings (DWG and IDW) and sheet metal IPTs
* Creation of a STEP from Inventor assemblies (IAMs) and parts (IPTs)
* Restrict check-out or status change, when a job in in the Job Queue for this file

## Installation
* Copy the ps1 files located in .\powerJobs\Jobs to “C:\ProgramData\coolOrange\powerJobs\Jobs” of your PowerJobs Processor machine
* Copy the ps1 files located in .\powerEvents\Jobs to “C:\ProgramData\coolOrange\powerEvents\Events” of your Vault client machine(s)

## Configuration

You can configure the outpuut loaction for the PDF, DXF or STEP file with setting varialbles in the header of the script file:
* To add the created file to Vault: $addToVault = $true
* The created file is **not** added to Vault:***$addToVault = $false***

* To add the created file to Vault as attachment: ***$addAsAttachment = $true***
* The created file is added to Vault **not** as an attachment:***$addAsAttachment = $false***

* To add the created file into the same folder in Vault as the main file: ***$vaultFolder = ""***
* Or specify the vault folder where the created file should be located, e.g.: ***$vaultFolder = "$/Designs/Public/PDF/"***

* The created file is **not** copied to a network folder: ***$networkFolder = ""***
* The created file is copied to the specified network folder, if this exists, e.g.: ***$networkFolder ="\\SERVER1\Share\Public\PDFs\"***

