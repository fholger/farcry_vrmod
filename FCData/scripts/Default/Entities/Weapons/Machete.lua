Machete = {
	name			= "Machete",
	object		= "objects/weapons/machete/machete_bind.cgf",
	character	= "objects/weapons/machete/machete.cgf",
	
	BoneRightHand = "Bone03",
	BoneLeftHand = "Bone19",
	SpitFireBone = "Bone13",
	TwoHandedMode = 0,

	-- factor to slow down the player when he holds that weapon
	PlayerSlowDown = 1.0,	
	---------------------------------------------------
	ActivateSound = Sound:LoadSound("sounds/weapons/machete/machete_pickup.wav",0,120),	-- sound to play when this weapon is selected
	---------------------------------------------------
	NoZoom=1,
	---------------------------------------------------
	-- describes all supported firemodes
	FireParams ={													
	{
		type = 3,			-- used for choosing animation - is a melee weapon 	
		AmmoType="Unlimited",
		reload_time=0.01,
		fire_rate=0.3,
		distance=1.4,
		damage=20,
		bullet_per_shot=1,
		bullets_per_clip=20,
		FModeActivationTime = 2.0,
		iImpactForceMul = 80,
		iImpactForceMulFinal = 80,
		fire_activation=bor(FireActivation_OnPress),
		FireSounds = {
			"sounds/weapons/machete/fire1.wav",
			"sounds/weapons/machete/fire2.wav",
			"sounds/weapons/machete/fire3.wav",
		},
		
		no_ammo=1,
		SoundMinMaxVol = { 205, 1, 20 },
	},
	},
}

CreateBasicWeapon(Machete);

---------------------------------------------------------------
--ANIMTABLE
------------------
--SINGLE FIRE
Machete.anim_table={}
Machete.anim_table[1]={
	idle={
		"Idle11",
		"Idle21",
	},
	fidget={
		"fidget11",
		"fidget21",
	},
	fire={
		--"Fire11",
		"Fire21",
	},
	swim={
		"swim"
	},
	activate={
		"Activate1"
	},
}