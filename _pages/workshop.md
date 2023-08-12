---
permalink: /workshop/
title: "Workshop support"
---

# Uploading items to the Workshop

**REMINDER: Only upload files you have the rights to upload**  

Using others' work without permission is not acceptable, even if it is just
a port of a Half-Life 2 mod.

To upload an item to the workshop, do the following:

### Prepare the item

The workshop currently supports uploading VPK and BSP (map) files. If you
instead have assets in folders (textures, models, sounds, etc.) you will need
to pack these into a VPK.

One easy method is to ensure you have only the assets you want to upload in
your `Half-Life 2 VR/hlvr/custom` folder. Then, test it out to ensure your
assets are working properly. Finally, open the `Half-Life 2 VR/bin` folder
and drag and drop the `Half-Life 2 VR/hlvr/custom` folder onto `vpk.exe`. It
should create a file named custom.vpk, which you can upload to the Workshop.

For more information about VPKs, see the [Valve Developer Wiki](https://developer.valvesoftware.com/wiki/VPK).

You will also need an icon picture in JPEG or BMP format (PNG is currently not
supported due to a bug).

### Upload the item

To upload an item, first navigate to `Half-Life 2 VR/bin/workshop` and 
double-click the HL2VRWorkshopUploader executable. It should open the Workshop
uploader tool. 

If it prompts with a message saying you need to install .NET,
do *not* click the Yes button. Instead, click No and download and install the
**.NET Desktop Runtime 3.1.32** version found here: [.NET Core 3.1](https://dotnet.microsoft.com/en-us/download/dotnet/3.1).
Then run HL2VRWorkshopUploader again. 

Click **Add** to create a new Workshop
item. Fill out all of the fields. The "File" field should point to your item's
VPK or BSP file.

Then, accept the terms of the Steam Workshop Contribution Agreement and click
**Publish**. If successful, you should get a message asking you if you want to
visit the page on Steam. By default, all uploaded items are set to Private, so
if you want to allow the item to be publicly visible, click Yes and adjust the
visibility on the Steam page. You can also add additional images or videos
here.
