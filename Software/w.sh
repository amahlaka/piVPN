
SSID=$1
ENCRYPTION=$2
PASSWORD=$3

if [ $(id -u) -ne 0 ]; then
  printf "This script must be run as root. \n"
  exit 1
fi

NETID=$(wpa_cli add_network | tail -n 1)
wpa_cli set_network $NETID ssid \"$SSID\"
case $ENCRYPTION in
'WPA')
    wpa_cli set_network $NETID key_mgmt WPA-PSK
    wpa_cli set_network $NETID psk \"$PASSWORD\"
    ;;
'WEP')
    wpa_cli set_network $NETID wep_key0 $PASSWORD
    wpa_cli set_network $NETID wep_key1 $PASSWORD
    wpa_cli set_network $NETID wep_key2 $PASSWORD
    wpa_cli set_network $NETID wep_key3 $PASSWORD
    ;;
*)
    ;;
esac
wpa_cli enable_network $NETID
wpa_cli save_config
