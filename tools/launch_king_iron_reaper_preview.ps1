param(
    [string]$GodotPath = 'D:\WORK_APP\godot\Godot_v4.7-stable_win64.exe'
)
$ErrorActionPreference = 'Stop'
$projectPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Godot not found at $GodotPath; pass -GodotPath for this PC." }
$previewPath = Join-Path $projectPath 'art_source/generated/characters/king/iron_reaper_side_preview_2026_10_14/preview/sweep.png'
if (-not (Test-Path -LiteralPath $previewPath)) { throw 'Rebuild first with --headless --path . --script tools/build_king_iron_reaper_preview.gd.' }
$previewArgs = @('--path', ('"' + $projectPath + '"'), '--rendering-method', 'gl_compatibility', '--script', 'res://tools/review_king_iron_reaper.gd')
# Interactive art review; it creates no playable weapon or campaign rewards.
Start-Process -FilePath $GodotPath -WorkingDirectory $projectPath -ArgumentList $previewArgs -PassThru | Select-Object Id, ProcessName
