# Load Params
param (
    [string]$profiles = "default"
)

$arr = $profiles -split ','

<#

Returns true if a program with the specified display name is installed.
This function will check both the regular Uninstall location as well as the
"Wow6432Node" location to ensure that both 32-bit and 64-bit locations are
checked for software installations.

@param String $program The name of the program to check for.
@return Booleam Returns true if a program matching the specified name is installed.

#>
function Is-Installed( $program ) {

    $x86 = ((Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall") |
        Where-Object { $_.GetValue( "DisplayName" ) -like "*$program*" } ).Length -gt 0;

    $x64 = ((Get-ChildItem "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
        Where-Object { $_.GetValue( "DisplayName" ) -like "*$program*" } ).Length -gt 0;

    return $x86 -or $x64;
}

function Load-Module ($m) {
    # If module is imported say that and do nothing
    if (Get-Module | Where-Object {$_.Name -eq $m}) {
        write-host "Module $m is already imported."
    } else {
        # If module is not imported, but available on disk then import
        if (Get-Module -ListAvailable | Where-Object {$_.Name -eq $m}) {
            Import-Module $m -Verbose
        } else {
            # If module is not imported, not available on disk, but is in online gallery then install and import
            if (Find-Module -Name $m | Where-Object {$_.Name -eq $m}) {
                Install-Module -Name $m -Force -Verbose -Scope CurrentUser
                Import-Module $m -Verbose
            } else {
                # If module is not imported, not available and not in online gallery then abort
                write-host "Module $m not imported, not available and not in online gallery, exiting."
                EXIT 1
            }
        }
    }
}

If (Is-Installed("AWS Command Line Interface")) {
    Write-Host "AWS CLI installed."
} else {
    Write-Host "ERROR!"
    Write-Host "Please install AWS CLI before using AWS Rotate IAM Keys."
    Write-Host "You can download it here:"
    Write-Host "https://s3.amazonaws.com/aws-cli/AWSCLISetup.exe"
    Write-Host ""
}

Load-Module "AWSPowerShell"

<#
Locations for AWS credentials:
C:\Users\username\.aws\credentials
AppData\Local\AWSToolkit\RegisteredAccounts.json
#>

# Set the profile used and default to default
Set-AWSCredential -ProfileName $arr[0]

$current_key = Get-AWSCredential -ProfileName $arr[0]

$location = "C:\Users\$($env:UserName)\.aws\credentials"

#Create a new AWS Key
$new_key = New-IAMAccessKey -ProfileName $arr[0]
Write-Output "Making new access key"

#Delete the AWS Key
Remove-IAMAccessKey -Force -AccessKeyId $current_key.GetCredentials().AccessKey -ProfileName $arr[0] -Confirm:$false

#Update the other profiles with the new key
foreach ($profile in $arr) {
    Write-Output "Updating profile: $($profile)"
    Set-AWSCredential -ProfileLocation $location -StoreAs $profile -AccessKey $new_key.AccessKeyId -SecretKey $new_key.SecretAccessKey
    Set-AWSCredential -StoreAs $profile -AccessKey $new_key.AccessKeyId -SecretKey $new_key.SecretAccessKey
}

Write-Output "Made new key $($new_key.AccessKeyId)"
Write-Output "Key rotated"
