$conf_filename = "config.json"
$script_filename = "mail_sender.ps1"
$current_scriptname = "Logger_v2.ps1"
$xml_filename = "StatusMailReporter.xml"

#Рабочие папка текущего скрипта
$current_directory = $MyInvocation.MyCommand.Path | split-path -parent
$mod_directory = "$current_directory\mod"


#Проверка прав администратора и запрос в случае отсутствия
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole( `
[Security.Principal.WindowsBuiltInRole] "Administrator")) {
	Start-Process Powershell -ArgumentList "$current_directory\$current_scriptname" -Verb RunAs -ErrorAction Ignore
	exit
}


#Описание задачи
$task_directory = "\"
$task_name = "StatusMailReporter"
$task_description = "Отправка сообщения SMTP о запуске системы или её выходе из спящего режима"
$xml_filename = $task_name + ".xml"

#Расположение скрипта для отправки почты и его конфигурационного файла в системе после распаковки!!!
$dst_directory = "C:\ProgramData\" + $task_name


#Почтовая конфигурация
$stmp_server = ''
$sender_mail = ''
$app_password = ''
$dest_mail = ''

#Ввод отсутствующей почтовой конфигурации
if ($stmp_server -eq ''){
	$stmp_server = Read-Host "Enter STMP server"
}
if ($sender_mail -eq ''){
	$sender_mail = Read-Host "Enter logsender mail"
}
if ($app_password -eq ''){
	$app_password = Read-Host "Enter APP-password"
}
if ($dest_mail -eq ''){
	$dest_mail = Read-Host "Enter the dest_email address"
}



#Проверка на существование задачи с данным именем и её дективация при нахождении
if (Get-ScheduledTask $task_name -ErrorAction Ignore) {
echo "Task will be overwritten"
Unregister-ScheduledTask `
-TaskPath $task_directory `
-TaskName $task_name `
-Confirm:$false
}

#Ввод имени компьютера, который будет отображаться в теме сообщения(при пустой строке тема будет только @)
$computer_name = Read-Host "Enter the computer name(as you wish)"


#Размещение скрипта и конфигурации
if ($dst_directory)
{
	echo "Directory will be overwritten"
}
New-Item -ItemType Directory -Path $dst_directory -Force
Copy-Item -Path "$mod_directory\$script_filename" -Destination "$dst_directory\$script_filename" -Force
New-Item -Path "$dst_directory\$conf_filename" -ItemType File `
-Value "
{`"stmp_server`": `"$stmp_server`",
  `"sender_mail`": `"$sender_mail`",
  `"app_password`": `"$app_password`",
  `"dest_mail`": `"$dest_mail`",
  `"computer_name`": `"$computer_name`"}" -Force

 
  #Регистрация XML файла как задачу  
  Register-ScheduledTask -Xml (Get-Content "$mod_directory\$xml_filename" | out-string) -TaskName $task_name -TaskPath $task_directory