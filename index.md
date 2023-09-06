---
layout: splash
author_profile: false

header:
  overlay_image: /assets/images/page_bg_raw.jpg
  overlay_filter: 0.5
  actions:
    - label: "Download"
      url: "https://github.com/fholger/farcry_vrmod/releases/latest"
    - label: "Discord"
      url: "http://flat2vr.com"

intro:
  - excerpt: >-
      *Welcome to Cabatu!*
---

{% include feature_row id="intro" type="center" %}

Far Cry VR is a third-party mod for the 2004 PC gaming classic by CryTek. It allows players to experience the world of Far Cry in virtual reality. Features:

- full 6DoF roomscale VR experience: play seated or standing with VR motion controllers
- aim your guns naturally with your hands; use two hands to stabilize the guns further
- physically swing the machete
- aim mounted and vehicle guns by pointing with your main hand
- climb ladders manually
- left-handed support
- support for bHaptics vests to provide haptic feedback for player damage, weapon recoil and more

The mod is completely free. Simply download [the latest release](https://github.com/fholger/farcry_vrmod/releases/latest)
and install it to your local Far Cry folder. If you do not own Far Cry, you can get it from
[Steam](https://store.steampowered.com/app/13520/Far_Cry/) or
[gog.com](https://www.gog.com/en/game/far_cry).

If you would like to see the mod in action, here are some impressions:

{% include video provider="youtube" id="TSNd7s_x-4g" %}


### Installation instructions

- Download and install Far Cry, if you haven't already. The game needs to be patched to v1.4; this is already the case for the Steam and gog versions.
- Download the Far Cry VR installer from the link above and run it. Note: the installer is not signed, so your browser and/or Windows will likely complain about not trusting the installer. You will have to tell Windows to run the installer, anyway.
- Make sure to select the right path to your Far Cry installation. If you are not sure where it resides, in Steam you can right-click on the game and select "Manage -> Browse local files" to find the path on your machine. Similarly, in GOG Galaxy you can right-click on the game and go to "Manage installation -> Show folder".
- Finish the installer.

You can now launch Far Cry VR by executing the `FarCryVR.exe` in your Far Cry install folder. Far Cry VR requires SteamVR; if you have trouble starting the game, make sure that SteamVR is running first and working with your VR headset.

NOTE: by default, the installer runs without admin privileges as the Far Cry game folder should be user-writeable.
If you run into issues, you may need to explicitly run the installer as an administrator.
To do so, right-click on it and select "Run as administrator".

### Update instructions

Simply download the installer for the new release and repeat the installation instructions. The installer will automatically replace the mod files with the latest version, and afterwards you are ready to go. You should not lose any saves or settings in the process.
