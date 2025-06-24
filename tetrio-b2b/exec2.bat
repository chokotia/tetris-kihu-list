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
echo 選択例: 1,3,5 または 1-3,5,7-9
set /p choice=番号を入力してください (カンマ区切り、範囲指定可): 

if "%choice%"=="" goto invalid

REM 選択された番号を解析
set "selected_files="
set "temp_choice=%choice%"

REM カンマで分割して処理
:parse_loop
if "%temp_choice%"=="" goto parse_done

REM 最初の要素を取得
for /f "tokens=1,* delims=," %%a in ("%temp_choice%") do (
    set "current=%%a"
    set "temp_choice=%%b"
)

REM 範囲指定かチェック
set "is_range=0"
echo !current! | find "-" >nul
if !errorlevel!==0 set "is_range=1"

if "!is_range!"=="1" (
    REM 範囲指定の処理
    for /f "tokens=1,2 delims=-" %%x in ("!current!") do (
        set "start=%%x"
        set "end=%%y"
        for /l %%i in (!start!,1,!end!) do (
            if %%i geq 1 if %%i leq %count% (
                set "selected_files=!selected_files! %%i"
            )
        )
    )
) else (
    REM 単一番号の処理
    set "num=!current!"
    if !num! geq 1 if !num! leq %count% (
        set "selected_files=!selected_files! !num!"
    )
)

goto parse_loop

:parse_done

if "%selected_files%"=="" goto invalid

echo.
echo 選択されたファイル:
for %%i in (%selected_files%) do (
    echo %%i. !file%%i!
)
echo.

REM 選択されたファイルパスを作成
set "file_list="
for %%i in (%selected_files%) do (
    set "current_file=!file%%i!"
    if "!file_list!"=="" (
        set "file_list=!current_file!"
    ) else (
        set "file_list=!file_list!,!current_file!"
    )
)

echo ストップウォッチサイトを開いています...
start chrome "https://stopwatch.onl.jp/"
echo.

echo URLをランダムに並び替えて開いています...
echo.

set url_count=0
for /f "usebackq delims=" %%i in (`powershell -Command "'!file_list!'.Split(',') | ForEach-Object { Get-Content $_.Trim() } | Where-Object { $_.Trim() -ne '' } | Sort-Object {Get-Random} | Select-Object -First 25"`) do (
    echo 開いています: %%i
    start chrome "%%i"
    set /a url_count+=1
)

echo.
echo 完了しました。開いたURL数: %url_count%
pause
exit /b

:invalid
echo 無効な選択です。
pause