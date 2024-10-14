#!/bin/bash

# Получаем список всех подключенных устройств (SATA и NVMe)
devices=$(lsblk -dno NAME)

# Проверяем наличие NVMe накопителей и устройств sda, sdb, sdc, sdd, sde
has_nvme=$(echo "$devices" | grep -q '^nvme' && echo 1 || echo 0)
has_sda=$(echo "$devices" | grep -q '^sda' && echo 1 || echo 0)
has_sdb=$(echo "$devices" | grep -q '^sdb' && echo 1 || echo 0)
has_sdc=$(echo "$devices" | grep -q '^sdc' && echo 1 || echo 0)
has_sdd=$(echo "$devices" | grep -q '^sdd' && echo 1 || echo 0)
has_sde=$(echo "$devices" | grep -q '^sde' && echo 1 || echo 0)
has_sdf=$(echo "$devices" | grep -q '^sdf' && echo 1 || echo 0)
has_flash=$(ls /dev | grep vfat > /dev/null && echo 1 || echo 0)
sda_bigger=$( [ "$(lsblk -b -n -o SIZE /dev/sda 2> /dev/null)" -gt "$(lsblk -b -n -o SIZE /dev/sdb 2> /dev/null)" ] 2> /dev/null && echo 1 || echo 0 )

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


# Определяем комбинации и выводим информацию
if [[ $has_nvme -eq 1 && $has_sda -eq 1 && $has_sdb -eq 1 && $has_sdc -eq 1 && $has_sdd -eq 1 && ($has_sde -eq 0 || $has_flash -eq 1) ]]; then
    echo -e "\e[32m\e[40m2 В системе обнаружены NVMe накопитель и устройства: sda, sdb, sdc, sdd.\e[0m"
    echo "/dev/sda1       /home/$USER/archive/disk1        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    echo "/dev/sdb1       /home/$USER/archive/disk2        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    echo "/dev/sdc1       /home/$USER/archive/disk3        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    echo "/dev/sdd1       /home/$USER/archive/disk4        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    sudo parted /dev/sda mklabel gpt
    sudo parted /dev/sdb mklabel gpt
    sudo parted /dev/sdc mklabel gpt
    sudo parted /dev/sdd mklabel gpt
    sudo parted /dev/sda mkpart '' ext4 0% 100%
    sudo parted /dev/sdb mkpart '' ext4 0% 100%
    sudo parted /dev/sdc mkpart '' ext4 0% 100%
    sudo parted /dev/sdd mkpart '' ext4 0% 100%

    sudo mkfs.ext4 /dev/sda1
    sudo mkfs.ext4 /dev/sdb1
    sudo mkfs.ext4 /dev/sdc1
    sudo mkfs.ext4 /dev/sdd1

    # Цикл по устройствам для удаления имени разделов
    for device in /dev/sda /dev/sdb /dev/sdc /dev/sdd; do
        echo "Обработка устройства: $device"
        remove_partition_name "$device"
    done

    echo "Имя разделов было удалено для всех устройств."
    sudo mkdir -p /home/$USER/archive/disk{1..4}

elif [[ $has_nvme -eq 1 && $has_sda -eq 1 && $has_sdb -eq 1 && $has_sdc -eq 1 && $has_sdd -eq 1 && $has_sde -eq 1 ]]; then
    echo -e "\e[32m\e[40m1 В системе обнаружены NVMe накопитель и устройства: sda, sdb, sdc, sdd, sde.\e[0m"
    echo "/dev/sda1       /home/$USER/archive/disk1        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    echo "/dev/sdb1       /home/$USER/archive/disk2        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    echo "/dev/sdc1       /home/$USER/archive/disk3        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    echo "/dev/sdd1       /home/$USER/archive/disk4        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    echo "/dev/sde1       /home/$USER/archive/disk5        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    sudo parted /dev/sda mklabel gpt
    sudo parted /dev/sdb mklabel gpt
    sudo parted /dev/sdc mklabel gpt
    sudo parted /dev/sdd mklabel gpt
    sudo parted /dev/sde mklabel gpt
    sudo parted /dev/sda mkpart '' ext4 0% 100%
    sudo parted /dev/sdb mkpart '' ext4 0% 100%
    sudo parted /dev/sdc mkpart '' ext4 0% 100%
    sudo parted /dev/sdd mkpart '' ext4 0% 100%
    sudo parted /dev/sde mkpart '' ext4 0% 100%
    sudo mkfs.ext4 /dev/sda1
    sudo mkfs.ext4 /dev/sdb1
    sudo mkfs.ext4 /dev/sdc1
    sudo mkfs.ext4 /dev/sdd1
    sudo mkfs.ext4 /dev/sde1
    # Цикл по устройствам для удаления имени разделов
    for device in /dev/sda /dev/sdb /dev/sdc /dev/sdd /dev/sde; do
        echo "Обработка устройства: $device"
        remove_partition_name "$device"
    done

    echo "Имя разделов было удалено для всех устройств."
    sudo mkdir -p /home/$USER/archive/disk{1..5}

elif [[ $has_nvme -eq 1 && $has_sda -eq 1 && ($has_sdb -eq 0 || $has_flash -eq 1) && $has_sdc -eq 0 && $has_sdd -eq 0 && $has_sde -eq 0 ]]; then
    echo -e "\e[32m\e[40m3 В системе обнаружены NVMe накопитель и устройство: sda.\e[0m"
    echo "/dev/sda1       /home/$USER/archive/disk1        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    sudo mkdir -p /home/$USER/archive/disk1
    sudo parted /dev/sda mklabel gpt
    sudo parted /dev/sda mkpart '' ext4 0% 100%
    sudo mkfs.ext4 /dev/sda1

    # Цикл по устройствам для удаления имени разделов
    for device in /dev/sda; do
        echo "Обработка устройства: $device"
        remove_partition_name "$device"
    done

    echo "Имя разделов было удалено для всех устройств."

elif [[ $has_nvme -eq 0 && $has_sda -eq 1 && $has_sdb -eq 1 && $has_sdc -eq 1 && $has_sdd -eq 1 && $has_sde -eq 1 && ($has_sdf -eq 0 || $has_flash -eq 1) && $sda_bigger -eq 0 ]]; then
    echo -e "\e[32m\e[40m4 В системе обнаружены устройства: sda, sdb, sdc, sdd, sde.(ОС на sda)\e[0m"
    echo "/dev/sdb1       /home/$USER/archive/disk1        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    echo "/dev/sdc1       /home/$USER/archive/disk2        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    echo "/dev/sdd1       /home/$USER/archive/disk3        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    echo "/dev/sde1       /home/$USER/archive/disk4        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    sudo mkdir -p /home/$USER/archive/disk{1..4}
    sudo parted /dev/sdb mklabel gpt
    sudo parted /dev/sdc mklabel gpt
    sudo parted /dev/sdd mklabel gpt
    sudo parted /dev/sde mklabel gpt

    sudo parted /dev/sdb mkpart '' ext4 0% 100%
    sudo parted /dev/sdc mkpart '' ext4 0% 100%
    sudo parted /dev/sdd mkpart '' ext4 0% 100%
    sudo parted /dev/sde mkpart '' ext4 0% 100%

    sudo mkfs.ext4 /dev/sdb1
    sudo mkfs.ext4 /dev/sdc1
    sudo mkfs.ext4 /dev/sdd1
    sudo mkfs.ext4 /dev/sde1
    # Цикл по устройствам для удаления имени разделов
    for device in /dev/sdb /dev/sdc /dev/sdd /dev/sde; do
        echo "Обработка устройства: $device"
        remove_partition_name "$device"
    done

    echo "Имя разделов было удалено для всех устройств."

elif [[ $has_nvme -eq 0 && $has_sda -eq 1 && $has_sdb -eq 1 && $has_sdc -eq 1 && $has_sdd -eq 1 && $has_sde -eq 1 && ($has_sdf -eq 0 || $has_flash -eq 1) && $sda_bigger -eq 1 ]]; then
    echo -e "\e[32m\e[40m5 В системе обнаружены устройства: sda, sdb, sdc, sdd, sde.(ОС на sdb)\e[0m"
    echo "/dev/sda1       /home/$USER/archive/disk1        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    echo "/dev/sdc1       /home/$USER/archive/disk2        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    echo "/dev/sdd1       /home/$USER/archive/disk3        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    echo "/dev/sde1       /home/$USER/archive/disk4        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    sudo mkdir -p /home/$USER/archive/disk{1..4}
    sudo parted /dev/sda mklabel gpt
    sudo parted /dev/sdc mklabel gpt
    sudo parted /dev/sdd mklabel gpt
    sudo parted /dev/sde mklabel gpt
    sudo parted /dev/sda mkpart '' ext4 0% 100%
    sudo parted /dev/sdc mkpart '' ext4 0% 100%
    sudo parted /dev/sdd mkpart '' ext4 0% 100%
    sudo parted /dev/sde mkpart '' ext4 0% 100%
    sudo mkfs.ext4 /dev/sda1
    sudo mkfs.ext4 /dev/sdc1
    sudo mkfs.ext4 /dev/sdd1
    sudo mkfs.ext4 /dev/sde1
    # Цикл по устройствам для удаления имени разделов
    for device in /dev/sda /dev/sdc /dev/sdd /dev/sde; do
        echo "Обработка устройства: $device"
        remove_partition_name "$device"
    done

    echo "Имя разделов было удалено для всех устройств."
    
elif [[ $has_nvme -eq 0 && $has_sda -eq 1 && $has_sdb -eq 1 && ($has_sdc -eq 0 || $has_flash -eq 1) && $has_sdd -eq 0 && $has_sde -eq 0 ]]; then
    echo -e "\e[32m\e[40m6 В системе обнаружены устройства: sda, sdb.(ОС на sda)\e[0m"
    echo "/dev/sdb1       /home/$USER/archive/disk1        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    sudo mkdir -p /home/$USER/archive/disk1
    sudo parted /dev/sdb mklabel gpt

    sudo parted /dev/sdb mkpart '' ext4 0% 100%

    sudo mkfs.ext4 /dev/sdb1

    # Цикл по устройствам для удаления имени разделов
    for device in /dev/sdb; do
        echo "Обработка устройства: $device"
        remove_partition_name "$device"
    done

    echo "Имя разделов было удалено для всех устройств."
    
elif [[ $has_nvme -eq 0 && $has_sda -eq 1 && $has_sdb -eq 1 && $has_sdc -eq 1 && $has_sdd -eq 1 && $has_sde -eq 1 && $has_sdf -eq 1 && $sda_bigger -eq 1 ]]; then
    echo -e "\e[32m\e[40m7 В системе обнаружены устройства: sda, sdb, sdc, sdd, sde, sdf.(ОС на sdb)\e[0m"
    echo "/dev/sda1       /home/$USER/archive/disk1        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    echo "/dev/sdc1       /home/$USER/archive/disk2        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    echo "/dev/sdd1       /home/$USER/archive/disk3        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    echo "/dev/sde1       /home/$USER/archive/disk4        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    echo "/dev/sdf1       /home/$USER/archive/disk5        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    sudo parted /dev/sda mklabel gpt
    sudo parted /dev/sdc mklabel gpt
    sudo parted /dev/sdd mklabel gpt
    sudo parted /dev/sde mklabel gpt
    sudo parted /dev/sdf mklabel gpt
    sudo parted /dev/sda mkpart '' ext4 0% 100%
    sudo parted /dev/sdc mkpart '' ext4 0% 100%
    sudo parted /dev/sdd mkpart '' ext4 0% 100%
    sudo parted /dev/sde mkpart '' ext4 0% 100%
    sudo parted /dev/sdf mkpart '' ext4 0% 100%

    sudo mkfs.ext4 /dev/sda1
    sudo mkfs.ext4 /dev/sdc1
    sudo mkfs.ext4 /dev/sdd1
    sudo mkfs.ext4 /dev/sde1
    sudo mkfs.ext4 /dev/sdf1
    # Цикл по устройствам для удаления имени разделов
    for device in /dev/sda /dev/sdc /dev/sdd /dev/sde /dev/sdf; do
        echo "Обработка устройства: $device"
        remove_partition_name "$device"
    done

    echo "Имя разделов было удалено для всех устройств."
    sudo mkdir -p /home/$USER/archive/disk{1..5}
    
elif [[ $has_nvme -eq 0 && $has_sda -eq 1 && $has_sdb -eq 1 && $has_sdc -eq 1 && $has_sdd -eq 1 && $has_sde -eq 1 && $has_sdf -eq 1 && $sda_bigger -eq 0 ]]; then
    echo -e "\e[32m\e[40m8 В системе обнаружены устройства: sda, sdb, sdc, sdd, sde, sdf.(ОС на sda)\e[0m"
    echo "/dev/sdb1       /home/$USER/archive/disk1        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    echo "/dev/sdc1       /home/$USER/archive/disk2        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    echo "/dev/sdd1       /home/$USER/archive/disk3        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    echo "/dev/sde1       /home/$USER/archive/disk4        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    echo "/dev/sdf1       /home/$USER/archive/disk5        ext4    defaults        0       0"| sudo tee -a /etc/fstab
    sudo parted /dev/sdb mklabel gpt
    sudo parted /dev/sdc mklabel gpt
    sudo parted /dev/sdd mklabel gpt
    sudo parted /dev/sde mklabel gpt
    sudo parted /dev/sdf mklabel gpt
    sudo parted /dev/sdb mkpart '' ext4 0% 100%
    sudo parted /dev/sdc mkpart '' ext4 0% 100%
    sudo parted /dev/sdd mkpart '' ext4 0% 100%
    sudo parted /dev/sde mkpart '' ext4 0% 100%
    sudo parted /dev/sdf mkpart '' ext4 0% 100%

    sudo mkfs.ext4 /dev/sdb1
    sudo mkfs.ext4 /dev/sdc1
    sudo mkfs.ext4 /dev/sdd1
    sudo mkfs.ext4 /dev/sde1
    sudo mkfs.ext4 /dev/sdf1
    # Цикл по устройствам для удаления имени разделов
    for device in /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf; do
        echo "Обработка устройства: $device"
        remove_partition_name "$device"
    done

    echo "Имя разделов было удалено для всех устройств."
    sudo mkdir -p /home/$USER/archive/disk{1..5}
else
    echo "Не обнаружены необходимые комбинации устройств."
fi
