<#

.SYNOPSIS
Retrieve participants from a past meeting.
.DESCRIPTION
Retrieve participants from a past meeting. Note: Please double encode your UUID when using this API.
.PARAMETER MeetingUuid
The meeting UUID.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
.LINK
.EXAMPLE
Get-ZoomPastMeetingParticipants 123456789

#>

function Get-ZoomPastMeetingParticipants {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('id', 'meeting_uuid', 'uuid')]
        [string]$MeetingUuid,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateRange(1, 300)]
        [Alias('page_size')]
        [int]$PageSize = 30,
        
        [Parameter(ValueFromPipelineByPropertyName = $True)]
        [Alias('next_page_token')]
        [string]$NextPageToken,

        [ValidateNotNullOrEmpty()]
        [string]$ApiKey,

        [ValidateNotNullOrEmpty()]
        [string]$ApiSecret
    )

    begin {
       #Get Zoom Api Credentials
        $Credentials = Get-ZoomApiCredentials -ZoomApiKey $ApiKey -ZoomApiSecret $ApiSecret
        $ApiKey = $Credentials.ApiKey
        $ApiSecret = $Credentials.ApiSecret

        #Generate Headers and JWT (JSON Web Token)
        $Headers = New-ZoomHeaders -ApiKey $ApiKey -ApiSecret $ApiSecret
    }

    process {
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/past_meetings/$MeetingUuid/participants"
        $Query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)  
        $Query.Add('page_size', $PageSize)

        if ($PSBoundParameters.ContainsKey('NextPageToken')) {
            $QUery.Add('next_page_token', $NextPageToken)
        }

        $Request.Query = $Query.ToString()
        
        try {
            $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Body $RequestBody -Method GET
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        }
        
        Write-Output $Response
    }
}