# powershellの実行権限修正
# Set-ExecutionPolicy Bypass -Scope CurrentUser

# https://48idol.net/からダウンロードする方法
# 仕様として、dll の参照追加よりも、using 名前空間の方を先に記載しなくちゃいけない
using namespace System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# include config
. "${PSScriptRoot}\streamConf.ps1"



# カレントディレクトリの獲得
# 特に変更する必要なし
cd ${FOLDER_PATH}
$current = Get-Location

# Open Folder Path
# ダウンロード先を指定
$OPEN_FOLDER_PATH = "${current}\movie"

# 環境変数の設定
# streamlinkが使えるようにする
# 本アプリケーションがダウンロードされたトップディレクトリを指定
$DOWNLOAD_DIR = "${current}"

$env:Path = $env:Path + ";${DOWNLOAD_DIR}\bin"
$env:Path = $env:Path + ";${DOWNLOAD_DIR}\bin\Streamlink"
$env:Path = $env:Path  + ";${FFMPEG_PATH}"

# Program name
# 特に変更する必要なし
$PROGRAM_NAME = "Stream downloader"

# 基準の横幅
$CRITERIA_WIDTH = 10

# 基準の横幅
$CRITERIA_WIDTH_2 = $CRITERIA_WIDTH + 65

# 基準の横幅
$CRITERIA_WIDTH_3 = $CRITERIA_WIDTH_2 + 285

# 基準の高さ
$CRITERIA_HEIGHT = 15

# 高さの均等幅
$HEIGHT_SPACE = 30

# 基準の高さ(URL)
$CRITERIA_HEIGHT_URL = 100

# タイトルラベルのデフォルト長
$TITLE_LENGTH = 60

# テキストのデフォルト長
$TEXT_LENGTH = 270

# ボタンのデフォルト長
$BTN_LENGTH = 110

# 高さ
$DEFAULT_HEIGHT_SIZE = 20

# catch句で捕まえられるようにする
# デフォルトでは「終了エラー」しかとらえられず、「継続エラー」が捕まえられない。
# 特に変更する必要なし
# Continue : デバッグ用
$ErrorActionPreference = "Continue"

#$ErrorActionPreference = "Stop"


# ------------------------------------------------------------------
# Windowsでファイル名に使用できない禁止文字を全角に変換する
# 関数名：ConvertTo-UsedFileName
# 引数  ：FileName ファイル名
# 戻り値：変換後のファイル名
# @author : Yuki-Kikuya
# refs : http://assembler0x.blogspot.com/2013/08/windows.html
# ------------------------------------------------------------------
function ConvertTo-UsedFileName([String]$FileName){
  # 禁止文字(半角記号)
  $CannotUsedFileName = '\/:*?`"><| 　・＆#[]'
  # 禁止文字(全角記号)
  $UsedFileName = '￥／：＊？`”＞＜｜__．&＃［］'

  for ($i = 0; $i -lt $UsedFileName.Length; $i++) {
    $FileName = $FileName.Replace($CannotUsedFileName[$i], $UsedFileName[$i])
  }
  if ($FileName.Contains("_｜_無料動画．見逃し配信を見るなら_｜_ABEMA")) {
    $FileName = $FileName.Substring(0, $FileName.Length - 26);
  }
  if ($FileName.Contains("_｜_無料で動画&見逃し配信を見るなら【ABEMAビデオ】")){
    $FileName = $FileName.Substring(0, $FileName.Length - 27);
  }
  Write-Host("[Info] rename file name : ${FileName} ")
  return $FileName
}

# ------------------------------------------------------------------
# ファイル名の長さチェック
# 引数  ：FileName ファイル名
# @author : Yuki-Kikuya
# ------------------------------------------------------------------
function CheckFileName([String]$FileName){
    $MAX_FILE_NAME_LENGTH = 120
    if ($FileName.Length -gt $MAX_FILE_NAME_LENGTH) {
        # 文字列の前から255文字分だけ抽出
        $FileName = $FileName.Substring(0, $MAX_FILE_NAME_LENGTH)
        Write-Host("[Info] 文字列縮小 : ${FileName}")
    } else {
        Write-Host("[Info] no modify string of file name : ${FileName}")
    }
    return $FileName
}

function ExtraTitle([String]$url){
    # SiteCollection URL 
    $response = Invoke-WebRequest $url
    # refs:https://docs.microsoft.com/ja-jp/dotnet/api/system.windows.forms.htmldocument?view=netframework-4.8
    # refs:http://winscript.jp/powershell/305
    # refs:http://sloppy-content.blog.jp/archives/12057529.html
    # タイトルを取得
    return CheckFileName(ConvertTo-UsedFileName($response.ParsedHtml.Title))
}

# アベマ生配信用のタイトル取得
function ExtraTitleNow([String]$url){
    # SiteCollection URL 
    $response = Invoke-WebRequest $url -OutFile "a.html"
    # refs:https://docs.microsoft.com/ja-jp/dotnet/api/system.windows.forms.htmldocument?view=netframework-4.8
    # refs:http://winscript.jp/powershell/305
    # refs:http://sloppy-content.blog.jp/archives/12057529.html
    # タイトルを取得
    #$response.ParsedHtml.get
    #$response.AllElements # | Where-Object { $_.tagName -eq 'h2'} | ForEach-Object {
	#    Write-Host $_.innerText
   # }
    #$response.AllElements | Where-Object { $_.tagName -eq 'span'} | ForEach-Object {
	#    Write-Host $_.innerText
    #}
    $html = $response.Content
    $obj = New-Object -ComObject "$current\a.html"
    Write-Host($obj)

    #return CheckFileName(ConvertTo-UsedFileName($html.getElementsByTagName("SCRIPT; type=application/ld+json")[0]))
}



function Output-File([String] $FileName, [String] $Data) {
    Write-Host "[Info] Output-File (FileName) : " + $FileName
    Write-Host "[Info]" + $Data
    Add-Content -LiteralPath ${FileName} -Value "${Data}"
}

function Output-HistoryFile([String] $Data) {
    Write-Host "[Info] Output-HistoryFile : " + $Data
    Output-File ${HISTORY_PATH} ${Data} 
}

function Input-File([String]$FileName) {
    return $(Get-Content ${FileName} -last 5)
}

function Input-HistoryFile() {
	return Input-File(${HISTORY_PATH})
}

#---------------------------------------------------
# フォーム設定
$f = New-Object Form
$f.Text = $PROGRAM_NAME
$f.Size = [string]($CRITERIA_WIDTH_3 + 150) + ", "+ ($CRITERIA_HEIGHT + 320)
$f.MaximumSize = [string]($CRITERIA_WIDTH_3 + 500) + ", " + ($CRITERIA_HEIGHT + 320)
#---------------------------------------------------


# -------------------------------------------------------
# ------------ m3u8ファイルダウンロード -----------------
# -------------------------------------------------------

# ラベルと入力欄
$lbl1 = New-Object Label
$lbl1.Text = "m3u8File:"
$lbl1.Location = ([string]$CRITERIA_WIDTH) + ", " + ($CRITERIA_HEIGHT + 22)
$lbl1.Size = New-Object System.Drawing.Size(${TITLE_LENGTH}, $DEFAULT_HEIGHT_SIZE)

$mname = New-Object TextBox
$mname.Name = "textbox1"
$mname.Text = "select m3u8 file"
$mname.Location = "75, " + ($CRITERIA_HEIGHT + 20)
$mname.Size = New-Object System.Drawing.Size(${TEXT_LENGTH}, ${$DEFAULT_HEIGHT_SIZE})

# ボタン(開く...)の設定
$obtn = New-Object Button
$obtn.Text = "Open...  "
$obtn.Size = New-Object System.Drawing.Size(${BTN_LENGTH}, ${DEFAULT_HEIGHT_SIZE})
$obtn.Location = ([String]$CRITERIA_WIDTH_3) +", " + ($CRITERIA_HEIGHT + 20)


# ファイル選択ボタン
$button_Click = {
    #ファイル選択ダイアログのオブジェクト取得
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
     
    #フィルタ条件の設定
    $dialog.Filter = 'm3u8 Files|*.m3u8|Text Files|*.txt|Csv Files|*.csv|All Files|*.*'
     
    #デフォルト選択ディレクトリの設定
    $dialog.InitialDirectory = $OPEN_FOLDER_PATH

    if ($dialog.ShowDialog() -eq "OK") {
        $new_filename = "$(Split-Path -Parent $dialog.FileName)\"
        $new_filename += ConvertTo-UsedFileName(CheckFileName([System.IO.Path]::GetFileNameWithoutExtension($dialog.FileName)))
        $new_filename += ".m3u8"
        Write-Host($new_filename)
        mv $dialog.FileName $new_filename
        $dialog.FileName = $new_filename
        $mname.Text = $dialog.FileName
        $sname.Text = CheckFileName([System.IO.Path]::GetFileNameWithoutExtension($dialog.FileName))
        $sname.Text = ConvertTo-UsedFileName($sname.Text)
        "選択したファイル`n`"" + $dialog.FileName + '"'
    } else {
        '選択なし。'
    }
}
$obtn.Add_Click($button_Click)

# Label of save name of m3u8
$lbl2 = New-Object Label
$lbl2.Text = "saveName:"
$lbl2.Location = "10, " + ($CRITERIA_HEIGHT + 52)
$lbl2.AutoSize = New-Object System.Drawing.Size(${TITLE_LENGTH}, $DEFAULT_HEIGHT_SIZE)

# TextBox of save name of m3u8
$sname = New-Object TextBox
$sname.Name = "textbox1"
$sname.Text = "input title"
$sname.Location = "75, " + ($CRITERIA_HEIGHT + 50)
$sname.Size = New-Object System.Drawing.Size(${TEXT_LENGTH}, ${DEFAULT_HEIGHT_SIZE})

# download button of m3u8
$btn = New-Object Button
$btn.Text = "download(m3u8)"
$btn.Size = New-Object System.Drawing.Size(${BTN_LENGTH}, ${DEFAULT_HEIGHT_SIZE})
$btn.Location = ([String]$CRITERIA_WIDTH_3) +", " + ($CRITERIA_HEIGHT + 50)

# on click listener of download button of m3u8
$button_Click2 = {
    $m3u8 = $mname.Text
    $output = $sname.Text
    try {
        ffmpeg -protocol_whitelist file,http,https,tcp,tls,crypto -i "${m3u8}" -movflags faststart -c copy "${output}.mp4"
        Write-Host("[Info] Downloaded ${output}.mp4")
        [MessageBox]::Show("downloaded :[" + $output + "]", "Info", "OK", "Information")
    } catch [Exception] {
        [MessageBox]::Show("fail to download :[" + $output + "]. check [$(Get-Date -UFormat %Y%m%d).log]", "Error", "OK", "Error")
    } finally {
    }
}
$btn.Add_Click($button_Click2)


#-------------------------------------------------------
# ラベル(区切り線)
$lbl_line = New-Object Label
$lbl_line.Text = ""
$lbl_line.Location = "0, " + ($CRITERIA_HEIGHT + 85)
$lbl_line.Size = "450, 1"
$lbl_line.AutoSize = $False
$lbl_line.BackColor = "white"
$lbl_line.ForeColor = "White"
$lbl_line.BorderStyle = "FixedSingle"

# ------------------------------------------------------
# -------------- URL download --------------------------
# ------------------------------------------------------

# ラベルと入力欄
$lbl_url = New-Object Label
$lbl_url.Text = "Url:"
$lbl_url.Location = "10, " + ($CRITERIA_HEIGHT + $CRITERIA_HEIGHT_URL  +2)
$lbl_url.AutoSize = New-Object System.Drawing.Size(${TITLE_LENGTH}, $DEFAULT_HEIGHT_SIZE)

# TextBox of Input URL of url download
$url_url = New-Object System.Windows.Forms.Combobox
# Default string(set abemaTV URL)
$url_url.Name = "textbox1"
$url_url.Text = "https://abema.tv/"
$url_url.Location = "75, " + ($CRITERIA_HEIGHT + $CRITERIA_HEIGHT_URL)
$url_url.Size = New-Object System.Drawing.Size(${TEXT_LENGTH}, ${$DEFAULT_HEIGHT_SIZE})

if( Test-Path .\.history ) {
	Input-HistoryFile | % { [void] $url_url.Items.Add($_) }
}

# label of save name of url download
$lbl_save = New-Object Label
$lbl_save.Text = "SaveName:"
$lbl_save.Location = "10, " + ($CRITERIA_HEIGHT + 132)
$lbl_save.AutoSize = New-Object System.Drawing.Size(${TITLE_LENGTH}, $DEFAULT_HEIGHT_SIZE)

# TextBox of save name of url download
$name_save = New-Object TextBox
$name_save.Name = "textbox1"
$name_save.Text = "input name"
$name_save.Location = "75, " + ($CRITERIA_HEIGHT + 130)
$name_save.Size = New-Object System.Drawing.Size(${TEXT_LENGTH}, ${$DEFAULT_HEIGHT_SIZE})


# download button of url download
$btn_download_url = New-Object Button
$btn_download_url.Text = "download(URL)"
$btn_download_url.Size = New-Object System.Drawing.Size(${BTN_LENGTH}, ${DEFAULT_HEIGHT_SIZE})
$btn_download_url.Location = ([String]$CRITERIA_WIDTH_3) +", " + ($CRITERIA_HEIGHT + 130)

# ボタンのクリック
$button_Click_download_url = {
    ($sender, $e) = $this, $_
    $parent = ($sender -as [Button]).Parent -as [Form]
    $txt = [TextBox]$parent.Controls[$url_url.Name];
    
    $random_name = Get-Random
    
    Write-Host("[Info] ******************************************")
    Write-Host("[Info] Downloading... [" + $name_save.Text + "]`n")
    
    $nmane_str = $name_save.Text
    $url_str = $url_url.Text

    try {
    	
        # URLより動画を(.ts)形式でダウンロードする
        #Start-Job -ScriptBlock 
        streamlink "$url_str" best -o "${current}\tmp\${random_name}.ts"  >> .\log\$(Get-Date -UFormat %Y%m%d).log 
        
        Write-Host("comleted to Download")

        # (.ts)形式を(.mp4)形式に変換する
        ffmpeg -i ".\tmp\${random_name}.ts" -vcodec copy -acodec copy ".\tmp\${random_name}.mp4"
        
        Write-Host("completed convert to mp4")

        mv ".\tmp\${random_name}.mp4" .\movie\"$nmane_str.mp4"
        rm .\tmp\${random_name}.ts
        
        Write-Host("[Info] Downloaded... [" + $nmane_str + "]")
        
        [MessageBox]::Show("downloaded :[" + $nmane_str + "]", "Info", "OK", "Information")

    } catch [Exception] {
        Write-Host("[Error]" + $_.Exception.Message)
        [MessageBox]::Show($_.Exception.Message + "fail to download :[" + $nmane_str + "]. check [$(Get-Date -UFormat %Y%m%d).log]", "Error", "OK", "Error")
    } finally {
    
    }
}
$btn_download_url.Add_Click($button_Click_download_url)

# タイトル抽出ボタン
$obtn_extract = New-Object Button
$obtn_extract.Text = "extra title"
$obtn_extract.Size = New-Object System.Drawing.Size(${BTN_LENGTH}, ${DEFAULT_HEIGHT_SIZE})
$obtn_extract.Location = ([String]$CRITERIA_WIDTH_3) +", " + ($CRITERIA_HEIGHT + 100)

# ボタンのクリック
# タイトルを抽出する処理
$button_Click_extract = {
    # 履歴ファイルにURLを出力
    Output-HistoryFile($url_url.Text)
    [void] $url_url.Items.Add($url_url.Text)

    # タイトルを取得
    $name_save.Text = ExtraTitle($url_url.Text)
}
$obtn_extract.Add_Click($button_Click_extract)


# ----------------------------------------------------
# ------------ abema生配信保存 -----------------------
# ----------------------------------------------------

# abema生配信保存の基準の高さ
$CRITERIA_HEIGHT_NOW = $CRITERIA_HEIGHT + 170

# ラベル(区切り線)
$lbl_now_line = New-Object Label
$lbl_now_line.Text = ""
$lbl_now_line.Location = "0, " + ($CRITERIA_HEIGHT_NOW - 12)
$lbl_now_line.Size = "450, 1"
$lbl_now_line.AutoSize = $False
$lbl_now_line.BackColor = "white"
$lbl_now_line.ForeColor = "White"
$lbl_now_line.BorderStyle = "FixedSingle"

# ラベルと入力欄
$lbl_now_url = New-Object Label
$lbl_now_url.Text = "AbemaNow:"
$lbl_now_url.Location = "10, " + ($CRITERIA_HEIGHT_NOW + 2)
$lbl_now_url.AutoSize = New-Object System.Drawing.Size(${TITLE_LENGTH}, $DEFAULT_HEIGHT_SIZE)

# TextBox of Input URL of url download
$txt_now_url = New-Object System.Windows.Forms.Combobox
# Default string(set abemaTV URL)
$txt_now_url.Name = "textbox1"
$txt_now_url.Text = "https://abema.tv/now-on-air/"
$txt_now_url.Location = "75, " + ($CRITERIA_HEIGHT_NOW + 2)
$txt_now_url.Size = New-Object System.Drawing.Size(${TEXT_LENGTH}, ${$DEFAULT_HEIGHT_SIZE})

[void] $txt_now_url.Items.Add("https://abema.tv/now-on-air/abema-news")
[void] $txt_now_url.Items.Add("https://abema.tv/now-on-air/news-plus")
[void] $txt_now_url.Items.Add("https://abema.tv/now-on-air/abema-special")
[void] $txt_now_url.Items.Add("https://abema.tv/now-on-air/special-plus")
[void] $txt_now_url.Items.Add("https://abema.tv/now-on-air/special-plus-2")


# タイトル抽出ボタン
$obtn_now_extract = New-Object Button
$obtn_now_extract.Text = "extra title"
$obtn_now_extract.Size = New-Object System.Drawing.Size(${BTN_LENGTH}, ${DEFAULT_HEIGHT_SIZE})
$obtn_now_extract.Location = ([String]$CRITERIA_WIDTH_3) +", " + ($CRITERIA_HEIGHT_NOW)

# label of save name of url download
$lbl_now_save_time = New-Object Label
$lbl_now_save_time.Text = "saveTime:"
$lbl_now_save_time.Location = [string]($CRITERIA_WIDTH) + ", " + ($CRITERIA_HEIGHT_NOW + $HEIGHT_SPACE + 2)
$lbl_now_save_time.AutoSize = New-Object System.Drawing.Size(${TITLE_LENGTH}, $DEFAULT_HEIGHT_SIZE)

# コンボボックスを作成
# @refs : https://letspowershell.blogspot.com/2015/07/powershell_29.html
$Combo_now_time1 = New-Object System.Windows.Forms.Combobox
$Combo_now_time1.Location = [string]($CRITERIA_WIDTH_2) + "," + ($CRITERIA_HEIGHT_NOW + $HEIGHT_SPACE)
$Combo_now_time1.size = New-Object System.Drawing.Size(50,30)
$Combo_now_time1.DropDownStyle = "DropDown"
$Combo_now_time1.FlatStyle = "standard"
$Combo_now_time1.BackColor = "black"
$Combo_now_time1.ForeColor = "white"

[void] $Combo_now_time1.Items.Add("00")
[void] $Combo_now_time1.Items.Add("01")
[void] $Combo_now_time1.Items.Add("02")
[void] $Combo_now_time1.Items.Add("03")
[void] $Combo_now_time1.Items.Add("04")
[void] $Combo_now_time1.Items.Add("05")
[void] $Combo_now_time1.Items.Add("06")
[void] $Combo_now_time1.Items.Add("07")
[void] $Combo_now_time1.Items.Add("08")
[void] $Combo_now_time1.Items.Add("09")
[void] $Combo_now_time1.Items.Add("10")
$Combo_now_time1.SelectedIndex = 0

# label of save name of url download
$lbl_now_save_time1 = New-Object Label
$lbl_now_save_time1.Text = "H"
$lbl_now_save_time1.Location = [string]($CRITERIA_WIDTH_2 + 55) + ", " + ($CRITERIA_HEIGHT_NOW + $HEIGHT_SPACE + 2)
$lbl_now_save_time1.AutoSize = New-Object System.Drawing.Size(${TITLE_LENGTH}, $DEFAULT_HEIGHT_SIZE)

$Combo_now_time2 = New-Object System.Windows.Forms.Combobox
$Combo_now_time2.Location = [string]($CRITERIA_WIDTH_2 + 70) + "," + ($CRITERIA_HEIGHT_NOW + $HEIGHT_SPACE)
$Combo_now_time2.size = New-Object System.Drawing.Size(50,30)
$Combo_now_time2.DropDownStyle = "DropDown"
$Combo_now_time2.FlatStyle = "standard"
$Combo_now_time2.BackColor = "black"
$Combo_now_time2.ForeColor = "white"


[void] $Combo_now_time2.Items.Add("00")
[void] $Combo_now_time2.Items.Add("01")
[void] $Combo_now_time2.Items.Add("02")
[void] $Combo_now_time2.Items.Add("03")
[void] $Combo_now_time2.Items.Add("04")
[void] $Combo_now_time2.Items.Add("05")
[void] $Combo_now_time2.Items.Add("06")
[void] $Combo_now_time2.Items.Add("07")
[void] $Combo_now_time2.Items.Add("08")
[void] $Combo_now_time2.Items.Add("09")
[void] $Combo_now_time2.Items.Add("10")
$Combo_now_time2.SelectedIndex = 0


# label of save name of url download
$lbl_now_save_time2 = New-Object Label
$lbl_now_save_time2.Text = "M"
$lbl_now_save_time2.Location = [string]($CRITERIA_WIDTH_2 + 70 + 55) + ", " + ($CRITERIA_HEIGHT_NOW + $HEIGHT_SPACE + 2)
$lbl_now_save_time2.AutoSize = $True

# 秒
$Combo_now_time3 = New-Object System.Windows.Forms.Combobox
$Combo_now_time3.Location = [string]($CRITERIA_WIDTH_2 + 140) + "," + ($CRITERIA_HEIGHT_NOW + $HEIGHT_SPACE)
$Combo_now_time3.size = New-Object System.Drawing.Size(50,30)
$Combo_now_time3.DropDownStyle = "DropDown"
$Combo_now_time3.FlatStyle = "standard"
$Combo_now_time3.BackColor = "black"
$Combo_now_time3.ForeColor = "white"


[void] $Combo_now_time3.Items.Add("00")
[void] $Combo_now_time3.Items.Add("01")
[void] $Combo_now_time3.Items.Add("02")
[void] $Combo_now_time3.Items.Add("03")
[void] $Combo_now_time3.Items.Add("04")
[void] $Combo_now_time3.Items.Add("05")
[void] $Combo_now_time3.Items.Add("06")
[void] $Combo_now_time3.Items.Add("07")
[void] $Combo_now_time3.Items.Add("08")
[void] $Combo_now_time3.Items.Add("09")
[void] $Combo_now_time3.Items.Add("10")
$Combo_now_time3.SelectedIndex = 0

# 編集禁止
$Combo_now_time3.DropDownStyle = "DropDownList"


# label of save name of url download
$lbl_now_save_time3 = New-Object Label
$lbl_now_save_time3.Text = "S"
$lbl_now_save_time3.Location = [string]($CRITERIA_WIDTH_2 + 140 + 55) + ", " + ($CRITERIA_HEIGHT_NOW + $HEIGHT_SPACE + 2)
$lbl_now_save_time3.AutoSize = $True

# label of save name of url download
$lbl_now_save = New-Object Label
$lbl_now_save.Text = "saveName:"
$lbl_now_save.Location = "10, " + ($CRITERIA_HEIGHT_NOW + $HEIGHT_SPACE * 2 + 2)
$lbl_now_save.AutoSize = $True

# TextBox of save name of url download
$txt_now_save = New-Object TextBox
$txt_now_save.Name = "textbox1"
$txt_now_save.Text = "input name"
$txt_now_save.Location = "75, " + ($CRITERIA_HEIGHT_NOW + $HEIGHT_SPACE * 2)
$txt_now_save.Size = New-Object System.Drawing.Size(${TEXT_LENGTH}, ${$DEFAULT_HEIGHT_SIZE})

$button_now_Click_extract = {
    # タイトルを取得
    $txt_now_save.Text = ExtraTitleNow($txt_now_url.Text)
}
$obtn_now_extract.Add_Click($button_now_Click_extract)

# download button of url download
$btn_now_lownload_url = New-Object Button
$btn_now_lownload_url.Text = "download(URL)"
$btn_now_lownload_url.Size = New-Object System.Drawing.Size(${BTN_LENGTH}, ${DEFAULT_HEIGHT_SIZE})
$btn_now_lownload_url.Location = ([String]$CRITERIA_WIDTH_3) +", " + ($CRITERIA_HEIGHT_NOW + $HEIGHT_SPACE * 2)


$button_now_Click_download_url = {
    ($sender, $e) = $this, $_
    $parent = ($sender -as [Button]).Parent -as [Form]
    $txt = [TextBox]$parent.Controls[$url_url.Name];
    
    $random_name = Get-Random
    
    Write-Host("[Info] ******************************************")
    Write-Host("[Info] Downloading... [" + $name_save.Text + "]`n")
    
    $nmane_str = $txt_now_save.Text
    $url_str = $txt_now_url.Text
    $save_time_str = $Combo_now_time1.Text + ":" + $Combo_now_time2.Text + ":" + $Combo_now_time3.Text
    Write-Host("$save_time_str")
    try {
        # URLより動画を(.ts)形式でダウンロードする
        streamlink "$url_str" best -o "${current}\tmp\${random_name}.ts" --hls-duration ${save_time_str}  >> .\log\$(Get-Date -UFormat %Y%m%d).log
        
        Write-Host("[Info] comleted to Download ts file(.ts)")

        # (.ts)形式を(.mp4)形式に変換する
        ffmpeg -i ".\tmp\${random_name}.ts" -vcodec copy -acodec copy ".\tmp\${random_name}.mp4"
        
        Write-Host("[Info] completed convert to mp4")

        mv ".\tmp\${random_name}.mp4" .\movie\"$nmane_str.mp4"
        rm .\tmp\${random_name}.ts
        
        Write-Host("[Info] Downloaded... [" + $nmane_str + "]")
        
        [MessageBox]::Show("[Info] downloaded :[" + $nmane_str + "]", "Info", "OK", "Information")

    } catch [Exception] {
        Write-Host $_.Exception.Message
        [MessageBox]::Show($_.Exception.Message + "fail to download :[" + $nmane_str + "]. check [$(Get-Date -UFormat %Y%m%d).log]", "Error", "OK", "Error")
    } finally {
    
    }
}
$btn_now_lownload_url.Add_Click($button_now_Click_download_url)

$now = @($lbl_now_line,$lbl_now_url, $txt_now_url,$btn_now_lownload_url, $obtn_now_extract,$lbl_now_save,$txt_now_save, $lbl_now_save_time, $Combo_now_time1,$lbl_now_save_time1,$Combo_now_time2,$lbl_now_save_time2,$Combo_now_time3,$lbl_now_save_time3)

#-----------------------------------------------------------------------------
$CRITERIA_HEIGHT_CR = $CRITERIA_HEIGHT + 260
# ラベルと入力欄
$lbl_copyright = New-Object Label
$lbl_copyright.Text = "Copyright (c) Yuki-Kikuya, 2019-2021"
$lbl_copyright.Location = "10, " + ($CRITERIA_HEIGHT_CR)
$lbl_copyright.AutoSize = New-Object System.Drawing.Size(200, $DEFAULT_HEIGHT_SIZE)

$f.Controls.AddRange($lbl_copyright)

# -------------------- メニューバーの作成 -------------------------------------
$mainMenu = New-Object System.Windows.Forms.MenuStrip
$f.MainMenuStrip = $mainMenu
$mainMenu.BackColor = "#383c3c"
$mainMenu.forecolor ="white"

#region メインメニューの項目追加
# Fileメニュー - $menuFileh
$menuFile = New-Object System.Windows.Forms.ToolStripMenuItem
$menuFile.Text = "Setting(S)"
$menuFile.BackColor = "black"

#------------------------------------

$menuNewFile1 = New-Object System.Windows.Forms.ToolStripMenuItem
$menuNewFile1.Text = "New"
$menuNewFile1.BackColor = "black"
$menuNewFile1.forecolor ="white"

$menuFile.DropDownItems.Add($menuNewFile1)

$menuNewFile2 = New-Object System.Windows.Forms.ToolStripMenuItem
$menuNewFile2.Text = "Open Explorer"
$menuNewFile2.BackColor = "black"
$menuNewFile2.forecolor ="white"

$menuNewFile2_1 = New-Object System.Windows.Forms.ToolStripMenuItem
$menuNewFile2_1.Text = "Open Save Folder"
$menuNewFile2_1.BackColor = "black"
$menuNewFile2_1.forecolor ="white"

$menuNewFile2_2 = New-Object System.Windows.Forms.ToolStripMenuItem
$menuNewFile2_2.Text = "Open Server Folder"
$menuNewFile2_2.BackColor = "black"
$menuNewFile2_2.forecolor ="white"

$menuNewFile2.DropDownItems.Add($menuNewFile2_1)
$menuNewFile2.DropDownItems.Add($menuNewFile2_2)

$menuFile.DropDownItems.Add($menuNewFile2)

$menuNewFile3 = New-Object System.Windows.Forms.ToolStripMenuItem
$menuNewFile3.Text = "Move Movie Server"
$menuNewFile3.BackColor = "black"
$menuNewFile3.forecolor ="white"

$menuFile.DropDownItems.Add($menuNewFile3)

#-----------------------------------------

# Helpメニュー - $menuFile
$menuSite = New-Object System.Windows.Forms.ToolStripMenuItem
$menuSite.Text = "Site(S)"
$menuSite.BackColor = "black"

$menuSite1 = New-Object System.Windows.Forms.ToolStripMenuItem
$menuSite1.Text = "AbemaTV"
$menuSite1.BackColor = "black"
$menuSite1.forecolor ="white"

$menuSite2 = New-Object System.Windows.Forms.ToolStripMenuItem
$menuSite2.Text = "Dailymotion"
$menuSite2.BackColor = "black"
$menuSite2.forecolor ="white"

$menuSite.DropDownItems.AddRange(@($menuSite1, $menuSite2))

$menuSite1.add_click({
    start ${CHROME_PATH} ${ABEMATV_URL}
})
$menuSite2.add_click({
    start ${CHROME_PATH} ${DAILY_URL}
})

#-----------------------------------------

# Helpメニュー - $menuFile
$menuHelp = New-Object System.Windows.Forms.ToolStripMenuItem
$menuHelp.Text = "Help(H)"
$menuHelp.BackColor = "black"

$mainMenu.Items.AddRange(@($menuFile, $menuSite, $menuHelp))

$menuNewFile1.add_click({
	[System.Windows.Forms.MessageBox]::Show("Menu Open Clicked")
	# フォーム設定
	$f_s = New-Object Form
	$f_s.Text = "Setteing Item Menu"
	$f_s.Size = "470, "+ ($CRITERIA_HEIGHT + 280)
	$f_s.MaximumSize = "470, " + ($CRITERIA_HEIGHT + 280)
	$f_s.BackColor = "black"
	$f_s.forecolor ="white"
	
	
	$f_s.ShowDialog()
})

$menuNewFile2_1.add_click({
	ii ${FOLDER_PATH}\
})

$menuNewFile2_2.add_click({
	ii ${SVR_PATH}\
})

$menuNewFile3.add_click({
	move ${FOLDER_PATH}\*.mp4 ${SVR_PATH} -force
	move ${FOLDER_PATH}\movie\*.mp4 ${SVR_PATH} -force
    move ${FOLDER_PATH}\tmp\*.ts ${SVR_PATH}\tmp -force
    move ${FOLDER_PATH}\tmp\*.mp4 ${SVR_PATH}\tmp -force
})

$f.Controls.Add($mainMenu)
# ------------------------------------------------------------------------------

$f.Controls.AddRange(@($lbl1, $lbl2,$mname, $name_save, $obtn, $btn, $sname, $lbl_line, $lbl_url,$url_url,$lbl_save,$name_save,$btn_download_url,$obtn_extract))
# abema生配信保存用フォーム追加
$f.Controls.AddRange($now)
$f.BackColor = "black"
$f.forecolor ="white"
$f.MaximizeBox = $False
$f.MinimizeBox = $False
$f.FormBorderStyle = "Fixed3D"
$f.ShowDialog()

# コンソールを非表示にする
powershell -WindowStyle Hidden
