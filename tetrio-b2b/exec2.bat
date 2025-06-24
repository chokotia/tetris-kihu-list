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

echo [DEBUG] 入力された選択: %choice%

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

echo [DEBUG] 処理中の要素: !current!

REM 範囲指定かチェック（より安全な方法）
set "is_range=0"
echo !current! | find "-" >nul
if !errorlevel!==0 set "is_range=1"

if "!is_range!"=="1" (
    echo [DEBUG] 範囲指定を検出: !current!
    REM 範囲指定の処理
    for /f "tokens=1,2 delims=-" %%x in ("!current!") do (
        set "start=%%x"
        set "end=%%y"
        echo [DEBUG] 範囲: !start! から !end!
        for /l %%i in (!start!,1,!end!) do (
            if %%i geq 1 if %%i leq %count% (
                set "selected_files=!selected_files! %%i"
                echo [DEBUG] 追加: %%i
            )
        )
    )
) else (
    echo [DEBUG] 単一番号: !current!
    REM 単一番号の処理
    set "num=!current!"
    if !num! geq 1 if !num! leq %count% (
        set "selected_files=!selected_files! !num!"
        echo [DEBUG] 追加: !num!
    )
)

goto parse_loop

:parse_done

if "%selected_files%"=="" goto invalid

echo.
echo [DEBUG] 解析結果 selected_files: %selected_files%
echo.
echo 選択されたファイル:
for %%i in (%selected_files%) do (
    echo %%i. !file%%i!
)
echo.

REM 選択されたファイルパスを作成（修正版）
set "file_list="
echo [DEBUG] ファイルパス構築開始
for %%i in (%selected_files%) do (
    set "current_file=!file%%i!"
    echo [DEBUG] 処理中のファイル%%i: !current_file!
    if "!file_list!"=="" (
        set "file_list=!current_file!"
    ) else (
        set "file_list=!file_list!,!current_file!"
    )
    echo [DEBUG] 現在のfile_list: !file_list!
)

echo [DEBUG] 最終的なfile_list: !file_list!
echo.

echo ストップウォッチサイトを開いています...
start chrome "https://stopwatch.onl.jp/"
echo.

echo URLをランダムに並び替えて開いています...
echo.

set url_count=0
echo [DEBUG] PowerShell実行開始

REM PowerShellでファイルリストを処理（修正版）
echo [DEBUG] PowerShell実行:
for /f "usebackq delims=" %%i in (`powershell -Command "'!file_list!'.Split(',') | ForEach-Object { Get-Content $_.Trim() } | Where-Object { $_.Trim() -ne '' } | Sort-Object {Get-Random} | Select-Object -First 25"`) do (
    echo [DEBUG] 取得したURL: %%i
    echo 開いています: %%i
    start chrome "%%i"
    set /a url_count+=1
)

if %url_count%==0 (
    echo [DEBUG] URLが取得できませんでした。
    echo [DEBUG] 手動でファイル内容確認:
    for %%i in (%selected_files%) do (
        set "check_file=!file%%i!"
        echo [DEBUG] ファイル !check_file! の内容:
        if exist "!check_file!" (
            type "!check_file!"
        ) else (
            echo [DEBUG] ファイルが存在しません: !check_file!
        )
        echo [DEBUG] ファイル終了
        echo.
    )
)

echo.
echo 完了しました。開いたURL数: %url_count%
pause
exit /b

:invalid
echo 無効な選択です。
pause