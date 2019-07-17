<#

.SYNOPSIS
Delete a user on your account.
.DESCRIPTION
Delete a user on your account.
.PARAMETER Action
Delete action options:
disassociate - Disassociate a user. This is the default.
delete - Permanently dlete a user.
Note: To delete pending user in the account, use disassociate.
.PARAMETER TransferEmail
Transfer email.
.PARAMETER TransferMeeting
Transfer meeting.
.PARAMETER TransferWebinar
Transfer webinar.
.PARAMETER TransferRecording
Transfer recording.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.EXAMPLE
Remove-ZoomUser 'sjackson@lawfirm.com' -action 'delete' -TransferEmail 'jsmith@lawfirm.com' -TransferMeeting
.OUTPUTS
A hastable with the Zoom API response.

#>

$Parent = Split-Path $PSScriptRoot -Parent
import-module "$Parent\ZoomModule.psm1"

function Remove-ZoomUser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
        [Alias('Email')]
        [string]$UserId,

        [ValidateSet('disassociate', 'delete')]
        [string]$Action = 'disassociate',

        [string]$TransferEmail,

        [switch]$TransferMeeting,
        
        [switch]$TransferWebinar,

        [switch]$TransferRecording,

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
        
        #Generate Headers with JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$UserId"
        $Query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        $UserInfoKeyValues = @{
            'action'             = 'Action'
            'transfer_email'     = 'TransferEmail'
            'transfer_meeting'   = 'TransferMeeting'
            'transfer_webinar'   = 'TransferWebinar'
            'transfer_recording' = 'TransferRecording'
        }

        #Adds parameters to UserInfo object if not Null
        $UserInfoKeyValues.Keys | ForEach-Object {
            if ($PSBoundParameters.ContainsKey("$($UserInfoKeyValues.$_)")) {
                $Query.Add($_, (get-variable $UserInfoKeyValues.$_))
            }
        }
        
        $Request.Query = $Query.ToString()

        try {
            Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Method DELETE
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        }
    }
}