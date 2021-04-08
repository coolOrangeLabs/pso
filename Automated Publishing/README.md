# Automated Publishing PSO

## Disclaimer

THE SAMPLE CODE ON THIS REPOSITORY IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.

THE USAGE OF THIS SAMPLE IS AT YOUR OWN RISK AND THERE IS NO SUPPORT RELATED TO IT.

## Description
The Automated Publishing PSO provides a set of predefined workflows to automate the creation of common neutral output format. 
The current workflows are:
* Creation of a PDF from AutoCAD DWGs and Inventor drawings (DWG and IDW)
* Creation of DXFs from Inventor drawings (DWG and IDW) and sheet metal IPTs
* Creation of a STEP from Inventor assemblies (IAMs) and parts (IPTs)
* Add publish jobs to Job Queue when an AutoCAD DWG or Inventor file (IPT, IAM, IDW, DWG) is released
* Restrict check-out or status change, when a job is in the Job Queue for this file
* Extend Vault file context menu with publish commands (Publish PDF, Publish DXF, Publish STEP)

## Prerequisite
To use the full functionality of the Automated Publishing PSO the coolOrange powerJobs Processor must be installed on the Jobprocessor machine. And on each Vault Client machine  powerEvents, powerJobs Client and qJob must be installed.

## Installation
* Download the ZIP file from the 'Releases' area and extract the ZIP 
* Copy the ps1 files located in *.\powerJobs\Jobs* to “*C:\ProgramData\coolOrange\powerJobs\Jobs*” of your PowerJobs Processor machine
* Copy the script files *PublishRestrictions.ps1* and *PublishAutomations.ps1* located in *.\powerEvents\Events* to “*C:\ProgramData\coolOrange\powerEvents\Events*” of your Vault client machine(s)
* Copy the *MenuSettings.xml* file located in *.\qJob\menu* to “*C:\ProgramData\Autodesk\ApplicationPlugins\coolOrange.qJob.bundle\<Vault version>*” of your Vault client machine(s)

## Configuration of the publish jobs
The output of the neutral format can be controlled via INI files that are called in the scripts. Consult the powerJobs documentation on https://www.coolorange.com/wiki/doku.php?id=powerjobs_processor.

Additionally you can configure the ***output location*** for the PDF, DXF or STEP file with setting variables in the header of the script file:
#### $addToVault
* To add the created file to Vault: $addToVault = $true
* The created file is **not** added to Vault:***$addToVault = $false***

#### $addAsAttachment
* To add the created file to Vault as attachment: ***$addAsAttachment = $true***
* The created file is added to Vault **not** as an attachment:***$addAsAttachment = $false***

#### $vaultFolder
* To add the created file into the same folder in Vault as the main file: ***$vaultFolder = ""***
* Or specify the vault folder where the created file should be located, e.g.: ***$vaultFolder = "$/Designs/Public/PDF/"***  
***Attention: Please avoid to store too many files in the same Vault folder***

#### $networkFolder
* The created file is **not** copied to a network folder: ***$networkFolder = ""***
* The created file is copied to the specified network folder, if this exists, e.g.: ***$networkFolder ="\\SERVER1\Share\Public\PDFs\"***

## Configuration of the powerEvents scripts
### Unregister events 
Per default the events for 'RestrictUpdateFileStates', 'RestrictCheckOutFiles' and 'SubmitPublishJobs' are registered after installation. If they should be deactivated you must uncomment the Register-VaultEvent with '#' at the begining of the line in the header of the script files.

### Configuration of adding jobs to  the Vault Job Queue
Per default the following jobs are added to the Vault Job Queue when the event for the function 'SubmitPublishJobs'.
* "PublishDXF" for files with extension "idw", "dwg" and "ipt"
* "PublishPDF" for files with extension "idw" and "dwg"
* "PublishSTEP" for files with extension "iam" and "ipt"

## Configuration of the context menu
Per default you will have the commands "PublishPDF", "PublishDXF" and "PublishSTEP" on the file context menu in Vault after installing the MenuSettings.xml file.
To remove a command from the context menu, just comment out the command in the section 'CommandSite' of the MenuSettings.xml.
For example to remove the PublishSTEP-command:

`<!-- <PublishSTEP />-->`

## Product Documentation

[coolOrange powerJobs Processor](https://doc.coolorange.com/doku.php?id=powerjobs_processor)

[coolOrange powerJobs Client](https://doc.coolorange.com/doku.php?id=powerjobs_client)

[coolOrange powerEvents](https://doc.coolorange.com/doku.php?id=powerevents)

[coolOrange qJobs](https://doc.coolorange.com/doku.php?id=qjob)


## Author
coolOrange s.r.l.

![coolOrange](https://i.ibb.co/NmnmjDT/Logo-CO-Full-colore-RGB-short-Payoff.png)
