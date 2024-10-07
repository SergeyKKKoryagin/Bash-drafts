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


# Определяем комбинации и выводим информацию


if [[ $has_nvme -eq 1 && $has_sda -eq 1 && $has_sdb -eq 1 && $has_sdc -eq 1 && $has_sdd -eq 1 && ($has_sde -eq 0 || $has_flash -eq 1) ]]; then
    echo -e "\e[32m\e[40m2 В системе обнаружены NVMe накопитель и устройства: sda, sdb, sdc, sdd.\e[0m"
    echo '/dev/sda1       /home/user/archive/disk1        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sdb1       /home/user/archive/disk2        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sdc1       /home/user/archive/disk3        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sdd1       /home/user/archive/disk4        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    sudo parted /dev/sda mklabel gpt
    sudo parted /dev/sdb mklabel gpt
    sudo parted /dev/sdc mklabel gpt
    sudo parted /dev/sdd mklabel gpt
    sudo mkdir -p /home/user/archive/disk{1..4}
    
elif [[ $has_nvme -eq 1 && $has_sda -eq 1 && $has_sdb -eq 1 && $has_sdc -eq 1 && $has_sdd -eq 1 && $has_sde -eq 1 ]]; then
    echo -e "\e[32m\e[40m1 В системе обнаружены NVMe накопитель и устройства: sda, sdb, sdc, sdd, sde.\e[0m"
    echo '/dev/sda1       /home/user/archive/disk1        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sdb1       /home/user/archive/disk2        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sdc1       /home/user/archive/disk3        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sdd1       /home/user/archive/disk4        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sde1       /home/user/archive/disk5        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    sudo parted /dev/sda mklabel gpt
    sudo parted /dev/sdb mklabel gpt
    sudo parted /dev/sdc mklabel gpt
    sudo parted /dev/sdd mklabel gpt
    sudo parted /dev/sde mklabel gpt
    sudo mkdir -p /home/user/archive/disk{1..5}

elif [[ $has_nvme -eq 1 && $has_sda -eq 1 && ($has_sdb -eq 0 || $has_flash -eq 1) && $has_sdc -eq 0 && $has_sdd -eq 0 && $has_sde -eq 0 ]]; then
    echo -e "\e[32m\e[40m3 В системе обнаружены NVMe накопитель и устройство: sda.\e[0m"
    echo '/dev/sda1       /home/user/archive/disk1        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    sudo mkdir -p /home/user/archive/disk1
    sudo parted /dev/sda mklabel gpt

elif [[ $has_nvme -eq 0 && $has_sda -eq 1 && $has_sdb -eq 1 && $has_sdc -eq 1 && $has_sdd -eq 1 && $has_sde -eq 1 && ($has_sdf -eq 0 || $has_flash -eq 1) && $sda_bigger -eq 0 ]]; then
    echo -e "\e[32m\e[40m4 В системе обнаружены устройства: sda, sdb, sdc, sdd, sde.(ОС на sda)\e[0m"
    echo '/dev/sdb1       /home/user/archive/disk1        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sdc1       /home/user/archive/disk2        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sdd1       /home/user/archive/disk3        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sde1       /home/user/archive/disk4        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    sudo mkdir -p /home/user/archive/disk{1..4}
    sudo parted /dev/sdb mklabel gpt
    sudo parted /dev/sdc mklabel gpt
    sudo parted /dev/sdd mklabel gpt
    sudo parted /dev/sde mklabel gpt

elif [[ $has_nvme -eq 0 && $has_sda -eq 1 && $has_sdb -eq 1 && $has_sdc -eq 1 && $has_sdd -eq 1 && $has_sde -eq 1 && ($has_sdf -eq 0 || $has_flash -eq 1) && $sda_bigger -eq 1 ]]; then
    echo -e "\e[32m\e[40m5 В системе обнаружены устройства: sda, sdb, sdc, sdd, sde.(ОС на sdb)\e[0m"
    echo '/dev/sda1       /home/user/archive/disk1        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sdc1       /home/user/archive/disk2        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sdd1       /home/user/archive/disk3        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sde1       /home/user/archive/disk4        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    sudo mkdir -p /home/user/archive/disk{1..4}
    sudo parted /dev/sda mklabel gpt
    sudo parted /dev/sdc mklabel gpt
    sudo parted /dev/sdd mklabel gpt
    sudo parted /dev/sde mklabel gpt
    
elif [[ $has_nvme -eq 0 && $has_sda -eq 1 && $has_sdb -eq 1 && ($has_sdc -eq 0 || $has_flash -eq 1) && $has_sdd -eq 0 && $has_sde -eq 0 ]]; then
    echo -e "\e[32m\e[40m6 В системе обнаружены устройства: sda, sdb.(ОС на sda)\e[0m"
    echo '/dev/sdb1       /home/user/archive/disk1        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    sudo mkdir -p /home/user/archive/disk1
    sudo parted /dev/sdb mklabel gpt
    
elif [[ $has_nvme -eq 0 && $has_sda -eq 1 && $has_sdb -eq 1 && $has_sdc -eq 1 && $has_sdd -eq 1 && $has_sde -eq 1 && $has_sdf -eq 1 && $sda_bigger -eq 1 ]]; then
    echo -e "\e[32m\e[40m7 В системе обнаружены устройства: sda, sdb, sdc, sdd, sde, sdf.(ОС на sdb)\e[0m"
    echo '/dev/sda1       /home/user/archive/disk1        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sdc1       /home/user/archive/disk2        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sdd1       /home/user/archive/disk3        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sde1       /home/user/archive/disk4        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sdf1       /home/user/archive/disk5        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    sudo parted /dev/sda mklabel gpt
    sudo parted /dev/sdc mklabel gpt
    sudo parted /dev/sdd mklabel gpt
    sudo parted /dev/sde mklabel gpt
    sudo parted /dev/sdf mklabel gpt
    sudo mkdir -p /home/user/archive/disk{1..5}
    
elif [[ $has_nvme -eq 0 && $has_sda -eq 1 && $has_sdb -eq 1 && $has_sdc -eq 1 && $has_sdd -eq 1 && $has_sde -eq 1 && $has_sdf -eq 1 && $sda_bigger -eq 0 ]]; then
    echo -e "\e[32m\e[40m8 В системе обнаружены устройства: sda, sdb, sdc, sdd, sde, sdf.(ОС на sda)\e[0m"
    echo '/dev/sdb1       /home/user/archive/disk1        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sdc1       /home/user/archive/disk2        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sdd1       /home/user/archive/disk3        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sde1       /home/user/archive/disk4        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sdf1       /home/user/archive/disk5        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    sudo parted /dev/sdb mklabel gpt
    sudo parted /dev/sdc mklabel gpt
    sudo parted /dev/sdd mklabel gpt
    sudo parted /dev/sde mklabel gpt
    sudo parted /dev/sdf mklabel gpt
    sudo mkdir -p /home/user/archive/disk{1..5}
else
    echo "Не обнаружены необходимые комбинации устройств."
fi
