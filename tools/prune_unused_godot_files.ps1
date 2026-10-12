param([switch]$Apply)
$ErrorActionPreference = 'Stop'
$taskWorkspace = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..')).TrimEnd('\', '/')
$taskCacheRoot = [IO.Path]::GetFullPath((Join-Path $taskWorkspace '.godot'))
$taskImportsRoot = [IO.Path]::GetFullPath((Join-Path $taskCacheRoot 'imported'))
if ($taskCacheRoot -ne ($taskWorkspace + '\.godot') -or $taskImportsRoot -ne ($taskCacheRoot + '\imported')) { throw 'Invalid cache scope.' }
if (Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like 'Godot*' }) { throw 'Close Godot before pruning unused cache files.' }
foreach ($taskDirectory in @($taskCacheRoot, $taskImportsRoot)) {
    if ((Test-Path -LiteralPath $taskDirectory) -and ((Get-Item -LiteralPath $taskDirectory -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'Refusing linked cache directory.' }
}

# Only flat imported files absent from current import metadata are candidates.
# Preserve editor settings, UID/class caches and shader caches.
$taskKeep = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($taskFolder in @('assets', 'autoload', 'data', 'entities', 'environment', 'gameplay', 'levels', 'ui', 'tools', 'tests', 'art_source')) {
    $taskSourcePath = Join-Path $taskWorkspace $taskFolder
    if (-not (Test-Path -LiteralPath $taskSourcePath)) { continue }
    foreach ($taskImport in Get-ChildItem -LiteralPath $taskSourcePath -Filter '*.import' -File -Recurse) {
        $taskText = Get-Content -Raw -LiteralPath $taskImport.FullName
        foreach ($taskMatch in [regex]::Matches($taskText, 'res://\.godot/imported/([^"\]\s,]+)')) {
            $taskName = $taskMatch.Groups[1].Value
            [void]$taskKeep.Add($taskName)
            [void]$taskKeep.Add([IO.Path]::ChangeExtension($taskName, '.md5'))
        }
    }
}
$taskCandidates = @()
if (Test-Path -LiteralPath $taskImportsRoot) {
    $taskCandidates += Get-ChildItem -LiteralPath $taskImportsRoot -File | Where-Object {
        $_.Extension -in @('.ctex', '.md5', '.sample', '.oggvorbisstr', '.mp3str', '.fontdata') -and -not $taskKeep.Contains($_.Name)
    }
}
if (Test-Path -LiteralPath $taskCacheRoot) {
    # Old custom review recordings/logs are not Godot editor state.
    $taskCandidates += Get-ChildItem -LiteralPath $taskCacheRoot -File | Where-Object { $_.Extension -in @('.avi', '.png', '.log', '.tmp') }
}
foreach ($taskFile in $taskCandidates) {
    $taskAbsolute = [IO.Path]::GetFullPath($taskFile.FullName)
    if ($taskFile.DirectoryName -notin @($taskCacheRoot, $taskImportsRoot) -or -not $taskAbsolute.StartsWith($taskCacheRoot + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Outside flat cache scope.' }
    if ($taskFile.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Refusing linked cache file.' }
}
$taskBytes = ($taskCandidates | Measure-Object Length -Sum).Sum
if ($Apply) {
    foreach ($taskFile in $taskCandidates) { Remove-Item -LiteralPath $taskFile.FullName -Force }
}
[pscustomobject]@{ applied = [bool]$Apply; files = $taskCandidates.Count; bytes = $taskBytes; scope = 'Stale imported files and flat old recordings; editor state preserved.' } | ConvertTo-Json
