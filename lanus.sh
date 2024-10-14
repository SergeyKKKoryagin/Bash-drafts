#!/bin/bash

# Получаем список всех подключений
connections=$(nmcli -t -f NAME connection show)

# Удаляем каждое подключение, обернув его в кавычки для корректной обработки пробелов и кириллицы
while IFS= read -r conn; do
  echo "Удаление подключения: \"$conn\""
  nmcli connection delete "$conn"
done <<< "$connections"

echo "Все подключения были удалены."

MAC_ADDRESS0=$(nmcli -g GENERAL.HWADDR device show eth0 | sed 's/\\//g')
MAC_ADDRESS1=$(nmcli -g GENERAL.HWADDR device show eth1 | sed 's/\\//g')
nmcli connection add type ethernet con-name Проводное\ соединение\ 1 ifname eth0 ip4 172.16.16.1/24 802-3-ethernet.mac-address $MAC_ADDRESS0
nmcli connection add type ethernet con-name Проводное\ соединение\ 2 ifname eth1 ip4 172.16.16.1/24 802-3-ethernet.mac-address $MAC_ADDRESS1
