MP5 = {
	-- DESCRIPTION:
	-- No Single shot
	-- Small recoil, does not travel far (300m), quiet
	-- good stealth gun
	name			= "MP5",
	object		= "Objects/Weapons/MP5/MP5_bind.cgf",
	character	= "Objects/Weapons/MP5/MP5.cgf",
	
	-- fixme: no right hand bone?
	BoneRightHand = "weapon",
	BoneLeftArm = "Bone25",

	---------------------------------------------------
	PlayerSlowDown = 0.85,			-- factor to slow down the player when he holds that weapon
	---------------------------------------------------
	ActivateSound = Sound:LoadSound("Sounds/Weapons/MP5/mp5weapact.wav",0,100),	-- sound to play when this weapon is selected
	---------------------------------------------------

	-- if the weapon supports zooming then add this...
	MaxZoomSteps =  1,
	ZoomSteps = { 1.4 },
	ZoomActive = 0,
	AimMode=1,
	
	ZoomOverlayFunc=AimModeZoomHUD.DrawHUD,
	ZoomFixedFactor=1,
	ZoomNoSway=1, --no sway in zoom mode
	
	---------------------------------------------------

	FireParams =
	{													-- describes all supported 	firemodes
		{
		HasCrosshair=1,
		AmmoType="SMG",
		reload_time=2.6,
		fire_rate=0.1,
		distance=100,
		damage=11, 
		damage_drop_per_meter=0.011,
		bullet_per_shot=1,
		bullets_per_clip=30,
		FModeActivationTime = 1.0,
		fire_activation=bor(FireActivation_OnPress,FireActivation_OnHold),
		iImpactForceMul = 20,
		iImpactForceMulFinal = 45,
		
		BulletRejectType=BULLET_REJECT_TYPE_RAPID,
		
		-- make sure that the last parameter in each sound (max-distance) is equal to "whizz_sound_radius"
		whizz_sound_radius=6,
		whizz_probability=350,	-- 0-1000
		whizz_sound={
			Sound:Load3DSound("Sounds/weapons/bullets/whiz1.wav",SOUND_UNSCALABLE,100,1,6),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz2.wav",SOUND_UNSCALABLE,100,1,6),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz3.wav",SOUND_UNSCALABLE,100,1,6),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz4.wav",SOUND_UNSCALABLE,100,1,6),
		},

		-- recoil values
		min_recoil=0,
		max_recoil=2.1,	-- default 0.6 its only a small recoil as more people seem to like it that way
		
		FireLoop="Sounds/Weapons/mp5/FINAL_MP5_MONO_LOOP.wav",
		FireLoopStereo="Sounds/Weapons/mp5/FINAL_MP5_STEREO_LOOP.wav",
		TrailOff="Sounds/Weapons/mp5/FINAL_MP5_MONO_TAIL.wav",
		TrailOffStereo="Sounds/Weapons/mp5/FINAL_MP5_STEREO_TAIL.wav",
		DrySound ="Sounds/Weapons/MP5/DryFire.wav",

		SmokeEffect = {
			size = {0.15,0.07,0.035,0.01},
			size_speed = 1.3,
			speed = 3.0,
			focus = 2,
			lifetime = 0.3,
			sprite = System:LoadTexture("textures\\cloud1.dds"),
			stepsoffset = 0.3,
			steps = 4,
			gravity = 1.2,
			AirResistance = 3,
			rotation = 3,
			randomfactor = 50,
		},
		
		ShellCases = {
			--filippo:mp5 do not use rifle shells :)
			geometry=System:LoadObject("Objects/Weapons/shells/smgshell.cgf"),
			--geometry=System:LoadObject("Objects/Weapons/shells/rifleshell.cgf"),
		
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

		-- trace "moving bullet"	
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
			bouncyness = 0,
		},

		SoundMinMaxVol = { 200, 4, 500 },

		LightFlash = {
			fRadius = 3.0,
			vDiffRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			vSpecRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			fLifeTime = 0.1,
		},
		
		},	
	--SINGLE SHOT--------------------------------
		{
		-- more recoil, more power, travels further
		HasCrosshair=1,
		AmmoType="SMG",
		ammo=120,
		reload_time=2.3, 	-- default 2.8
		fire_rate=0.2,
		fire_activation=FireActivation_OnPress,
		distance=200,
		damage=15, 		-- default =7
		damage_drop_per_meter=.011,	-- default .011
		bullet_per_shot=1,
		bullets_per_clip=30,
		FModeActivationTime = 0,
		iImpactForceMul = 10,
		iImpactForceMulFinal = 45,
		
		BulletRejectType=BULLET_REJECT_TYPE_SINGLE,
		
		-- make sure that the last parameter in each sound (max-distance) is equal to "whizz_sound_radius"
		whizz_sound_radius=6,
		whizz_sound={
			Sound:Load3DSound("Sounds/weapons/bullets/whiz1.wav",SOUND_UNSCALABLE,100,1,6),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz2.wav",SOUND_UNSCALABLE,100,1,6),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz3.wav",SOUND_UNSCALABLE,100,1,6),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz4.wav",SOUND_UNSCALABLE,100,1,6),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz5.wav",SOUND_UNSCALABLE,100,1,6),
			
		},	
		
		-- recoil values
		min_recoil=2,
		max_recoil=2.5, -- more recoil
		
		FireSounds = {"Sounds/Weapons/mp5/FINAL_MP5_MONO_SINGLE.wav"},
		FireSoundsStereo = {"Sounds/Weapons/mp5/FINAL_MP5_STEREO_SINGLE.wav"},
		DrySound = "Sounds/Weapons/DE/dryfire.wav",
		
		LightFlash = {
			fRadius = 3.0,
			vDiffRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			vSpecRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			fLifeTime = 0.1,
		},
		
		SmokeEffect = {
			size = {0.15,0.07,0.035,0.01},
			size_speed = 1.3,
			speed = 3.0,
			focus = 2,
			lifetime = 0.3,
			sprite = System:LoadTexture("textures\\cloud1.dds"),
			stepsoffset = 0.3,
			steps = 4,
			gravity = 1.2,
			AirResistance = 3,
			rotation = 3,
			randomfactor = 50,
		},
		
		ShellCases = {
			--filippo: CGFName do not works
			geometry=System:LoadObject("Objects/Weapons/shells/smgshell.cgf"),
			--CGFName = "Objects/Weapons/shells/rifleshell.cgf",
			
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

		-- trace "moving bullet"	
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
			bouncyness = 0,
		},
		
		SoundMinMaxVol = { 135, 5, 500 },
		},
		
	},

		SoundEvents={
		--	animname,	frame,	soundfil
		{	"reload1",	17,			Sound:LoadSound("Sounds/Weapons/MP5/mp5_18.wav",0,100)},
		{	"reload1",	32,			Sound:LoadSound("Sounds/Weapons/MP5/mp5_41.wav",0,100)},
		{	"reload1",	48,			Sound:LoadSound("Sounds/Weapons/MP5/mp5_57.wav",0,100)},
--		{	"swim",		1,			Sound:LoadSound("Sounds/player/water/underwaterswim2.wav",0,255)},
	},
}

CreateBasicWeapon(MP5);

---------------------------------------------------------------
--ANIMTABLE
------------------
MP5.anim_table={}
--AUTOMATIC FIRE
MP5.anim_table[1]={
	idle={
		"Idle11",
		"Idle21",
	},
	reload={
		"Reload1",	
	},
	fidget={
		"fidget11",
		"fidget21",
	},
	fire={
		"Fire11",
		"Fire21",
	},
	melee={
		"Fire23",
	},
	swim={
		"swim",
	},
	activate={
		"Activate1",
	},
}

--SINGLE FIRE
MP5.anim_table[2]=MP5.anim_table[1];
