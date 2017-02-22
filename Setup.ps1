# supply a dir name for your web application
# supply the actual dir of your web app
# this script creates an app pool, an iis site, binds the domain to the site and creates a hosts file entry
# if you follow my naming convention then on your local machine, your app dir is named like so:
# subdomain-dev.domain.com
# e.g. www-dev.example.com
# the pattern being that durind the deployment pipeline, we can follow the naming convention like so:
# test:    www-tst.example.com
# staging: www-sta.example.com
# live:    www.example.com
# this works nicely for any other subdomains too e.g.
# api.example.com, api-dev.example.com, api-tst.example.com, api-sta.example.com
param(
    [string]$base = "D:\all\Code\Mine", 
    [string]$proj = "www-dev.bestest.comwwwww"
)

function Create-IIS-SiteDir($dirName) 
{
    echo "Creating Directory $($dirName)"

    if(Test-Path $dirName) 
    {
        echo "Directory Already Exists $($dirName)"
    }
    else 
    {
        New-Item -ItemType "Directory" -Path $dirName
        echo "Directory Created $($dirName)"
    }
}

function Create-IIS-AppPool($project) 
{
    echo "Creating Application Pool $($project.IISAppPoolName)"

    if(Test-Path IIS:\AppPools\$($project.IISAppPoolName)) 
    {
        echo "Application Pool Already Exists $($project.IISAppPoolName)"
    }
    else 
    {
        New-WebAppPool -Name $project.IISAppPoolName
        echo "Application Pool Created $($project.IISAppPoolName)"
    }
}

function Create-IIS-Site($project) 
{
    echo "Creating Site: $($project.IISSiteName)"
    
    if(Test-Path IIS:\Sites\$($project.IISSiteName)) 
    {
        echo "Site Already Exists: $($project.IISSiteName)"
    }
    else 
    {
        Start-IISCommitDelay
        $NewSite = New-IISSite -Name $project.IISSiteName -BindingInformation $project.IISBindings –PhysicalPath $project.IISPath -Passthru
        $NewSite.Applications[“/”].ApplicationPoolName = $project.IISAppPoolName
        Stop-IISCommitDelay
        
        echo "Site Created: $($project.IISSiteName)"
    }
}

#http://stackoverflow.com/questions/2602460/powershell-to-manipulate-host-file
function Add-Hosts-File-Entry([string]$hostname) 
{
    $hostsFile = "C:\Windows\System32\drivers\etc\hosts"
    $ip = "127.0.0.1"
    Remove-Hosts-File-Entry $hostsFile $hostname
    $ip + "`t`t" + $hostname | Out-File -encoding ASCII -append $hostsFile
}

function Remove-Hosts-File-Entry([string]$filename, [string]$hostname)
 {
    $c = Get-Content $filename
    $newLines = @()

    foreach ($line in $c) {
        $bits = [regex]::Split($line, "\t+")
        if ($bits.count -eq 2) {
            if ($bits[1] -ne $hostname) {
                $newLines += $line
            }
        } else {
            $newLines += $line
        }
    }

    # Write file
    Clear-Content $filename
    foreach ($line in $newLines) {
        $line | Out-File -encoding ASCII -append $filename
    }
}


Class Project 
{
    [String] $Name = ""
    [String] $IISSiteName = ""
    [String] $IISAppPoolName = ""
    [String] $IISBindings = ""
    [String] $IISPath = ""
}

# Main
$newProject = [Project]::New()
$newProject.Name = $proj
$newProject.IISAppPoolName = $newProject.Name
$newProject.IISSiteName = $newProject.Name
#$newProject.IISBindings = "*:8002:localhost"
$newProject.IISBindings = "*:80:$($newProject.Name)"
$newProject.IISPath = "$($base)\$($newProject.Name)"

Create-IIS-SiteDir -dirName $newProject.IISPath
Create-IIS-AppPool -project $newProject
Create-IIS-Site -project $newProject
Add-Hosts-File-Entry -hostname $newProject.Name