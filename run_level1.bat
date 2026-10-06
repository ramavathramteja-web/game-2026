@echo off
cd /d "%~dp0"
godot.exe --rendering-driver d3d12 "res://src/levels/L1_DarkCity.tscn"
pause
