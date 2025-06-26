@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo URLファイルを選択してください:
echo.

set count=0
for %%f in (url\*.txt) do (
    set /a count+=1
    echo !count!. %%~nf
    set "file!count!=%%f"
)

if %count%==0 (
    echo urlフォルダにtxtファイルが見つかりませんでした。
    pause
    exit /b
)

echo.
set /p choice=番号を入力してください (1-%count%): 

if "%choice%"=="" goto invalid
if %choice% lss 1 goto invalid
if %choice% gtr %count% goto invalid

set "selectedfile=!file%choice%!"
echo.
echo 選択されたファイル: %selectedfile%
echo.

echo ストップウォッチサイトを開いています...
start chrome "https://stopwatch.onl.jp/"
echo.

echo URLを開いています...
echo.
set tabcount=0
for /f "usebackq delims=" %%i in ("%selectedfile%") do (
    echo 開いています: %%i
    start chrome "%%i"
    set /a tabcount+=1
)

echo.
echo 完了しました。
echo num: !tabcount!
pause
exit /b

:invalid
echo 無効な選択です。
pause