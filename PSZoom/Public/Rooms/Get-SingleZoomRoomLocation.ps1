function Get-SingleZoomRoomLocation {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [String]$location_id,
        [ValidateNotNullOrEmpty()]
        # Must pass in locations to stop nested api calls. 
        [Array]$Locations,
        [ValidateNotNullOrEmpty()]
        #Pass in structure to account for users that don't have the same as me Floor/City/State/Campus/Country. Assumes same amount of levels though.. 
        [Array]$Strucure
    )
    
    begin {
      
    }
    
    process {

        # Broken in to vars here to keep order. Otherwise could try something like below
        # $Strucure[4] = ($Locations | Where { $_.id -like $location_id}).name

        $FloorObj =  $Locations | Where { $_.id -like $location_id}
        $CampusObj = $Locations | Where { $_.id -like $FloorObj.parent_location_id}
        $CityObj = $Locations | Where { $_.id -like $CampusObj.parent_location_id}
        $StateObj = $Locations | Where { $_.id -like $CityObj.parent_location_id}
        $CountryObj = $Locations | Where { $_.id -like $StateObj.parent_location_id}

        $hierarchy = @{
            $Strucure[4] = $FloorObj.name
            $Strucure[3] = $CampusObj.name
            $Strucure[2] = $CityObj.name
            $Strucure[1] = $StateObj.name
            $Strucure[0] = $CountryObj.name
        }

    }
    
    end {
        $hierarchy
    }
}