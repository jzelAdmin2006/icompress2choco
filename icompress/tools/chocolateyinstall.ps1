$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$packageName = $env:ChocolateyPackageName
$zipFile = 'MassImageCompressorV3.2.0.zip'
$setupExe = 'MassImageCompressorV3.2.0\setup.exe'
$zipUrl = 'https://deac-fra.dl.sourceforge.net/project/icompress/icompress/Mass%20Image%20Compressor/MassImageCompressorV3.2.0.zip'
$setupExePath = "$toolsDir\$setupExe"
$processName = 'Image Compressor'

$zipPackageArgs = @{
  packageName   = $packageName
  unzipLocation = $toolsDir
  fileType      = 'ZIP'
  url           = $zipUrl
  checksum      = 'C828BD46016304346DD9E531BEA56F370D687A8C5C372535E7BC59B30523A661'
  checksumType  = 'sha256'
}

Install-ChocolateyZipPackage @zipPackageArgs

$installPackageArgs = @{
  packageName   = $packageName
  fileType      = 'exe'
  file          = $setupExePath
  silentArgs    = "/Q"
  validExitCodes= @(0, 3010, 1641)
  softwareName  = "$packageName*"
}

Install-ChocolateyInstallPackage @installPackageArgs

Start-Job -ScriptBlock {
    param($processName)
    while (-not (Get-Process -Name $processName -ErrorAction SilentlyContinue)) { 
        Start-Sleep -Milliseconds 100 
    }
    Stop-Process -Name $processName -Force
} -ArgumentList $processName

Get-Job | Wait-Job | Receive-Job
