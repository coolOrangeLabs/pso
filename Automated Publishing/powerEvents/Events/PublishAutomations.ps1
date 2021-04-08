#=============================================================================#
# PowerShell script sample for coolOrange powerEvents                         #
# Automates repetitive tasks (e.g. submits jobs when files are released) 	  #
#                                                                             #
# Copyright (c) coolOrange s.r.l. - All rights reserved.                      #
#                                                                             #
# THIS SCRIPT/CODE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER   #
# EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES #
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.  #
#=============================================================================#
$supportedExtensions = @("idw","dwg","ipt","iam")

Register-VaultEvent -EventName UpdateFileStates_Post -Action 'SubmitPublishJobs'
 
function SubmitPublishJobs($files, $successful) {
    if (-not $successful) { return }
    $releasedFiles = @($files | Where-Object { $_._Extension -in $supportedExtensions -and $_._ReleasedRevision -eq $true })
    foreach ($file in $releasedFiles) {
        #DXF
        if( @("idw","dwg","ipt") -contains $file._Extension ) {
            #if ($file.'Sub-Type' -eq "Sheet Metal") { #requirement: UDP "Sub-Type" must be mapped with Inventor iProperty "Doc Sub Type Name"
                Add-VaultJob -Name "PublishDXF" -Parameters @{ "EntityId" = $file.Id; "EntityClassId" = "FILE" } -Description "Publish DXF for file '$($file._Name)'"
            #}      
        }

        #PDF
        if ( @("idw", "dwg") -contains $file._Extension ) {
            Add-VaultJob -Name "PublishPDF" -Parameters @{ "EntityId" = $file.Id; "EntityClassId" = "FILE" } -Description "Publish PDF for file '$($file._Name)'"
        }

        #STEP
        if( @("iam","ipt") -contains $file._Extension ) {
            Add-VaultJob -Name "PublishSTEP" -Parameters @{ "EntityId" = $file.Id; "EntityClassId" = "FILE" } -Description "Publish STEP for file '$($file._Name)'"
        }
    }
}