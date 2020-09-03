# mpv-discord-linux
Using client id from [this project](https://github.com/noaione/mpv-discordRPC) without any shame because I can. Check it out ([or an alternative version](https://github.com/cniw/mpv-discordRPC)) in case you're on Windows.  

Long story short: both these projects require mpv to be built with LuaJIT support, which apparently isn't how the build in Arch repos was compiled. I couldn't be bothered to rebuild it so writing a plugin which should work with the default mpv I'm using is obviously the way to go.

# Installation

## Arch Linux
Install lua52-socket from the repos in case you don't have it yet.
```
sudo pacman -S lua52-socket
```

After that simply copy mpv-discord-status.lua to your ~/.config/mpv/scripts folder and it should work next time you launch something. 

Or if you fancy a retarted but (supposedly) working one-liner:
```bash
git clone https://github.com/sgtxn/mpv-discord-linux && mkdir -p ~/.config/mpv/scripts && cp mpv-discord-linux/mpv-discord-linux.lua ~/.config/mpv/scripts/ && rm -rf mpv-discord-linux
```

Regexes for anime are not quite compatible with every weird naming pattern under the sun yet, but should be good for most releases.  

Feel free to leave an issue in case something is off!

![Haha](https://blog.codinghorror.com/content/images/uploads/2007/03/6a0120a85dcdae970b0128776ff992970c-pi.png)
