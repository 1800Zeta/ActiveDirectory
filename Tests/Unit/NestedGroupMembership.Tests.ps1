$script:ParentPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

$script:ADGroups = Import-PowerShellDataFile "$script:ParentPath\Tests\Data\ADGroups.psd1"
$script:TestedScript = "$script:ParentPath\Scripts\NestedGroupMembership.ps1"
$Mock2019Groups = $script:ADGroups.Default2019
$Mock2019GroupsDN = $Mock2019Groups | Where-Object { $_.DistinguishedName -contains 'CN=Builtin,DC=corp,DC=contoso,DC=com' }
$Mock2019GroupsDomainUsers = $Mock2019Groups | Where-Object { $_.Name -eq 'Domain Users' }
$MockNestedGroups = $script:ADGroups.NestedGroups
$MockNestedChild = $MockNestedGroups | Select-Object DistinguishedName, Name, Guid

Describe "When validating the default Windows Server 2019 groups" {
    BeforeAll{
        Mock -CommandName Get-ADObject
    }

    It "should pass without throwing" {
        Mock -CommandName Get-ADGroup { return $Mock2019Groups }
        { & $script:TestedScript } | Should -Not -Throw
    }

    It "should pass without throwing when specifying a path" {
        Mock -CommandName Get-ADGroup { return $Mock2019GroupsDN }
        { & $script:TestedScript -SearchBaseDN "CN=Builtin,DC=corp,DC=contoso,DC=com" } | Should -Not -Throw
    }

    It "should pass without throwing when specifying a Name" {
        Mock -CommandName Get-ADGroup { return $Mock2019GroupsDomainUsers }
        { & $script:TestedScript -GroupName "Domain Users" } | Should -Not -Throw
    }
}

Describe "When working with nested groups" {
    Context "When the Child group has grand parent as a member" {
        It "it should produce an output" {
            Mock -CommandName Get-ADObject { return $MockNestedChild }
            Mock -CommandName Get-ADGroup { return $MockNestedGroups }

            $testResult = { & $script:TestedScript }
            $testResult | Should -Not -Throw
            $testResult | Should -Not -BeNullOrEmpty
        }
    }
}