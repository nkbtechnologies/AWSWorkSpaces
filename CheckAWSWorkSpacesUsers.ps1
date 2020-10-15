# @ nkbtechnologies
# This script will work on a Windows System with following requirement met - 1. WorkSpaces IAM permission,2. AD PowerShell Module Available
#AWS Region where workspaces are deployed
$Region = "ap-southeast-2"
#AWS Directory ID
$Directory = 'd-976713e89b' #Replace with your directory ID
$Run = Get-Date -Format FileDateTime
$WorkSpaces = Get-WKSWorkspace -Region $Region | Select-object DirectoryID, Username, WorkSpaceID
$WorkSpaces.Length

$WKSPWMissingUser = @()

$index = 0
do
{
    

    $WKSPUname = Get-WKSWorkspace -UserName $WorkSpaces[$index].UserName -DirectoryId $Directory -region $Region
    #$WKSPUname
    $TempInformation = New-Object -TypeName PSobject
    $TempInformation | Add-Member -MemberType NoteProperty -Name '#' -Value $index
    if ($Null -eq $WKSPUname) {
        
        $TempInformation | Add-Member -MemberType NoteProperty -Name 'WorkSpaceID' -Value $WorkSpaces[$index].WorkspaceId
        $TempInformation | Add-Member -MemberType NoteProperty -Name  'Directory' -Value $Directory
        $TempInformation | Add-Member -MemberType NoteProperty -Name 'UserNameFromWorkSpaceID' -Value $WorkSpaces[$index].UserName
        $TempInformation | Add-Member -MemberType NoteProperty -Name 'WS-User-State' -Value 'User Deleted'
        $WKSPWMissingUser += $TempInformation


    } else{
        $ADUserTest = Get-ADUser -Identity $WorkSpaces[$index].UserName -Properties * | Select-Object -Property samaccountname,enabled
        #$ADUserTest | fl
        if($ADUserTest.enabled -eq $True)
            {
             $TempInformation | Add-Member -MemberType NoteProperty -Name 'WorkSpaceID' -Value $WorkSpaces[$index].WorkspaceId
        $TempInformation | Add-Member -MemberType NoteProperty -Name  'Directory' -Value $Directory
        $TempInformation | Add-Member -MemberType NoteProperty -Name 'UserNameFromWorkSpaceID' -Value $WorkSpaces[$index].UserName
        $TempInformation | Add-Member -MemberType NoteProperty -Name 'WS-User-State' -Value 'User Found and enabled'
        $WKSPWMissingUser += $TempInformation
            }else{
             $TempInformation | Add-Member -MemberType NoteProperty -Name 'WorkSpaceID' -Value $WorkSpaces[$index].WorkspaceId
        $TempInformation | Add-Member -MemberType NoteProperty -Name  'Directory' -Value $Directory
        $TempInformation | Add-Member -MemberType NoteProperty -Name 'UserNameFromWorkSpaceID' -Value $WorkSpaces[$index].UserName
        $TempInformation | Add-Member -MemberType NoteProperty -Name 'WS-User-State' -Value 'User Disabled'
        $WKSPWMissingUser += $TempInformation

           
            }

    }
$index++
}
while ($index -lt $WorkSpaces.Length)


$WKSPWMissingUser | Export-Csv -Path C:\Temp\WorkSpaceWithNoUser-$Run.csv -NoClobber -NoTypeInformation -Force
$WKSPWMissingUser | FT * -AutoSize


#Output will look like below

# WorkSpaceID  Directory    UserNameFromWorkSpaceID WS-User-State         
- -----------  ---------    ----------------------- -------------         
0 ws-7kz54j21c d-976713e89b Chimeuser01             User Disabled         
1 ws-8b9l90hz9 d-976713e89b AMZTestU15              User Disabled         
2 ws-dv6qlqkg7 d-976713e89b nalinbx                 User Deleted          
3 ws-42wbj23z1 d-976713e89b AMZTestU17              User Disabled         
4 ws-bp7kg2xg4 d-976713e89b AMZTestU20              User Deleted          
5 ws-6kc47mtf1 d-976713e89b AMZTestU19              User Deleted          
6 ws-30fp55bdt d-976713e89b awsadmin                User Found and enabled
7 ws-wc5d4nd1v d-976713e89b AMZTestU16              User Disabled         
8 ws-gz35yd7hv d-976713e89b AMZTestU18              User Deleted          

