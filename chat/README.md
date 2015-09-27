=Abode Chat=

XMPP Bonjour Abode HA node that allows control of the node over chat.


==Install==

Setup Bonjour (Zeroconf) advertising.
```
sudo apt-get install avahi-daemon
sudo insserv avahi-daemon
sudo cp abode.service /etc/avahi/services/
```

Install dependencies.
```
pip install -r requirements.txt
```

Start daemon.
```
```
