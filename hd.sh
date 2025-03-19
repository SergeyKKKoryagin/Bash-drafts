#!/bin/bash

# Определяем системный диск (SSD)
SYSTEM_DISK=$(df / | tail -1 | awk '{print $1}' | sed 's/[0-9]*$//')  # Убираем номер раздела, получаем /dev/sda
echo -e "\e[32m\e[40mСистемный диск (SSD): $SYSTEM_DISK\e[0m"

# Функция для удаления имени раздела с использованием expect
remove_partition_name() {
    local device=$1
    expect <<EOF
    set timeout 10
    spawn sudo parted $device name 1 ""
    expect "Partition name?" {
        send "''\r"
    }
    expect eof
EOF
}

# Получаем список всех устройств с ROTA=1 (HDD), исключая USB
HDD_LIST=$(lsblk -d --noheadings -o NAME,ROTA,TRAN | awk '$2 == 1 && $1 != "sr0" && $3 != "usb" {print "/dev/"$1}')

echo -e "\e[32m\e[40mНайденные HDD:\e[0m"
echo -e "\e[32m\e[40m$HDD_LIST\e[0m"

# Проверяем, есть ли устройства в списке
if [ -z "$HDD_LIST" ]; then
    echo "Жёсткие диски (HDD) не найдены."
    exit 0
fi

# Счетчик для нумерации дисков
COUNTER=1

# Проходим по списку HDD и исключаем системный диск
for DISK in $HDD_LIST; do
    if [ "$DISK" != "$SYSTEM_DISK" ]; then
        echo "Разметка диска: $DISK"
        # Создаем раздел (используем $DISK с номером 1 для первого раздела)
        PARTITION="${DISK}1"
        sudo parted "$DISK" mklabel gpt
        sudo parted "$DISK" mkpart primary ext4 0% 100%
        sudo mkfs.ext4 "$PARTITION"

        # Удаляем имя раздела для текущего устройства
        remove_partition_name "$DISK"

        # Создаем точку монтирования для текущего диска
        MOUNT_POINT="/home/$USER/archive/disk$COUNTER"
        sudo mkdir -p "$MOUNT_POINT"

        # Добавляем запись в /etc/fstab для текущего диска
        echo "$PARTITION       $MOUNT_POINT        ext4    defaults        0       0" | sudo tee -a /etc/fstab

        # Увеличиваем счетчик для следующего диска
        COUNTER=$((COUNTER + 1))
    else
        echo "Пропускаем системный диск: $DISK"
    fi
done

echo "Настройка завершена. Проверьте /etc/fstab и смонтируйте диски командой 'sudo mount -a'"

