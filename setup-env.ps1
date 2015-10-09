#Run this script the first time you log on to a machine you've never logged on to before.
cls

$rootPath = 'E:\OneDrive'       # The location of utilities
$rootDevLangPath = 'e:\langs'            # The location of programing languages
$rootDevToolsPath = "e:\devtools"

if (-not (Test-Path -Path $rootPath)) {
	$rootPath = "$env:USERPROFILE\OneDrive"
    if (-not (Test-Path -Path $rootPath)) {
        Write-Host "Could not find root path $rootPath" -ForegroundColor Red
        return
    }
}

if (-not (Test-Path -Path $rootDevToolsPath)) {
    Write-Host "Could not find root development tools path $rootDevToolsPath" -ForegroundColor Red
    return
}

if (-not (Test-Path -Path $rootDevLangPath)) {
    Write-Host "Could not find root languages path $rootDevLangPath" -ForegroundColor Red
    return
}


$currentDir = Split-Path $MyInvocation.MyCommand.Definition

Write-Host "Current directory is $currentDir"


# Create the PowerShell profile directory if it doesn't exist
$powershellProfileDir = [System.IO.Directory]::GetParent($PROFILE).FullName

if (-not (Test-Path $powershellProfileDir)) {
    mkdir $powershellProfileDir
    Write-Host "Created PowerShell profile directory $powershellProfileDir" -ForegroundColor Green
}

# If the profile file is not named Microsoft.PowerShell_profile.ps1 then the profile won't load.
$profileFullPath = Join-Path -Path $powershellProfileDir -ChildPath "Microsoft.PowerShell_profile.ps1"

Get-Content -Path "$currentDir\Microsoft.PowerShell_profile.ps1" |
	% { $_.Replace('%rootPath%', $rootPath) } |
    % { $_.Replace('%rootDevPath%', $rootDevPath) } | Set-Content $profileFullPath

Write-Host "Wrote profile to $profileFullPath" -ForegroundColor Green


$moduleRoot = $env:PSModulePath.Split(";")[0]

if (-not (Test-Path $moduleRoot)) {
	md -Path $moduleRoot
    Write-Host "Created PowerShell module directory $moduleRoot" -ForegroundColor Green
}


# Clear the current user PATH variable as it's going to be reset below
[System.Environment]::SetEnvironmentVariable('PATH', '', [System.EnvironmentVariableTarget]::User)


function CopyModule
{
	param($moduleName, $startingPath = '..\Modules\')

    $sourcePath = Join-Path -Path $startingPath -ChildPath $moduleName

    if ((Test-Path $sourcePath)) {

	    $ptDir = Join-Path $moduleRoot $moduleName

	    if (-not (Test-Path $ptDir)) {
		    md -Path $ptDir
	    }
	    Copy-Item ($startingPath + $moduleName) -Dest $moduleRoot -Recurse -Force

    } else {
        Write-Host "Could not find source module $sourcePath" -ForegroundColor Red
    }
}


function setEnvVariable($name, $value, $checkPath = $true)
{
    if ($name -eq "PATH") {

        if (-not (Test-Path -Path $value)) {
            Write-Host "Could not find path $value. Not added to PATH." -ForegroundColor Magenta
            return;
        }

        $existingValue = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)
	  
	    if ($existingValue -eq $null) {
	  	    $existingValue = ''
	    }

        $value = $value.TrimEnd(';').TrimEnd('\')

        if ($existingValue -contains $value) {
            return;
        }
	        $value = $existingValue.TrimEnd(';').TrimEnd('\') + ";" + $value
    } else {
        if (-not $value.StartsWith("%") -and $checkPath -and (Test-Path -Path $value -IsValid) -and -not (Test-Path -Path $value)) {
            Write-Host "Could not find path $value. Not added to $name." -ForegroundColor Magenta
            return;
        }
    }   

    [System.Environment]::SetEnvironmentVariable($name, $value, [System.EnvironmentVariableTarget]::User)
    Write-Host "Set name $name and value $value" -ForegroundColor Green
}


# Modules
CopyModule 'Pscx'
CopyModule 'PowerTab'
CopyModule 'z'
CopyModule 'Git-PsRadar'
CopyModule 'posh-git'
CopyModule 'PSReadLine'

$Env:TOOLS = "$rootPath\tools"
setEnvVariable "TOOLS" "$rootPath\tools"

setEnvVariable "PATH" $Env:TOOLS
setEnvVariable "PATH" "$rootPath\psscripts"
setEnvVariable "PATH" (Join-Path $Env:TOOLS "\UnixUtils")
setEnvVariable "PATH" (Join-Path $Env:TOOLS "\SysinternalsSuite")
setEnvVariable "PATH" (Join-Path $Env:TOOLS "\Remote Desktop Connection Manager")

# NodeJS
setEnvVariable "PATH" 'C:\Program Files\nodejs\'
setEnvVariable "PATH" "$env:USERPROFILE\AppData\Roaming\npm"
setEnvVariable "NODE_PATH" "$env:USERPROFILE\AppData\Roaming\npm"

# git
setEnvVariable "GIT_HOME" 'C:\Program Files\Git'
setEnvVariable "PATH" 'C:\Program Files\Git\cmd'

# Go lang
setEnvVariable "PATH" (Join-Path $rootDevLangPath "\go\bin")
setEnvVariable "GOROOT" (Join-Path $rootDevLangPath "\go")

# Python
setEnvVariable "PATH" (Join-Path $rootDevLangPath "\python27")
setEnvVariable "PATH" (Join-Path $rootDevLangPath "\python27\scripts")

# Ruby
setEnvVariable "PATH" (Join-Path $rootDevLangPath "\Ruby193\bin")

# Android
setEnvVariable "ANDROID_NDK_PATH" "$rootDevToolsPath\Android\android-ndk"
setEnvVariable "ANDROID_SDK_HOME" "$rootDevToolsPath\Android\android-sdk"
setEnvVariable "ANDROID_HOME" "$rootDevToolsPath\Android\android-sdk"
setEnvVariable "ADT_HOME" "$rootDevToolsPath\Android\android-sdk"
setEnvVariable "PATH" "$rootDevToolsPath\Android\android-sdk\tools"
setEnvVariable "PATH" "$rootDevToolsPath\Android\android-sdk\platform-tools"


# Java
setEnvVariable "JAVA_HOME" 'C:\Program Files\Java\jdk1.8.0_60'
setEnvVariable "JDK_HOME" 'C:\Program Files\Java\jdk1.8.0_60'
setEnvVariable "PATH" 'C:\Program Files\Java\jdk1.8.0_60\bin'

# Gradle
setEnvVariable "PATH" (Join-Path $rootDevToolsPath "\gradle-2.6\bin")

# Ant
setEnvVariable "ANT_HOME" (Join-Path $rootDevToolsPath "\apache-ant-1.9.4")
setEnvVariable "PATH" (Join-Path $rootDevToolsPath "\apache-ant-1.9.4\bin")

# Vim
setEnvVariable "VIM" (Join-Path $Env:TOOLS 'Vim')

Write-Host
Write-Host 'PowerShell profile installed. Restart PowerShell for settings to take effect.' -ForegroundColor Yellow
Write-Host
Write-Host "Root Path = $rootPath" -ForegroundColor Green
Write-Host "Root Languages Path = $rootDevLangPath" -ForegroundColor Green
Write-Host "Root Development Tools Path = $rootDevToolsPath" -ForegroundColor Green
Write-Host
