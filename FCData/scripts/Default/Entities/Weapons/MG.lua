Game:CreateHapticsEffectFlat("mg_fire", 0.1, 0.25);

MG = {
	name = "MG",
	
	PlayerSlowDown = 1.0,									-- factor to slow down the player when he holds that weapon
	---------------------------------------------------
	ActivateSound = Sound:Load3DSound("Sounds/Weapons/M4/m4weapact.wav"),	-- sound to play when this weapon is selected
	AimMode=1,
	
	ZoomNoSway=1, 			--no sway in zoom mode
	ZoomOverlayFunc=AimModeZoomHUD.DrawHUD,
	---------------------------------------------------
	ZoomFixedFactor=1,
	FireParams ={													-- describes all supported firemodes
	{
		no_zoom = 1,
		HasCrosshair=1,
		AmmoType="Unlimited",
		ammo=120,
		min_recoil=0,
		max_recoil=0,
		reload_time=0.1, -- default 2.8
		fire_rate=0.082,
		distance=1600,
		damage=20, -- default =7
		damage_drop_per_meter=.004,
		bullet_per_shot=1,
		bullets_per_clip=300,
		FModeActivationTime = 2.0,
		iImpactForceMul = 50,
		iImpactForceMulFinal = 140,
		no_ammo=1,

		-- make sure that the last parameter in each sound (max-distance) is equal to "whizz_sound_radius"
		whizz_sound_radius=8,
		whizz_probability=350,	-- 0-1000
		whizz_sound={
			Sound:Load3DSound("Sounds/weapons/bullets/whiz1.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz2.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz3.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz4.wav",SOUND_UNSCALABLE,100,1,8),
		},
		
		FireLoop="Sounds/Weapons/mounted/vulcan_mono.wav",
		FireLoopStereo="Sounds/Weapons/mounted/vulcan.wav",
		TrailOff="Sounds/Weapons/mounted/FINAL_M249_MONO_TAIL.wav",
		TrailOffStereo="Sounds/Weapons/mounted/FINAL_M249_STEREO_TAIL.wav",
		
		DrySound = "Sounds/Weapons/DE/dryfire.wav",
		HapticFireEffect = "mg_fire",
		BHapticsFireRight = "m4_fire_r",
		BHapticsFireLeft = "m4_fire_l",
		BHapticsIntensity = 0.1,
		
		LightFlash = {
			fRadius = 5.0,
			vDiffRGBA = { r = 1.0, g = 1.0, b = 0.0, a = 1.0, },
			vSpecRGBA = { r = 0.3, g = 0.3, b = 0.3, a = 1.0, },
			fLifeTime = 0.75,
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
			size = {0.25,0.17,0.135,0.1},
			size_speed = 1.3,
			speed = 20.0,
			focus = 2,
			lifetime = 0.15,
			sprite = System:LoadTexture("textures\\cloud1.dds"),
			stepsoffset = 0.3,
			steps = 4,
			gravity = 1.2,
			AirResistance = 3,
			rotation = 3,
			randomfactor = 50,
		},
		
		MuzzleEffect = {
			size = {0.2},--0.07},
			size_speed = 5.0,
			speed = 0.0,
			focus = 20,
			lifetime = 0.03,
			sprite = System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzle1.dds"),
			stepsoffset = 0.07,
			steps = 1,--10,
			gravity = 0.0,
			AirResistance = 0,
			rotation = 30,
			randomfactor = 25,
			--color = {0.5,0.5,0.5},
		},

		-- remove this if not nedded for current weapon
		MuzzleFlash = {
			geometry_name = "Objects/Weapons/Muzzle_flash/mf_MG_fpv.cgf",
			bone_name = "spitfire",
			lifetime = 0.15,
		},
		MuzzleFlashTPV = {
			geometry_name = "Objects/Weapons/Muzzle_flash/mf_MG_tpv.cgf",
			bone_name = "spitfire",
			lifetime = 0.05,
		},

		-- trace "moving bullet"	
		-- remove this if not nedded for current weapon
		Trace = {
			geometry=System:LoadObject("Objects/Weapons/trail_mounted.cgf"),
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

		SoundMinMaxVol = { 225, 4, 2600 },

	},
	},

	SoundEvents={
	--	animname,	frame,	soundfile		
	{	"reload1",	20,			Sound:LoadSound("Sounds/Weapons/M4/M4_20.wav")},
	{	"reload1",	33,			Sound:LoadSound("Sounds/Weapons/M4/M4_33.wav")},
	{	"reload1",	47,			Sound:LoadSound("Sounds/Weapons/M4/M4_47.wav")},
	},
}

CreateBasicWeapon(MG);
