---
layout: splash
author_profile: false

header:
  overlay_image: /assets/images/page_bg_raw.jpg
  overlay_filter: 0.5
  actions:
    - label: "Download"
      url: "https://github.com/fholger/farcry_vrmod/releases/tag/v0.5.0"
    - label: "Discord"
      url: "http://flat2vr.com"

intro:
  - excerpt: >-
      *Welcome to Cabatu!*

feature_row:
  - image_path: /assets/images/feature_row/roomscale.jpg
    alt: "Features"
    title: "Roomscale VR"
    excerpt: Move around freely, pick up and throw stuff with your hands, *be* Gordon Freeman.
    url: "/features/#full-roomscale-vr"
    btn_class: "btn--primary"
  - image_path: /assets/images/feature_row/interface.jpg
    alt: "Intuitive weapons"
    title: "Intuitive weapons"
    excerpt: All weapons have been adapted to VR. Cycle through them in an intuitive Alyx-inspired weapon selection wheel.
    url: "/features/#weapon-handling"
    btn_class: "btn--primary"
  - image_path: /assets/images/feature_row/vehicles.jpg
    alt: "Vehicle rides"
    title: "Vehicle rides"
    excerpt: The vehicle sections in the game can be jarring in VR. We are doing our best to make them accessible to as many people as possible.
    url: "/features/#vehicle-rides"
    btn_class: "btn--primary"

about:
  - image_path: /assets/images/capsule_616x353.jpg
    alt: "About"
    title: "About Half-Life 2: VR Mod"
    excerpt: >-
      *Half-Life 2: VR Mod* is a third-party mod for the 2004 PC gaming classic by Valve Software.
      It is being developed by the Source VR Mod Team and is available free of charge on
      Steam to owners of Half-Life 2.
    url: "/about/"
    btn_class: "btn--primary"

release:
  - image_path: /assets/images/feature_row/ep1_logo.jpg
    alt: "Release announcement"
    title: "Episode One VR is now available"
    excerpt: >-
      Great news - *Half-Life 2: VR Mod - Episode One* is now available on Steam, free to any owners of the original *Half-Life 2: Episode One*.
      Check out the Steam page right now to download it! :)
    url: "https://store.steampowered.com/app/2177750/HalfLife_2_VR_Mod__Episode_One/"
    btn_class: "btn--primary"
    btn_label: "Steam page"
---

{% include feature_row id="intro" type="center" %}

Far Cry VR is a third-party mod for the 2004 PC gaming classic by CryTek. It allows players to experience the world of Far Cry in virtual reality.

The mod is completely free. Simply download [the latest release](https://github.com/fholger/farcry_vrmod/releases/tag/v0.5.0)
and install it to your local Far Cry folder. If you do not own Far Cry, you can get it from
[Steam](https://store.steampowered.com/app/13520/Far_Cry/) or
[gog.com](https://www.gog.com/en/game/far_cry).

### Installation instructions

- Download and install Far Cry, if you haven't already. The game needs to be patched to v1.4; this is already the case for the Steam and gog versions.
- Download the Far Cry VR installer from the link above and run it. Note: the installer is not signed, so your browser and/or Windows will likely complain about not trusting the installer. You will have to tell Windows to run the installer, anyway.
- Make sure to select the right path to your Far Cry installation. If you are not sure where it resides, in Steam you can right-click on the game and select "Manage -> Browse local files" to find the path on your machine. Similarly, in GOG Galaxy you can right-click on the game and go to "Manage installation -> Show folder".
- Finish the installer.

You can now launch Far Cry VR by executing the `FarCryVR.bat` in your Far Cry install folder. Far Cry VR requires SteamVR; if you have trouble starting the game, make sure that SteamVR is running first and working with your VR headset.

### Update instructions

Simply download the installer for the new release and repeat the installation instructions. The installer will automatically replace the mod files with the latest version, and afterwards you are ready to go. You should not lose any saves or settings in the process.
