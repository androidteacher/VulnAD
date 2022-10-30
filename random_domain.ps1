$group_names = [System.Collections.ArrayList](Get-Content data/group_names.txt)
$first_names =[System.Collections.ArrayList](Get-Content data/first_names.txt)
$last_names =[System.Collections.ArrayList](Get-Content data/last_names.txt)
$passwords =[System.Collections.ArrayList](Get-Content data/passwords.txt)

$num_users = 15

$users = @()
$group_list = @()

for ($i = 0; $i -lt 10; $i++){
$group_name = (Get-Random -InputObject $group_names)
$group_list += @{"name" = "$group_name"}
#echo @($group_list).name

$group_names.Remove($group_name)


}


for ($i = 0; $i -lt $num_users; $i= $i + 1){

    $first_name = (Get-Random -InputObject $first_names)
    $last_name = (Get-Random -InputObject $last_names)
    $password = (Get-Random -InputObject $passwords)
    $memberof = (Get-Random -inputobject $group_list.name)
        $new_user = @{
        "name"= "$first_name $last_name"
        "password"="$password"
        "groups" = $memberof
        }
    
    $first_names.Remove($first_name)
    $last_names.Remove($first_last)
    $passwords.Remove($password)

    $users += $new_user

    }
 @{
    "domain"="beck.local"
    "groups"=$group_list
    "users"=$users
}




