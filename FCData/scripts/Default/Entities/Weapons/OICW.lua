function GetScopeTex()
	local cur_r_TexResolution = tonumber( getglobal( "r_TexResolution" ) );
	if( cur_r_TexResolution >= 2 ) then -- lower res texture for low texture quality setting
		return System:LoadImage("Textures/Hud/crosshair/OICW_Scope_low.dds");
	else
		return System:LoadImage("Textures/Hud/crosshair/OICW_Scope.dds");
	end
end

OICWSP = {
	name			= "OICW",
	object		= "Objects/Weapons/oicw/oicw_bind.cgf",
	character	= "Objects/Weapons/oicw/oicw.cgf",
	
	BoneRightHand = "Bone67",
	BoneLeftHand = "Bone19",
	RHOffset = {0.0, -0.08, 0.01},
	RHOffsetAngles = {-33.0, 0.0, -15.0},

	-- if the weapon supports zooming then add this...
	ZoomActive = 0,												-- initially always 0
	MaxZoomSteps = 1,
	ZoomSteps = { 3 },
	---------------------------------------------------
	PlayerSlowDown = 0.8,									-- factor to slow down the player when he holds that weapon
	---------------------------------------------------
	ActivateSound = Sound:LoadSound("Sounds/Weapons/oicw/oicwact.wav",0,155),	-- sound to play when this weapon is selected
	Sway=2,
	---------------------------------------------------
	DrawFlare=1,
	---------------------------------------------------
	FireParams ={													-- describes all supported firemodes
	{
		FModeActivationTime=1,
		HasCrosshair=1,
		AmmoType="Assault",
		reload_time=2.02, -- default 2.55
		fire_rate=0.05,
		distance=1600,
		damage=15, -- Default = 9
		damage_drop_per_meter=.007,
		bullet_per_shot=1,
		bullets_per_clip=40,
		iImpactForceMul = 20,
		iImpactForceMulFinal = 100,
		fire_activation=bor(FireActivation_OnPress,FireActivation_OnHold),

		-- recoil values
		min_recoil=0,
		max_recoil=0.8,	-- its only a small recoil as more people seem to like it that way

		BulletRejectType=BULLET_REJECT_TYPE_RAPID,

		-- make sure that the last parameter in each sound (max-distance) is equal to "whizz_sound_radius"
		whizz_sound_radius=8,
		whizz_probability=250,	-- 0-1000
		whizz_sound={
			Sound:Load3DSound("Sounds/weapons/bullets/whiz1.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz2.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz3.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz4.wav",SOUND_UNSCALABLE,100,1,8),
		},

		FireLoop="Sounds/Weapons/oicw/FINAL_OICW_MONO_LOOP.wav",
		FireLoopStereo="Sounds/Weapons/oicw/FINAL_OICW_STEREO_LOOP.wav",
		TrailOff="Sounds/Weapons/oicw/FINAL_OICW_MONO_TAIL.wav",
		TrailOffStereo="Sounds/Weapons/oicw/FINAL_OICW_STEREO_TAIL.wav",
		DrySound = "Sounds/Weapons/oicw/DryFire.wav",

		ScopeTexId = GetScopeTex(),

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

			size = {0.175},
			size_speed = 4.3,
			speed = 0.0,
			focus = 20,
			lifetime = 0.03,

			sprite = {
					{
						System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzleoicw.dds"),
						System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzleoicw2.dds")
					}
				},

			stepsoffset = 0.05,
			steps = 1,
			gravity = 0.0,
			AirResistance = 0,
			rotation = 3,
			randomfactor = 20,
			color = {0.9,0.9,0.9},
		},

		-- remove this if not nedded for current weapon
		MuzzleFlash = {
			geometry_name = "Objects/Weapons/Muzzle_flash/mf_OICW_fpv.cgf",
			bone_name = "spitfire",
			lifetime = 0.125,
		},
		MuzzleFlashTPV = {
			geometry_name = "Objects/Weapons/Muzzle_flash/mf_OICW_tpv.cgf",
			bone_name = "weapon_bone",
			lifetime = 0.05,
		},

		-- trace "moving bullet"
		-- remove this if not nedded for current weapon
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

		SoundMinMaxVol = { 255, 4, 2600 },
	},
	{
		no_zoom = 1,
		FModeActivationTime=1,
		HasCrosshair=1,
		AmmoType="OICWGrenade",
		projectile_class="OICWGrenade",
		ammo=500,
		reload_time=2.5,
		fire_rate=1.0,
		fire_activation=FireActivation_OnPress,
		bullet_per_shot=1,
		bullets_per_clip=5,

		FireSounds = {
			"Sounds/Weapons/OICW/FINAL_OICW_MONO_GRENADE.wav",
			"Sounds/Weapons/OICW/FINAL_OICW_MONO_GRENADE.wav",
			"Sounds/Weapons/OICW/FINAL_OICW_MONO_GRENADE.wav",
		},
		FireSoundsStereo = {
			"Sounds/Weapons/OICW/FINAL_OICW_STEREO_GRENADE.wav",
			"Sounds/Weapons/OICW/FINAL_OICW_STEREO_GRENADE.wav",
			"Sounds/Weapons/OICW/FINAL_OICW_STEREO_GRENADE.wav",
		},
		DrySound = "Sounds/Weapons/AG36/DryFire.wav",

		LightFlash = {
			fRadius = 3.0,
			vDiffRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			vSpecRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
			fLifeTime = 0.1,
		},

		SoundMinMaxVol = { 255, 4, 2600 },
	}

	},

		SoundEvents={
		--	animname,	frame,	soundfile												---
		{	"reload1",	14,			Sound:LoadSound("Sounds/Weapons/OICW/oicwB_14.wav",0,155)},
		{	"reload1",	32,			Sound:LoadSound("Sounds/Weapons/OICW/oicwB_32.wav",0,155)},
		{	"reload2",	32,			Sound:LoadSound("Sounds/Weapons/OICW/oicwG_32.wav",0,155)},
		{	"reload2",	48,			Sound:LoadSound("Sounds/Weapons/OICW/oicwG_48.wav",0,155)},
--		{	"swim",		1,				Sound:LoadSound("Sounds/player/water/underwaterswim2.wav",0,255)},

	},
}

OICWMP = {
	name			= "OICW",
	object		= "Objects/Weapons/oicw/oicw_bind.cgf",
	character	= "Objects/Weapons/oicw/oicw.cgf",
	
	BoneRightHand = "Bone67",
	BoneLeftArm = "Bone25",

	fireCanceled = 0,

	-- if the weapon supports zooming then add this...
	ZoomActive = 0,												-- initially always 0
	MaxZoomSteps = 1,
	ZoomSteps = { 3 },
	---------------------------------------------------
	PlayerSlowDown = 0.7,									-- factor to slow down the player when he holds that weapon
	---------------------------------------------------
	ActivateSound = Sound:LoadSound("Sounds/Weapons/oicw/oicwact.wav",0,155),	-- sound to play when this weapon is selected
	ZoomNoSway=1,
	---------------------------------------------------
	DrawFlare=1,
	---------------------------------------------------
	FireParams ={													-- describes all supported firemodes
	{
		FModeActivationTime=1,
		HasCrosshair=1,
		AmmoType="Assault",
		reload_time=2.02, -- default 2.55
		fire_rate=0.05,
		distance=1600,
		damage=15, -- Default = 9
		damage_drop_per_meter=.007,
		bullet_per_shot=1,
		bullets_per_clip=40,
		iImpactForceMul = 20,
		iImpactForceMulFinal = 100,
		fire_activation=bor(FireActivation_OnPress,FireActivation_OnHold),

		-- recoil values
		min_recoil=0,
		max_recoil=0.8,	-- its only a small recoil as more people seem to like it that way

		BulletRejectType=BULLET_REJECT_TYPE_RAPID,

		-- make sure that the last parameter in each sound (max-distance) is equal to "whizz_sound_radius"
		whizz_sound_radius=8,
		whizz_probability=250,	-- 0-1000
		whizz_sound={
			Sound:Load3DSound("Sounds/weapons/bullets/whiz1.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz2.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz3.wav",SOUND_UNSCALABLE,100,1,8),
			Sound:Load3DSound("Sounds/weapons/bullets/whiz4.wav",SOUND_UNSCALABLE,100,1,8),
		},

		FireLoop="Sounds/Weapons/oicw/FINAL_OICW_MONO_LOOP.wav",
		FireLoopStereo="Sounds/Weapons/oicw/FINAL_OICW_STEREO_LOOP.wav",
		TrailOff="Sounds/Weapons/oicw/FINAL_OICW_MONO_TAIL.wav",
		TrailOffStereo="Sounds/Weapons/oicw/FINAL_OICW_STEREO_TAIL.wav",
		DrySound = "Sounds/Weapons/oicw/DryFire.wav",

		ScopeTexId = GetScopeTex(),

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

			size = {0.175},
			size_speed = 4.3,
			speed = 0.0,
			focus = 20,
			lifetime = 0.03,

			sprite = {
					{
						System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzleoicw.dds"),
						System:LoadTexture("Textures\\WeaponMuzzleFlash\\muzzleoicw2.dds")
					}
				},

			stepsoffset = 0.05,
			steps = 1,
			gravity = 0.0,
			AirResistance = 0,
			rotation = 3,
			randomfactor = 20,
			color = {0.9,0.9,0.9},
		},

		-- remove this if not nedded for current weapon
		MuzzleFlash = {
			geometry_name = "Objects/Weapons/Muzzle_flash/mf_OICW_fpv.cgf",
			bone_name = "spitfire",
			lifetime = 0.125,
		},
		MuzzleFlashTPV = {
			geometry_name = "Objects/Weapons/Muzzle_flash/mf_OICW_tpv.cgf",
			bone_name = "weapon_bone",
			lifetime = 0.05,
		},

		-- trace "moving bullet"
		-- remove this if not nedded for current weapon
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

		SoundMinMaxVol = { 255, 4, 2600 },
	},
	{
			--no_zoom = 0,
			--HasCrosshair=1,
			AmmoType="OICWGrenade",
			min_recoil=4,
			max_recoil=4,		
			projectile_class="OICWGrenade",
			reload_time= 2.5,
			fire_rate= 1,
			bullet_per_shot=1,
			bullets_per_clip=2,
			--FModeActivationTime = 0.02,
			fire_activation=bor(FireActivation_OnPress,FireActivation_OnRelease),
			FireOnRelease = 1,

			ScopeTexId = GetScopeTex(),

			
			FireSounds = {
				"Sounds/Weapons/OICW/FINAL_OICW_MONO_GRENADE.wav",
				"Sounds/Weapons/OICW/FINAL_OICW_MONO_GRENADE.wav",
				"Sounds/Weapons/OICW/FINAL_OICW_MONO_GRENADE.wav",
			},
			FireSoundsStereo = {
				"Sounds/Weapons/OICW/FINAL_OICW_STEREO_GRENADE.wav",
				"Sounds/Weapons/OICW/FINAL_OICW_STEREO_GRENADE.wav",
				"Sounds/Weapons/OICW/FINAL_OICW_STEREO_GRENADE.wav",
			},
			DrySound = "Sounds/Weapons/AG36/DryFire.wav",

			
			LightFlash = {
				fRadius = 3.0,
				vDiffRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
				vSpecRGBA = { r = 1.0, g = 1.0, b = 0.7, a = 1.0, },
				fLifeTime = 0.1,
			},

	
			SoundMinMaxVol = { 255, 15, 100000 },
	}

	},




	SoundEvents={
		--	animname,	frame,	soundfile												---
		{	"reload1",	14,			Sound:LoadSound("Sounds/Weapons/OICW/oicwB_14.wav",0,155)},
		{	"reload1",	32,			Sound:LoadSound("Sounds/Weapons/OICW/oicwB_32.wav",0,155)},
		{	"reload2",	32,			Sound:LoadSound("Sounds/Weapons/OICW/oicwG_32.wav",0,155)},
		{	"reload2",	48,			Sound:LoadSound("Sounds/Weapons/OICW/oicwG_48.wav",0,155)},
--		{	"swim",		1,				Sound:LoadSound("Sounds/player/water/underwaterswim2.wav",0,255)},

	},

	TargetHelperImage = System:LoadImage("Textures/Hud/crosshair/g36.tga"),
	NoTargetImage = System:LoadImage("Textures/Hud/crosshair/noTarget.dds"),	
	temp_ang={x=0,y=0,z=0},
	temp_pos={x=0,y=0,z=0},
	minaimtime = 0.45,
	initdist = 0,
	initangle = 0,
	maxdist = 15,
	maxangle = 45,
	queuetime={0,0,0,0,0,0,0,0,0,0,0,0},
	queueid={0,0,0,0,0,0,0,0,0,0,0},
	queuesize=1,
}

function ClampAngle(a)
	if(a.x>180)then a.x=a.x-360;
	elseif(a.x<-180)then a.x=a.x+360; end

	if(a.y>180)then a.y=a.y-360;
	elseif(a.y<-180)then a.y=a.y+360; end

	if(a.z>180)then a.z=a.z-360;
	elseif(a.z<-180)then a.z=a.z+360; end
end

OICW = OICWSP;

if (Game:IsMultiplayer()) then
	OICW= OICWMP;
end


CreateBasicWeapon(OICW);

function OICW.Client:OnEvent(EventId, Params)
	if (Game:IsMultiplayer()) then
		if (EventId == ScriptEvent_Fire) then
		
			if (Params.fire_event_type == FireActivation_OnPress) then
				_localplayer.cnt.aimtime = _time;
				Params.shooter.cnt.aimtime = _time;
	
	
				--System:Log("Client Press");
				self.clientrelease = 0;
				self.beginclientfire = 1;
				
				self.fireCanceled = 0;
				-- Player pressing the button for the first time, mark the target
				if (Params.distance == nil) then
					Params.distance = 1000;
				end
	
				-- Pass the ray-description-table (shooter, pos, angles, dir, distance) and
				-- receive the target-description-table (objtype (0=entity, 1=stat-obj, 2=terrain), 
				-- pos, normal, dir, target (nil if objtype!=0)) 
				local ang=Params.angles;
				local pos=Params.pos;
				--System:Log("OnFire ,"..ang.x..","..ang.y..","..ang.z.."POS"..pos.x..","..pos.y..","..pos.z);
				local hits=self.cnt:GetInstantHit(Params)
				local TargetDescTable;
				if(hits)then
					--get the first(unpierceble hit)
					TargetDescTable = hits[0];
				end
	
				if (TargetDescTable ~= nil) then
					Params.shooter.cnt.vTargetSpot = new(TargetDescTable.pos);
					-- System.LogToConsole("OnEvent --> x:"..TargetDescTable.pos.x.." y:"..TargetDescTable.pos.y.." z:"..TargetDescTable.pos.z);
				else
					Params.shooter.cnt.vTargetSpot=nil;
				end
	
				local ppos=self.temp_pos;
				local vAngles = self.temp_ang;	
				_localplayer.cnt:GetFirePosAngles(ppos,vAngles);
				self.initdist = ppos;
				self.initangle = vAngles.z;
	
				--return beacuse basic weapon shouldn't play any effects
				return
			elseif (Params.fire_event_type == FireActivation_OnRelease) then
				local elapstime =_time-Params.shooter.cnt.aimtime;
		
				if ( (Params.shooter.cnt.aimtime > 0) and (self.minaimtime < elapstime)) then
					--System:Log("Client Release");
					self.clientrelease = 1;
					-- Player releasing the button, unmark the target
					Params.shooter.cnt.vTargetSpot=nil;
					self.fireCanceled = 0;
					Params.shooter.cnt.aimtime = 0;
				else
					Params.shooter.cnt.vTargetSpot=nil;
					self.fireCanceled = 1;
					self.beginclientfire = nil;
					self.clientrelease = 0;
					Params.shooter.cnt.aimtime = 0;
					--return;
				end
			end
		elseif (EventId == ScriptEvent_FireCancel) then
			-- Player canceled fire, unmark the target
			Params.shooter.cnt.vTargetSpot=nil;
			self.fireCanceled = 1;
			self.beginclientfire = nil;
			self.clientrelease = 0;
			return
		end
		if( self.fireCanceled == 1 or self.clientrelease ~= 1 or self.beginclientfire == 0 or Params.shooter.cnt.aiming ~= 1)then	-- don't fire
			do return nil end;
		end	
		
		self.beginclientfire = 0;
		return BasicWeapon.Client.OnEvent(self, EventId, Params);
	else
		return BasicWeapon.Client.OnEvent(self, EventId, Params);
	end
end



function OICW.Client:OnEnhanceHUD(scale, bHit)
	--function OICW.Client:OnEnhanceHUD()
	if (Game:IsMultiplayer()) then	
		if (_localplayer.cnt.firemode == 1) then
			if (_localplayer.cnt.vTargetSpot and _localplayer and _localplayer.cnt.aiming == 1) then
				
				local ppos=self.temp_pos;
				local vAngles = self.temp_ang;
				
				_localplayer.cnt:GetFirePosAngles(ppos,vAngles);
				ClampAngle(vAngles);
				local vDiff=DifferenceVectors(_localplayer.cnt.vTargetSpot, ppos);
				local fDistY = vDiff.z;
				vDiff.z=0;
				local fDistX=abs(sqrt(LengthSqVector(vDiff)));
				
				--System:Log("fireang ,"..vAngles.x..","..vAngles.y..","..vAngles.z.."## firePos ,"..ppos.x..","..ppos.y..","..ppos.z);
				local iTargetAngle = self.cnt:GetProjectileFiringAngle(65.0, 3.0*9.8, fDistX, fDistY);
				local pang=-vAngles.x;
				local iAngleDiff = -vAngles.x - iTargetAngle;
			--	printf("xdist=%0.2f ydist=%0.2f",fDistX, fDistY);
				--local iAngleDiff = iTargetAngle - vAngles.x;
				-- System.LogToConsole("--> SQDistance = "..fDistX.." | iTargetAngle = "..iTargetAngle.." | iAngleDiff = "..iAngleDiff);
				local iHeight = 300 + (iAngleDiff * 3);
				if(iHeight>600)then
					iHeight=600;
				elseif(iHeight<0)then
					iHeight=0;
				end
				
				--if(iTargetAngle==0)then
				--	System:DrawImageColor(self.NoTargetImage, 400 - 15, 300 - 15, 30, 30, 4, 1, 0, 0, 1);
				--printf(" NO TARGET ");
				--	self.cnt:SetWeaponCrosshair( "Textures/Hud/crosshair/sniper.tga", 0);						
				--else
				--	System:DrawImageColor(self.TargetHelperImage, 400 - 15, iHeight - 15, 30, 30, 4, 1, 0, 0, 1);
				--	Game:WriteHudString(425,280,"trg="..sprintf("%0.2f",iTargetAngle),0.7,0.7,0.7,1,15,15);
				--	Game:WriteHudString(425,300,"ply="..sprintf("%0.2f",-vAngles.x),0.7,0.7,0.7,1,15,15);
				--end
				
				local elapstime =_time-_localplayer.cnt.aimtime;
				local ppos=self.temp_pos;
				local vAngles = self.temp_ang;	
				_localplayer.cnt:GetFirePosAngles(ppos,vAngles);
				local diffdist = abs(sqrt(LengthSqVector(DifferenceVectors(self.initdist, ppos))));
				local diffangle = abs(self.initangle - vAngles.z);
	
				if (elapstime < self.minaimtime or iTargetAngle==0
					 or (self.maxdist < tonumber(diffdist)) 
					 or (self.maxangle < tonumber(diffangle))) then
					System:DrawImageColor(self.NoTargetImage, 400 - 15, iHeight - 15, 30, 30, 4, 1, 0, 0, 1);
					Game:WriteHudString(425,280,"wait="..sprintf("%0.2f",self.minaimtime - elapstime),0.7,0.7,0.7,1,15,15);
	
				else
					System:DrawImageColor(self.TargetHelperImage, 400 - 15, iHeight - 15, 30, 30, 4, 1, 0, 0, 1);
					Game:WriteHudString(425,300,"y="..sprintf("%0.2f",self.initangle - vAngles.z),0.7,0.7,0.7,1,15,15);
					Game:WriteHudString(425,320,"x="..sprintf("%0.2f",iAngleDiff),0.7,0.7,0.7,1,15,15);
					Game:WriteHudString(425,340,"dist="..sprintf("%0.2f",fDistX),0.7,0.7,0.7,1,15,15);
	
				end
			else
				-- just looking around - not in firemode
				local myPlayer=_localplayer;
				if ( myPlayer ) then
					local trace={};
					local	firePos={x=0,y=0,z=0};
					local	fireAng={x=0,y=0,z=0};
					myPlayer.cnt:GetFirePosAngles(firePos,fireAng);
					ClampAngle(fireAng);
					--System:Log("fireang ,"..fireAng.x..","..fireAng.y..","..fireAng.z.."## firePos ,"..firePos.x..","..firePos.y..","..firePos.z);
					trace.pos = firePos;
					trace.dir = myPlayer:GetDirectionVector();
					trace.distance = 1000;
					trace.shooter = myPlayer;
					local hits=self.cnt:GetInstantHit(trace)
					local iTargetAngle = 0;
					local	lTargetSpot = {x=0,y=0,z=0};
						local TargetDescTable;
						if(hits)then
							--get the first(unpierceble hit)
							TargetDescTable = hits[0];
						end
						if (TargetDescTable ~= nil) then
							lTargetSpot = new(TargetDescTable.pos);
							local ppos=firePos;--self.temp_pos;
							local vDiff=DifferenceVectors(lTargetSpot, ppos);
							local fDistY = vDiff.z;
							vDiff.z=0;
							local fDistX=abs(sqrt(LengthSqVector(vDiff)));
							
							iTargetAngle = self.cnt:GetProjectileFiringAngle(65.0, 3.0*9.8, fDistX, fDistY);
						end
					if (_localplayer.cnt.aiming ~= nil)  then
						if(iTargetAngle==0)then
							System:DrawImageColor(self.NoTargetImage, 400 - 15, 300 - 15, 30, 30, 4, 1, 0, 0, 1);
							local elapstime =_time-_localplayer.cnt.aimtime;
							if (_localplayer.cnt.aimtime > 0 and self.minaimtime > elapstime) then
	Game:WriteHudString(425,280,"wait="..sprintf("%0.2f",self.minaimtime - elapstime),0.7,0.7,0.7,1,15,15);
							end
						else 
						
							System:DrawImageColor(self.TargetHelperImage, 400 - 15, 300 - 15, 30, 30, 4, 1, 0, 0, 1);
						end
					
					end
				end	
			end
			BasicWeapon.Client.OnEnhanceHUD(self);		
		else
			local posX = 400;
			local posY = 300;
			BasicWeapon.Client.OnEnhanceHUD(self, scale, bHit, posX, posY);
		end
	else
		BasicWeapon.Client.OnEnhanceHUD(self);
	end
end



function OICW.Server:OnEvent(EventId, Params)
	if (Game:IsMultiplayer()) then
		if (EventId == ScriptEvent_Fire) then
			--System:Log("Server FIRE");
			if (Params.fire_event_type == FireActivation_OnPress) then
				--System:Log("Server PRESS");
				self.beginfire = 1;
				Params.shooter.cnt.aimtimesvr=_time;
			end
			if (Params.fire_event_type == FireActivation_OnRelease and self.beginfire == 1) then
				--System:Log("Server RELEASE");
				
	
				local elapstime =_time-Params.shooter.cnt.aimtimesvr;
				if ( (Params.shooter.cnt.aimtimesvr > 0) and (self.minaimtime < elapstime) ) then
					self.beginfire = 0;
					self.fireCanceled = 0;
					Params.shooter.cnt.aimtimesvr = 0;
				else
					self.beginfire = 0;
					self.fireCanceled = 1;
					Params.shooter.cnt.aimtimesvr = 0;
				end
			else return end
		elseif (EventId == ScriptEvent_FireCancel) then
			-- Player canceled fire, 
			self.fireCanceled = 1;
			return
		end
		if( self.fireCanceled == 1 or Params.shooter.cnt.aiming ~= 1)then	-- don't fire
			self.beginfire = nil;
			do return nil end;
		end	
		--System:Log("Server ONEVENT");
		return BasicWeapon.Server.OnEvent(self, EventId, Params);
	else
		return BasicWeapon.Server.OnEvent(self, EventId, Params);
	end
end


---------------------------------------------------------------
--ANIMTABLE
------------------
OICW.anim_table={}
--AUTOMATIC FIRE
OICW.anim_table[1]={
	idle={
		"Idle11",
		"Idle21",
	},
	reload={
		"Reload1",
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

--AUTOMATIC FIRE
OICW.anim_table[2]={
	idle={
		"Idle21",
		"Idle22",
	},
	reload={
		"Reload2",
	},
	fire={
		"Fire12",
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