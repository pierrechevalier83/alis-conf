# alis-conf
Custom installation config for [alis](https://github.com/picodotdev/alis)

## Usage

* Download alis from upstream and its configuration from this repo and configure it
```
curl -sL https://raw.githubusercontent.com/pierrechevalier83/alis-conf/main/download.sh | bash
```
* Check `alis.conf` and `alis-packages.conf` look good, edit them as desired
* Install Arch Linux
```
./alis.sh
```
* Reboot into the fancy new installation
```
./alis-reboot.sh
```
