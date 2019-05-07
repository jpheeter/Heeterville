# This is used to collect and overwrite the group memberships with the members of the Primary site
# ideally, only run this for the visitors group. 

### what to update, $true or $false

$UpdateVisitors = $true
$UpdateMembers = $false
$UpdateOwners = $false


#1#  run the connects just once prior to running the other sections
$Tenant = "Heeterville"

##Connect-PnPOnline "https://$tenant-admin.sharepoint.com" -UseWebLogin
#Connect-SPOService -Url https://$tenant-admin.sharepoint.com

$siteN = "SC_portal"

$SiteName = "https://$tenant.sharepoint.com/sites/" + $siteN
$HubSiteurl = $sitename
#get HubSiteID to identify which sites are members of the Hub
$HubSiteID = (get-sposite -Identity $HubSiteurl).HubSiteId.Guid

#2## 
connect-pnponline $sitename -UseWebLogin
$ctx = Get-PnPContext
$web = Get-PnPWeb


###  get-sposite -Identity $SiteName

#3###  load source variables for later (Group members)
$visitors1 = @()
$Members1 = @()
$owners1 = @()
if($UpdateVisitors){
   # i created a group on the web site and added the members i want to apply elsewhere
   $visitors1 = Get-PnPGroup -AssociatedVisitorGroup
   $VisitorsArray = get-pnpgroupmembers -Identity $visitors1.LoginName
}
if($UpdateMembers){
$owners1 = Get-PnPGroup -AssociatedOwnerGroup
$ownerArray = Get-PnPGroupMembers -Identity $owners1.LoginName
}
if($UpdateOwners){
$Members1 = Get-PnPGroup -AssociatedMemberGroup
$MemberArray = Get-PnPGroupMembers -Identity $Members1.LoginName
}

#4####  This is to identify all the sites associated to a Hub Site and then to apply consistant permissions to the visitors group of each associated site matching the Main Hub Site
#4##  Name the hubsite master (source of membership)



#5#####   Collect a list of each associated site
$gethubsites = $false
if($getHubSites){
$HubArray = @()

$sites = get-sposite -limit all
foreach($site in $sites){
    $siteHID = get-sposite -Identity $site | select-object URL,HubSiteId,Title
        if($siteHID.HubSiteId -eq $HubSiteID){
         #  $sitename = $site.url
         #   write-host "$siteHID"
            $hubarray += $siteHID
            $hubTitleArray += $site.title
            $hubarray.count 
        } 
}
#This spits out a list of the sties in the hub
 $hubarray.url
}

 #$sites2 = $sites | select url,hubsiteid,title | Where-Object {$_.HubSiteID -eq $hubsiteID}
#6######    Copy all of the urls from the printout into the $siteArray below
#6######    IMPORTANT!  REMOVE the sites you don't want to repermission, these would be any team sites or Non-communication sites

#SiteArray is the list of sites needing updating

$siteArray=@"
https://Heeterville.sharepoint.com/teams/SC_Team
https://Heeterville.sharepoint.com/teams/SC_EDI
https://Heeterville.sharepoint.com/teams/SC_Reporting
https://Heeterville.sharepoint.com/teams/SC_SupplyChain
https://Heeterville.sharepoint.com/teams/SC_CustomerService
https://Heeterville.sharepoint.com/teams/SC_Sales
https://Heeterville.sharepoint.com/teams/SC_Credit
https://Heeterville.sharepoint.com/teams/SC_Compliance
https://Heeterville.sharepoint.com/sites/SC_portal
https://Heeterville.sharepoint.com/teams/SC_Distribution
"@ -split("`r`n")


#this next block will update the memberships of the $True groups in the sites listed in the $siteArray
#safety break to make sure it isn't run in whole. it can't be run until the site array is manually updated or all of the sites in the hub will have the same permissions, this may not be desirable

if($HighLightAndRun){


#this should always be false, manually highlight the block below and run AFTER the $siteArray is double checked.
#Really!
#A psudo report will spit out identifying the previous values of the groups incase this is run and overwrites the existing values

foreach($site in $SiteArray){
   $site
connect-pnponline $site -UseWebLogin 
$owners2 = ""
$visitors2 = ""
$members2 = ""
$owners3 = @()
$visitors3 = @()
$members3 = @()

Start-Sleep -seconds 3
$owners2 = get-pnpgroup -AssociatedOwnerGroup
$visitors2 = get-pnpgroup -AssociatedVisitorGroup
$members2 = Get-PnPGroup -AssociatedMemberGroup

$owners3 = get-pnpgroupmembers -Identity $owners2.LoginName
$visitors3 = get-pnpgroupmembers -Identity $visitors2.LoginName
$members3 = get-pnpgroupmembers -Identity $members2.LoginName
write-host -BackgroundColor Red "site name         $site"
write-host -BackgroundColor Green "Site Owners     "  $owners3.email
write-host -BackgroundColor blue "Site Visitors    " $visitors3.email
write-host -BackgroundColor white "Site Members    " $members3.email
if($UpdateOwners){  $owners2.LoginName
foreach($own in $ownerArray){
 Add-PnPUserToGroup -LoginName $own.LoginName -Identity $owners2.LoginName 
 write-host -BackgroundColor Green "New Site Owners     "  $own.email
   }
   }
if($UpdateVisitors){ $visitors2.LoginName
foreach($vis in $visitorsArray){
      Add-PnPUserToGroup -LoginName $vis.LoginName -Identity $visitors2.LoginName
      write-host -BackgroundColor blue "New Site Visitors    " $vis.email
   }
   }
if($UpdateMembers){ $members2.LoginName
   foreach($mem in $MemberArray){
    Add-PnPUserToGroup -LoginName $mem.LoginName -Identity $Members2.LoginName
    write-host -BackgroundColor white "New Site Members    " $mem.email
   }
   }
}


}


