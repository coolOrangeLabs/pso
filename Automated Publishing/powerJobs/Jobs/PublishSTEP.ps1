#=============================================================================#
# PowerShell script sample for coolOrange powerJobs                           #
# Creates a STEP file and add it to Autodesk Vault as Design Vizualization    #
#                                                                             #
# Copyright (c) coolOrange s.r.l. - All rights reserved.                      #
#                                                                             #
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER   #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.  #
#=============================================================================#

#TODO: Configure output location:
# To add STEP to Vault set '$addToVault = $true' to keep it out set to '$false'
$addToVault = $true

#TODO: To add STEP as attachment to main document set 'addAsAttachment = $true' otherwise 'addAsAttachment = $false'
$addAsAttachment = $true

#TODO: To copy STEP to a dedicated Vault folder set folder in $vaultFolder, e.g. $vaultFolder = "$/Designs/Public/STEP/"
# $vaultFolder = "" saves the STEP file right next to the source file
$vaultFolder = ""

#TODO: To copy the STEP to a network folder fill $networkFolder with the folder e.g. $networkFolder ="\\SERVER1\Share\Public\STEP\"
$networkFolder = ""


$hideSTEP = $false
$workingDirectory = "C:\Temp\$($file._Name)"
$localSTEPfileLocation = "$workingDirectory\$($file._Name).stp"

if ($vaultFolder) {
    $vaultSTEPfileLocation = $vaultFolder.TrimEnd('/') + "/" + (Split-Path -Leaf $localSTEPfileLocation)
}
else {
    $vaultSTEPfileLocation = $file._EntityPath + "/" + (split-path -Leaf $localSTEPfileLocation)
}

Write-Host "Starting job 'Publish STEP' for file '$($file._Name)' ..."

if (-not $addToVault -and -not $networkFolder) {
    throw("ERROR: No output for the STEP file is defined in ps1 file!")
}

if( @("iam","ipt") -notcontains $file._Extension ) {
    Write-Host "Files with extension: '$($file._Extension)' are not supported"
    return
}

$downloadedFiles = Save-VaultFile -File $file._FullPath -DownloadDirectory $workingDirectory -ExcludeChildren:$fastOpen -ExcludeLibraryContents:$fastOpen
$file = $downloadedFiles | Select-Object -First 1
$openResult = Open-Document -LocalFile $file.LocalPath

if($openResult) {    
    $exportResult = Export-Document -Format 'STEP' -To $localSTEPfileLocation -Options "$($env:POWERJOBS_MODULESDIR)Export\STEP.ini"
    if($exportResult) {
		#Add STEP to Vault
        if ($addToVault) {
			$STEPfile = Add-VaultFile -From $localSTEPfileLocation -To $vaultSTEPfileLocation -FileClassification DesignVisualization -Hidden $hideSTEP
            Write-Host "Add STEP '$($file._Name).stp' to Vault: " $vaultSTEPfileLocation
			if ($addAsAttachment) {
				$file = Update-VaultFile -File $file._FullPath -AddAttachments @($STEPfile._FullPath)
			}
		}
        # Copy STEP to network folder
        if ($networkFolder) {
            if (!(Test-Path $networkFolder)) {
                $copyResult = $false
            }
            else {
                Copy-Item -Path $localSTEPfileLocation -Destination $networkFolder
                Write-Host "Copied STEP '$($file._Name).stp' to folder: " $networkFolder
                $copyResult = $true
            }
        }		
    }
    $closeResult = Close-Document
}
Clean-Up -folder $workingDirectory

if(-not $openResult) {
    throw("Failed to open document $($file.LocalPath)! Reason: $($openResult.Error.Message)")
}
if(-not $exportResult) {
    throw("Failed to export document $($file.LocalPath) to $localSTEPfileLocation! Reason: $($exportResult.Error.Message)")
}
if(-not $closeResult) {
    throw("Failed to close document $($file.LocalPath)! Reason: $($closeResult.Error.Message))")
}
if ($networkFolder -and -not $copyResult) {
    throw("Folder '$networkFolder' does not exist! Correct networkFolder in ps1 file!")
}

Write-Host "Completed job 'Publish STEP'"