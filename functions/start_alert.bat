@echo off
cd /d "%~dp0"
echo Broadcasting Agricultural Alert directly to the Smart Farm App...
node send_daily_alert.js
