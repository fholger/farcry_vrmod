VehicleMountedRocket = {
	name = "VehicleMountedRocket",
	
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
		HasCrosshair=1,
		no_zoom = 1,
		draw_thirdperson = 1,--if 1 the crosshair will be showed also in thirdperson view
		AmmoType="VehicleRocket",
		projectile_class="VehicleRocket",
		reload_time=4.5, -- default 3.82
		fire_rate=3.65,
		fire_activation=FireActivation_OnPress,
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
		HapticFireEffect = "rl_fire",

		LightFlash = {
			fRadius = 5.0,
			vDiffRGBA = { r = 1.0, g = 1.0, b = 0.0, a = 1.0, },
			vSpecRGBA = { r = 0.3, g = 0.3, b = 0.3, a = 1.0, },
			fLifeTime = 0.25,
		},

		SoundMinMaxVol = { 255, 5, 4000 },
	},
	-- special AI firemode follows
	{
		vehicleWeapon = 1,		
		HasCrosshair=1,
		draw_thirdperson = 1,--if 1 the crosshair will be showed also in thirdperson view
		AmmoType="Unlimited",
		projectile_class="VehicleRocket",
		reload_time=4.5, -- default 3.82
		fire_rate=3.65,
		fire_activation=FireActivation_OnPress,
		bullet_per_shot=1,
		bullets_per_clip=1,
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

		SoundMinMaxVol = { 255, 5, 4000 },
	},
	
	},

	SoundEvents={
	--	animname,	frame,	soundfile		
	{	"reload1",	20,			Sound:LoadSound("Sounds/Weapons/M4/M4_20.wav")},
	{	"reload1",	33,			Sound:LoadSound("Sounds/Weapons/M4/M4_33.wav")},
	{	"reload1",	47,			Sound:LoadSound("Sounds/Weapons/M4/M4_47.wav")},
	},
}

CreateBasicWeapon(VehicleMountedRocket);

function VehicleMountedRocket.Client:OnEnhanceHUD(scale, bHit)
	BasicWeapon.DoAutoCrosshair( self, scale, bHit);	
end
