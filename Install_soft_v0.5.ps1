#Если окно запущено без прав администратора перезапускаем
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {   
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}
Add-Type -AssemblyName System.Windows.Forms #Подключаем то, с помощью чего будем рисовать нашу форму
Add-Type -AssemblyName System.Drawing #Размеры форм
$softtable = @{ #Сопостовление Отображаемых и реальных имен ПО
    'Office 365 Business' = 'office365business'
    'Office 365 ProPlus'  = 'office365proplus'
    'Slack'               = 'slack'
    'Skype'               = 'skype'
    'NAPS2'               = 'naps2'
    'Adobe Reader'        = 'adobereader'
    'Google Chrome'       = 'googlechrome'
    '7-Zip'               = '7zip.install'
    'TeamViewer'          = 'teamviewer'
    'Telegram'            = 'telegram'
    'Не устанавливать'    = ''
}
If (Test-Path -Path "$env:ProgramData\Chocolatey") { #Если установлен chocolatey то идем дальше
     #Создаем окно
    
    #Показываем текущую политику выполнения сценариев
    Write-Host(Get-ExecutionPolicy)

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Установка ПО'
    $form.Size = New-Object System.Drawing.Size(610, 300)
    $form.StartPosition = 'CenterScreen'
    #Кнопка старта
    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Point(10, 210)
    $OKButton.Size = New-Object System.Drawing.Size(570, 25)
    $OKButton.Text = 'Установить'
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $OKButton
    $form.Controls.Add($OKButton)
    #Надпись "Какую версию офиса устанавливаем?"
    $ov = New-Object System.Windows.Forms.Label
    $ov.Location = New-Object System.Drawing.Point(300, 120)
    $ov.Size = New-Object System.Drawing.Size(280, 20)
    $ov.Text = 'Какую версию офиса устанавливаем?'
    $form.Controls.Add($ov)
    #Выбор версии офиса
    $officeversion = New-Object System.Windows.Forms.ListBox
    $officeversion.Location = New-Object System.Drawing.Point(300, 145)
    $officeversion.Size = New-Object System.Drawing.Size(280, 20)
    $officeversion.Height = 60
    [void] $officeversion.Items.Add('Office 365 Business')
    [void] $officeversion.Items.Add('Office 365 ProPlus')
    [void] $officeversion.Items.Add('Не устанавливать')
    $officeversion.SelectedIndex = 2
    $form.Controls.Add($officeversion)

    #Надпись "Какой софт устанавливаем?"
    $ov = New-Object System.Windows.Forms.Label
    $ov.Location = New-Object System.Drawing.Point(10, 10)
    $ov.Size = New-Object System.Drawing.Size(280, 20)
    $ov.Text = 'Какой софт устанавливаем?'
    $form.Controls.Add($ov)
    #Выбор ПО
    $softbox = New-Object System.Windows.Forms.CheckedListBox
    [void] $softbox.Items.Add("Выбрать все")
    [void] $softbox.Items.Add("Slack")
    [void] $softbox.Items.Add("NAPS2")
    [void] $softbox.Items.AddRange("Skype")
    [void] $softbox.Items.AddRange("Adobe Reader")
    [void] $softbox.Items.AddRange("Google Chrome")
    [void] $softbox.Items.AddRange("7-Zip")
    [void] $softbox.Items.AddRange("TeamViewer")
    [void] $softbox.Items.AddRange("Telegram")
    $softbox.CheckOnClick = $true
    $softbox.Location = New-Object System.Drawing.Point(10, 40)
    $softbox.Size = New-Object System.Drawing.Size(280, 20)
    $softbox.Height = 170
    $form.Controls.Add($softbox)
    #Выбрать все
    $softbox.Add_Click( {

            If ($This.SelectedItem -eq 'Выбрать все') {

                For ($i = 1; $i -lt $softbox.Items.count; $i++) {

                    $softbox.SetItemchecked($i, $True)

                }

            }

        })
    #Лого
    $logo = New-Object System.Windows.Forms.PictureBox
    $logo.Load('/path_icon.png') #Пришлось затереть корпоративный логтип
    $logo.Location = New-Object System.Drawing.Point(400, 40)
    $form.Controls.add($logo)
    $form.Topmost = $true

    $result1 = $form.ShowDialog()
    if ($result1 -eq [System.Windows.Forms.DialogResult]::OK) {
        $x = $softtable[$softbox.CheckedItems] + $softtable[$officeversion.SelectedItems]
        choco install -y $x
    }
}
Else { #Если не установлен то устанавливаем
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments #Перезпускаем скрипт с правами админа
}