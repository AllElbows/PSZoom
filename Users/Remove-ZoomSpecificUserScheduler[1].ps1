<#

.SYNOPSIS
Delete a specific scheduler.
.DESCRIPTION
Delete a specific scheduler. schedulers are the users to whom the current user has assigned  on the user’s behalf.
.PARAMETER UserId
The user ID or email address.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.EXAMPLE
Remove-ZoomSpecificUsersSheduler jmcevoy@lawfirm.com
.OUTPUTS
A hastable with the Zoom API response.

#>

$Parent = Split-Path $PSScriptRoot -Parent
import-module "$Parent\ZoomModule.psm1"

function Remove-ZoomSpecificUserScheduler {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True
        )]
        [Alias('Email', 'EmailAddress', 'Id')]
        [string]$UserId,

        [Parameter(
            Mandatory = $True, 
            Position = 1
        )]
        [string]$schedulerId,

        [string]$ApiKey,

        [string]$ApiSecret
    )

    begin {
        #Get Zoom Api Credentials
        if (-not $ApiKey -or -not $ApiSecret) {
            $ApiCredentials = Get-ZoomApiCredentials
            $ApiKey = $ApiCredentials.ApiKey
            $ApiSecret = $ApiCredentials.ApiSecret
        }

        #Generate Header with JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$UserId/schedulers/$schedulerId"

        try {
            $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Method DELETE
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        }

        Write-Output $Response
    }
}