#=============================================================================#
# PowerShell script sample for coolOrange powerJobs                           #
# Creates a DXF file and add it to Autodesk Vault as Design Vizualization     #
#                                                                             #
# Copyright (c) coolOrange s.r.l. - All rights reserved.                      #
#                                                                             #
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER   #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.  #
#=============================================================================#

#TODO: Configure output location:
# To add DXF to Vault set '$addToVault = $true' to keep it out set to '$false'
$addToVault = $true

#TODO: To add DXF as attachment to main document set 'AddAsAttachment = $true' otherwise 'addAsAttachment = $false'
$addAsAttachment = $true

#TODO: To copy DXF to a dedicated Vault folder set folder in $vaultFolder, e.g. $vaultFolder = "$/Designs/Public/DXF/"
# $vaultFolder = "" saves the DXF file right next to the source file
$vaultFolder = ""

#TODO: To copy the DXF to a network folder fill $networkFolder with the folder e.g. $networkFolder ="\\SERVER1\Share\Public\DXFs\"
$networkFolder = ""

$hideDXF = $false
$workingDirectory = "C:\Temp\$($file._Name)"
$localDXFfileLocation = "$workingDirectory\$($file._Name).dxf"
if ($vaultFolder) {
    $vaultDXFfileLocation = $vaultFolder.TrimEnd('/') + "/" + (Split-Path -Leaf $localDXFfileLocation)
}
else {
    $vaultDXFfileLocation = $file._EntityPath + "/" + (Split-Path -Leaf $localDXFfileLocation)
}
$fastOpen = $file._Extension -eq "idw" -or $file._Extension -eq "dwg" -and $file._ReleasedRevision

Write-Host "Starting job 'Publish DXF' for file '$($file._Name)' ..."

if (-not $addToVault -and -not $networkFolder) {
    throw("ERROR: No output for the DXF is defined in ps1 file!")
}

if ( @("idw", "dwg", "ipt") -notcontains $file._Extension ) {
    Write-Host "Files with extension: '$($file._Extension)' are not supported"
    return
}

$downloadedFiles = Save-VaultFile -File $file._FullPath -DownloadDirectory $workingDirectory -ExcludeChildren:$fastOpen -ExcludeLibraryContents:$fastOpen
$file = $downloadedFiles | Select-Object -First 1
$openResult = Open-Document -LocalFile $file.LocalPath -Options @{ FastOpen = $fastOpen } -application Inventor
$openResult.Application.Instance.Visible = $true
if ($openResult) {
    if ($file._Extension -eq "ipt") {
        $configFile = "$($env:POWERJOBS_MODULESDIR)Export\DXF_SheetMetal.ini"
    } else {
        $configFile = "$($env:POWERJOBS_MODULESDIR)Export\DXF_2D.ini" 
    }
    $exportResult = Export-Document -Format 'DXF' -To $localDXFfileLocation -Options $configFile 
    if ($exportResult) {
        $localDXFfiles = Get-ChildItem -Path (split-path -path $localDXFfileLocation) | Where-Object { $_.Name -match '^' + [System.IO.Path]::GetFileNameWithoutExtension($localDXFfileLocation) + '.*(.dxf|.zip)$' }
        $vaultFolder = (Split-Path $vaultDXFfileLocation).Replace('\', '/')
        $DXFfiles = @()
        #Add DXF to Vault
        if ($addToVault) {
            foreach ($localDXFfile in $localDXFfiles) {
                $DXFfile = Add-VaultFile -From $localDXFfile.FullName -To ($vaultFolder + "/" + $localDXFfile.Name) -FileClassification DesignVisualization -Hidden $hideDXF
                Write-Host "Add DXF '$($localDXFfile.Name).dxf' to Vault: " $vaultDXFfileLocation
                $DXFfiles += $DXFfile._FullPath
            }
            if ($addAsAttachment) {
                $file = Update-VaultFile -File $file._FullPath -AddAttachments $DXFfiles
            }
        }
        # Copy DXF to network folder
        if ($networkFolder) {
            if (!(Test-Path $networkFolder)) {
                $copyResult = $false
            }
            else {
                foreach ($localDXFfile in $localDXFfiles) {
                    Copy-Item -Path $localDXFfile.FullName -Destination $networkFolder
                    Write-Host "Copied DXF '$($localDXFfile.Name)' to folder: " $networkFolder
                }
                $copyResult = $true
            }
        }
    } 
    $closeResult = Close-Document
}

Clean-Up -folder $workingDirectory

if (-not $openResult) {
    throw("Failed to open document $($file.LocalPath)! Reason: $($openResult.Error.Message)")
}
if (-not $exportResult) {
    throw("Failed to export document $($file.LocalPath) to $localDXFfileLocation! Reason: $($exportResult.Error.Message)")
}
if (-not $closeResult) {
    throw("Failed to close document $($file.LocalPath)! Reason: $($closeResult.Error.Message))")
}
if ($networkFolder -and -not $copyResult) {
    throw("Folder '$networkFolder' does not exist! Correct networkFolder in ps1 file!")
}

Write-Host "Completed job 'Publish DXF'"