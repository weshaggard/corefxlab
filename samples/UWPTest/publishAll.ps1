
$targetArchs = @("x86", "x64", "arm");

foreach ($targetArch in $targetArchs)
{
    msbuild UWPTest.proj /p:TargetArch=$targetArch
    msbuild UWPTest.proj /p:TargetArch=$targetArch /p:IsNetNative=true
}