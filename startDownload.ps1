# �d�l�Ƃ��āAdll �̎Q�ƒǉ������Ausing ���O��Ԃ̕����ɋL�ڂ��Ȃ����Ⴂ���Ȃ�
using namespace System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing



# ���ϐ��̐ݒ�
#$env:Path = $env:Path + ";C:\Program Files By My Self\AbemaTV�^��"
$env:Path = $env:Path + ";Z:\30_movie\04_�e���r�ԑg\04_AbemaTV\00_AbemaTV�^��"

# ���x���Ɠ��͗�
$lbl1 = New-Object Label
$lbl1.Text = "url:"
$lbl1.Location = "10, 22"
$lbl1.AutoSize = $True

# URL����
$url = New-Object TextBox
$url.Name = "textbox1"
$url.Text = "https://abema.tv/"
$url.Location = "55, 20"
$url.Size = New-Object System.Drawing.Size(250,20)

# ���x���Ɠ��͗�
$lbl2 = New-Object Label
$lbl2.Text = "�ۑ���:"
$lbl2.Location = "10, 52"
$lbl2.AutoSize = $True

# �ۑ������
$mname = New-Object TextBox
$mname.Name = "textbox1"
$mname.Text = "�^�C�g���̂���Ă�"
$mname.Location = "55, 50"
$mname.Size = New-Object System.Drawing.Size(250,20)


# �_�E�����[�h�{�^��
$btn = New-Object Button
$btn.Text = "�_�E�����[�h"
$btn.Size = "120, 40"
$btn.Location = "10, 100"

# �^�C�g�����o�{�^��
$obtn = New-Object Button
$obtn.Text = "�^�C�g�����o"
$obtn.Size = "120, 20"
$obtn.Location = "310, 20"
$obtn.Size = New-Object System.Drawing.Size(60,20)

# �{�^���̃N���b�N
$button_Click = {
    ($sender, $e) = $this, $_
    $parent = ($sender -as [Button]).Parent -as [Form]
    $txt = [TextBox]$parent.Controls[$url.Name];
    
    $random_name = Get-Random
    
    Write-Host("***********************************************")
    Write-Host("************** Downloading... " + $mname.Text + " ************`n")
    
    streamlink $url.Text best -o "${random_name}.ts" >> .\$(Get-Date -UFormat %Y%m%d).log
    ffmpeg -i "${random_name}.ts" -vcodec copy -acodec copy "${random_name}.mp4"
    $nmane_str = $mname.Text
    mv .\"$random_name.mp4" .\"$nmane_str.mp4"
    rm .\${random_name}.ts
    Write-Host("Downloaded... " + $nmane_str)
    
    [MessageBox]::Show("�u" + $nmane_str + "�v���_�E�����[�h���܂���", "���", "OK", "Information")
    
}
$btn.Add_Click($button_Click)

# �{�^���̃N���b�N
# �^�C�g���𒊏o���鏈��
$button_Click2 = {
    # SiteCollection URL 
    $response = Invoke-WebRequest $url.Text
    # refs:https://docs.microsoft.com/ja-jp/dotnet/api/system.windows.forms.htmldocument?view=netframework-4.8
    # refs:http://winscript.jp/powershell/305
    # refs:http://sloppy-content.blog.jp/archives/12057529.html
    # �^�C�g�����擾
    $mname.Text = $response.ParsedHtml.Title
}
$obtn.Add_Click($button_Click2)


# �t�H�[��
$f = New-Object Form
$f.Text = "Stream downloader"
$f.Size = "380, 240"
$f.Controls.AddRange(@($lbl1, $url, $lbl2, $mname, $btn, $obtn))
$f.ShowDialog()