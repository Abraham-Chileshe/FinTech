@echo off
title Munda AI - Mobile Phone SMS Mockup & Automation Simulator
echo ======================================================================
echo    MUNDA AI - MOBILE PHONE SMS MOCKUP & AUTOMATION TEST HARNESS
echo ======================================================================
echo.
echo [1/2] Checking Python dependencies...
python -c "import flask, requests" >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing flask and requests...
    pip install -r requirements.txt
)

echo [2/2] Starting Mobile Mockup Server on http://127.0.0.1:5050 ...
echo.
echo Press Ctrl+C in this window to stop the server.
echo.

start "" http://127.0.0.1:5050
python app.py
pause
