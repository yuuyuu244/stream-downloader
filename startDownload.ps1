# 仕様として、dll の参照追加よりも、using 名前空間の方を先に記載しなくちゃいけない
using namespace System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing



# 環境変数の設定
#$env:Path = $env:Path + ";C:\Program Files By My Self\AbemaTV録画"
$env:Path = $env:Path + ";Z:\30_movie\04_テレビ番組\04_AbemaTV\00_AbemaTV録画"

# ラベルと入力欄
$lbl1 = New-Object Label
$lbl1.Text = "url:"
$lbl1.Location = "10, 22"
$lbl1.AutoSize = $True

# URL入力
$url = New-Object TextBox
$url.Name = "textbox1"
$url.Text = "https://abema.tv/"
$url.Location = "55, 20"
$url.Size = New-Object System.Drawing.Size(250,20)

# ラベルと入力欄
$lbl2 = New-Object Label
$lbl2.Text = "保存名:"
$lbl2.Location = "10, 52"
$lbl2.AutoSize = $True

# 保存先入力
$mname = New-Object TextBox
$mname.Name = "textbox1"
$mname.Text = "タイトルのいれてね"
$mname.Location = "55, 50"
$mname.Size = New-Object System.Drawing.Size(250,20)


# ダウンロードボタン
$btn = New-Object Button
$btn.Text = "ダウンロード"
$btn.Size = "120, 40"
$btn.Location = "10, 100"

# タイトル抽出ボタン
$obtn = New-Object Button
$obtn.Text = "タイトル抽出"
$obtn.Size = "120, 20"
$obtn.Location = "310, 20"
$obtn.Size = New-Object System.Drawing.Size(60,20)

# ボタンのクリック
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
    
    [MessageBox]::Show("「" + $nmane_str + "」をダウンロードしました", "情報", "OK", "Information")
    
}
$btn.Add_Click($button_Click)

# ボタンのクリック
# タイトルを抽出する処理
$button_Click2 = {
    # SiteCollection URL 
    $response = Invoke-WebRequest $url.Text
    # refs:https://docs.microsoft.com/ja-jp/dotnet/api/system.windows.forms.htmldocument?view=netframework-4.8
    # refs:http://winscript.jp/powershell/305
    # refs:http://sloppy-content.blog.jp/archives/12057529.html
    # タイトルを取得
    $mname.Text = $response.ParsedHtml.Title
}
$obtn.Add_Click($button_Click2)


# フォーム
$f = New-Object Form
$f.Text = "Stream downloader"
$f.Size = "380, 240"
$f.Controls.AddRange(@($lbl1, $url, $lbl2, $mname, $btn, $obtn))
$f.ShowDialog()