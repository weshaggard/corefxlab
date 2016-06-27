$nugetUrl = "https://dist.nuget.org/win-x86-commandline/v3.5.0-beta/NuGet.exe"
$symchkPath = "C:\Program Files (x86)\Windows Kits\10\Debuggers\x86"
$msBuildBinFolderPath = "C:\Program Files (x86)\MSBuild\14.0\Bin\"

# Ensure clean state.
$currentWorkingDirectory = (Get-Item -Path ".\" -Verbose).FullName
Remove-Item -Path "$currentWorkingDirectory\packages" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$currentWorkingDirectory\RestoredOutput" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$currentWorkingDirectory\Bin\" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$currentWorkingDirectory\BuildLog.txt" -Force -ErrorAction SilentlyContinue

$localBinFolderPath = "$currentWorkingDirectory\Bin"

mkdir $localBinFolderPath | out-null

# Get NuGet
$nugetLocalPath = Join-Path $localBinFolderPath "NuGet.exe"
$webclient = new-object System.Net.WebClient
do
{
    try
    {
		$webclient.DownloadFile($nugetUrl, $nugetLocalPath)
        break;
    }
    catch
    {
        Write-Warning "Error occurred while downloading NuGet.  Exception message follows $_"
        Start-Sleep -Seconds 2
    }

} while ($true)


if (!(Test-Path "c:\debuggers\symchk.exe"))
{
    # Get SymbolCheck
    Copy-Item -Path $symchkPath\symchk.exe -Destination "$localBinFolderPath\symchk.exe" -Force -ErrorAction Continue
    Copy-Item -Path "$symchkPath\SymbolCheck.dll" -Destination "$localBinFolderPath\SymbolCheck.dll" -Force -ErrorAction Continue
}

# Get MSBuild
Copy-Item -Path $msBuildBinFolderPath\* -Destination $localBinFolderPath -Recurse -Force

$targetArchs = @("x86", "x64", "arm")

foreach ($targetArch in $targetArchs)
{
    $msBuildPath = "$localBinFolderPath\MSBuild.exe"
    $msBuildArgs = "UWPTest.proj /p:TargetArch=$targetArch /verbosity:diag /fileLoggerParameters:LogFile=.\BuildLog.txt;Append;Verbosity=diagnostic;Encoding=UTF-8"

    $p = Start-Process -FilePath $msBuildPath -ArgumentList $msBuildArgs -PassThru -Verbose -Wait -ErrorAction Continue
    if ($p.ExitCode -ne 1)
    {
        Write-Warning "Error occurred while running MSBuild with the following argument $msBuildArgs.  See $currentWorkingDirectory\BuildLog.txt for mode details."
    }

    $msBuildArgs = "UWPTest.proj /p:TargetArch=$targetArch /p:IsNetNative=true"

    $p = Start-Process -FilePath $msBuildPath -ArgumentList $msBuildArgs -PassThru -Verbose -Wait -ErrorAction Continue
    if ($p.ExitCode -ne 1)
    {
        Write-Warning "Error occurred while running MSBuild with the following argument $msBuildArgs.  See $currentWorkingDirectory\BuildLog.txt for more details."
    }
}
