ScoutTool = {
	-- DESCRIPTION
	-- Scout class specific tool
	name			= "ScoutTool",
	object		= "Objects/Weapons/explosive/explosive_bind.cgf",
	character	= "Objects/Weapons/explosive/explosive.cgf",	
	
	BoneRightHand = "Bone03",
	BoneLeftHand = "Bone19",

	PlayerSlowDown = 1.0,									-- factor to slow down the player when he holds that weapon
	---------------------------------------------------
	NoZoom=1,
	---------------------------------------------------
	switch_on_empty_ammo = 1,
	
	special_bone_to_bind = "Bip01 L Hand", --usually the weapon model is attached to "weapon_bone" bone, 
					       --but some weapons should need a different bone, like this one.
					       --if "special_bone_to_bind" doesnt exist "weapon_bone" will be taken.

	FireParams ={													-- describes all supported firemodes
	{
		no_reload = 1,--dont play player reload animation
		FModeActivationTime=1,
		HasCrosshair=nil,
		type = 5,
		AmmoType="StickyExplosive",
		projectile_class="StickyExplosive",
		ammo=50,
		reload_time=2.5,
		fire_rate=1.0,
		fire_activation=FireActivation_OnPress,
		bullet_per_shot=1,
		bullets_per_clip=1,
		
		FireSounds = {
			"sounds/items/throw.wav",
		},
		
		SoundMinMaxVol = { 255, 5, 200 },
	},
	},
	
	SoundEvents={
		--	animname,	frame,	soundfile												---
	},

	GrenadeThrowFrame = 12,
}

CreateBasicWeapon(ScoutTool);

---------------------------------------------------------------
--ANIMTABLE
------------------
ScoutTool.anim_table={}

ScoutTool.anim_table[1]={
	idle={
		"Idle11",
	},
	fire={
		"Fire11",
	},
	reload={
		"Activate1",
	},
	swim={
		"swim"
	},
	activate={
		"Activate1"
	},
}
