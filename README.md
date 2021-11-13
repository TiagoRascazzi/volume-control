# volume-control.sh

Control pulseaudio volume with keyboard event 

Allows to increase volume pass 100%



### Dependency:


* bash 
* gdbus
* pulseaudio
* pulseaudio-utils
* python
* desktop-notify


To install the dependencies on Debian use: 


```
sudo apt-get install bash libglib2.0-bin pulseaudio pulseaudio-utils
```


### Install

Bind keyboard event to following scripts:

	Audio lower volume	-> volume-control.sh dec

	Audio raise volume	-> volume-control.sh inc

	Audio mute		-> volume-control.sh mute
