param([Parameter(Mandatory = $true)][string]$PlanPath)
$ErrorActionPreference = 'Stop'
$taskWorkspace = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..')).TrimEnd('\', '/')
$taskPlan = Get-Content -Raw -LiteralPath $PlanPath | ConvertFrom-Json
if ([IO.Path]::GetFullPath($taskPlan.root).TrimEnd('\', '/') -ne $taskWorkspace) { throw 'Plan belongs to a different workspace.' }
$taskAllowed = @('art_source', 'assets', 'tools', 'tests', 'data', 'entities', 'gameplay', 'docs')
$taskTargets = @($taskPlan.folder_targets) + @($taskPlan.file_targets)
# Resolve and check every target before any deletion. Never cross the project,
# remove Git history, or delete a folder containing a retained dependency.
foreach ($taskRelative in $taskTargets) {
    $taskAbsolute = [IO.Path]::GetFullPath((Join-Path $taskWorkspace $taskRelative))
    if (-not $taskAbsolute.StartsWith($taskWorkspace + '\', [StringComparison]::OrdinalIgnoreCase)) { throw "Outside workspace: $taskRelative" }
    if (($taskRelative -split '[/\\]')[0] -notin $taskAllowed) { throw "Unsupported deletion root: $taskRelative" }
    foreach ($taskProtected in $taskPlan.protected_paths) {
        if ($taskProtected -eq $taskRelative -or $taskProtected.StartsWith($taskRelative.TrimEnd('/') + '/', [StringComparison]::OrdinalIgnoreCase)) { throw "Target includes a retained dependency: $taskRelative" }
    }
    if (Test-Path -LiteralPath $taskAbsolute) {
        $taskItem = Get-Item -LiteralPath $taskAbsolute -Force
        if ($taskItem.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Refusing linked target: $taskRelative" }
    }
}
foreach ($taskRelative in $taskTargets) {
    $taskAbsolute = [IO.Path]::GetFullPath((Join-Path $taskWorkspace $taskRelative))
    if (Test-Path -LiteralPath $taskAbsolute) { Remove-Item -LiteralPath $taskAbsolute -Recurse -Force }
}
[pscustomobject]@{ removed_files = $taskPlan.removed_files; removed_bytes = $taskPlan.removed_bytes; folder_operations = @($taskPlan.folder_targets).Count; file_operations = @($taskPlan.file_targets).Count } | ConvertTo-Json
