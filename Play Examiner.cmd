@echo off
setlocal
set "EXAMINER_GODOT=D:\WORK_APP\godot\Godot_v4.7-stable_win64_console.exe"
if not exist "%EXAMINER_GODOT%" (
  echo Godot was not found at the configured local path.
  echo Open this project in Godot and press F7 during play.
  pause
  exit /b 1
)
start "" "%EXAMINER_GODOT%" --path "%~dp0." res://levels/combat_lab/combat_lab.tscn
