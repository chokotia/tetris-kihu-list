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
echo URLをランダムに並び替えて開いています...
echo.

:: PowerShellを使ってファイルをランダムに並び替えて直接処理
for /f "usebackq delims=" %%i in (`powershell -Command "Get-Content '%selectedfile%' | Sort-Object {Get-Random}"`) do (
    echo 開いています: %%i
    start chrome "%%i"
    timeout /t 0.1 >nul
)

echo.
echo 完了しました。
pause
exit /b

:invalid
echo 無効な選択です。
pause