#Считывает параметры с файла, созданного при регистрации, отправляет сообщение на почту
#
#
#
#Получить настройки с конфигурационного файла json
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
$test_connection_address = $Config.test_connection_address
if (($stmp_server -eq $null) -or ($sender_mail -eq $null) -or ($app_password -eq $null) `
	-or ($dest_mail -eq $null) -or ($computer_name -eq $null) -or ($test_connection_address -eq $null) `
-or ($stmp_server -eq "") -or ($sender_mail -eq "") -or ($app_password -eq "") `
	-or ($dest_mail -eq "") -or ($test_connection_address -eq ""))
{
	exit
}


#Настройка и отправка сообщения
$CurrentDate = Get-Date -Format 'HH:mm dddd dd/MM/yyyy'
$subject = "@" + $computer_name
$Body = 'Компьютер включён в ' + $CurrentDate
$Password = $app_password | ConvertTo-SecureString -AsPlainText -Force
$Credential = New-Object `
-TypeName System.Management.Automation.PSCredential `
-ArgumentList $sender_mail, $Password
#Отправка сообщения с ожиданием подключения к сети интернет
while ($true)
{
	if ((Test-NetConnection -ComputerName $test_connection_address -WarningAction SilentlyContinue).PingSucceeded)
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
