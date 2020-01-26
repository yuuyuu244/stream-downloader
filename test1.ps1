Write-Host($(Get-Date -UFormat %Y%m%d))

Set-StrictMode -version Latest
 
#.NET Frameworkのダイアログ関連オブジェクトの取り込み
Add-Type -assemblyName System.Windows.Forms

#ファイル選択ダイアログのオブジェクト取得
$dialog = New-Object System.Windows.Forms.OpenFileDialog
 
#フィルタ条件の設定
$dialog.Filter = 'Text Files|*.txt|Csv Files|*.csv|All Files|*.*'
 
#デフォルト選択ディレクトリの設定
$dialog.InitialDirectory = '.'
 
if ($dialog.ShowDialog() -eq "OK") {
    "選択したファイル`n`"" + $dialog.FileName + '"'
} else {
    '選択なし。'
}