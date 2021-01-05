# https://48idol.net/����_�E�����[�h������@
# �d�l�Ƃ��āAdll �̎Q�ƒǉ������Ausing ���O��Ԃ̕����ɋL�ڂ��Ȃ����Ⴂ���Ȃ�
using namespace System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# �J�����g�f�B���N�g���̊l��
# ���ɕύX����K�v�Ȃ�
cd "C:\Program Files Made BySelf\streamDownloader"
$current = Get-Location

# Open Folder Path
# �_�E�����[�h����w��
$OPEN_FOLDER_PATH = "${current}\movie"

# ���ϐ��̐ݒ�
# streamlink���g����悤�ɂ���
# �{�A�v���P�[�V�������_�E�����[�h���ꂽ�g�b�v�f�B���N�g�����w��
$DOWNLOAD_DIR = "${current}"

$env:Path = $env:Path + ";${DOWNLOAD_DIR}"

# Program name
# ���ɕύX����K�v�Ȃ�
$PROGRAM_NAME = "Stream downloader"

# catch��ŕ߂܂�����悤�ɂ���
# �f�t�H���g�ł́u�I���G���[�v�����Ƃ炦��ꂸ�A�u�p���G���[�v���߂܂����Ȃ��B
# ���ɕύX����K�v�Ȃ�
$ErrorActionPreference = "Stop"

# ------------------------------------------------------------------
# Windows�Ńt�@�C�����Ɏg�p�ł��Ȃ��֎~������S�p�ɕϊ�����
# �֐����FConvertTo-UsedFileName
# ����  �FFileName �t�@�C����
# �߂�l�F�ϊ���̃t�@�C����
# @author : Yuki-Kikuya
# refs : http://assembler0x.blogspot.com/2013/08/windows.html
# ------------------------------------------------------------------
function ConvertTo-UsedFileName([String]$FileName){
  # �֎~����(���p�L��)
  $CannotUsedFileName = '\/:*?`"><| �@�E��#[]'
  # �֎~����(�S�p�L��)
  $UsedFileName = '���^�F���H`�h�����b__�D&���m�n'

  for ($i = 0; $i -lt $UsedFileName.Length; $i++) {
    $FileName = $FileName.Replace($CannotUsedFileName[$i], $UsedFileName[$i])
  }
  Write-Host("rename file name : ${FileName} ")
  return $FileName
}

# ------------------------------------------------------------------
# �t�@�C�����̒����`�F�b�N
# ����  �FFileName �t�@�C����
# @author : Yuki-Kikuya
# ------------------------------------------------------------------
function CheckFileName([String]$FileName){
    $MAX_FILE_NAME_LENGTH = 150
    if ($FileName.Length -gt $MAX_FILE_NAME_LENGTH) {
        # ������̑O����255�������������o
        $FileName= $FileName.Substring(0,$MAX_FILE_NAME_LENGTH)
        Write-Host("������k��")
    } else {
        Write-Host("no modify string of file name")
    }
    return $FileName
}

function ExtraTitle([String]$url){
    # SiteCollection URL 
    $response = Invoke-WebRequest $url
    # refs:https://docs.microsoft.com/ja-jp/dotnet/api/system.windows.forms.htmldocument?view=netframework-4.8
    # refs:http://winscript.jp/powershell/305
    # refs:http://sloppy-content.blog.jp/archives/12057529.html
    # �^�C�g�����擾
    return CheckFileName(ConvertTo-UsedFileName($response.ParsedHtml.Title))
}

# �A�x�}���z�M�p�̃^�C�g���擾
function ExtraTitleNow([String]$url){
    # SiteCollection URL 
    $response = Invoke-WebRequest $url -OutFile "a.html"
    # refs:https://docs.microsoft.com/ja-jp/dotnet/api/system.windows.forms.htmldocument?view=netframework-4.8
    # refs:http://winscript.jp/powershell/305
    # refs:http://sloppy-content.blog.jp/archives/12057529.html
    # �^�C�g�����擾
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

# -------------------------------------------------------
# ------------ m3u8�t�@�C���_�E�����[�h -----------------
# -------------------------------------------------------

# ���x���Ɠ��͗�
$lbl1 = New-Object Label
$lbl1.Text = "m3u8File:"
$lbl1.Location = "10, 22"
$lbl1.AutoSize = $True

$mname = New-Object TextBox
$mname.Name = "textbox1"
$mname.Text = "select m3u8 file"
$mname.Location = "75, 20"
$mname.Size = New-Object System.Drawing.Size(250,20)

# �{�^��(�J��...)�̐ݒ�
$obtn = New-Object Button
$obtn.Text = "Open...  "
$obtn.Size = New-Object System.Drawing.Size(110,20)
$obtn.Location = "330, 20"


# �t�@�C���I���{�^��
$button_Click = {
    #�t�@�C���I���_�C�A���O�̃I�u�W�F�N�g�擾
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
     
    #�t�B���^�����̐ݒ�
    $dialog.Filter = 'm3u8 Files|*.m3u8|Text Files|*.txt|Csv Files|*.csv|All Files|*.*'
     
    #�f�t�H���g�I���f�B���N�g���̐ݒ�
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
        "�I�������t�@�C��`n`"" + $dialog.FileName + '"'
    } else {
        '�I���Ȃ��B'
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
$btn.Size = New-Object System.Drawing.Size(110,20)
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
        [MessageBox]::Show("fail to download :[" + $output + "]. check [$(Get-Date -UFormat %Y%m%d).log]", "Error", "OK", "Error")
    } finally {
    }
}
$btn.Add_Click($button_Click2)


#-------------------------------------------------------
# ���x��(��؂��)
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
# ------------------------------------------------------

# ���x���Ɠ��͗�
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
$btn_download_url.Size = New-Object System.Drawing.Size(110,20)
$btn_download_url.Location = "330, 130"

# �{�^���̃N���b�N
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
        # URL��蓮���(.ts)�`���Ń_�E�����[�h����
        streamlink "$url_str" best -o "${current}\tmp\${random_name}.ts" >> .\log\$(Get-Date -UFormat %Y%m%d).log
        
        Write-Host("comleted to Download")

        # (.ts)�`����(.mp4)�`���ɕϊ�����
        ffmpeg -i ".\tmp\${random_name}.ts" -vcodec copy -acodec copy ".\tmp\${random_name}.mp4"
        
        Write-Host("completed convert to mp4")

        mv ".\tmp\${random_name}.mp4" .\movie\"$nmane_str.mp4"
        rm .\tmp\${random_name}.ts
        
        Write-Host("Downloaded... [" + $nmane_str + "]")
        
        [MessageBox]::Show("downloaded :[" + $nmane_str + "]", "Info", "OK", "Information")

    } catch [Exception] {
        [MessageBox]::Show($_.Exception.Message + "fail to download :[" + $nmane_str + "]. check [$(Get-Date -UFormat %Y%m%d).log]", "Error", "OK", "Error")
    } finally {
    
    }
}
$btn_download_url.Add_Click($button_Click_download_url)

# �^�C�g�����o�{�^��
$obtn_extract = New-Object Button
$obtn_extract.Text = "extra title"
$obtn_extract.Size = New-Object System.Drawing.Size(110,20)
$obtn_extract.Location = "330, 100"

# �{�^���̃N���b�N
# �^�C�g���𒊏o���鏈��
$button_Click_extract = {
    # �^�C�g�����擾
    $name_save.Text = ExtraTitle($url_url.Text)
}
$obtn_extract.Add_Click($button_Click_extract)


# ----------------------------------------------------
# ------------ abema���z�M�ۑ� -----------------------
# ----------------------------------------------------

# ���x��(��؂��)
$lbl_now_line = New-Object Label
$lbl_now_line.Text = ""
$lbl_now_line.Location = "0, 162"
$lbl_now_line.Size = "450, 1"
$lbl_now_line.AutoSize = $False
$lbl_now_line.BackColor = "white"
$lbl_now_line.ForeColor = "White"
$lbl_now_line.BorderStyle = "FixedSingle"

# ���x���Ɠ��͗�
$lbl_now_url = New-Object Label
$lbl_now_url.Text = "AbemaNow:"
$lbl_now_url.Location = "10, 172"
$lbl_now_url.AutoSize = $True

# TextBox of Input URL of url download
$txt_now_url = New-Object TextBox
# Default string(set abemaTV URL)
$txt_now_url.Name = "textbox1"
$txt_now_url.Text = "https://abema.tv/now-on-air/"
$txt_now_url.Location = "75, 170"
$txt_now_url.Size = New-Object System.Drawing.Size(250,20)

# �^�C�g�����o�{�^��
$obtn_now_extract = New-Object Button
$obtn_now_extract.Text = "extra title"
$obtn_now_extract.Size = New-Object System.Drawing.Size(110,20)
$obtn_now_extract.Location = "330, 170"

# label of save name of url download
$lbl_now_save = New-Object Label
$lbl_now_save.Text = "saveName:"
$lbl_now_save.Location = "10, 202"
$lbl_now_save.AutoSize = $True

# TextBox of save name of url download
$txt_now_save = New-Object TextBox
$txt_now_save.Name = "textbox1"
$txt_now_save.Text = "input name"
$txt_now_save.Location = "75, 200"
$txt_now_save.Size = New-Object System.Drawing.Size(250,20)

$button_now_Click_extract = {
    # �^�C�g�����擾
    $txt_now_save.Text = ExtraTitleNow($txt_now_url.Text)
}
$obtn_now_extract.Add_Click($button_now_Click_extract)

# download button of url download
$btn_now_lownload_url = New-Object Button
$btn_now_lownload_url.Text = "download(URL)"
$btn_now_lownload_url.Size = New-Object System.Drawing.Size(110,20)
$btn_now_lownload_url.Location = "330, 200"


$button_now_Click_download_url = {
    ($sender, $e) = $this, $_
    $parent = ($sender -as [Button]).Parent -as [Form]
    $txt = [TextBox]$parent.Controls[$url_url.Name];
    
    $random_name = Get-Random
    
    Write-Host("******************************************")
    Write-Host("Downloading... [" + $name_save.Text + "]`n")
    
    $nmane_str = $name_save.Text
    $url_str = $url_url.Text
    try {
        # URL��蓮���(.ts)�`���Ń_�E�����[�h����
        streamlink "$url_str" best -o "${current}\tmp\${random_name}.ts" >> .\log\$(Get-Date -UFormat %Y%m%d).log
        
        Write-Host("comleted to Download")

        # (.ts)�`����(.mp4)�`���ɕϊ�����
        ffmpeg -i ".\tmp\${random_name}.ts" -vcodec copy -acodec copy ".\tmp\${random_name}.mp4"
        
        Write-Host("completed convert to mp4")

        mv ".\tmp\${random_name}.mp4" .\movie\"$nmane_str.mp4"
        rm .\tmp\${random_name}.ts
        
        Write-Host("Downloaded... [" + $nmane_str + "]")
        
        [MessageBox]::Show("downloaded :[" + $nmane_str + "]", "Info", "OK", "Information")

    } catch [Exception] {
        [MessageBox]::Show($_.Exception.Message + "fail to download :[" + $nmane_str + "]. check [$(Get-Date -UFormat %Y%m%d).log]", "Error", "OK", "Error")
    } finally {
    
    }
}
$btn_now_lownload_url.Add_Click($button_now_Click_download_url)

$now = @($lbl_now_line,$lbl_now_url, $txt_now_url,$btn_now_lownload_url, $obtn_now_extract,$lbl_now_save,$txt_now_save)

#---------------------------------------------------
# �t�H�[���ݒ�
$f = New-Object Form
$f.Text = $PROGRAM_NAME
$f.Size = "470, 280"
$f.MaximumSize = "470, 280"
$f.Controls.AddRange(@($lbl1, $lbl2,$mname, $name_save, $obtn, $btn, $sname, $lbl_line, $lbl_url,$url_url,$lbl_save,$name_save,$btn_download_url,$obtn_extract))
# abema���z�M�ۑ��p�t�H�[���ǉ�
$f.Controls.AddRange($now)
$f.BackColor = "black"
$f.forecolor ="white"
$f.MaximizeBox = $False
$f.MinimizeBox = $False
$f.FormBorderStyle = "Fixed3D"
$f.ShowDialog()
