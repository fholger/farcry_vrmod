function GetScopeTex()
	local cur_r_TexResolution = tonumber( getglobal( "r_TexResolution" ) );
	if( cur_r_TexResolution >= 2 ) then -- lower res texture for low texture quality setting
		return System:LoadImage("Textures/Hud/crosshair/g36_zoom_low.tga");
	else
		return System:LoadImage("Textures/Hud/crosshair/g36_zoom.tga");
	end
end


AG36SP = {
	name			= "AG36",
	object		= "Objects/Weapons/ag36/ag36_bind.cgf",
	character	= "Objects/Weapons/ag36/ag36.cgf",
	
	BoneRightHand = "Bone67",
	BoneLeftHand = "Bone19",
	RHOffsetAngles = {-2.0, -8.0, 2.0},

	-- if the weapon supports zooming then add this...
	ZoomActive = 0,												-- initially always 0
	MaxZoomSteps = 2,
	ZoomSteps = { 2, 4 },
	---------------------------------------------------
	PlayerSlowDown = 0.8,									-- factor to slow down the player when he holds that weapon
	---------------------------------------------------
	ActivateSound = Sound:LoadSound("Sounds/Weapons/AG36/agweapact.wav",0,150),	-- sound to play when this weapon is selected
	---------------------------------------------------
	Sway=2,
	---------------------------------------------------
	DrawFlare=1,
	---------------------------------------------------

	FireParams ={													-- describes all supported 	firemodes
	{
		HasCrosshair=1,
		AmmoType="Assault",
		reload_time= 2.6,
		fire_rate= 0.1,
		distance= 1200,
		damage= 12,
		damage_drop_per_meter = 0.011,
		bullet_per_shot= 1,
		bullets_per_clip=30,
		FModeActivationTime = 1.0,
		fire_activation=bor(FireActivation_OnPress,FireActivation_OnHold),
		iImpactForceMul = 20,
		iImpactForceMulFinal = 65,

		BulletRejectType=BULLET_REJECT_TYPE_RAPID,

		-- make sure that the last parameter in each sound (max-distance) is equal to "whizz_sound_radius"
		whizz_sound_radius=8,
		whizz_probability=250,	-- 0-1000
		whizz_sound={
			Sound:Load3DSound("Sounds/weapons/bullets/whiz1.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz2.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz3.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz4.wav",SOUND_UNSCALABLE,100,1,8),
		},

		FireLoop="Sounds/Weapons/ag36/FINAL_AG36_MONO_LOOP.wav",
		FireLoopStereo="Sounds/Weapons/ag36/FINAL_AG36_STEREO_LOOP.wav",
		TrailOff="Sounds/Weapons/ag36/FINAL_AG36_MONO_TAIL.wav",
		TrailOffStereo="Sounds/Weapons/ag36/FINAL_AG36_STEREO_TAIL.wav",

		DrySound = "Sounds/Weapons/AG36/DryFire.wav",
		HapticFireEffect = "oicw_fire",

		ScopeTexId = GetScopeTex(),

		ShellCases = {
			geometry=System:LoadObject("Objects/Weapons/shells/rifleshell.cgf"),
			focus = 1.5,
			color = { 1, 1, 1},
			speed = 0.1,
			count = 1,
			size = 3.0,
			size_speed = 0.0,
			gravity = { x = 0.0, y = 0.0, z = -9.81 },
			lifetime = 5.0,
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
			size = {0.175,0.01,0.02,0.03,0.015},--0.15,0.25,0.35,0.3,0.2},
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
			steps = 5,
			gravity = 0.0,
			AirResistance = 0,
			rotation = 3,
			randomfactor = 60,
			color = {0.5,0.5,0.5},
		},

		-- remove this if not nedded for current weapon
		MuzzleFlash = {
			geometry_name = "Objects/Weapons/Muzzle_flash/mf_ag36_fpv.cgf",
			bone_name = "spitfire",
			lifetime = 0.15,
		},
		MuzzleFlashTPV = {
			geometry_name = "Objects/Weapons/Muzzle_flash/mf_ag36_tpv.cgf",
			bone_name = "weapon_bone",
			lifetime = 0.05,
		},

		-- trace "moving bullet"
		-- remove this if not nedded for current weapon
		Trace = {
			geometry=System:LoadObject("Objects/Weapons/trail.cgf"),
			focus = 5000,
			color = { 1, 1, 1},
			speed = 120.0,
			count = 1,
			size = 1.0,
			size_speed = 0.0,
			gravity = { x = 0.0, y = 0.0, z = 0.0 },
			lifetime = 0.04,
			frames = 0,
			color_based_blending = 3,
			particle_type = 0,
		},

		SoundMinMaxVol = { 225, 4, 2600 },
		
		LightFlash = {
			fRadius = 3.0,
			vDiffRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			vSpecRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			fLifeTime = 0.1,
		},
	},
--GRENADE-----------------------------
	{
		no_zoom = 1,
		FModeActivationTime=1,
		HasCrosshair=1,
		AmmoType="AG36Grenade",
		projectile_class="AG36Grenade",
		reload_time=2.5,
		fire_rate=1.0,
		fire_activation=FireActivation_OnPress,
		bullet_per_shot=1,
		bullets_per_clip=1,

		FireSounds = {
			"Sounds/Weapons/ag36/FINAL_GRENADE_MONO.wav",
			"Sounds/Weapons/ag36/FINAL_GRENADE_MONO.wav",
			"Sounds/Weapons/ag36/FINAL_GRENADE_MONO.wav",
		},
		FireSoundsStereo = {
			"Sounds/Weapons/ag36/FINAL_GRENADE_STEREO.wav",
			"Sounds/Weapons/ag36/FINAL_GRENADE_STEREO.wav",
			"Sounds/Weapons/ag36/FINAL_GRENADE_STEREO.wav",

		},
		DrySound = "Sounds/Weapons/AG36/DryFire.wav",
		HapticFireEffect = "oicw_grenade",

		SoundMinMaxVol = { 255, 4, 2600 },

		LightFlash = {
			fRadius = 3.0,
			vDiffRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			vSpecRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			fLifeTime = 0.1,
		},
	},
	},

		SoundEvents={
		--	animname,	frame,	soundfil{	"reload1",	15,			Sound.LoadSound("Sounds/Weapons/ag36/ag36b_15.wav")},
		{	"reload1",	23,			Sound:LoadSound("Sounds/Weapons/ag36/Ag36b_23.wav",0,150)},
		{	"reload1",	38,			Sound:LoadSound("Sounds/Weapons/ag36/Ag36b_38.wav",0,150)},
		{	"reload1",	54,			Sound:LoadSound("Sounds/Weapons/ag36/Ag36b_54.wav",0,150)},
		{	"reload2",	13,			Sound:LoadSound("Sounds/Weapons/ag36/ag36g_13.wav",0,150)},
		{	"reload2",	37,			Sound:LoadSound("Sounds/Weapons/ag36/ag36g_37.wav",0,150)},
--		{	"swim",		1,			Sound:LoadSound("Sounds/player/water/underwaterswim2.wav",0,255)},

	},
}

 
AG36MP = {
	name			= "AG36",
	object		= "Objects/Weapons/ag36/ag36_bind.cgf",
	character	= "Objects/Weapons/ag36/ag36.cgf",
	
	BoneRightHand = "Bone67",
	BoneLeftArm = "Bone25",

	fireCanceled = 0,

	-- if the weapon supports zooming then add this...
	ZoomActive = 0,												-- initially always 0
	MaxZoomSteps = 2,
	ZoomSteps = { 2, 4 },
	---------------------------------------------------
	PlayerSlowDown = 0.75,									-- factor to slow down the player when he holds that weapon
	---------------------------------------------------
	ActivateSound = Sound:LoadSound("Sounds/Weapons/AG36/agweapact.wav",0,150),	-- sound to play when this weapon is selected
	---------------------------------------------------
	ZoomNoSway=1,
	---------------------------------------------------
	DrawFlare=1,
	---------------------------------------------------
	FireParams ={													-- describes all supported firemodes
	{
		FModeActivationTime = 1.0,

		HasCrosshair=1,
		AmmoType="Assault",
		reload_time= 2.6,
		fire_rate= 0.1,
		distance= 1200,
		damage= 12,
		damage_drop_per_meter = 0.011,
		bullet_per_shot= 1,
		bullets_per_clip=30,
		iImpactForceMul = 20,
		iImpactForceMulFinal = 100,
		fire_activation=bor(FireActivation_OnPress,FireActivation_OnHold),

		-- recoil values
		min_recoil=0,
		max_recoil=0.8,	-- its only a small recoil as more people seem to like it that way

		BulletRejectType=BULLET_REJECT_TYPE_RAPID,

		-- make sure that the last parameter in each sound (max-distance) is equal to "whizz_sound_radius"
		whizz_sound_radius=8,
		whizz_probability=250,	-- 0-1000
		whizz_sound={
			Sound:Load3DSound("Sounds/weapons/bullets/whiz1.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz2.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz3.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz4.wav",SOUND_UNSCALABLE,100,1,8),
		},

		FireLoop="Sounds/Weapons/ag36/FINAL_AG36_MONO_LOOP.wav",
		FireLoopStereo="Sounds/Weapons/ag36/FINAL_AG36_STEREO_LOOP.wav",
		TrailOff="Sounds/Weapons/ag36/FINAL_AG36_MONO_TAIL.wav",
		TrailOffStereo="Sounds/Weapons/ag36/FINAL_AG36_STEREO_TAIL.wav",
		DrySound = "Sounds/Weapons/AG36/DryFire.wav",

		ScopeTexId = GetScopeTex(),

		ShellCases = {
			geometry=System:LoadObject("Objects/Weapons/shells/rifleshell.cgf"),
			focus = 1.5,
			color = { 1, 1, 1},
			speed = 0.1,
			count = 1,
			size = 3.0,
			size_speed = 0.0,
			gravity = { x = 0.0, y = 0.0, z = -9.81 },
			lifetime = 5.0,
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
			size = {0.175,0.01,0.02,0.03,0.015},--0.15,0.25,0.35,0.3,0.2},
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
			steps = 5,
			gravity = 0.0,
			AirResistance = 0,
			rotation = 3,
			randomfactor = 60,
			color = {0.5,0.5,0.5},
		},

		-- remove this if not nedded for current weapon
		MuzzleFlash = {
			geometry_name = "Objects/Weapons/Muzzle_flash/mf_ag36_fpv.cgf",
			bone_name = "spitfire",
			lifetime = 0.15,
		},
		MuzzleFlashTPV = {
			geometry_name = "Objects/Weapons/Muzzle_flash/mf_ag36_tpv.cgf",
			bone_name = "weapon_bone",
			lifetime = 0.05,
		},

		-- trace "moving bullet"
		-- remove this if not nedded for current weapon
		Trace = {
			geometry=System:LoadObject("Objects/Weapons/trail.cgf"),
			focus = 5000,
			color = { 1, 1, 1},
			speed = 120.0,
			count = 1,
			size = 1.0,
			size_speed = 0.0,
			gravity = { x = 0.0, y = 0.0, z = 0.0 },
			lifetime = 0.04,
			frames = 0,
			color_based_blending = 3,
			particle_type = 0,
		},

		SoundMinMaxVol = { 225, 4, 2600 },
		
		LightFlash = {
			fRadius = 3.0,
			vDiffRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			vSpecRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			fLifeTime = 0.1,
		},
	},
--GRENADE-----------------------------
	{
		no_zoom = 1,
		FModeActivationTime=1,
		--HasCrosshair=1,
		AmmoType="AG36Grenade",
			min_recoil=4,
			max_recoil=4,		
		projectile_class="AG36Grenade",
		reload_time=2.5,
		fire_rate=1.0,
		fire_activation=FireActivation_OnPress,
		bullet_per_shot=1,
		bullets_per_clip=1,
			

		ScopeTexId = GetScopeTex(),

		FireSounds = {
			"Sounds/Weapons/ag36/FINAL_GRENADE_MONO.wav",
			"Sounds/Weapons/ag36/FINAL_GRENADE_MONO.wav",
			"Sounds/Weapons/ag36/FINAL_GRENADE_MONO.wav",
		},
		FireSoundsStereo = {
			"Sounds/Weapons/ag36/FINAL_GRENADE_STEREO.wav",
			"Sounds/Weapons/ag36/FINAL_GRENADE_STEREO.wav",
			"Sounds/Weapons/ag36/FINAL_GRENADE_STEREO.wav",

		},
		DrySound = "Sounds/Weapons/AG36/DryFire.wav",

		SoundMinMaxVol = { 255, 4, 2600 },

		LightFlash = {
			fRadius = 3.0,
			vDiffRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			vSpecRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			fLifeTime = 0.1,
		},
	},

	},




		SoundEvents={
		--	animname,	frame,	soundfil{	"reload1",	15,			Sound.LoadSound("Sounds/Weapons/ag36/ag36b_15.wav")},
		{	"reload1",	23,			Sound:LoadSound("Sounds/Weapons/ag36/Ag36b_23.wav",0,150)},
		{	"reload1",	38,			Sound:LoadSound("Sounds/Weapons/ag36/Ag36b_38.wav",0,150)},
		{	"reload1",	54,			Sound:LoadSound("Sounds/Weapons/ag36/Ag36b_54.wav",0,150)},
		{	"reload2",	13,			Sound:LoadSound("Sounds/Weapons/ag36/ag36g_13.wav",0,150)},
		{	"reload2",	37,			Sound:LoadSound("Sounds/Weapons/ag36/ag36g_37.wav",0,150)},
--		{	"swim",		1,			Sound:LoadSound("Sounds/player/water/underwaterswim2.wav",0,255)},

	},

	TargetHelperImage = System:LoadImage("Textures/Hud/crosshair/g36.tga"),
	NoTargetImage = System:LoadImage("Textures/Hud/crosshair/noTarget.dds"),	
}

AG36 = AG36SP;

if (Game:IsMultiplayer()) then
	AG36 = AG36MP;
end


CreateBasicWeapon(AG36);

function AG36.Client:OnEnhanceHUD(scale, bHit)
--function AG36.Client:OnEnhanceHUD()
	
	if (_localplayer.cnt.firemode == 1) then
		System:DrawImageColor(self.TargetHelperImage, 400 - 15, 300 - 15, 30, 30, 4, 1, 0, 0, 1);			
		BasicWeapon.Client.OnEnhanceHUD(self);		
	else
		local posX = 400;
		local posY = 300;
		BasicWeapon.Client.OnEnhanceHUD(self, scale, bHit, posX, posY);
	end
end


---------------------------------------------------------------
--ANIMTABLE
------------------
--AUTOMATIC FIRE
AG36.anim_table={}
AG36.anim_table[1]={
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
	melee={
		"Fire13",
		"Fire23",
	},
	swim={
		"swim"
	},
	activate={
		"Activate1"
	},
}
------------------
--GRENADE LAUNCHER
AG36.anim_table[2]={
	idle={
		"Idle11",
		"Idle21",
	},
	reload={
		"Reload2",
	},
	fidget={
		"fidget11",
	},
	fire={
		"Fire12",
	},
	melee={
		"Fire13",
		"Fire23",
	},
	swim={
		"swim"
	},
	activate={
		"Activate2"
	},
}
