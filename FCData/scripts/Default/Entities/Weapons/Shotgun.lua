Shotgun = {
	name			= "Shotgun",
	object		= "Objects/Weapons/pancor/pancor_bind.cgf",
	character	= "Objects/Weapons/pancor/pancor.cgf",
	
	-- fixme: no right hand bone?
	BoneRightHand = "weapon",
	BoneLeftArm = "Bone25",
	
	PlayerSlowDown = 0.75,									-- factor to slow down the player when he holds that weapon
	---------------------------------------------------
	ActivateSound = Sound:LoadSound("Sounds/Weapons/Pancor/jackwaepact.wav",0,100),	-- sound to play when this weapon is selected
	---------------------------------------------------

	MaxZoomSteps =  1,
	ZoomSteps = { 1.4 },
	ZoomActive = 0,
	AimMode=1,
	ZoomNoSway=1, 			--no sway in zoom mode
	ZoomOverlayFunc=AimModeZoomHUD.DrawHUD,

	---------------------------------------------------

	FireParams ={													-- describes all supported firemodes
	{
		HasCrosshair=1,
		AmmoType="Shotgun",
		reload_time=2.4, -- default 3.25
		fire_rate=0.7,
		fire_activation=bor(FireActivation_OnPress,FireActivation_OnHold),
		distance=100,
		damage=20, -- default 30
		damage_drop_per_meter=.080,
		bullet_per_shot=5,
		bullets_per_clip=10,
		FModeActivationTime = 1.0,
		iImpactForceMul = 25, -- 5 bullets divided by 10
		iImpactForceMulFinal = 100, -- 5 bullets divided by 10	
		
		BulletRejectType=BULLET_REJECT_TYPE_SINGLE,
		
		-- make sure that the last parameter in each sound (max-distance) is equal to "whizz_sound_radius"
		whizz_sound_radius=8,
		whizz_probability=350,	-- 0-1000
		whizz_sound={
			Sound:Load3DSound("Sounds/weapons/bullets/whiz1.wav",SOUND_UNSCALABLE,55,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz2.wav",SOUND_UNSCALABLE,55,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz3.wav",SOUND_UNSCALABLE,55,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz4.wav",SOUND_UNSCALABLE,55,1,8),
		},
		
		FireSounds = {
			"Sounds/Weapons/Pancor/FINAL_PANCOR1_MONO.wav",
			"Sounds/Weapons/Pancor/FINAL_PANCOR2_MONO.wav",
			"Sounds/Weapons/Pancor/FINAL_PANCOR3_MONO.wav",
		},
		FireSoundsStereo = {
			"Sounds/Weapons/pancor/FINAL_PANCOR1_STEREO.wav",
			"Sounds/Weapons/pancor/FINAL_PANCOR2_STEREO.wav",
			"Sounds/Weapons/pancor/FINAL_PANCOR3_STEREO.wav",
		},
		DrySound = "Sounds/Weapons/Pancor/DryFire.wav",
		ReloadSound = "Sounds/Weapons/Pancor/jackrload.wav",

		LightFlash = {
			fRadius = 5.0,
			vDiffRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			vSpecRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			fLifeTime = 0.1,
		},
		
		SmokeEffect = {
			size = {0.6,0.3,0.15,0.07,0.035,0.035},
			size_speed = 0.7,
			speed = 9.0,
			focus = 3,
			lifetime = 0.9,
			sprite = System:LoadTexture("textures\\cloud1.dds"),
			stepsoffset = 0.3,
			steps = 6,
			gravity = 0.6,
			AirResistance = 2,
			rotation = 3,
			randomfactor = 50,
		},
		
		MuzzleEffect = {
			size = {0.175},
			size_speed = 3.3,
			speed = 0.0,
			focus = 20,
			lifetime = 0.03,
			sprite = System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzle1.dds"),
			stepsoffset = 0.05,
			steps = 1,
			gravity = 0.0,
			AirResistance = 0,
			rotation = 30,
			randomfactor = 10,
		},

		-- remove this if not nedded for current weapon
		MuzzleFlash = {
			geometry_name = "Objects/Weapons/Muzzle_flash/mf_Pancor_fpv.cgf",
			bone_name = "spitfire",
			lifetime = 0.1,
		},
		MuzzleFlashTPV = {
			geometry_name = "Objects/Weapons/Muzzle_flash/mf_Pancor_tpv.cgf",
			bone_name = "weapon_bone",
			lifetime = 0.05,
		},
		
		SoundMinMaxVol = { 225, 4, 2600 },
	},
	},

		SoundEvents={
		--	animname,	frame,	soundfile												---
		{	"reload1",	29,			Sound:LoadSound("Sounds/Weapons/Pancor/pancor_29.wav",0,100)},
		{	"reload1",	45,			Sound:LoadSound("Sounds/Weapons/Pancor/pancor_49.wav",0,100)},
--		{	"swim",		1,			Sound:LoadSound("Sounds/player/water/underwaterswim2.wav",0,255)},
	},
}

CreateBasicWeapon(Shotgun);

---------------------------------------------------------------
--ANIMTABLE
------------------
Shotgun.anim_table={}
--AUTOMATIC FIRE
Shotgun.anim_table[1]={
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
		"Fire23",
	},
	swim={
		"swim",
	},
	activate={
		"Activate1",
	},
	--modeactivate={},
}