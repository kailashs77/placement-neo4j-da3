@echo off
rem Starts the local Neo4j server. Keep this window open while you work.
rem Then open http://localhost:7474 in a browser (login details are in local-login.txt).
rem Press Ctrl+C in this window to stop the server.
cd /d "%~dp0neo4j-server\neo4j-community-2026.10.1"
call bin\neo4j.bat console
pause
