param ([Parameter(Mandatory = $true)] $JSONFile)

function CreateADGroup() {
    param ([Parameter(Mandatory = $true)] $groupObject)
    $group = $groupObject.name
   
    New-ADGroup -name $group -GroupScope Global

}
function RemoveADGroup() {
    param( [Parameter(Mandatory = $true)] $groupObject)
    $name = $groupObject.name
    Remove-ADGroup -Identity $name -Confirm:$false
   
}
function RemoveADUser() {
    param ([Parameter(Mandatory = $true)] $userObject)
    $name = $userObject.name
    $firstname, $lastname = $name.Split(" ")
    $username = ($name[0] + $name.Split(" ")[1]).ToLower()
    remove-ADUser -Identity $username -Confirm:$false
}
function CreateADUser() {
    param ([Parameter(Mandatory = $true)] $userObject)
    $name = $userObject.name
    $password=$userobject.password
    $firstname, $lastname = $name.Split(" ")
    $username = ($name[0] + $name.Split(" ")[1]).ToLower()
    $samAccountName = $username
    $principalname = $username
    #$password = "Student123!"
    #Create the AD user object

    New-ADUser -Name "$firstname $lastname" -GivenName $firstname -Surname $lastname -SamAccountName $SamAccountName -UserPrincipalName $principalname@$Global:Domain -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) -PassThru | Enable-ADAccount

    foreach ($group_name in $userObject.groups) {

        try {
            Get-ADGroup -Identity $group_name
            Add-ADGroupMember -Identity $group_name -Members $samAccountName
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
            Write-Warning "User $name not added to group $group : Group not found"
        }

    }

}

function WeakenPasswordPolicy(){
    secedit /export /cfg C:\Windows\Tasks\secpol.cfg
    (Get-Content C:\Windows\Tasks\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0").replace("MinimumPasswordLength = 7", "MinimumPasswordLength = 1") | Out-File C:\Windows\Tasks\secpol.cfg
    secedit /configure /db c:\windows\security\local.sdb /cfg C:\Windows\Tasks\secpol.cfg /areas SECURITYPOLICY
    rm -force C:\Windows\Tasks\secpol.cfg -confirm:$false
}

function StrengthenPasswordPolicy(){
    secedit /export /cfg C:\Windows\Tasks\secpol.cfg
    (Get-Content C:\Windows\Tasks\secpol.cfg).replace("PasswordComplexity = 0", "PasswordComplexity = 1").replace("MinimumPasswordLength = 1", "MinimumPasswordLength = 7") | Out-File C:\Windows\Tasks\secpol.cfg
    secedit /configure /db c:\windows\security\local.sdb /cfg C:\Windows\Tasks\secpol.cfg /areas SECURITYPOLICY
    rm -force C:\Windows\Tasks\secpol.cfg -confirm:$false
}

$json = (get-content $JSONFile | convertfrom-json)
$removeallgroups = Read-Host "Would you like to remove groups this time? (Y/N)"
$removeallusers = Read-Host "Would you like to remove all users? (Y/N)"
if ($removeallgroups -eq "Y") {
    foreach ($group in $json.groups) {
        RemoveADGroup $group
    }
}
if ($removeallgroups -ne "Y") {
    foreach ($group in $json.groups) {
        CreateADGroup $group
    }
}
$Global:Domain = $json.domain
if ($removeallusers -ne "Y") {
    foreach ($user in $json.users) {
        CreateADUser $user
    }
}
if ($removeallusers -eq "Y") {
    foreach ($user in $json.users) {
        RemoveADUser $user
    }
}



