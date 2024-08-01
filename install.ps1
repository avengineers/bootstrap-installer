function Remove-Path {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$path
    )
    if (Test-Path -Path $path -PathType Container) {
        Write-Output "Deleting directory '$path' ..."
        Remove-Item $path -Force -Recurse
    }
    elseif (Test-Path -Path $path -PathType Leaf) {
        Write-Output "Deleting file '$path' ..."
        Remove-Item $path -Force
    }
}

# Call a command and handle its exit code
function Invoke-CommandLine {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression', '', Justification = 'Usually this statement must be avoided (https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/avoid-using-invoke-expression?view=powershell-7.3), here it is OK as it does not execute unknown code.')]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$CommandLine,
        [Parameter(Mandatory = $false, Position = 1)]
        [bool]$StopAtError = $true,
        [Parameter(Mandatory = $false, Position = 2)]
        [bool]$Silent = $false
    )
    if (-Not $Silent) {
        Write-Output "Executing: $CommandLine"
    }
    $global:LASTEXITCODE = 0
    if ($Silent) {
        # Omit information stream (6) and stdout (1)
        Invoke-Expression $CommandLine 6>&1 | Out-Null
    }
    else {
        Invoke-Expression $CommandLine
    }
    if ($global:LASTEXITCODE -ne 0) {
        if ($StopAtError) {
            Write-Error "Command line call `"$CommandLine`" failed with exit code $global:LASTEXITCODE"
        }
        else {
            Write-Output "Command line call `"$CommandLine`" failed with exit code $global:LASTEXITCODE, continuing ..."
        }
    }
}

function CloneOrPullGitTag {
    param (
        [string]$RepoUrl,
        [string]$Tag,
        [string]$TargetDirectory
    )

    # Check if the repo directory already exists
    if (Test-Path -Path "$TargetDirectory\.git" -PathType Container) {
        try {
            Push-Location $TargetDirectory
            
            # fetch and checkout the tag
            Invoke-CommandLine "git fetch --tags" -Silent $true
            Invoke-CommandLine "git checkout $Tag" -Silent $true
            Invoke-CommandLine "git reset --hard --quiet" -Silent $true
            
            Pop-Location
            return
        }
        catch {
            Write-Output "Failed to checkout tag '$Tag' in repository '$RepoUrl' at directory '$TargetDirectory'."
            Pop-Location
            Remove-Path $TargetDirectory
        }
    }

    # Repo directory does not exist, remove any possible leftovers and get a fresh clone
    try {
        Remove-Path $TargetDirectory
        Invoke-CommandLine "git -c advice.detachedHead=false clone --branch $Tag $RepoUrl $TargetDirectory" -Silent $true
    }
    catch {
        Write-Output "Failed to clone repository '$RepoUrl' at directory '$TargetDirectory'."
        Remove-Path $TargetDirectory
    }
}

## start of script
# Always set the $InformationPreference variable to "Continue" globally,
# this way it gets printed on execution and continues execution afterwards.
$InformationPreference = "Continue"

# Stop on first error
$ErrorActionPreference = "Stop"

# Clone the bootstrap repository (using a release tag)
CloneOrPullGitTag -RepoUrl "https://github.com/avengineers/bootstrap.git" -Tag "v1.12.0" -TargetDirectory ".bootstrap"

## end of script
