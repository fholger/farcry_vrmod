Shocker = {
	name			= "Shocker",
	object		= "Objects/Weapons/Shocker/Shocker_bind.cgf",
	character	= "Objects/Weapons/Shocker/Shocker.cgf",
	
	BoneRightHand = "Bone03",
	BoneLeftHand = "Bone19",
	
	-- factor to slow down the player when he holds that weapon
	PlayerSlowDown = 1.0,	
	---------------------------------------------------
	NoZoom=1,
	---------------------------------------------------
	-- describes all supported firemodes
	FireParams ={													
	{

		MuzzleFlash = {
			geometry_name = "Objects/Weapons/Muzzle_flash/mf_shocker_fpv.cgf",
			bone_name = "spitfire1",
			lifetime = 0.15,
		},

		type = 3,		-- used for choosing animation - is a melee weapon
		AmmoType="Unlimited",
		reload_time=0.1,
		fire_rate=0.3,
		distance=1.4,
		damage=20,
		bullet_per_shot=1,
		bullets_per_clip=20,
		FModeActivationTime = 2.0,
		iImpactForceMul = 0,
		iImpactForceMulFinal = 0,
		fire_activation=bor(FireActivation_OnPress,FireActivation_OnHold),
		FireSounds = {
			"Sounds/Weapons/Shocker/fire1.wav",
			"Sounds/Weapons/Shocker/fire2.wav",
			"Sounds/Weapons/Shocker/fire3.wav",
		},
		DrySound = "Sounds/Weapons/Shocker/dryfire.wav",
		ReloadSound = "Sounds/Weapons/Shocker/reload.wav",
		ExitEffect = "misc.shocker.b",

		SoundMinMaxVol = { 255, 5, 20 },
		
		mat_effect = "nothing",
	
		LightFlash = {
			fRadius = 3.0,
			vDiffRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			vSpecRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			fLifeTime = 0.1,
		},
	},
	},

	SoundEvents={
		--	animname,	frame,	soundfile
	},
}

CreateBasicWeapon(Shocker);

---------------------------------------------------------------
--ANIMTABLE
------------------
Shocker.anim_table={}
--AUTOMATIC FIRE
Shocker.anim_table[1]={
	idle={
		"Idle11",
		"Idle21",
	},
	fidget={
		"fidget11",
		"fidget21",
	},
	fire={
		"Fire11",
		"Fire21",
	},
	swim={
		"swim"
	},
	activate={
		"Activate1",
	},
}