#! /bin/bash

read -p "yyyy-mm-dd hh:mm:ss " var1
#echo $var1
sudo hwclock --set --date="$var1"
sudo hwclock -s

(
echo n
echo p
echo 1
echo
echo
echo y
echo w) | sudo fdisk /dev/sda
lsblk
sudo mkfs.ext4 /dev/sda1

sudo nano /etc/fstab

sudo gparted

# Указание нового и старого устройства
NEW_DEVICE="/dev/sda1"
OLD_UUID="996335ad-911e-433d-bd88-66cd50292a04"  # Замените на старый UUID, который нужно найти

# Получение нового UUID
NEW_UUID=$(blkid -s UUID -o value $NEW_DEVICE)

# Проверка, получен ли новый UUID
if [ -z "$NEW_UUID" ]; then
  echo "Не удалось получить UUID для устройства $NEW_DEVICE."
  exit 1
fi

# Обновление /etc/fstab
FSTAB_FILE="/etc/fstab"
sudo sed -i "s/#UUID=[^ ]*/UUID=$NEW_UUID/" /etc/fstab
sudo sed -i '4s/^#//' /etc/fstab
# Замена старого UUID на новый и раскомментирование строки


# Информирование о завершении
echo "UUID в файле $FSTAB_FILE обновлен. Старый UUID: $OLD_UUID, Новый UUID: $NEW_UUID"
sudo mount -a
sudo chown -R user:user /media/odroid/TOSHIBA/

SYSTEM_NAME_ORIG=$1
SYSTEM_NAME_LOW=`echo $SYSTEM_NAME_ORIG | tr '[:upper:]' '[:lower:]'`


stringZ=$SYSTEM_NAME_ORIG 
#sudo sed -i s/%/${stringZ:3}/ /etc/hostname /opt/Synerget_debug/conf.ini 
sudo sed -i s/64047/${stringZ:3}/ /etc/hostname  
sudo sed -i s/odroid64/$stringZ/ /opt/Synerget_debug/conf.ini
sudo rm /opt/Synerget_debug/cert.reg
find /mnt -name  "*${stringZ:3}.reg" -exec cp {} /opt/Synerget_debug/cert.reg \;
cd /opt/Synerget_debug/
./Synerget -n odroid64 -clone $stringZ

sudo reboot
