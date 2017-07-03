import configparser
config =configparser.ConfigParser()
config.sections()
config.read('piVPN.cfg')
config.sections()
print(config)
SSID=config['Wireless']['SSID']
PROTO=config['Wireless']['PROTO']
PSK=config['Wireless']['PSK']
apconf=SSID+" "+PROTO+" "+PSK
OPmode=config['Mode']['OperatingMode']
if  OPmode == "wired" or OPmode == "Wired":
    print("Wired mode")
    import os
    print(apconf)
    os.system("./w.sh "+ apconf)
