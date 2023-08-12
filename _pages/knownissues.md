---
permalink: /knownissues/
title: "Known Issues and solutions"
---

This page lists a number of common issues our players have encountered and potential solutions and workarounds.

### This is intentionally an incomplete list.  
It's being updated over time, and only covers the biggest *game-breaking* issues we've come across.
It does not include smaller bugs or feedback on the game. (Please see [the Help page](/help/#reporting-bugs) and bug tracker for those!)

<br />

| Table of Contents  |
| ------------- |
| [Step 1](#step-1-for-every-issue)  |
| [Downloading or Installing issues](#downloading--installing-issues  )  |
| [Launching or crash issues](#crashes-or-other-game-breaking-issues)  |
| [Ingame issues](#ingame-issues)   |

<br />

---

# Step 1 for every issue

---

I know nobody likes to hear *just turn it off and on again*, but you're going to turn it off and on again and you're going to like it!

Please try the basics, listed below, before anything else. We've seen these solve problems for half the users who report issues.

- Update Windows, Steam, and SteamVR to the latest versions.  
- Update your graphics drivers. This includes the drivers for any iGPU you may have on a laptop!
  Don't skip this step! I know you're thinking *I'm just gonna skip this step because I know all about my updates already*, but that would be a mistake!  
  For NVIDIA users, [click here to search for the newest available](https://www.nvidia.com/en-us/geforce/drivers/).  
  AMD users can [click here to search for the newest available](https://www.amd.com/en/support).
- Close Steam and SteamVR, and reboot your device.

<br />

---

# Downloading / Installing issues

---

### Unable to claim or download the game in the Steam Store

This is often caused by the user not owning the standard Half-Life 2 on Steam. Having access to HL2 via Steam Family Sharing is not enough -- your account needs to own HL2. Similarly, you cannot share HL2VR through family sharing. This is a decision made by Valve, and we can do nothing about it.

We've also seen cases where it takes a bit of time after purchasing Half-Life 2 for Steam to notice that you should now be allowed to grab HL2VR. So if you've *just now* bought it, please give it a bit of time and try again later, possibly after restarting the Steam client.

If you are still facing issues, we recommend reaching out to the Steam support as these issues are out of our control.

<br />

---

# Crashes or other game-breaking issues

---

### Game does not start, crashes immediately or hangs

This issue has a number of different causes. There is no one definitive fix, but there are a number of things you can try that have helped some of those affected:

- Update your graphics driver to the newest available.  
NVIDIA users can [click here to search for the newest available](https://www.nvidia.com/en-us/geforce/drivers/).  
AMD users can [click here to search for the newest available](https://www.amd.com/en/support).
- Try different versions of **SteamVR** by either switching to the stable branch or to the beta branch.
- If you are using a **laptop**, see if your laptop has an option to disable the integrated GPU, either via the laptop manufacturer's control software or in the BIOS. If no such option exists, try forcing both HL2VR and SteamVR to use the dedicated GPU.  
  For instructions, [see here](https://www.windowsdigitals.com/force-chrome-firefox-game-to-use-nvidia-gpu-integrated-graphics/).
- If you are using a laptop with an **AMD Ryzen processor**, a very particular fix that has helped a number of people is to go to the Windows Device Manager, then disable and re-enable the integrated Radeon graphics.  
- Disable or uninstall **MSI Afterburner and RivaTuner**. These have been known to cause issues with Vulkan games on occasion and with HL2VR in particular.  
- Temporarily disable your anti-virus and see if the game launches. (Some overzealous AV software may erroneously flag HL2VR, or parts of it, and not allow it to run.)

### Game launches on the desktop, but doesn't display in the VR headset or has very poor performance

This is a common phenomenon on systems with more than one GPU and therefore usually applies to laptops with both an integrated and dedicated GPU. If possible, you may want to try and disable the GPU you are not using for VR to see if it helps.

###### Update your graphics drivers

This is known to have fixed the issue for people in the past. (See the drivers linked above.) Do make sure that you update the drivers for *all* GPUs, even the ones that you do not intend to use for VR!

###### Ensure the game is running on a display wired to the correct GPU

If your laptop screen or external monitor on which the game is running is connected to the internal GPU, you will most likely run into issues. Try to disconnect all screens except one that you know is connected to the right GPU and then try to launch the game.

###### Bad launch parameters
If you were trying to launch the game with *-dev* or *-console* parameters, then this behaviour is actually normal. The menu will not load in the headset, and you will have to load a save game or start a new game before you will actually see something in the headset.

For that reason, we recommend not using these launch parameters. The console can actually be opened via a button from the options menu, and if you need cheat access, you may find the launch parameter *-vrdev* more convenient. It will add a "Developer" panel to the Options menu.


### Error: "Engine Error - Failed to initialize OpenVR", or "Could not load library client"

This is typically caused by SteamVR not being installed or not running. Please install it via Steam: [SteamVR](https://store.steampowered.com/app/250820/SteamVR/) and start it before launching HL2VR. On rare occasions, a reinstall of SteamVR may be necessary.


<br />

---

# In-game issues

---

### I am falling half-way into the ground / I am a dwarf?

Chances are you accidentally toggled Crouch. This is bound to your main hand's joystick "down" direction. Simply pull the joystick down again to un-crouch.


### I cannot get out of the water!

Make sure you're holding forward and jump towards a nearby ledge, and if it's low enough you'll likely hop your way out of the water within a couple seconds.

Alternatively, you may have accidentally crouched, which prevents you from properly jumping out of the water. Try to uncrouch using your main hand's joystick "down" to toggle it.


### I am getting an error "AI Disabled"

This is a long-standing Source bug, and probably not something we can resolve on our end. But if you run into this, you can usually resolve it by using these two commands in the Console:

  ai_norebuildgraph 1
  ai_resume  

Then reload your save.

Alternatively, you may also simply restart the map you are currently on by typing `restart` in the console. HL2's maps are usually reasonably short so that you shouldn't lose too much progress, and it may actually prevent your save from going corrupt.

### I cannot progress / a level transition isn't working / characters are not doing an action they should be doing

Chances are your save game may have become corrupt. The best course of action is to restart your current map by typing `restart` in the console.
