$rep = Read-Host "Введите путь к папке, где вы хотите видеть отчет о дублированных файлов"
$dir = Read-Host "Введите путь к дереву каталогов, в котором хотите найти дублирующие файлы"
cd $rep
del Report.txt
$c = New-Item FilesNames.txt
$b = New-Item FilesHashs.txt 
$a = New-Item Report.txt
$d = New-Item DuplFileList.txt
$l = New-Item NumOrigFile.txt
$repa = $rep + "\FilesNames.txt"
$repb = $rep + "\FilesHashs.txt"
$repd = $rep + "\DuplFileList.txt"
$repr = $rep + "\Report.txt"
$repl = $rep + "\NumOrigFile.txt"
cd $dir
$NameFiles = Get-ChildItem -Path $dir -Recurs -attributes !D+A+!S+!R | Where-Object { ($_.Name -ne "FilesNames.txt") -and ($_.Name -ne "FilesHashs.txt") -and ($_.Name -ne "Report.txt") -and ($_.Name -ne "DuplFileList.txt")} | Where DirectoryName -NotLike "*Windows*"
$lenFiles = $NameFiles.Length 
$l2 = 0
for ($i = 0; $i -le $lenFiles - 1; $i++){ 
    $flag = 0
    $File = [string]::Concat($NameFiles[$i].DirectoryName,'\',$NameFiles[$i].Name) 
    $Files = Get-Content -LiteralPath $repa
    if ($l2 -le 1){
        $len = $l2
        $l2++
    }
    else{
        $len = $Files.Length
    }

    $Hash = Get-FileHash $File
    $Hash = $Hash.Hash 
    $Hashs = Get-Content -LiteralPath $repb
    if ($len -eq 0){ 
        $File | Out-File $repa -Append
        $Hash | Out-File $repb -Append
        Write-Host "Обработано " ($i + 1) " из " $lenFiles " файлов. "
        continue
    }
    for ($j = $len - 1; $j -ge 0; $j--){
        if ($Hash -eq $Hashs[$j]){
            $File | Out-File $repd -Append
            $j | Out-File $repl -Append
            $flag = 1
            break
        }
    }
    if ($flag -eq 0){
        $File | Out-File $repa -Append
        $Hash | Out-File $repb -Append
    }
    Write-Host "Обработано " ($i + 1) " из " $lenFiles " файлов. "
}
$DupFiles = Get-Content -LiteralPath $repd
$lenDup = $DupFiles | Measure-Object -Line
$lenDup =$lenDup.Lines
$indexOrigFiles = Get-Content -LiteralPath $repl
$Files = Get-Content -LiteralPath $repa
Write-Host "Найдено " $lenDup " файлов. "
if ($lenDup -ne 0){
    do{ 
        $choice = Read-Host "Хотите ли вы удалить все дублированные файлы автоматически? [y/n]"
        if (($choice -ne 'y') -and ($choice -ne 'n')){
            Write-Host "Попробуйте ввести снова!"
        }
    }while (($choice -ne 'y') -and ($choice -ne 'n'))
    $Text = "OriginalFile: "
    $Text2 = "    SecondaryFile: "
    $Text3 = "    Deleted SecondaryFile: "
    if ($choice -eq 'y'){
        for ($i = 0; $i -le ($lenDup - 1); $i++){
            $Text + $Files[$indexOrigFiles[$i]] | Out-File $repr -Append
            $Text3 + $DupFiles[$i] | Out-File $repr -Append
            del $DupFiles[$i] 
        }
        Write-Host "Отчёт об удаленных дублированных файлов находится в текстовом файле Report.txt по пути:" $repr
    }
    else{
        do{
            $choice2 = Read-Host "Хотите ли вы удалить дублированные файлы выборочно? [y/n]"
            if (($choice2 -ne 'y') -and ($choice2 -ne 'n')){
                Write-Host "Попробуйте ввести снова!"
            }
        }while (($choice2 -ne 'y') -and ($choice2 -ne 'n'))
        if ($choice2 -eq 'y'){
            for ($i = 0; $i -le ($lenDup - 1); $i++){
                Write-Host $Text $Files[$indexOrigFiles[$i]]
                $Text + $Files[$indexOrigFiles[$i]] | Out-File $repr -Append
                Write-Host $Text2 $DupFiles[$i]
                do{
                    $choice3 = Read-Host "Хотите ли вы удалить этот дублированный файл? [y/n]"
                    if (($choice3 -ne 'y') -and ($choice3 -ne 'n')){
                        Write-Host "Попробуйте ввести снова!"
                    }
                }while (($choice3 -ne 'y') -and ($choice3 -ne 'n'))
                if ($choice3 -eq 'y'){
                    $Text3 + $DupFiles[$i] | Out-File $repr -Append
                    del $DupFiles[$i]
                }
                else{ 
                    $Text2 + $DupFiles[$i] | Out-File $repr -Append
                }
            }
            Write-Host "Отчёт об дублированных файлов находится в текстовом файле Report.txt по пути:" $repr
        }
        else{
            Write-Host "Отчёт об дублированных файлов находится в текстовом файле Report.txt по пути:" $repr
            for ($i = 0; $i -le ($lenDup - 1); $i++){
                $Text + $Files[$indexOrigFiles[$i]] | Out-File $repr -Append
                $Text2 + $DupFiles[$i] | Out-File $repr -Append
            }
        }
    }
}
else{
    Write-Host "Дублированных файлов не найдено"
}      
del $repa
del $repb
del $repd
del $repl            

      