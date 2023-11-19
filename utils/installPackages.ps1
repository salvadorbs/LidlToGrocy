param ([string] $Source, [string] $LazBuildPath, [switch] $BuildIde = $false)

# *** FUNCTION DEFINITIONS

function InstallPackage($LazBuildPath, $PackagePath)
{
  write-output "Installing Package $PackagePath"
  $LazBuild_AllArgs = @('--add-package', "$PackagePath", '--skip-dependencies', '-q')
  & $LazBuildPath $LazBuild_AllArgs
}

function InstallPackageLink($LazBuildPath, $PackagePath)
{
  write-output "Installing Package (only link) $PackagePath"
  $LazBuild_AllArgs = @('--add-package-link', "$PackagePath", '--skip-dependencies', '-q')
  & $LazBuildPath $LazBuild_AllArgs
}

function BuildIde($LazBuildPath)
{
  write-output "Building Lazarus IDE"
  $LazBuild_AllArgs = @('--build-ide=')
  & $LazBuildPath $LazBuild_AllArgs
}

# *** BEGIN MAIN SCRIPT

write-output "Source = $Source"
write-output "LazBuildPath = $LazBuildPath"
write-output "BuildIde = $BuildIde"

# Install Lazarus Components
write-output "Installing Lazarus Components for building project"
InstallPackageLink $LazBuildPath "$Source/3p/mORMot2/packages/lazarus/mormot2.lpk"

# Download mORMot 2 Static files and extract them in proper directory
$Url = 'https://github.com/synopse/mORMot2/releases/download/2.1.stable/mormot2static.7z' 
$ZipFile = $(Split-Path -Path $Url -Leaf) 
$Destination = $Source + '/3p/mORMot2/static/'
$pwd = Get-Location

write-output "Downloading $ZipFile for mORMot2"
Invoke-WebRequest -Uri $Url -OutFile $ZipFile

$command = "7z x '$ZipFile' -o'$Destination'"
Invoke-Expression $command

if ($BuildIde) {
  BuildIde $LazBuildPath
}