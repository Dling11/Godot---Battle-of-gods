param([string]$OutputPath = 'exports/Battle-of-Gods-project.zip')
$ErrorActionPreference = 'Stop'
$taskWorkspace = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$taskOutput = [IO.Path]::GetFullPath((Join-Path $taskWorkspace $OutputPath))
if (-not $taskOutput.StartsWith([IO.Path]::GetFullPath((Join-Path $taskWorkspace 'exports')) + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Write packages inside exports/.' }
New-Item -ItemType Directory -Path ([IO.Path]::GetDirectoryName($taskOutput)) -Force | Out-Null
$taskFolders = @('assets', 'autoload', 'data', 'entities', 'environment', 'gameplay', 'levels', 'ui', 'tools/editor')
$taskFiles = @((Get-Item -LiteralPath (Join-Path $taskWorkspace 'project.godot')))
foreach ($taskFolder in $taskFolders) { $taskFiles += Get-ChildItem -LiteralPath (Join-Path $taskWorkspace $taskFolder) -File -Recurse }
# Source distribution: includes actual runtime dependencies, not Git history,
# captures, tests, art-generation sources or the generated .godot cache.
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$taskStream = [IO.File]::Open($taskOutput, [IO.FileMode]::Create)
$taskZip = [IO.Compression.ZipArchive]::new($taskStream, [IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($taskFile in $taskFiles) {
        $taskEntryName = $taskFile.FullName.Substring($taskWorkspace.TrimEnd('\').Length + 1).Replace('\', '/')
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($taskZip, $taskFile.FullName, $taskEntryName, [IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
} finally { $taskZip.Dispose(); $taskStream.Dispose() }
[pscustomobject]@{ path = $taskOutput; files = $taskFiles.Count; bytes = (Get-Item -LiteralPath $taskOutput).Length; sha256 = (Get-FileHash -LiteralPath $taskOutput -Algorithm SHA256).Hash; requirement = 'Godot 4.7.2 standard; import project.godot and press F5.' } | ConvertTo-Json
