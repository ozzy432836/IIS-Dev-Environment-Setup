# supply a base name for your web application
# supply the actual dir of your web app
# supply the desired url for your web app
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

##### TODO ####
# 1.0. create similar function to Remove-Hosts-File-Entry to check if entry exists rather than delete and re-add
# 1.1. open a browser window to browse the new site on localhost
# 1.2. add some text to index.html file so at least something shows when you browse to the site

# 2.0. Initialise new project with Git? (commands below)
## Git init web site dir (if not already done)
## Git create remote repo
## Git add remote repo
## Git add -A
## Git commit -m "initial"
## Git push -u origin master

param(
    [string]$base = "D:\all\Code\Mine", 
    [string]$projName = "BestTest",
    [string]$projUrl = "www-dev.bestest.comwwwww"
)

function Create-IIS-SiteDir($dirName) 
{
    echo "Creating Directory: $($dirName)"

    if(Test-Path $dirName) 
    {
        echo "Directory Already Exists: $($dirName)"
    }
    else 
    {
        New-Item -ItemType "Directory" -Path $dirName
        echo "Directory Created: $($dirName)"
    }
}

function Create-Default-SiteFile($siteDir) 
{
    $indexFile = "$siteDir\index.html"
    echo "Creating Site Index File: $($indexFile)"
    
    if(Test-Path $indexFile) 
    {
        echo "Site Index File Already Exists: $($indexFile)"
    }
    else 
    {
        New-Item $indexFile -ItemType "File"
        echo "Site Index File Created: $($indexFile)"
    }
}

function Create-IIS-AppPool($project) 
{
    echo "Creating Application Pool: $($project.IISAppPoolName)"

    if(Test-Path IIS:\AppPools\$($project.IISAppPoolName)) 
    {
        echo "Application Pool Already Exists: $($project.IISAppPoolName)"
    }
    else 
    {
        New-WebAppPool -Name $project.IISAppPoolName
        echo "Application Pool Created: $($project.IISAppPoolName)"
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
    echo "Creating Hosts File Entry: $($hostname)"
    $hostsFile = "C:\Windows\System32\drivers\etc\hosts"
    $ip = "127.0.0.1"
    
    Remove-Hosts-File-Entry $hostsFile $hostname
    $ip + "`t`t" + $hostname | Out-File -encoding ASCII -append $hostsFile
    echo "Hosts File Entry Created: $($hostname)"
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
    [String] $Url = ""
    [String] $IISSiteName = ""
    [String] $IISAppPoolName = ""
    [String] $IISBindings = ""
    [String] $IISPath = ""
}

# Main
$newProject = [Project]::New()
$newProject.Name = $projName
$newProject.Url = $projUrl
$newProject.IISAppPoolName = $newProject.Name
$newProject.IISSiteName = $newProject.Name
#$newProject.IISBindings = "*:8002:localhost"
$newProject.IISBindings = "*:80:$($newProject.Url)"
$newProject.IISPath = "$($base)\$($newProject.Name)"

Create-IIS-SiteDir -dirName $newProject.IISPath
Create-Default-SiteFile -siteDir $newProject.IISPath
Create-IIS-AppPool -project $newProject
Create-IIS-Site -project $newProject
Add-Hosts-File-Entry -hostname $newProject.Url