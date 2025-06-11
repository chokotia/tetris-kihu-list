@echo off
for /f "delims=" %%i in (urls.txt) do (
    start chrome "%%i"
)
