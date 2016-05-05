[CmdletBinding()]
param (

    [ValidateNotNullOrEmpty()]
    [String] $Path = ".\_DotNetCore10",

    [ValidateNotNullOrEmpty()]
    [string] $NugetExe = "c:\temp\nuget\3.4\nuget.exe",

    [ValidateNotNullOrEmpty()]
    [string] $SymchkExe = "d:\pk\src\tools\x86\symchk.exe"
)

$ErrorActionPreference = 'Stop'

function Get-ScriptDirectory
{
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    Split-Path $Invocation.MyCommand.Path
}

$DownloadDir = $Path
if (Test-Path $DownloadDir)
{
    rmdir $DownloadDir -Recurse
}
mkdir $DownloadDir


$ProjDir = Get-ScriptDirectory
Copy-Item (Join-Path $ProjDir "project.json") $DownloadDir
Copy-Item (Join-Path $ProjDir "download.proj") $DownloadDir

$Archs = @("x86", "x64", "arm")
$Archs | % {
    msbuild ".\download.proj" /p:TargetArch=$_ /p:NuGetToolPath=$NugetExe /p:SymChkToolPath=$SymchkExe /flp:v=diag`;LogFile=msbuild.$_.log
}
