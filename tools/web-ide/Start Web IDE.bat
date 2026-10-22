@echo off
rem Starts the OXT-Beyond web IDE on this computer (serve.py; needs Python 3)
cd /d "%~dp0"
where py >nul 2>nul
if %errorlevel%==0 (py serve.py %*) else (python serve.py %*)
pause
