#! /bin/bash

SYSTEM_NAME_ORIG=$1
SYSTEM_NAME_LOW=`echo $SYSTEM_NAME_ORIG | tr '[:upper:]' '[:lower:]'`
stringZ=$SYSTEM_NAME_ORIG 


sudo grub-install
sudo update-grub

# Получаем список всех подключенных устройств (SATA и NVMe)
devices=$(lsblk -dno NAME)

# Проверяем наличие NVMe накопителей и устройств sda, sdb, sdc, sdd, sde
has_nvme=$(echo "$devices" | grep -q '^nvme' && echo 1 || echo 0)
has_sda=$(echo "$devices" | grep -q '^sda' && echo 1 || echo 0)
has_sdb=$(echo "$devices" | grep -q '^sdb' && echo 1 || echo 0)
has_sdc=$(echo "$devices" | grep -q '^sdc' && echo 1 || echo 0)
has_sdd=$(echo "$devices" | grep -q '^sdd' && echo 1 || echo 0)
has_sde=$(echo "$devices" | grep -q '^sde' && echo 1 || echo 0)
has_flash=$(ls /dev | grep vfat > /dev/null && echo 1 || echo 0)

# Определяем комбинации и выводим информацию
if [[ $has_nvme -eq 1 && $has_sda -eq 1 && $has_sdb -eq 1 && $has_sdc -eq 1 && $has_sdd -eq 1 && $has_sde -eq 1 ]]; then
    echo "В системе обнаружены NVMe накопитель и устройства: sda, sdb, sdc, sdd, sde."
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

elif [[ $has_nvme -eq 1 && $has_sda -eq 1 && $has_sdb -eq 1 && $has_sdc -eq 1 && $has_sdd -eq 1 && ($has_sde -eq 0 || $has_flash -eq 1)]]; then
    echo "В системе обнаружены NVMe накопитель и устройства: sda, sdb, sdc, sdd."
    echo '/dev/sda1       /home/user/archive/disk1        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sdb1       /home/user/archive/disk2        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sdc1       /home/user/archive/disk3        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sdd1       /home/user/archive/disk4        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    sudo parted /dev/sda mklabel gpt
    sudo parted /dev/sdb mklabel gpt
    sudo parted /dev/sdc mklabel gpt
    sudo parted /dev/sdd mklabel gpt
    sudo mkdir -p /home/user/archive/disk{1..4}

elif [[ $has_nvme -eq 1 && $has_sda -eq 1 && ($has_sdb -eq 0 || $has_flash -eq 1) && $has_sdc -eq 0 && $has_sdd -eq 0 && $has_sde -eq 0 ]]; then
    echo "В системе обнаружены NVMe накопитель и устройство: sda."
    echo '/dev/sda1       /home/user/archive/disk1        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    sudo mkdir -p /home/user/archive/disk1
    sudo parted /dev/sda mklabel gpt

elif [[ $has_nvme -eq 0 && $has_sda -eq 1 && $has_sdb -eq 1 && $has_sdc -eq 1 && $has_sdd -eq 1 && $has_sde -eq 1 ]]; then
    echo "В системе обнаружены устройства: sda, sdb, sdc, sdd, sde."
    echo '/dev/sdb1       /home/user/archive/disk1        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sdc1       /home/user/archive/disk2        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sdd1       /home/user/archive/disk3        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    echo '/dev/sde1       /home/user/archive/disk4        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    sudo mkdir -p /home/user/archive/disk{1..4}
    sudo parted /dev/sda mklabel gpt
    sudo parted /dev/sdb mklabel gpt
    sudo parted /dev/sdc mklabel gpt
    sudo parted /dev/sdd mklabel gpt
    sudo parted /dev/sde mklabel gpt
elif [[ $has_nvme -eq 0 && $has_sda -eq 1 && $has_sdb -eq 1 && ($has_sdc -eq 0 || $has_flash -eq 1) && $has_sdd -eq 0 && $has_sde -eq 0 ]]; then
    echo "В системе обнаружены устройства: sda, sdb."
    echo '/dev/sdb1       /home/user/archive/disk1        ext4    defaults        0       0'| sudo tee -a /etc/fstab
    sudo mkdir -p /home/user/archive/disk1
    sudo parted /dev/sdb mklabel gpt
else
    echo "Не обнаружены необходимые комбинации устройств."
fi


sudo nano /etc/fstab

sudo rm -rf /opt/Synerget_debug/xml
sudo gparted &
sudo fly-admin-date &
sudo nm-connection-editor &
wait
#sudo gparted | sudo kate /etc/fstab
#sudo mount -a


find /run/user/1000/media/by-id-usb-Kingston_DataTraveler_2.0_1C6F6581FDF7EF60897EBA5D-0:0-part1 -name  "*${stringZ:3}.reg" -exec mv {} /opt/Synerget_debug/cert.reg \;

sudo sed -i s/%/${stringZ:3}/ /etc/hosts /etc/hostname /opt/Synerget_debug/conf.ini


cd /opt/Synerget_debug/
./Synerget
sudo cp cert.key cert.reg /home/user/install/
kesl-control -L -query

rm /home/user/install/as1c2.sh
ls /home/user/install/
