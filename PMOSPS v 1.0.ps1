$rep = Read-Host "Введите путь к папке, где вы хотите видеть отчет о дублированных файлов"
$dir = Read-Host "Введите путь к дереву каталогов, в котором хотите найти дублирующие файлы"
cd $rep
del Report.txt
$c = New-Item FilesNames.txt
$b = New-Item FilesHashs.txt 
$a = New-Item Report.txt
$repa = $rep + "\FilesNames.txt"
$repb = $rep + "\FilesHashs.txt"
$repr = $rep + "\Report.txt"
cd $dir
$l2 = 0
$Text = "OriginalFile: "
$Text2 = "    SecondaryFile: "
$Text3 = "    Deleted SecondaryFile: "
do{ 
    $choice = Read-Host "Хотите ли вы удалить все дублированные файлы автоматически? [y/n]"
    if (($choice -ne 'y') -and ($choice -ne 'n')){
        Write-Host "Попробуйте ввести снова!"
    }
}while (($choice -ne 'y') -and ($choice -ne 'n'))
foreach ($NameFile in ($lena = Get-ChildItem -recurse -attributes !D+A -Exclude "FilesNames.txt","FilesHashs.txt","Report.txt" |where FullName -NotLike "C:\Windows\*" | Select DirectoryName,Name)) { 
    $flag = 0
    $File = [string]::Concat($NameFile.DirectoryName,'\',$NameFile.Name) 
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
        continue
    }
    if($choice -eq 'y'){
        for ($i = $len - 1; $i -ge 0; $i--){
            if ($Hash -eq $Hashs[$i]){
                Write-Host "OrigHash: " $Hashs[$i]
                Write-Host "DuplHash: " $Hash
                $Text + $Files[$i] | Out-File $repr -Append
                $Text3 + $File | Out-File $repr -Append
                $flag = 1 
                del $File
                break
            }
        }
        if ($flag -eq 0){
            $File | Out-File $repa -Append
            $Hash | Out-File $repb -Append
        }
    }  
    else{
        for ($i = $len - 1; $i -ge 0; $i--){
            if ($Hash -eq $Hashs[$i]){
                Write-Host "OrigHash: " $Hashs[$i]
                Write-Host "DuplHash: " $Hash
                Write-Host $Text " " $Files[$i]
                do{
                    $choice2 = Read-Host "    Хотите ли вы удалить этот дублированный файл: " $File " [y/n]?"  
                    if (($choice2 -ne 'y') -and ($choice2 -ne 'n')){
                        Write-Host "Попробуйте ввести снова!"
                    }
                }while (($choice2 -ne 'y') -and ($choice2 -ne 'n'))  
                $Text + $Files[$i] | Out-File $repr -Append
                if ($choice2 -eq 'y'){
                    $Text3 + $File | Out-File $repr -Append
                    del $File
                }
                else{
                    $Text2 + $File | Out-File $repr -Append
                }
                $flag = 1 
                break
            }
        }
        if ($flag -eq 0){
            $File | Out-File $repa -Append
            $Hash | Out-File $repb -Append
        }
    }
    Write-Host "Проверено " ($len + 1) " из " $lena.Length " файлов. "
}
cd $rep
del FilesNames.txt
del FilesHashs.txt
