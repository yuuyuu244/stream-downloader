# https://48idol.net/からダウンロードする方法
# 仕様として、dll の参照追加よりも、using 名前空間の方を先に記載しなくちゃいけない
using namespace System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Open Folder Path
$OPEN_FOLDER_PATH = "C:\Users\user\Downloads"

# Program name
$PROGRAM_NAME = "Stream downloader"

# 環境変数の設定
# streamlinkが使えるようにする
#$env:Path = $env:Path + ";C:\Program Files By My Self\AbemaTV録画"
$env:Path = $env:Path + ";Z:\30_movie\04_テレビ番組\04_AbemaTV\00_AbemaTV録画"

# カレントディレクトリの獲得
$current = Get-Location

# catch句で捕まえられるようにする
# デフォルトでは「終了エラー」しかとらえられず、「継続エラー」が捕まえられない。
$ErrorActionPreference = "Stop"

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
  $CannotUsedFileName = "\/:*?`"><| 　・＆#"
  # 禁止文字(全角記号)
  $UsedFileName = "￥／：＊？`”＞＜｜__．&＃"

  for ($i = 0; $i -lt $UsedFileName.Length; $i++) {
    $FileName = $FileName.Replace($CannotUsedFileName[$i], $UsedFileName[$i])
  }
  return $FileName
}

# ------------------------------------------------------------------
# ファイル名の長さチェック
# 引数  ：FileName ファイル名
# @author : Yuki-Kikuya
# ------------------------------------------------------------------
function CheckFileName([String]$FileName){
    $MAX_FILE_NAME_LENGTH = 150
    if ($FileName.Length -gt $MAX_FILE_NAME_LENGTH) {
        # 文字列の前から255文字分だけ抽出
        $FileName= $FileName.Substring(0,$MAX_FILE_NAME_LENGTH)
        Write-Host("文字列縮小")
    } else {
        Write-Host("no modify string of file name")
    }
    return $FileName
}

# ------------------------------------------------------
# ------------ m3u8ファイルダウンロード -----------------

# ラベルと入力欄
$lbl1 = New-Object Label
$lbl1.Text = "m3u8File:"
$lbl1.Location = "10, 22"
$lbl1.AutoSize = $True

$mname = New-Object TextBox
$mname.Name = "textbox1"
$mname.Text = "select m3u8 file"
$mname.Location = "75, 20"
$mname.Size = New-Object System.Drawing.Size(250,20)

# ボタン(開く...)の設定
$obtn = New-Object Button
$obtn.Text = "Open..."
$obtn.Size = "120, 20"
$obtn.Location = "330, 20"
$obtn.Size = New-Object System.Drawing.Size(40,20)

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
$lbl2.Location = "10, 52"
$lbl2.AutoSize = $True

# TextBox of save name of m3u8
$sname = New-Object TextBox
$sname.Name = "textbox1"
$sname.Text = "input title"
$sname.Location = "75, 50"
$sname.Size = New-Object System.Drawing.Size(250,20)

# download button of m3u8
$btn = New-Object Button
$btn.Text = "download(m3u8)"
$btn.Size = "120, 20"
$btn.Location = "330, 50"

# on click listener of download button of m3u8
$button_Click2 = {
    $m3u8 = $mname.Text
    $output = $sname.Text
    try {
        ffmpeg -protocol_whitelist file,http,https,tcp,tls,crypto -i "${m3u8}" -movflags faststart -c copy "${output}.mp4"
        Write-Host("Downloaded ${output}.mp4")
        [MessageBox]::Show("downloaded :[" + $output + "]", "Info", "OK", "Information")
    } catch [Exception] {
        [MessageBox]::Show("fail to download :[" + $output + "]", "Error", "OK", "Error")
    } finally {
    }
}
$btn.Add_Click($button_Click2)


#-------------------------------------------------------
# ラベル(区切り線)
$lbl_line = New-Object Label
$lbl_line.Text = ""
$lbl_line.Location = "0, 85"
$lbl_line.Size = "450, 1"
$lbl_line.AutoSize = $False
$lbl_line.BackColor = "white"
$lbl_line.ForeColor = "White"
$lbl_line.BorderStyle = "FixedSingle"

# ------------------------------------------------------
# -------------- URL download --------------------------
# ラベルと入力欄
$lbl_url = New-Object Label
$lbl_url.Text = "url:"
$lbl_url.Location = "10, 102"
$lbl_url.AutoSize = $True

# TextBox of Input URL of url download
$url_url = New-Object TextBox
# Default string(set abemaTV URL)
$url_url.Name = "textbox1"
$url_url.Text = "https://abema.tv/"
$url_url.Location = "75, 100"
$url_url.Size = New-Object System.Drawing.Size(250,20)

# label of save name of url download
$lbl_save = New-Object Label
$lbl_save.Text = "saveName:"
$lbl_save.Location = "10, 132"
$lbl_save.AutoSize = $True

# TextBox of save name of url download
$name_save = New-Object TextBox
$name_save.Name = "textbox1"
$name_save.Text = "input name"
$name_save.Location = "75, 130"
$name_save.Size = New-Object System.Drawing.Size(250,20)


# download button of url download
$btn_download_url = New-Object Button
$btn_download_url.Text = "download(URL)"
$btn_download_url.Size = "120, 20"
$btn_download_url.Location = "330, 130"

# ボタンのクリック
$button_Click_download_url = {
    ($sender, $e) = $this, $_
    $parent = ($sender -as [Button]).Parent -as [Form]
    $txt = [TextBox]$parent.Controls[$url_url.Name];
    
    $random_name = Get-Random
    
    Write-Host("******************************************")
    Write-Host("Downloading... [" + $name_save.Text + "]`n")
    
    $nmane_str = $name_save.Text
    $url_str = $url_url.Text
    try {
        # URLより動画を(.ts)形式でダウンロードする
        streamlink "$url_str" best -o "${current}\${random_name}.ts" >> .\$(Get-Date -UFormat %Y%m%d).log
        # (.ts)形式を(.mp4)形式に変換する
        ffmpeg -i "${random_name}.ts" -vcodec copy -acodec copy "${random_name}.mp4"

        mv .\"$random_name.mp4" .\"$nmane_str.mp4"
        rm .\${random_name}.ts
        Write-Host("Downloaded... [" + $nmane_str + "]")
        [MessageBox]::Show("downloaded :[" + $nmane_str + "]", "Info", "OK", "Information")

    } catch [Exception] {
        [MessageBox]::Show("fail to download :[" + $nmane_str + "]", "Error", "OK", "Error")

    } finally {
    
    }
}
$btn_download_url.Add_Click($button_Click_download_url)

# タイトル抽出ボタン
$obtn_extract = New-Object Button
$obtn_extract.Text = "extra title"
$obtn_extract.Size = "120, 20"
$obtn_extract.Location = "330, 100"
$obtn_extract.Size = New-Object System.Drawing.Size(60,20)
# ボタンのクリック
# タイトルを抽出する処理
$button_Click_extract = {
    # SiteCollection URL 
    $response = Invoke-WebRequest $url_url.Text
    # refs:https://docs.microsoft.com/ja-jp/dotnet/api/system.windows.forms.htmldocument?view=netframework-4.8
    # refs:http://winscript.jp/powershell/305
    # refs:http://sloppy-content.blog.jp/archives/12057529.html
    # タイトルを取得
    $name_save.Text = ConvertTo-UsedFileName($response.ParsedHtml.Title)
}
$obtn_extract.Add_Click($button_Click_extract)

# フォーム設定
$f = New-Object Form
$f.Text = $PROGRAM_NAME
$f.Size = "450, 240"
$f.Controls.AddRange(@($lbl1, $lbl2,$mname, $name_save, $obtn, $btn, $sname, $lbl_line, $lbl_url,$url_url,$lbl_save,$name_save,$btn_download_url,$obtn_extract))
$f.BackColor = "black"
$f.forecolor ="white"
$f.ShowDialog()
