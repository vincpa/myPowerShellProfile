#Run this script the first time you log on to a machine you've never logged on to before.

$rootPath = 'C:\Users\Vince\OneDrive'
$rootDevPath = 'C:\dev\'
$currentDir = Split-Path $MyInvocation.MyCommand.Definition

Write-Host "Current directory is $currentDir"

$powershellProfileDir = [System.IO.Directory]::GetParent($PROFILE).FullName

if (-not (Test-Path $powershellProfileDir)) {
    mkdir $powershellProfileDir
}

Get-Content -Path "$currentDir\Microsoft.PowerShell_profile.ps1" |
	% { $_.Replace('%rootPath%', $rootPath) } |
    % { $_.Replace('%rootDevPath%', $rootDevPath) } | Set-Content $PROFILE

Write-Host "Wrote profile to $PROFILE"

$moduleRoot = $env:PSModulePath.Split(";")[0]

if (-not (Test-Path $moduleRoot)) {
	md -Path $env:PSModulePath.Split(";")[0]
}

function CopyModule
{
	param($moduleName, $startingPath = '..\Modules\')

	$ptDir = Join-Path $moduleRoot $moduleName

	if (-not (Test-Path $ptDir)) {
		md -Path $ptDir
	}
	Copy-Item ($startingPath + $moduleName) -Dest $moduleRoot -Recurse -Force
}

# Modules
CopyModule 'Pscx'
CopyModule 'PowerTab'
CopyModule 'z' '..\'
CopyModule 'ShowCalendar'
CopyModule 'posh-git'
CopyModule 'PSReadLine'

function setEnvVariable($name, $value)
{
    if ($name -eq "PATH") {

      $existingValue = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::User)
	  
	  if ($existingValue -eq $null) {
	  	$existingValue = ''
	  }

      $value = $value.TrimEnd(';').TrimEnd('\')

      if ($existingValue -contains $value) {
        return;
      }
	    $value = $existingValue.TrimEnd(';').TrimEnd('\') + ";" + $value
    }
	
    [System.Environment]::SetEnvironmentVariable($name, $value, [System.EnvironmentVariableTarget]::User)
    Write-Host "Set name $name and value $value"
}
#c:\program files (x86)\haskell\bin;c:\haskellplatform\2013.2.0.0\lib\extralibs\bin;c:\haskellplatform\2013.2.0.0\bin;c:\windows\system32;c:\windows;c:\windows\system32\wbem;c:\windows\system32\windowspowershell\v1.0\;d:\program files (x86)\microsoft sql server\110\tools\binn\;d:\program files\microsoft sql server\110\tools\binn\;d:\program files\microsoft sql server\110\dts\binn\;d:\program files (x86)\microsoft sql server\110\tools\binn\managementstudio\;d:\program files (x86)\microsoft sql server\110\dts\binn\;c:\program files (x86)\microsoft asp.net\asp.net web pages\v1.0\;c:\program files (x86)\windows kits\8.1\windows performance toolkit\;c:\haskellplatform\2013.2.0.0\mingw\bin;c:\program files (x86)\gtksharp\2.12\bin;c:\program files\tortoisesvn\bin;c:\fpc\2.6.2\bin\i386-win32;c:\users\vince\skydrive\tools\mercurial\;c:\program files\microsoft\web platform installer\;c:\program files (x86)\microsoft sdks\windows azure\cli\wbin;c:\nodejs\;d:\dev\smlnj\bin\;c:\p

setEnvVariable "TOOLS" "$rootPath\tools"
setEnvVariable "UTILS" "$rootPath\utils"

setEnvVariable "PATH" $Env:TOOLS
setEnvVariable "PATH" "$Env:TOOLS\mercurial"
setEnvVariable "PATH" "$rootPath\psscripts"
setEnvVariable "PATH" (Join-Path $Env:TOOLS "\UnixUtils")
setEnvVariable "PATH" (Join-Path $Env:UTILS "\SysinternalsSuite")
setEnvVariable "PATH" (Join-Path $Env:TOOLS "\fizzler")
setEnvVariable "PATH" (Join-Path $Env:TOOLS "\Remote Desktop Connection Manager")

# NodeJS
setEnvVariable "PATH" 'C:\Program Files (x86)\nodejs\'
setEnvVariable "PATH" 'C:\Users\Vince\AppData\Roaming\npm'

# git
setEnvVariable "GIT_HOME" 'C:\Program Files (x86)\Git'
setEnvVariable "PATH" '%GIT_HOME%\cmd'

# Go lang
setEnvVariable "PATH" (Join-Path $rootDevPath "\go\bin")
setEnvVariable "GOROOT" (Join-Path $rootDevPath "\go")

# Python
setEnvVariable "PATH" (Join-Path $rootDevPath "\python27")
setEnvVariable "PATH" (Join-Path $rootDevPath "\python27\scripts")

# Ruby
setEnvVariable "PATH" (Join-Path $rootDevPath "\Ruby193\bin")

# Android
setEnvVariable "ANDROID_NDK_PATH" (Join-Path $rootDevPath "\ndk\android-ndk-r8d")
setEnvVariable "ANDROID_SDK_HOME" 'C:\Program Files (x86)\Android\android-sdk'
setEnvVariable "ADT_HOME" 'C:\Program Files (x86)\Android\android-sdk'
setEnvVariable "PATH" '%ANDROID_SDK_HOME%\tools'
setEnvVariable "PATH" '%ANDROID_SDK_HOME%\platform-tools'

# Java
setEnvVariable "JAVA_HOME" 'C:\Program Files (x86)\Java\jdk1.7.0_55'
setEnvVariable "PATH" '%JAVA_HOME%\bin'

# Ant
setEnvVariable "ANT_HOME" (Join-Path $rootDevPath "\apache-ant-1.9.4")
setEnvVariable "PATH" '%ANT_HOME%\bin'

# Vim
setEnvVariable "VIM" (Join-Path $rootPath "\tools\Vim")

## [System.Environment]::SetEnvironmentVariable("GIT_EXTERNAL_DIFF", ($toolsPath.Replace('\', '/') + '/KDiff3/kdiff3.exe'), "Process")

Write-Host
Write-Host 'PowerShell profile installed. Restart PowerShell for settings to take effect.' -ForegroundColor Yellow
Write-Host
Write-Host "Root Path = $rootPath" -ForegroundColor Green
Write-Host "Root Development Path = $rootDevPath" -ForegroundColor Green
Write-Host
