param(
    [string]$base = "D:\all\Code\Mine", 
    [string]$proj = "www.bestest.com"
)


#Main -baseDir $base -projName $proj

Function Main12345([string]$baseDir, [string]$projName) {

    #$baseDir = Read-Host "Enter your project dir (this could look like this: C:\inetpub\wwwroot)"
    #$projName = Read-Host "Enter your project name (this should look like this subdomain-env.domain.com)"
    # validate params...
    
    $newProject = [Project]::New()
    $newProject.Name = $projName
    $newProject.IISAppPoolName = $newProject.Name
    $newProject.IISSiteName = $newProject.Name
    #$newProject.IISBindings = "*:8002:localhost"
    $newProject.IISBindings = "*:80:$($newProject.Name)"
    $newProject.IISPath = "$($baseDir)\$($newProject.Name)"

    Create-IIS-SiteDir -dirName $newProject.IISPath
    Create-IIS-AppPool -project $newProject
    Create-IIS-Site -project $newProject
    Add-Hosts-File-Entry -hostname $newProject.Name

}

Function Create-IIS-SiteDir($dirName) 
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