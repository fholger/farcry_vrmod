SniperRifle = {
	-- DESCRIPTION:
	-- Non zoom mode has no crosshair, its like a rail gun with one
	-- High power, travels far (800m), but loud
	-- player travels slower with it
	-- Standard sniper gun

	name			= "SniperRifle",
	object		= "Objects/Weapons/aw50/aw50_bind.cgf",
	character	= "Objects/Weapons/aw50/aw50.cgf",
	
	BoneRightHand = "Bone67",
	BoneLeftHand = "Bone19",
	RHOffset = {0.0, -0.08, -0.018}

	-- if the weapon supports zooming then add this...
	ZoomActive = 0,												-- initially always 0
	MaxZoomSteps = 4,
	ZoomSteps = { 3, 6, 12, 18, },
	ZoomSound=Sound:LoadSound("Sounds/items/scope.wav"),
	ZoomDeadSwitch= 1,
	Sway = 2,

	---------------------------------------------------
	PlayerSlowDown = 0.5,									-- factor to slow down the player when he holds that weapon
	---------------------------------------------------
	ActivateSound = Sound:LoadSound("Sounds/Weapons/AW50/aw50weapact.wav",0,100),	-- sound to play when this weapon is selected
	---------------------------------------------------
	DoesFTBSniping = 1,
	---------------------------------------------------
	DrawFlare=1,

	FireParams ={													-- describes all supported firemodes
	{
		AmmoType="Sniper",
		reload_time= 2.5,
		fire_rate= 1.35,
		fire_activation=FireActivation_OnPress,
		damage= 50, -- the aidamage multipler makes this an instant death but does not kill the player
		damage_drop_per_meter= 0.005,
		bullet_per_shot= 1,
		bullets_per_clip=5,
		FModeActivationTime=1.0,
		iImpactForceMul = 20,
		iImpactForceMulFinal = 120,

		BulletRejectType=BULLET_REJECT_TYPE_SINGLE,

		-- make sure that the last parameter in each sound (max-distance) is equal to "whizz_sound_radius"
		whizz_sound_radius=8,
		whizz_probability=250,	-- 0-1000
		whizz_sound={
			Sound:Load3DSound("Sounds/weapons/bullets/whiz1.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz2.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz3.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz4.wav",SOUND_UNSCALABLE,100,1,8),
		},

		FireSounds = {
			"Sounds/Weapons/aw50/FINAL_AW50_MONO_FIRE1.wav",
			"Sounds/Weapons/aw50/FINAL_AW50_MONO_FIRE2.wav",
			"Sounds/Weapons/aw50/FINAL_AW50_MONO_FIRE3.wav",
		},
		FireSoundsStereo = {
			"Sounds/Weapons/aw50/FINAL_AW50_STEREO_FIRE1.wav",
			"Sounds/Weapons/aw50/FINAL_AW50_STEREO_FIRE2.wav",
			"Sounds/Weapons/aw50/FINAL_AW50_STEREO_FIRE3.wav",
		},
		DrySound = "Sounds/Weapons/AW50/DryFire.wav",

		LightFlash = {
			fRadius = 3.0,
			vDiffRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			vSpecRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			fLifeTime = 0.1,
		},

		ShellCases = {
			geometry=System:LoadObject("Objects/Weapons/shells/snipershell.cgf"),
			focus = 1.5,
			color = { 1, 1, 1},
			speed = 0.1,
			count = 1,
			size = 3.0,
			size_speed = 0.0,
			gravity = { x = 0.0, y = 0.0, z = -9.81 },
			lifetime = 10.0,
			frames = 0,
			color_based_blending = 0,
			particle_type = 0,
		},

		SmokeEffect = {
			size = {0.15,0.07,0.035,0.01},
			size_speed = 1.3,
			speed = 9.0,
			focus = 3,
			lifetime = 0.25,
			sprite = System:LoadTexture("textures\\cloud1.dds"),
			stepsoffset = 0.3,
			steps = 4,
			gravity = 1.2,
			AirResistance = 3,
			rotation = 3,
			randomfactor = 50,
		},

		MuzzleEffect = {
			size = {0.3,0.01,0.03,0.015},--0.15,0.25,0.35,0.3,0.2},
			size_speed = 3.3,
			speed = 0.0,
			focus = 20,
			lifetime = 0.03,
			sprite = {
					{
						System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzlehoriz.dds")
					}
					,
					{
						--System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzle4.dds"),
						System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzle5.dds"),
						System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzle6.dds"),
						System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzle7.dds"),
					}
				},
			stepsoffset = 0.1,
			steps = 2,
			gravity = 0.0,
			AirResistance = 0,
			rotation = 3,
			randomfactor = 30,
			color = {0.9,0.9,0.9},
		},

		-- remove this if not nedded for current weapon
		MuzzleFlash = {
			geometry_name = "Objects/Weapons/Muzzle_flash/mf_AW50_fpv.cgf",
			bone_name = "spitfire",
			lifetime = 0.05,
		},
		MuzzleFlashTPV = {
			geometry_name = "Objects/Weapons/Muzzle_flash/mf_AW50_tpv.cgf",
			bone_name = "weapon_bone",
			lifetime = 0.05,
		},

		ExitEffect = "bullet.sniper_trail",

		SoundMinMaxVol = { 200, 4, 2600 },
	},
	{
		AmmoType="Sniper",
		reload_time= 2.5,
		fire_rate= 1.35,
		fire_activation=FireActivation_OnPress,
		damage= 50, -- the aidamage multipler makes this an instant death but does not kill the player
		damage_drop_per_meter= 0.005,
		bullet_per_shot= 1,
		bullets_per_clip=5,
		FModeActivationTime=1.0,
		iImpactForceMul = 20,
		iImpactForceMulFinal = 120,

		BulletRejectType=BULLET_REJECT_TYPE_SINGLE,

		-- make sure that the last parameter in each sound (max-distance) is equal to "whizz_sound_radius"
		whizz_sound_radius=8,
		whizz_probability=250,	-- 0-1000
		whizz_sound={
			Sound:Load3DSound("Sounds/weapons/bullets/whiz1.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz2.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz3.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz4.wav",SOUND_UNSCALABLE,100,1,8),
		},

		FireSounds = {
			"Sounds/Weapons/aw50/aw50fire1.wav",
			"Sounds/Weapons/aw50/aw50fire2.wav",
			"Sounds/Weapons/aw50/aw50fire3.wav",
		},
		DrySound = "Sounds/Weapons/AW50/DryFire.wav",

		LightFlash = {
			fRadius = 3.0,
			vDiffRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			vSpecRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			fLifeTime = 0.1,
		},

		ShellCases = {
			geometry=System:LoadObject("Objects/Weapons/shells/snipershell.cgf"),
			focus = 1.5,
			color = { 1, 1, 1},
			speed = 0.1,
			count = 1,
			size = 3.0,
			size_speed = 0.0,
			gravity = { x = 0.0, y = 0.0, z = -9.81 },
			lifetime = 10.0,
			frames = 0,
			color_based_blending = 0,
			particle_type = 0,
		},

		SmokeEffect = {
			size = {0.15,0.07,0.035,0.01},
			size_speed = 1.3,
			speed = 9.0,
			focus = 3,
			lifetime = 0.25,
			sprite = System:LoadTexture("textures\\cloud1.dds"),
			stepsoffset = 0.3,
			steps = 4,
			gravity = 1.2,
			AirResistance = 3,
			rotation = 3,
			randomfactor = 50,
		},

		MuzzleEffect = {
			size = {0.3,0.01,0.03,0.015},--0.15,0.25,0.35,0.3,0.2},
			size_speed = 3.3,
			speed = 0.0,
			focus = 20,
			lifetime = 0.03,
			sprite = {
					{
						System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzlehoriz.dds")
					}
					,
					{
						--System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzle4.dds"),
						System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzle5.dds"),
						System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzle6.dds"),
						System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzle7.dds"),
					}
				},
			stepsoffset = 0.1,
			steps = 2,
			gravity = 0.0,
			AirResistance = 0,
			rotation = 3,
			randomfactor = 30,
			color = {0.9,0.9,0.9},
		},

		-- remove this if not nedded for current weapon
		MuzzleFlash = {
			geometry_name = "Objects/Weapons/Muzzle_flash/mf_AW50_fpv.cgf",
			bone_name = "spitfire",
			lifetime = 0.05,
		},
		MuzzleFlashTPV = {
			geometry_name = "Objects/Weapons/Muzzle_flash/mf_AW50_tpv.cgf",
			bone_name = "weapon_bone",
			lifetime = 0.05,
		},

		ExitEffect = "bullet.sniper_trail",

		SoundMinMaxVol = { 200, 4, 2600 },
	},
	},
		SoundEvents={
		--	animname,	frame,	soundfile												---
		{	"reload1",	10,	Sound:LoadSound("Sounds/Weapons/AW50/aw50clip_10.wav",0,100)},
		{	"reload1",	57,	Sound:LoadSound("Sounds/Weapons/AW50/AW50bolt_11.wav",0,100)},
		{	"fire11",	11,	Sound:LoadSound("Sounds/Weapons/AW50/AW50bolt_11.wav",0,100)},
		{	"fire21",	11,	Sound:LoadSound("Sounds/Weapons/AW50/AW50bolt_11.wav",0,100)},
--		{	"swim",		1,			Sound:LoadSound("Sounds/player/water/underwaterswim2.wav",0,255)},

	},
}

function SniperRifle:ZoomZoggle( Active )
	if ( Active==0 ) then
		if ( SniperRifle.ZoomSound ) then
			Sound.StopSound( SniperRifle.ZoomSound );
		end
	end
end

function SniperRifle:DrawZoomOverlay( ZoomStep )
	-- if we're in the sniper-scope send an SNIPER-mood-event
	Sound:AddMusicMoodEvent("Sniper", MM_SNIPER_TIMEOUT);
	if ( ZoomStep ~= self.PrevZoomStep ) then
		if ( SniperRifle.ZoomSound ) then
			Sound:StopSound( SniperRifle.ZoomSound );
			Sound:PlaySound( SniperRifle.ZoomSound );
		end
		self.PrevZoomStep = ZoomStep;
	end

	if ( SniperRifle.ZoomBackgroundTID ) then
		-- [tiago] note image inversion, in order to achieve one-one texel to pixel mapping we must correct texture coordinates
		-- also, texture wrap should be set to clamping mode... i hacked texture coordinates a bit to go around incorrect texture wrapping mode...
		local fTexelW=1.0/512.0;
		local fTexelH=1.0/512.0;

		System:DrawImageColorCoords( SniperRifle.ZoomBackgroundTID, 400, 300, -400, -300, 4, 1, 1, 1, 1, fTexelW, fTexelH, 1-fTexelW, 1-fTexelH);
		System:DrawImageColorCoords( SniperRifle.ZoomBackgroundTID, 400, 300, 400, -300, 4, 1, 1, 1, 1, fTexelW, fTexelH, 1-fTexelW, 1-fTexelH);
		System:DrawImageColorCoords( SniperRifle.ZoomBackgroundTID, 400, 300, -400, 300, 4, 1, 1, 1, 1, fTexelW, fTexelH, 1-fTexelW, 1-fTexelH);
		System:DrawImageColorCoords( SniperRifle.ZoomBackgroundTID, 400, 300, 400, 300, 4, 1, 1, 1, 1, fTexelW, fTexelH, 1-fTexelW, 1-fTexelH);
	end

	if ( SniperRifle.ZoomTID ) then
		local zs=SniperRifle.ZoomTID[ZoomStep];
		System:DrawImage( zs[1], zs[2], zs[3], 100, 200, 4);
	end

--	Game:SetHUDFont("radiosta", "sniperscope");
	Game:SetHUDFont("radiosta", "binozoom");
	
	-- Draw distance
	local myPlayer=_localplayer;
	if ( myPlayer ) then
		local int_pt=myPlayer.cnt:GetViewIntersection();
		if ( int_pt ) then
			local s=format( "%07.2fm", int_pt.len*1.5);
			--Game:WriteHudStringFixed(585, 280, s, 1, 1, 1, 0.25, 20, 20, 0.6);
			Game:WriteHudString(582, 280, s, 1, 1, 1, 0.25, 15, 15);
		else
			--Game:WriteHudStringFixed(585, 280, "----.--m", 1, 1, 1, 0.25, 20, 20, 0.6);
			Game:WriteHudString(582, 280, "----.--m", 1, 1, 1, 0.25, 15, 15);
		end
	end
end

CreateBasicWeapon(SniperRifle);

-- override functions
function SniperRifle.Client:OnInit()
	System:LoadFont("radiosta");

	SniperRifle.ZoomBackgroundTID=System:LoadImage("Textures/Hud/sniperscope/Snipe_Scope");
	SniperRifle.ZoomTID={};

	local cur_r_TexResolution = tonumber( getglobal( "r_TexResolution" ) );
	if( cur_r_TexResolution >= 2 ) then -- lower res texture for low texture quality setting
		SniperRifle.ZoomTID[1]={System:LoadImage("Textures/Hud/sniperscope/3_low.tga"),161,115};
		SniperRifle.ZoomTID[2]={System:LoadImage("Textures/Hud/sniperscope/6_low.tga"),161,159};
		SniperRifle.ZoomTID[3]={System:LoadImage("Textures/Hud/sniperscope/12_low.tga"),161,245};
		SniperRifle.ZoomTID[4]={System:LoadImage("Textures/Hud/sniperscope/18_low.tga"),161,286};
	else
		SniperRifle.ZoomTID[1]={System:LoadImage("Textures/Hud/sniperscope/3.tga"),161,115};
		SniperRifle.ZoomTID[2]={System:LoadImage("Textures/Hud/sniperscope/6.tga"),161,159};
		SniperRifle.ZoomTID[3]={System:LoadImage("Textures/Hud/sniperscope/12.tga"),161,245};
		SniperRifle.ZoomTID[4]={System:LoadImage("Textures/Hud/sniperscope/18.tga"),161,286};
	end

	self.ZoomOverlayFunc = SniperRifle.DrawZoomOverlay;
	BasicWeapon.Client.OnInit(self);
end

---------------------------------------------------------------
--ANIMTABLE
------------------
--SINGLE FIRE
SniperRifle.anim_table={}
SniperRifle.anim_table[1]={
	idle={
		"Idle11",
		"Idle21",
	},
	reload={
		"Reload1",
	},
	fidget={
		"fidget11",
	},
	fire={
		"Fire11",
		"Fire21",
	},
	swim={
		"swim"
	},
	activate={
		"Activate1"
	},
}
