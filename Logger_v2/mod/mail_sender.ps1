#��������� ��������� � �����, ���������� ��� �����������, ���������� ��������� �� �����
#
#
#
#�������� ��������� � ����������������� ����� json
$directory = $MyInvocation.MyCommand.Path | split-path -parent
$json_path = $directory + "\config.json"
$Config = Get-Content -Path $json_path | ConvertFrom-Json
if ($Config -eq $null)
{
	exit
}
$stmp_server = $Config.stmp_server
$sender_mail = $Config.sender_mail
$app_password = $Config.app_password
$dest_mail = $Config.dest_mail
$computer_name = $Config.computer_name
if (($stmp_server -eq $null) -or ($sender_mail -eq $null) -or ($app_password -eq $null) `
	-or ($dest_mail -eq $null) -or ($computer_name -eq $null) `
-or ($stmp_server -eq "") -or ($sender_mail -eq "") -or ($app_password -eq "") `
	-or ($dest_mail -eq ""))
{
	exit
}


#��������� � �������� ���������
$CurrentDate = Get-Date -Format 'HH:mm dddd dd/MM/yyyy'
$subject = "@" + $computer_name
$Body = '��������� ������� � ' + $CurrentDate
$Password = $app_password | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object `
-TypeName System.Management.Automation.PSCredential `
-ArgumentList $sender_mail, $Password
#�������� ��������� � ��������� ����������� � ���� ��������
while ($true)
{
	if ((Test-NetConnection -WarningAction SilentlyContinue).PingSucceeded)
	{
		Send-MailMessage `
		-From $sender_mail `
		-To $dest_mail `
		-Subject $subject `
		-Body $Body `
		-Encoding 'UTF8' `
		-SmtpServer $stmp_server -port 587 -UseSsl `
		-Credential $Credential
		break
	}
	else
	{
		sleep -Seconds 5
	}
}
