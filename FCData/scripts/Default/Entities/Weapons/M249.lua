M249 = {
	name			= "M249",
	object		= "Objects/Weapons/M249/M249_bind.cgf",
	character	= "Objects/Weapons/M249/M249.cgf",
	
	BoneRightHand = "Bone67",
	BoneLeftHand = "Bone19",
	
	MaxZoomSteps =  1,
	ZoomSteps = { 1.4 },
	ZoomActive = 0,
	AimMode=1,
	
	ZoomOverlayFunc=AimModeZoomHUD.DrawHUD,
	ZoomFixedFactor=1,
	ZoomNoSway=1, 			--no sway in zoom mode
	
	PlayerSlowDown = 0.7,									-- factor to slow down the player when he holds that weapon
	---------------------------------------------------
	ActivateSound = Sound:Load3DSound("Sounds/Weapons/M4/m4weapact.wav"),	-- sound to play when this weapon is selected
	---------------------------------------------------
	ZoomFixedFactor=1,
	FireParams ={													-- describes all supported firemodes
	{
		HasCrosshair=1,
		AmmoType="Assault",
		reload_time= 3.3,
		fire_rate= 0.082,
		distance= 1600,
		damage= 20,
		damage_drop_per_meter= 0.004,
		bullet_per_shot = 1,
		bullets_per_clip = 100,
		FModeActivationTime = 2.0,
		iImpactForceMul = 50,
		iImpactForceMulFinal = 140,
		
		-- make sure that the last parameter in each sound (max-distance) is equal to "whizz_sound_radius"
		whizz_sound_radius=8,
		whizz_probability=250,	-- 0-1000
		whizz_sound={
			Sound:Load3DSound("Sounds/weapons/bullets/whiz1.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz2.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz3.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz4.wav",SOUND_UNSCALABLE,100,1,8),
		},
		
		FireLoop="Sounds/Weapons/m4/m4loop.wav",
		FireLoopStereo="Sounds/Weapons/mounted/FINAL_M249_STEREO_LOOP.wav",
		TrailOff="Sounds/Weapons/m4/m4tail.wav",
		TrailOffStereo="Sounds/Weapons/mounted/FINAL_M249_STEREO_TAIL.wav",
		
		DrySound = "Sounds/Weapons/DE/dryfire.wav",
		
		LightFlash = {
			fRadius = 3.0,
			vDiffRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			vSpecRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			fLifeTime = 0.1,
		},
	
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
					
			size = {0.15,0.003},--0.15,0.25,0.35,0.3,0.2},
			size_speed = 4.3,
			speed = 0.0,
			focus = 20,
			lifetime = 0.03,
			
			sprite = {
					{
						System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzlesix3.dds"),
						System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzlesix4.dds"),
						System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzlesix5.dds"),
					}
					,
					{
						System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzle4.dds"),
						System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzle5.dds"),
						System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzle6.dds"),
					}
				},
				
			stepsoffset = 0.05,
			steps = 2,
			gravity = 0.0,
			AirResistance = 0,
			rotation = 3,
			randomfactor = 10,
			color = {0.9,0.9,0.9},
		},

		-- remove this if not nedded for current weapon
		MuzzleFlash = {
			geometry_name = "Objects/Weapons/Muzzle_flash/mf_m4_fpv.cgf",
			bone_name = "spitfire",
			lifetime = 0.1,
		},
		MuzzleFlashTPV = {
			geometry_name = "Objects/Weapons/Muzzle_flash/mf_m4_tpv.cgf",
			bone_name = "weapon_bone",
			lifetime = 0.05,
		},

		-- trace "moving bullet"	
		-- remove this if not nedded for current weapon
		Trace = {
			--filippo: CGFName do not works
			geometry=System:LoadObject("Objects/Weapons/trail.cgf"),
			--CGFName = "Objects/Weapons/trail.cgf",
			
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

		SoundMinMaxVol = { 175, 4, 2600 },

	},
	},

		SoundEvents={
		--	animname,	frame,	soundfile		
		{	"reload1",	1,			Sound:LoadSound("Sounds/Weapons/M4/M249_reload1.wav")},
		{	"reload1",	48,			Sound:LoadSound("Sounds/Weapons/M4/M249_reload2.wav")},
		{	"reload1",	85,			Sound:LoadSound("Sounds/Weapons/M4/M249_reload3.wav")},
	},
	GrenadeThrowFrame = 12,
}

CreateBasicWeapon(M249);
---------------------------------------------------------------
--ANIMTABLE
------------------
M249.anim_table={}
--AUTOMATIC FIRE
M249.anim_table[1]={
	idle={
		"Idle11",
		"Idle21",
	},
	reload={
		"Reload1",	
	},
	fire={
		"Fire11",
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