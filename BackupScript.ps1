$sourcePath = "C:\"
$backupDir = "C:\"
$retentionDays = 30

$logFile = "C:\Path\To\Backup\log.txt"

function Write-Log {
    param (
        [string]$message
    )
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') : $message"
    Add-Content -Path $logFile -Value $logMessage
}

Write-Log "Запуск скрипта создания бэкапа"

if (-not (Test-Path -Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir
    Write-Log "Папка для бэкапов не найдена. Создана новая папка: $backupDir"
}

$date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$backupFileName = "Backup_$date.zip"
$backupFilePath = Join-Path $backupDir $backupFileName

try {
    Compress-Archive -Path $sourcePath -DestinationPath $backupFilePath
    Write-Log "Бэкап успешно создан: $backupFilePath"
} catch {
    Write-Log "Ошибка при создании бэкапа: $_"
}

try {
    $oldBackups = Get-ChildItem -Path $backupDir -Filter "*.zip" | Where-Object {
        $_.CreationTime -lt (Get-Date).AddDays(-$retentionDays)
    }

    if ($oldBackups.Count -gt 0) {
        $oldBackups | ForEach-Object {
            Remove-Item -Path $_.FullName -Force
            Write-Log "Удален старый бэкап: $($_.FullName)"
        }
    } else {
        Write-Log "Нет старых бэкапов для удаления."
    }
} catch {
    Write-Log "Ошибка при удалении старых бэкапов: $_"
}

Write-Log "Скрипт завершен."
