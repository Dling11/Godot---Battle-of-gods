param([string]$GodotPath = 'D:\WORK_APP\godot\Godot_v4.7-stable_win64.exe', [switch]$Eira, [switch]$TrainingDemo, [switch]$InterfaceDemo)
$projectPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Godot not found at $GodotPath" }
# Visible window is the requested interactive environment review.
$reviewArgs = @('--path', ('"' + $projectPath + '"'), '--resolution', '1280x720', '--script', 'res://tools/launch_sanctuary_study.gd')
if ($Eira -or $TrainingDemo) { $reviewArgs += @('--', '--eira') }
if ($TrainingDemo) { $reviewArgs += '--training-demo' }
if ($InterfaceDemo) {
    if (-not ($Eira -or $TrainingDemo)) { $reviewArgs += '--' }
    $reviewArgs += '--interface-demo'
}
Start-Process -FilePath $GodotPath -WorkingDirectory $projectPath -ArgumentList $reviewArgs -PassThru | Select-Object Id, ProcessName
