<#

.SYNOPSIS
List users on a Zoom account.
.DESCRIPTION
List users on a Zoom account.
.PARAMETER UserId
The user ID or email address.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.EXAMPLE
Get-ZoomSpecificUser jsmith@lawfirm.com
.OUTPUTS
A hastable with the Zoom API response.

#>

$Parent = Split-Path $PSScriptRoot -Parent
import-module "$Parent\ZoomModule.psm1"

function Get-ZoomSpecificUser {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            Position = 0, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True
        )]
        [Alias('Email', 'EmailAddress', 'Id', 'user_id')]
        [string]$UserId,

        [ValidateSet('Facebook', 'Google', 'API', 'Zoom', 'SSO', 0, 1, 99, 100, 101)]
        [Alias('login_type')]
        [string]$LoginType,

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
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/users/$UserId"

        if ($LoginType) {
            $LoginType = switch ($LoginType) {
                'Facebook' { 0 }
                'Google' { 1 }
                'API' { 99 }
                'Zoom' { 100 }
                'SSO' { 101 }
                Default { $LoginType }
            }
            $Query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
            $Query.Add('login_type', $LoginType)
            $Request.Query = $Query.ToString()
        }

        try {
            $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $Headers -Method GET
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        }

        Write-Output $Response
    }
}