<#

.SYNOPSIS
Update a meeting registrant’s status.
.DESCRIPTION
Update a meeting registrant’s status.
.PARAMETER MeetingId
The meeting ID.
.PARAMETER ApiKey
The Api Key.
.PARAMETER ApiSecret
The Api Secret.
.OUTPUTS
.LINK
.EXAMPLE
Update-ZoomMeetingRegistrantStatus  123456789


#>

function Update-ZoomMeetingRegistrantStatus {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $True, 
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            Position = 0
        )]
        [Alias('meeting_id')]
        [string]$MeetingId,

        [Parameter(
            ValueFromPipelineByPropertyName = $True, 
            Position=1
        )]
        [Alias('occurence_id')]
        [string]$OcurrenceId,

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
        $Request = [System.UriBuilder]"https://api.zoom.us/v2/meetings/$MeetingId/registrants/status"
        $Query = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

        if ($PSBoundParameters.ContainsKey('OcurrenceId')) {
            $Query.Add('occurrence_id', $OcurrenceId)
            $Request.Query = $Query.toString()
        }        

        try {
            $Response = Invoke-RestMethod -Uri $Request.Uri -Headers $headers -Body $RequestBody -Method PUT
        } catch {
            Write-Error -Message "$($_.exception.message)" -ErrorId $_.exception.code -Category InvalidOperation
        }
        
        Write-Output $Response
    }
}