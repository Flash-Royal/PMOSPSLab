$rep = Read-Host "Введите путь к папке, где вы хотите видеть отчет о дублированных файлов"
$dir = Read-Host "Введите путь к дереву каталогов, в котором хотите найти дублирующие файлы"
Write-Host "Подождите пожалуйста, идет обработка файлов"
cd $rep
del Report.txt
$c = New-Item FilesNames.txt
$b = New-Item FilesHashs.txt 
$a = New-Item Report.txt
$repa = $rep + "\FilesNames.txt"
$repb = $rep + "\FilesHashs.txt"
$repr = $rep + "\Report.txt"
cd $dir
foreach ($NameFile in (Get-ChildItem -recurse -attributes A -Exclude "FilesNames.txt","FilesHashs.txt","Report.txt" |where FullName -NotLike "C:\Windows\*" | Select DirectoryName,Name)) { [string]::Concat($NameFile.DirectoryName,'\',$NameFile.Name) | Out-File $repa -Append }
$Files = Get-Content -LiteralPath $repa
$len = $Files.Length
foreach ($Hashs in (Get-FileHash $Files)) {$Hashs.Hash | Out-File $repb -Append}
$Hash = Get-Content -LiteralPath $repb
$Text = "OriginalFile: "
do{
    $choice = Read-Host "Хотите ли вы удалить все дублированные файлы автоматически? [y/n]"
    if ($choice -eq 'y'){
        $Text2 = "    Deleted SecondaryFile: "
        for ($i = $Hash.Length - 1; $i -ge 1; $i--) {
            $len1 = $len - $i
            $l = 0
            $flag = 0
            if ($i -ge 1) {
                for ($k = $Hash.Length - 1; $k -ge $i + 1; $k--) {
                    if ($Hash[$i] -eq $Hash[$k]) {
                        $flag = 1 
                        break
                    }
                }
            }
            if ($flag -eq 1) {
                continue
            }

            for ($j = $i - 1; $j -ge 0; $j--) {
                if ($Hash[$i] -eq $Hash[$j]) {
                    if ($l -eq 0) {
                        $Text + $Files[$i] | Out-File $repr -Append 
                    }
                    $Text2 + $Files[$j] | Out-File $repr -Append
                    del $Files[$j]
                    $l++
                }
            }
            Write-Host "Проверенно файлов: " $len1 " из " $len
        }
    }
    elseif ($choice -eq "n"){
        $Text2 = "    SecondaryFile: "
        $Text3 = "    Deleted SecondaryFile: "
        for ($i = $Hash.Length - 1; $i -ge 1; $i--) {
            $len1 = $len - $i
            $l = 0
            $flag = 0
            if ($i -ge 1) {
                for ($k = $Hash.Length - 1; $k -ge $i + 1; $k--) {
                    if ($Hash[$i] -eq $Hash[$k]) {
                        $flag = 1 
                        break
                    }
                }
            }
            if ($flag -eq 1) {
                continue
            }

            for ($j = $i - 1; $j -ge 0; $j--) {
                if ($Hash[$i] -eq $Hash[$j]) {
                    if ($l -eq 0) {
                        $Text + $Files[$i] | Out-File $repr -Append 
                    }
                    Write-Host "Оригинальный файл: " $Files[$i]
                    Write-Host "    Дублированный файл: " $Files[$j]
                    do{
                        $choice2 = Read-Host "    Хотите ли вы удалить этот дублированный файл? [y/n]"
                        if ($choice2 -eq 'y'){
                            $Text3 + $Files[$j] | Out-File $repr -Append
                            del $Files[$j]
                        }
                        elseif ($choice2 -eq 'n'){
                            $Text2 + $Files[$j] | Out-File $repr -Append
                        }
                        else{
                            Read-Host "Вы ошиблись клавишей. Нажмите Enter и выберите нужную клавишу!"
                        }
                    }while (($choice2 -ne 'y') -and ($choice2 -ne 'n'))
                    $l++
                }
            }
            Write-Host "Проверенно файлов: " $len1 " из " $len
        }
    }
    else{
        Read-Host "Вы ошиблись клавишей. Нажмите Enter и выберите нужную клавишу!"
    }
}while (($choice -ne 'y') -and ($choice -ne 'n'))
cd $rep
del FilesNames.txt
del FilesHashs.txt
