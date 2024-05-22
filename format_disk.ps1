# Fonction pour lister les disques disponibles
function List-Disks {
    $disks = Get-Disk | Where-Object IsSystem -eq $false
    foreach ($disk in $disks) {
        $diskNumber = $disk.Number
        $diskSizeGB = [math]::Round($disk.Size / 1GB, 2)
        Write-Output "Disk Number: $diskNumber - Size: ${diskSizeGB}GB - Model: $($disk.Model)"
    }
}

# Fonction pour formater un disque
function Format-Disk {
    param (
        [int]$DiskNumber
    )
    
    # Obtenir le disque
    $disk = Get-Disk -Number $DiskNumber

    if ($null -eq $disk) {
        Write-Output "Le disque $DiskNumber n'existe pas."
        return
    }

    # Supprimer toutes les partitions existantes
    $partitions = $disk | Get-Partition
    foreach ($partition in $partitions) {
        $partition | Remove-Partition -Confirm:$false
    }

    # Initialiser le disque (si nécessaire)
    $disk | Initialize-Disk -PartitionStyle MBR -Confirm:$false

    # Créer une nouvelle partition de 4GB
    $partitionSizeGB = 4
    $partitionSizeBytes = $partitionSizeGB * 1GB
    $partition = New-Partition -DiskNumber $DiskNumber -Size $partitionSizeBytes -AssignDriveLetter

    # Formater la partition en FAT32
    $volume = $partition | Format-Volume -FileSystem FAT32 -NewFileSystemLabel "4GBDISK" -Confirm:$false

    Write-Output "Le disque $DiskNumber a été formaté en FAT32 avec une partition de 4GB."
}

# Lister les disques disponibles
Write-Output "Liste des disques disponibles :"
List-Disks

# Demander à l'utilisateur de choisir un disque
$diskNumber = Read-Host "Entrez le numéro du disque à formater"

# Confirmation de l'utilisateur
$confirm = Read-Host "Êtes-vous sûr de vouloir formater le disque $diskNumber ? Cette opération effacera toutes les données sur le disque ! (oui/non)"

if ($confirm -eq "oui") {
    Format-Disk -DiskNumber $diskNumber
} else {
    Write-Output "Opération annulée."
}
