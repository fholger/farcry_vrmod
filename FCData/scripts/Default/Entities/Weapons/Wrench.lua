Wrench = {
	name		= "Wrench",
	object		= "Objects/Weapons/wrench/wrench_bind.cgf",
	character	= "Objects/Weapons/wrench/wrench.cgf",
	
	BoneRightHand = "Bone03",
	BoneLeftHand = "Bone19",
	TwoHandedMode = 0,
	
	-- factor to slow down the player when he holds that weapon
	PlayerSlowDown = 0.9,	
	---------------------------------------------------
	NoZoom=1,
	---------------------------------------------------
	-- describes all supported firemodes
	FireParams ={													
	{
		AmmoType="Unlimited",
		accuracy=1,
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
			"Sounds/Weapons/Machete/fire1.wav",		-- todo
			"Sounds/Weapons/Machete/fire2.wav",		-- todo
			"Sounds/Weapons/Machete/fire3.wav",		-- todo
		},
		
		no_ammo=1,
		SoundMinMaxVol = { 255, 5, 20 },
	},
	},

--	SoundEvents={
		--	animname,	frame,	soundfile
--		{	"swim",		1,			Sound:LoadSound("Sounds/player/water/underwaterswim2.wav",0,255)},
--	},
}

CreateBasicWeapon(Wrench);

---------------------------------------------------------------
--ANIMTABLE
------------------
--SINGLE FIRE
Wrench.anim_table={}
Wrench.anim_table[1]={
	idle={
		"Idle11",
		"Idle21",
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