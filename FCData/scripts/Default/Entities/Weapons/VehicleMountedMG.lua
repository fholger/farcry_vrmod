VehicleMountedMG = {
	name = "VehicleMountedMG",
	
	PlayerSlowDown = 1.0,									-- factor to slow down the player when he holds that weapon
--	character	= "Objects/Vehicles/Mounted_gun/m2.cga",
	---------------------------------------------------
	ActivateSound = Sound:Load3DSound("Sounds/Weapons/M4/m4weapact.wav"),	-- sound to play when this weapon is selected
	AimMode=1,
	
	ZoomNoSway=1, 			--no sway in zoom mode
	ZoomOverlayFunc=AimModeZoomHUD.DrawHUD,
	---------------------------------------------------
	ZoomFixedFactor=1,
	FireParams ={													-- describes all supported firemodes
	{
		vehicleWeapon = 1,
		no_zoom = 1,
		HasCrosshair=1,
--		draw_thirdperson = 1,--if 1 the crosshair will be showed also in thirdperson view
		AmmoType="VehicleMG",
		min_recoil=0,
		max_recoil=0,
		reload_time=0.1, -- default 2.8
		fire_rate=0.082,
		distance=1600,
		damage=20, -- default =7
		damage_drop_per_meter=.004,
		bullet_per_shot=1,
		bullets_per_clip=500,
		FModeActivationTime = 2.0,
		iImpactForceMul = 50,
		iImpactForceMulFinal = 140,
		
		FireLoop="Sounds/Weapons/mounted/FINAL_M249_STEREO_MONO.wav",
		FireLoopStereo="Sounds/Weapons/mounted/FINAL_M249_STEREO_LOOP.wav",
		TrailOff="Sounds/Weapons/mounted/FINAL_M249_MONO_TAIL.wav",
		TrailOffStereo="Sounds/Weapons/mounted/FINAL_M249_STEREO_TAIL.wav",
		
		DrySound = "Sounds/Weapons/DE/dryfire.wav",
		HapticFireEffect = "mg_fire",
		
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
		
		--------------------
		--particle weaponfx
		SmokeEffect = {
			size = {0.25,0.17,0.135,0.1},
			size_speed = 1.3,
			speed = 20.0,
			focus = 2,
			lifetime = 0.2,
			sprite = System:LoadTexture("textures\\cloud1.dds"),
			stepsoffset = 0.3,
			steps = 4,
			gravity = 1.2,
			AirResistance = 3,
			rotation = 3,
			randomfactor = 50,
		},
		
		MuzzleEffect = {
			size = {0.2},
			size_speed = 5.0,
			speed = 0.0,
			focus = 20,
			lifetime = 0.03,
			sprite = System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzle1.dds"),
			stepsoffset = 0.1,
			steps = 1,--10,
			gravity = 0.0,
			AirResistance = 0,
			rotation = 30,
			randomfactor = 25,
			--color = {0.5,0.5,0.5},
		},
		--------------------

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

		SoundMinMaxVol = { 255, 10, 4000 },
	},
	{
		vehicleWeapon = 1,		
		HasCrosshair=1,
		no_zoom = 1,
--		draw_thirdperson = 1,--if 1 the crosshair will be showed also in thirdperson view
		AmmoType="VehicleRocket",
		projectile_class="VehicleRocket",
		reload_time=4.5, -- default 3.82
		fire_rate=3.65,
--		fire_activation=FireActivation_OnPress,
		bullet_per_shot=1,
		bullets_per_clip=30,
		FModeActivationTime = 0.0,
		iImpactForceMul = 10,
		
		FireSounds = {
			"Sounds/Weapons/rl/FINAL_RL_MONO.wav",
		},
		FireSoundsStereo = {
			"Sounds/Weapons/rl/FINAL_RL_STEREO.wav",
			
		},
		DrySound = "Sounds/Weapons/AG36/DryFire.wav",

		LightFlash = {
			fRadius = 5.0,
			vDiffRGBA = { r = 1.0, g = 1.0, b = 0.0, a = 1.0, },
			vSpecRGBA = { r = 0.3, g = 0.3, b = 0.3, a = 1.0, },
			fLifeTime = 0.25,
		},

		SoundMinMaxVol = { 255, 6, 4000 },
	},
	-- special AI firemode follows
	{
		vehicleWeapon = 1,
		no_zoom = 1,
		HasCrosshair=1,
--		draw_thirdperson = 1,--if 1 the crosshair will be showed also in thirdperson view
		AmmoType="Unlimited",
		min_recoil=0,
		max_recoil=0,
		reload_time=0.1,
		fire_rate=0.082,
		distance=1600,
		damage=20,
		damage_drop_per_meter=.004,
		bullet_per_shot=1,
		bullets_per_clip=500,
		FModeActivationTime = 2.0,
		iImpactForceMul = 50,
		iImpactForceMulFinal = 140,
		
		FireLoop="Sounds/Weapons/mounted/FINAL_M249_STEREO_MONO.wav",
		FireLoopStereo="Sounds/Weapons/mounted/FINAL_M249_STEREO_LOOP.wav",
		TrailOff="Sounds/Weapons/mounted/FINAL_M249_MONO_TAIL.wav",
		TrailOffStereo="Sounds/Weapons/mounted/FINAL_M249_STEREO_TAIL.wav",
		
		DrySound = "Sounds/Weapons/DE/dryfire.wav",
		
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
		
		--------------------
		--particle weaponfx
		SmokeEffect = {
			size = {0.25,0.17,0.135,0.1},
			size_speed = 1.3,
			speed = 20.0,
			focus = 2,
			lifetime = 0.2,
			sprite = System:LoadTexture("textures\\cloud1.dds"),
			stepsoffset = 0.3,
			steps = 4,
			gravity = 1.2,
			AirResistance = 3,
			rotation = 3,
			randomfactor = 50,
		},
		
		MuzzleEffect = {
			size = {0.2},
			size_speed = 5.0,
			speed = 0.0,
			focus = 20,
			lifetime = 0.03,
			sprite = System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzle1.dds"),
			stepsoffset = 0.1,
			steps = 1,--10,
			gravity = 0.0,
			AirResistance = 0,
			rotation = 30,
			randomfactor = 25,
			--color = {0.5,0.5,0.5},
		},
		--------------------

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

		SoundMinMaxVol = { 255, 10, 4000 },
	},
	
	},

	SoundEvents={
	--	animname,	frame,	soundfile		
	{	"reload1",	20,			Sound:LoadSound("Sounds/Weapons/M4/M4_20.wav")},
	{	"reload1",	33,			Sound:LoadSound("Sounds/Weapons/M4/M4_33.wav")},
	{	"reload1",	47,			Sound:LoadSound("Sounds/Weapons/M4/M4_47.wav")},
	},
	
	
	CrosshairParticles = {
		focus = 0,
		speed = 0.0,
		count = 1,
		size = 0.15, 
		size_speed=0.0,
		gravity={x=0.0,y=0.0,z=-0.0},
		rotation={x=0.0,y=0.0,z=0.0},
		lifetime=0.0,
		tid = System:LoadTexture("textures\\cloud.dds"),
		start_color = {1,.2,.2},
		end_color = {1,.2,.2},
		blend_type = 2,
		frames=0,
		draw_last=1,
	},
	
	cross3D = 1;
}

CreateBasicWeapon(VehicleMountedMG);

--function VehicleMountedMG.Client:OnEnhanceHUD(bHit)
--
--	BasicWeapon.DoAutoCrosshair( self, bHit);
--
--end
