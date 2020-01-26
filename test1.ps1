Write-Host($(Get-Date -UFormat %Y%m%d))

Set-StrictMode -version Latest
 
#.NET Framework�̃_�C�A���O�֘A�I�u�W�F�N�g�̎�荞��
Add-Type -assemblyName System.Windows.Forms

#�t�@�C���I���_�C�A���O�̃I�u�W�F�N�g�擾
$dialog = New-Object System.Windows.Forms.OpenFileDialog
 
#�t�B���^�����̐ݒ�
$dialog.Filter = 'Text Files|*.txt|Csv Files|*.csv|All Files|*.*'
 
#�f�t�H���g�I���f�B���N�g���̐ݒ�
$dialog.InitialDirectory = '.'
 
if ($dialog.ShowDialog() -eq "OK") {
    "�I�������t�@�C��`n`"" + $dialog.FileName + '"'
} else {
    '�I���Ȃ��B'
}