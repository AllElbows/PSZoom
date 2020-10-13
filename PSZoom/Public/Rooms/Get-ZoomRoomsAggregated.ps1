# Get-ZoomRoomsAggregated
# Sample of aggregating all zoom room information in one module.

$Global:ZoomApiKey = Get-Secret -Name 'ZoomAPI' -AsPlainText
$Global:ZoomApiSecret = Get-Secret -Name 'ZoomAPIsecret' -AsPlainText

Import-Module Join-Object

$ZoomRooms = Get-ZoomRooms -PageSize 300
$DashboardInfo = Get-DashboardZoomRooms -PageSize 300

#If we run this once then we can reduce API calls. Otherwise there is another API call for every room 
$ZoomRoomLocations = Get-ZoomRoomLocations -page_size 300
$ZoomRoomStructure = Get-ZoomRoomLocationStructure

$Obj = @()

foreach ($Room in $ZoomRooms) {
    # Join Objects
    $TempObj = Join-Object -Left $Room -Right $DashboardInfo -LeftJoinProperty 'name' -RightJoinProperty 'room_name' -ExcludeRightProperties id,status
    
    # Add devices
    Add-Member -InputObject $TempObj -NotePropertyName 'Devices' -NotePropertyValue $(Get-ZoomRoomDevices -RoomID $Room.id | Select-Object -ExcludeProperty room_name)

    # Add Hierarchy
    Add-Member -InputObject $TempObj -NotePropertyName 'Location' -NotePropertyValue $(Get-SingleZoomRoomLocation -location_id $Room.location_id -Locations $ZoomRoomLocations -Strucure $ZoomRoomStructure) -Force

    #Add to array
    $Obj += $TempObj

}

$Obj