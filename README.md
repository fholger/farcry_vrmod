# Far Cry VR Mod

This is a mod for the 2004 Crytek game *Far Cry* which makes it possible to experience it in Virtual Reality.
You need to own and have installed the original Far Cry. It is available at:
* [Steam](https://store.steampowered.com/app/13520/Far_Cry/)
* [gog.com](https://www.gog.com/en/game/far_cry)

- This mod features fully working stereoscopic rendering with 6DOF headset tracking.
- You can play seated or standing.
- You can play with VR motion controllers or with keyboard and mouse.
- bHaptics vests are supported

## Installation

Download and install Far Cry. Then head over to the mod's [Releases](https://github.com/fholger/farcry_vrmod/releases) and
find the latest release at the top of the page. Under the "Assets" section find and download the `farcry-vrmod-x.y.exe` installer.
Open it and install into your Far Cry install directory. If you are not sure where it is located,
right-click on Far Cry in your Steam library, then select "Manage" -> "Browse local files", and it will show you the game's install location.

Launch the `FarCryVR.bat` to start the game in VR.

Note: the installer is not signed, so Windows will most likely complain about it. You'll have to tell it to execute the installer, anyway.

## Configuration

The most common configuration options for the mod are accessible in the ingame Options menu under the "VR options" tab.

Some more advanced config options are only available through the console or the `system.cfg` file. In particular:
- `vr_video_disable` - can be used to disable any and all video playback in the mod

## Playing

This mod requires SteamVR. If you have any issues, ensure that SteamVR is already running and working with your headset before launching the game.

Important: you need to recenter your view in SteamVR once you have assumed your seated or standing position. To do so, bring up the SteamVR dashboard and hit the "Recenter view" icon. The game will place the player's head at the calibrated height; your floor level may not necessarily match the ingame floor height.

Refer to the [manual](https://farcryvr.de/manual/) for the default controller bindings if playing with VR motion controllers. At the moment, Index and Touch-like controllers are supported out of the box. Any other controller type may require you to create your own custom controller bindings for the game.

## Known issues / limitations

- No comfort options: you need your VR legs for this game!
- Distant LOD may under certain viewing angles cause stereo artifacting.
- Weapon orientation in two-handed mode can go into reverse under certain angles
- The machete hit detection is not always very accurate
- Grenade throws happen at the press of a button, there is currently no physical throwing
- Motion controls do not work properly in multiplayer

## Legal notices

This mod is developed and its source code is covered under the CryEngine Mod SDK license which you can review in the `EULA.txt` file.

This mod is not endorsed by or affiliated with Crytek or Ubisoft.  Trademarks are the property of their respective owners. Game content copyright Crytek.
