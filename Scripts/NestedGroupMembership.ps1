# Script to find and Circular Nested groups
# Grabs a list of all groups in AD
# Goes through one by one and if the count of members is greater
# than 0 will see if there is a recurisive membership

[CmdletBinding(SupportsShouldProcess=$true)]
Param(
    [Parameter()]
    [System.String]
    $GroupName,

    [Parameter()]
    [System.String]
    $SearchBaseDN
)

$getADGroupParameters = @{
    Properties = 'MemberOf'
}

if ($GroupName)
{
    $getADGroupParameters.Add("Identity", $GroupName)
}
else
{
    $getADGroupParameters.Add("Filter", "*")
}

if ($SearchBaseDN)
{
    $getADGroupParameters.Add("SearchBase", $SearchBaseDN)
}

$Groups = Get-ADGroup @getADGroupParameters

$i = 0
if ($groupName)
{
    $groupCount = 1
}
else
{
    $groupCount = $Groups.Count
}

Write-Verbose "Checking $groupCount groups for circular nesting"

$nestedGroups = foreach ($Group in $Groups)
{
    Write-Progress -Activity "Checking group membership" -Status "Progress: $($Group.Name)" -PercentComplete ($i/$groupCount*100)

    $membershipCount = $Group.MemberOf.Count
    Write-Verbose "MembershipCount = $membershipCount"

    if ($Group.MemberOf.Count -gt 0)
    {
        $GroupDN = $Group.DistinguishedName
        $GroupName = $Group.Name
        Write-Verbose "Checking group membership for $GroupName"
        $memberOf = Get-ADObject -LDAPFilter "(&(memberOf:1.2.840.113556.1.4.1941:=$GroupDN)(objectClass=group))"
        if ($memberOf.DistinguishedName -contains $groupDN)
        {
            Write-Verbose "Circular group membership found for $GroupName"
            $Group | Select-Object DistinguishedName, GroupCategory, GroupScope, Name, ObjectClass, ObjectGuid, SamAccountName, SID
        }
    }
    $i = $i + 1
}

$nestedGroupsCount = $nestedGroups.Count

if ($nestedGroups)
{
    Write-Output "Found $nestedGroupsCount Groups with circular nesting"
    Write-Output $nestedGroups | Sort-Object Name | Format-Table Name, GroupCategory, GroupScope, DistinguishedName
}
