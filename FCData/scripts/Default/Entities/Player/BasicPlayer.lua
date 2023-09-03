-- #Script.ReloadScript("scripts/default/entities/player/basicplayer.lua")

Game:CreateHapticsEffectFlat("damage_fall", 0.2, 1.0);
Game:CreateHapticsEffectFlat("damage_drowning", 0.034, 0.5, 0, 0);
Game:CreateHapticsEffectFlat("damage_explosion", 0.6, 1.0, 0.0, 0.3);
Game:CreateHapticsEffectFlat("damage_fire", 0.4, 1.0, 0.0, 0.4);
Game:CreateHapticsEffectFlat("damage_melee", 0.3, 1.0, 0.0, 0.2);
Game:CreateHapticsEffectFlat("damage", 0.1, 1.0);

GoreDecals = { 			-- used to be projected on walls/objects/terrain
		count = 1,
		dec1=
		{
			texture = System:LoadTexture("Languages/Textures/human_bullet_hit_d.DDS"),		
			scale = 1, --0.30
			random_rotation	= 360,
			random_scale = 50,
			life_time = 15,
			grow_time = 0,
		},
		dec2=
		{
			texture = System:LoadTexture("Languages/Textures/Decal/flesh_slash.dds"),		
			scale = 1, --0.30
			random_rotation	= 360,
			random_scale = 20,
			life_time = 15,
			grow_time = 0,
		},
	}

GoreDecalsBld = { 			-- blood under dead body
		count = 1,
		dec1=
		{
--			texture = System:LoadTexture("Languages/Textures/human_bullet_hit_d.DDS"),		
			texture = System:LoadTexture("Languages/Textures/blood_pool.DDS"),
			scale = 1, --0.50
			random_rotation	= 360,
			random_scale = 10,
			life_time = 30,
			grow_time = 30,		}, --23
		dec2=
		{
			texture = System:LoadTexture("Languages/Textures/Decal/flesh_slash.dds"),		
			scale = 2, --1.30
			random_rotation	= 360,
			random_scale = 20,
			life_time = 15,
			grow_time = 15, --10,
		},
	}



-- definition for keyframe identifiers
KEYFRAME_APPLY_MELEE = 1;
KEYFRAME_ALLOW_AI_MOVE = 2;
KEYFRAME_BREATH_SOUND = 3;
KEYFRAME_JOB_ATTACH_MODEL_NOW = 4;
KEYFRAME_HOLD_GUN = 9;
KEYFRAME_HOLSTER_GUN = 10;
KEYFRAME_FIRE_LEFTHAND = 11;
KEYFRAME_FIRE_RIGHTHAND = 12;
KEYFRAME_FIRE_LEFTTOP = 13;
KEYFRAME_FIRE_RIGHTTOP = 14;

BasicPlayer =	 {
---------------------------------------------- common data
 	type = "Player",
 	
 	--UpdateTime = 100,--filippo:was 300
	UpdateTime = 300,
	death_time = nil,

	decalTime = 0,

	proneMinAngle = -32,
	proneMaxAngle = 32,

	normMinAngle = -85,
	normMaxAngle = 85,

	isPhysicalized = 0,

	holdedWeapon = nil,

	BloodTimer = 100000,
	
	aux_vec = {x=0,y=0,z=0},

	deathImpuls = {x=0,y=0,z=0},
	deathImpulseTorso = 0,
	deathPoint = {x=0,y=0,z=0},
  	deathImpulsePart = 0,

	DTExplosion = 0,
	DTSingleP = 1,
	DTSingle = 2,
	DTRapid = 3,

	painSound = nil,
	downSound = 0,

	isProning = 0,
	InWater	= 0,
	isRefractive = 0,
	
	--[filippo]
	lastStanceSound = 0,
	--lastProne = 0,
	hasJumped = 0,
	jumpSoundPlayed = 0,
	tempvec = {x=0,y=0,z=0},
	jumpTime = 0,
	nextPush = 0,
	nextPush_Client = 0,

	--	number of updates to move in bush to have max bush sound volume.Time would be UpdateTime*BushSoundScale
	BushSoundScale = 10,
	--  internal counter of updates
	BushInCounter = 0,
	--	the same for AI
	BushSoundScaleAI = 10,
	BushInCounterAI = 0,

	--in seconds
	drown_time=20,

	-- falling damage
	-- if land speed is greater than FallDmgS dammage will be applyed.
	-- ammount of damage is (landSpeed - FallDmgS)*FallDmgK
	-- speed = sqrt(2*9.8*height)
	FallDmgS = 10, --8.5 
	FallDmgK = 22, --30.15, 16 	

	-- collision damage coefficient
	CollisionDmg = .5, 
	-- collision damage coefficient for vehicles (cars)
	CollisionDmgCar = 3, 



	-- protection stuff
	hasHelmet = 0,
--	hasArmor = 0,

--	bushSndTime=0,
--	bushSndTimeAI=0,

	-- flash light parametrs
--	lightFileShader="LightBeam",
--	lightFileTexture="Textures/Lights/Light_testgrid",
	
--	lightFileShader="sun_midday",
	lightFileShader="",	
	lightFileTexture="Textures/Lights/gk_spotlight_lg.dds",
--	lColor={1.0,1.0,1.0},
--	lightFlag	= 192,


	AnimationBlendingTimes={
		{"srunfwd",						.31},
		{"srunback",					.23},
		{"arunfwd",						.35},
		{"arunback",					.33},
		{"srunback_utaim",		.2},
		{"srunback_utshoot",	.2},
	},

	PainAnimations =
	{
		"pain_head",
		"pain_torso",
		"pain_larm",
		"pain_rarm",
		"pain_lleg",
		"pain_rleg"
	},


--	theWeapon = 0,

---------------------------------------------- common data over

--	sndUnderwaterAmbient = Sound:LoadSound("sounds/player/water/UnderwaterAmbient.wav"),

	soundScale = {
		run = 0.8,
		walk = 0.6,
		crouch = 0.4,
		prone = 0.3,
	},

	soundRadius = {
		--[filippo]
		run = 6.0,--before was 12
		walk = 2.0,-- before was 6
		crouch = 1.0,-- 1
		prone = 0.5,--before was 1
		jump = 3.0,--for jump
		sprint = 12.0,--for sprint
	},

	soundEventRadius = {
		run = 0,
		jump = 0,		-- when landing after jump
		walk = 0,
		crouch = 0,
		prone = 0,
	},

	DynProp = {
		air_control = 0.9, --filippo:was 0.4  -- default 0.6
		gravity = 9.81,--18.81,
		jump_gravity = 15.0,--gravity used when the player jump, if this parameter dont exist normal gravity is used also for jump.
		swimming_gravity = -1.0,
		inertia = 10.0,
		swimming_inertia = 1.0,
		nod_speed = 50.0,--filippo:was 60
		min_slide_angle = 46,
		max_climb_angle = 55,
		min_fall_angle = 70,
		max_jump_angle = 50,
	},

	sndWaterSwim = Sound:LoadSound("sounds/player/water/newswim2lp.wav"),
	sndUnderWaterSwim = Sound:LoadSound("sounds/player/water/underwaterswim2.wav"),
	
	--{
	--	Sound:LoadSound("sounds/player/footsteps/water/step1.wav"),
	--	Sound:LoadSound("sounds/player/footsteps/water/step2.wav"),
	--	Sound:LoadSound("sounds/player/footsteps/water/step3.wav"),
	--	Sound:LoadSound("sounds/player/footsteps/water/step4.wav"),
	--},

	sndUnderwaterNoise = Sound:LoadSound("sounds/player/water/underwaterloop.wav"),
	
	--sndUnderWaterSplash = 	Sound:LoadSound("sounds/player/water/underwatersplash.wav"),

	sndWaterSplash = Sound:Load3DSound("sounds/player/water/WaterSplash.wav", SOUND_RADIUS, 160, 3, 50),	
	
	sndBreathIn = {
		Sound:LoadSound("sounds/player/breathin.wav"),
	},
	
	sndNoAir = Sound:LoadSound("sounds/ai/pain/pain3.wav"),
	tSndNoAir = 100,

	WaterRipples = {
		focus = 0.2,
		color = {1,1,1},
		speed = 0.0,
		count = 1,
		size = 0.15, size_speed=0.6,
		gravity=0,
		lifetime=3,
		tid = System:LoadTexture("textures\\ripple.dds"),
		frames=0,
		color_based_blending = 1,
		particle_type = 1,
	},

	WaterSplash = {
		focus = 3,
		color = {1,1,1},
		speed = 10,
		count = 140,
		size = 0.025, size_speed=0,
		gravity=1,
		lifetime=0.5,
		tid = 0,
		frames=0,
		color_based_blending = 0

	},
	
	fLightSound = Sound:Load3DSound("SOUNDS/items/flight.wav",SOUND_UNSCALABLE,160,3,30),

	--[marco] Steve add reward sound here (NOTE: these are 2d sounds)
	--sndHeadShotComment=Sound:LoadSound("LANGUAGES/English/missiontalk/impressive.wav",SOUND_UNSCALABLE,160),
	--sndLongDistanceShotComment=Sound:LoadSound("LANGUAGES/English/missiontalk/60meters.wav",SOUND_UNSCALABLE,160),
	--sndFarDistanceShotComment=Sound:LoadSound("LANGUAGES/English/missiontalk/100meters.wav",SOUND_UNSCALABLE,160),

	-- current body heat 
 	 fBodyHeat=1.0,                  

	StaminaTable = {
		sprintScale	= 1.4,
		sprintSwimScale = 1.4,
		decoyRun	= 10,
		decoyJump	= 10,
		restoreRun	= 1.5,
		restoreWalk	= 8,
		restoreIdle	= 10,

		breathDecoyUnderwater	= 2.0,
		breathDecoyAim		= 3,
		breathRestore		= 80,

	},

	fallscale = 1.0,

	expressionsTable = {
		"Scripts/Expressions/DeadRandomExpressions.lua",		-- Dead	
		"Scripts/Expressions/DefaultRandomExpressions.lua",	-- idle
		"Scripts/Expressions/SearchRandomExpressions.lua",		-- search
		"Scripts/Expressions/CombatRandomExpressions.lua",		-- combat	
	},
};


--////////////////////////////////////////////////////////////////////////////
-- \return 1=alive / nil=not alife
function BasicPlayer:IsAlive()
	if self.GetState then
		return self:GetState()=="Alive";
	end
end

--////////////////////////////////////////////////////////////////////////////
function BasicPlayer:OnBeginDeadState()
	--System:Log("BEGIN DEAD STATE - PLAY SOUND");

	if ((self.SwimSound~=nil) and (Sound:IsPlaying(self.SwimSound)==1)) then
		Sound:StopSound(self.SwimSound);
		self.SwimSound=nil;
	end
	
	self:DoRandomExpressions("Scripts/Expressions/DeadRandomExpressions.lua", 0);
	-- make sure that there is no weapon sound playing anymore
	local weapon = self.cnt.weapon;
	if (weapon) then
		BasicWeapon.Client.OnStopFiring(weapon, self);
	end

	BasicPlayer.PlayOneSound( self, self.deathSounds, 110 );
	self:ReleaseLipSync();	-- we dont want the corpse to say anything...
end

--////////////////////////////////////////////////////////////////////////////
function BasicPlayer:MakeDeadbody()
	if(self.isDedbody~=1) then
		self:KillCharacter(0);
		self:SetPhysicParams(PHYSICPARAM_SIMULATION, self.DeadBodyParams);
		self:SetPhysicParams(PHYSICPARAM_ARTICULATED, self.DeadBodyParams);
		self:SetPhysicParams(PHYSICPARAM_BUOYANCY, self.DeadBodyParams);
		if self.deathImpuls==nil or self.deathPoint==nil or self.deathImpulsePart==nil then
			System:Log("ERROR: self.cnt:StartDie wrong input");
		end
		self.cnt:StartDie( self.deathImpuls, self.deathPoint, self.deathImpulsePart, self.deathType );
		
		self.isDedbody = 1;
	end
end


--////////////////////////////////////////////////////////////////////////////
function BasicPlayer:OnBeginAliveState()
	self:DoRandomExpressions("Scripts/Expressions/DefaultRandomExpressions.lua", 0);
end

-----------------------------------------------------------------------------------------------------------
function BasicPlayer:OnReset()

	--System:Log("BasicPlayer:OnReset name="..self:GetName());

	merge( self, BasicPlayer );
	self["AddAmmo"]=BasicPlayer.AddAmmo;
	self["GetAmmoAmount"]=BasicPlayer.GetAmmoAmount;
	self.bShowOnRadar=nil;	-- dont show on radar by default...
	self.bEnemyInCombat=0; -- default radarstate
	self.cnt:ResetCamera();	
	
	local stats = self.cnt;

	local nMaterialID=Game:GetMaterialIDByName("mat_flesh");
	self:CreateLivingEntity(self.PhysParams, nMaterialID);
	self:PhysicalizeCharacter(self.PhysParams.mass, nMaterialID, self.BulletImpactParams.stiffness_scale, 0);
	self:SetCharacterPhysicParams(0,"", PHYSICPARAM_SIMULATION,self.BulletImpactParams);
	self.isPhysicalized = 1;

	self.LastFootStepTime=0;

	--System:Log("--> OnReset() Called !");

	local CurWeaponInfo = self.weapon_info;
	if (CurWeaponInfo) then
		local tempfiremode = self.cnt.firemode+1;
		local w = self.cnt.weapon;
		if (w) then
			local CurFireParams = w.FireParams[tempfiremode];
			local SoundData = CurWeaponInfo.SndInstances[tempfiremode];
			if (SoundData) then
				BasicWeapon.StopFireLoop(CurWeapon, self, CurFireParams, SoundData);
				--System:Log("--> Fire Loop Stopped OnReset() !");
			end
		end
	end


	stats:SetCurrWeapon( 0 );

	stats:SetDimNormal(self.PlayerDimNormal);
	stats:SetDimCrouch(self.PlayerDimCrouch);
	stats:SetDimProne(self.PlayerDimProne);

	stats:SetMinAngleLimitV( self.normMinAngle );
	stats:SetMaxAngleLimitV( self.normMaxAngle );
	stats:EnableAngleLimitV( 1 );
	stats:EnableAngleLimitH( nil );

	if (self.AniRefSpeeds == nil) then
		self.AniRefSpeeds = self.Properties.AniRefSpeeds;
	end

	self.cnt:SetAnimationRefSpeedRun(	self.AniRefSpeeds.RunFwd,
						self.AniRefSpeeds.RunSide,
						self.AniRefSpeeds.RunBack);
	self.cnt:SetAnimationRefSpeedWalk(self.AniRefSpeeds.WalkFwd,
						self.AniRefSpeeds.WalkSide,
						self.AniRefSpeeds.WalkBack);
	self.cnt:SetAnimationRefSpeedWalkRelaxed(self.AniRefSpeeds.WalkRelaxedFwd,
						self.AniRefSpeeds.WalkRelaxedSide,
						self.AniRefSpeeds.WalkRelaxedBack);
	self.cnt:SetAnimationRefSpeedXWalk(self.AniRefSpeeds.XWalkFwd,
						self.AniRefSpeeds.XWalkSide,
						self.AniRefSpeeds.XWalkBack);
	if(self.AniRefSpeeds.XRunFwd) then
		self.cnt:SetAnimationRefSpeedXRun(	self.AniRefSpeeds.XRunFwd,
							self.AniRefSpeeds.XRunSide,
							self.AniRefSpeeds.XRunBack);
	end
	self.cnt:SetAnimationRefSpeedCrouch(self.AniRefSpeeds.CrouchFwd,
						self.AniRefSpeeds.CrouchSide,
						self.AniRefSpeeds.CrouchBack);

	--stats.SetRunSpeed( self.speedRun );
	--stats.SetWalkSpeed( self.speedWalk );
	--stats.SetCrouchSpeed( self.speedCrouch );
	--stats.SetProneSpeed( self.speedProne );

	--stats.SetJumpForce( self.jumpForce );
	--stats.SetLean( self.lean );
	--stats.SetCameraBob( self.bobPitch, self.bobRoll, self.bobLength );
	--stats.SetWeaponBob( self.bobWeapon );

	stats:SetDynamicsProperties( self.DynProp );
	if (Game:IsMultiplayer()) then
	  local flags = { flags_mask = lef_push_objects+lef_push_players+lef_snap_velocities, flags = lef_snap_velocities, }
	  self:SetPhysicParams(PHYSICPARAM_FLAGS, flags);
	end
	
	if self.Properties.max_health>255 then				-- 255 is the maximum for players (network protocol limitation)
		self.Properties.max_health=255;
	end

	stats.health = self.Properties.max_health;
	
	stats.max_health = self.Properties.max_health;
	stats.armor = 0;
	stats.max_armor = 100;

	stats.fallscale = self.fallscale;
	
	stats.has_flashlight = 0;
	stats.has_binoculars = 0;
	self.FlashLightActive = 0;
	self.items = {};
	
	if (self.Properties.equipEquipment) then
		local WeaponPack = EquipPacks[self.Properties.equipEquipment];
		if (WeaponPack) then
			--search if there is a primary weapon
			for i,val in WeaponPack do
				if(val.Type == "Item" and val.Name == "PickupFlashlight") then
					self.cnt:GiveFlashLight(1);
				end
				if(val.Type == "Item" and val.Name == "PickupBinoculars") then
					self.cnt:GiveBinoculars(1);
				end
				if(val.Type == "Item" and val.Name == "PickupHeatVisionGoggles") then
					self.items.heatvisiongoggles = 1;
				end
			end
		end
	end

	
	if (self.Properties.fMeleeDistance) then
		stats.melee_distance = self.Properties.fMeleeDistance;
	else
		stats.melee_distance = 2.0;
	end

	self:EnablePhysics(1);
	
	self.cnt:InitStaminaTable( self.StaminaTable );

	self:DrawCharacter( 0,1 );

	if(Game:IsServer())then
		self:GotoState( "Alive" );
	end
		
	self.cnt:UseLadder(0);
	self.cnt:ResetCamera();		-- needed because UseLadder wasn't doing it - can be removed soon
	self.ladder = nil;
	

	self.fBodyHeat=1.0; 	
	
	-- available effects: 1= reset, 2= team color, 3= invulnerable, 4= heatsource, 5= stealth mode, 6= mutated arms
	self.iPlayerEffect=1;
	self.bPlayerHeatMask=0;
	self.fLastBodyHeat=0;
	self.iLastWeaponID=0;
	self.bUpdatePlayerEffectParams=1;
	-- render effects	
	self.iEffectCount=0;		
	self.pEffectStack={};
	self.pEffectStack[1]=1;	
	
	self.jumpSoundPlayed = 0;
	self.hasJumped = 0;
	self.lastStanceSound = 0;
	--self.lastProne = 0;

end

-----------------------------------------------------------------------------------------------------------
function BasicPlayer:Server_OnInit()
--	System:Log("function BasicPlayer:Server_OnInit()");
	-- Only when the player spawns the first time
	if (self == _localplayer and _LastCheckPPos == nil) then
		_LastCheckPPos = self:GetPos();
	end
	self:RegisterStates( self );
	if (not self.wasreset) then
		BasicPlayer.OnReset( self );
		self.wasreset=1;
	end

	BasicPlayer.InitAllWeapons(self);

	self.MyInventory = new( Inventory );
	Game:CreateVariable("p_max_vert_angle");
	p_max_vert_angle=90;

	if(self.isPhysicalized == 0) then
		local nMaterialID=Game:GetMaterialIDByName("mat_flesh");
		self:PhysicalizeCharacter(self.PhysParams.mass, nMaterialID, self.BulletImpactParams.stiffness_scale, 0);
		self:SetCharacterPhysicParams(0,"", PHYSICPARAM_SIMULATION,self.BulletImpactParams);
		self.isPhysicalized = 1;
	end

	self.Refractive = nil;
	self.fLastRefractValue = 0;	
	self.vLastPos = self:GetPos();

--	System:LogToConsole("player "..self.id.." SetTimer");
	self:SetTimer(self.UpdateTime);
	self.fBodyHeat=1.0;
end


-----------------------------------------------------------------------------------------------------------
function BasicPlayer:Client_OnInit()

--	System:Log("function BasicPlayer:Client_OnInit()");
	Game:RegisterBHapticsEffect("hit_by_bullet", "bhaptics/vest/HitByBullet.tact");
	Game:RegisterBHapticsEffect("hit_by_melee", "bhaptics/vest/HitByMelee.tact");
	Game:RegisterBHapticsEffect("hit_by_explosion", "bhaptics/vest/HitByExplosion.tact");
	Game:RegisterBHapticsEffect("hit_by_sniper", "bhaptics/vest/HitBySniper.tact");
	Game:RegisterBHapticsEffect("hit_by_shotgun", "bhaptics/vest/HitByBuckshot.tact");
	Game:RegisterBHapticsEffect("damage_fall", "bhaptics/vest/Landing.tact");
	Game:RegisterBHapticsEffect("damage_fire", "bhaptics/vest/Burning.tact");
	Game:RegisterBHapticsEffect("damage_drowning", "bhaptics/vest/Drowning.tact");
	Game:RegisterBHapticsEffect("jump", "bhaptics/vest/Jumping.tact");
	Game:RegisterBHapticsEffect("heal", "bhaptics/vest/ConsumeHealth.tact");
	Game:RegisterBHapticsEffect("pickup", "bhaptics/vest/ConsumeOther.tact");

	self:RegisterStates();

	if (not self.wasreset) then
		BasicPlayer.OnReset( self );
		self.wasreset=1;
	end

--	System:Log(" calling SetAnimationKeyEvent ");

	if(self.SoundEvents) then
		for i,event in self.SoundEvents do
			self:SetAnimationKeyEvent(event[1],event[2],event[3]);
			--System:Log("registering animation key "..event[1].."/"..event[2]);
			if(event[4]~=nil)then
				Sound:SetSoundVolume(event[3],event[4]);
			end
		end
	end

	if(self.AnimationBlendingTimes) then
		for k,blends in self.AnimationBlendingTimes do
			self.cnt:SetBlendTime(blends[1],blends[2]);
		end
	end

--	self:RegisterStates();
--	self:GotoState( "Alive" );

	BasicPlayer.InitAllWeapons(self);

	self.Refractive = nil;
	self.fLastRefractValue = 0;
	self.vLastPos = self:GetPos();

	if(self.isPhysicalized == 0) then
		local nMaterialID=Game:GetMaterialIDByName("mat_flesh");
		self:PhysicalizeCharacter(self.PhysParams.mass, nMaterialID, self.BulletImpactParams.stiffness_scale, 0);
		self:SetCharacterPhysicParams(0,"", PHYSICPARAM_SIMULATION,self.BulletImpactParams);
		self.isPhysicalized = 1;
	end

--	self:RenderShadow( 1 ); -- enable rendering of player shadow

--	self.hasHelmet = self.Properties.bHelmetOnStart;
--	if(self.Properties.bHelmetOnStart == 1)	then
--		BasicPlayer.HelmetOn(self);
--		self.AttachObjectToBone( 0, "hat_bone" );
--	end

--	self:InitDynamicLight(self.lightFileTexture, self.lightFileShader);
	self.cnt:InitDynamicLight(self.lightFileTexture, self.lightFileShader);
--	System:LogToConsole("player "..self.id.." SetTimer CLI");
	self:SetTimer(self.UpdateTime);

--	self.cnt:SetAnimationRefSpeed(4.15, 1.2728, 1.2554, 0.4705);

--	self.cnt:SetAnimationRefSpeedRun(4.62, 3.57, 3.6 );
--	self.cnt:SetAnimationRefSpeedWalk(1.27, 1.22, 1.29 );
--	self.cnt:SetAnimationRefSpeedXWalk(1.2, 1.0, 0.94 );
--	self.cnt:SetAnimationRefSpeedCrouch(1.02, 1.02, 1.04 );

	self.fBodyHeat=1.0;	

	-- available effects: 1= reset, 2= team color, 3= invulnerable, 4= heatsource, 5= stealth mode, 6= mutated arms
	self.iPlayerEffect=1;
	self.bPlayerHeatMask=0;
	self.fLastBodyHeat=0;
	self.iLastWeaponID=0;
	self.bUpdatePlayerEffectParams=1;
	-- render effects	
	self.iEffectCount=0;		
	self.pEffectStack={};	
	self.pEffectStack[1]=1;		
  
--	System:Log("function BasicPlayer:Client_OnInit() end");
end


function BasicPlayer:InitAllWeapons(forceInit)
	-- Everytime AddWeapon() is called every active player entity gets
	-- ScriptInitWeapon() called for the new weapon. The name is also placed in
	-- the global WeaponsLoaded table. So new players need to traverse the list
	-- of recently spawned weapons themself and call ScriptInitWeapon() for each
	-- of them. Also, the player entity needs to call MakeWeaponAvailable() for
	-- each weapon in his weapon pack

	--if (forceInit == 1) then
		self.bAllWeaponsInititalized = nil;
	--end

	-- Check to prevent double initialize for local client
	if (self.bAllWeaponsInititalized ~= nil) then
		return
	end

	if (self.DontInitWeapons == nil) then
		-- Let the container initialize the C/C++ strutures for all weapons
		self.cnt:InitWeapons();
	
		-- Create a new map to map weapon entity class IDs to weapon state information
		if (self.WeaponState == nil) then
			self.WeaponState = new(Map);
		end
	
		-- Main player doesn't have an equipEquipment property, copy from global table
		if (not Game:IsMultiplayer()) then
			if ((self.Properties.equipEquipment == nil) or (self==_localplayer)) then
				self.Properties.equipEquipment = MainPlayerEquipPack;
			end
		else
			if ((self.Properties.equipEquipment == nil)) then
				self.Properties.equipEquipment = MainPlayerEquipPack;
			end
		end
		
		self.Ammo={};
		for i,val in MaxAmmo do
			self.Ammo[i]=0;
		end
	
		local primary_weapon;
		-- Copy initial ammo table from equip pack
		if (self.Properties.equipEquipment) then
			--System:Log("LOADING EQUIP PACK "..self.Properties.equipEquipment);
			local WeaponPack = EquipPacks[self.Properties.equipEquipment];
			if (WeaponPack) then
				if (self.DontResetAmmo == nil) then
					merge(self.Ammo,WeaponPack.Ammo);
				end
	
				--search if there is a primary weapon
				for i,val in WeaponPack do
					if(val.Primary)then
						primary_weapon=val;
					end
					
					-- TODO: think of a better solution and clean this up
					if (Game:IsServer()) then
						local item = nil;
						if(val.Type == "Item" and val.Name == "PickupBinoculars") then
							item = "B";
						end
						if(val.Type == "Item" and val.Name == "PickupHeatVisionGoggles" and self.items) then
							item = "C";
						end
						if(val.Type == "Item" and val.Name == "PickupFlashlight") then
							item = "F";
						end
						if (item) then
							local serverSlot = Server:GetServerSlotByEntityId(self.id);
							if (serverSlot) then
								serverSlot:SendCommand("GI "..item);
							end
						end
					end
	
					if(val.Type == "Weapon") then
						BasicPlayer.ScriptInitWeapon(self, val.Name);
					end
				end
			end
		end
		
		if(primary_weapon and WeaponClassesEx[primary_weapon.Name]~=nil)then
			self.cnt:SetCurrWeapon(WeaponClassesEx[primary_weapon.Name].id);
		else
			-- Make sure we have a weapon active
			self.cnt:SelectFirstWeapon();
		end
	else
		self.DontInitWeapons = nil;
	end
	
	--select granade
	--the rock
	self.cnt.grenadetype=1;
	local id=2;--rick id is 1
	for i=id,count(GrenadesClasses) do
		if(self.Ammo and self.Ammo[GrenadesClasses[id]]>0)then
			self.cnt.grenadetype=id;
			self.cnt.numofgrenades=self.Ammo[GrenadesClasses[id]];
		end
	end

	self.bAllWeaponsInititalized = 1;
end

-----------------------------------------------------------------------------------------------------------
function BasicPlayer:ScriptInitWeapon(wName, bIgnoreLoadClips)
	-- Add the data structures for the passed weapon to this player and make an instance
	-- of the sounds. Give the weapon to the player if it is in his weapon pack

	-- make sure that the weapon is loaded
	Game:AddWeapon(wName);

	-- Create a new map to map weapon entity class IDs to weapon state information
	if (self.WeaponState == nil) then
		self.WeaponState = new(Map);
	end
	
	-- Initializing weapon state info
	local WeaponStateTemplate  = {
		FireMode,	     -- Firemode
		AmmoInClip,          -- Amount of ammunition in the current clip
	};

	local CurWeapon = WeaponClassesEx[wName];

	if (CurWeapon == nil) then
		System:Log("ERROR: Can't find weapon '"..wName.."' in weapon tables !");
		do return end;
	end
	
	local CurWeaponClsID = CurWeapon.id;

	-- Weapon name and table
	local weapontbl = getglobal(wName);

	-- Create the state table for this weapon
	local NewTable = new(WeaponStateTemplate);
	NewTable.FireMode = 0;
	NewTable.AmmoInClip = {0};
	NewTable.Name = wName;
	NewTable.SndInstances = {};

	--System:Log("AMMO!!"..WeaponDesc);
	--for i,val in self.Ammo do
		--	System:Log(i.."="..val);
	--end
	-- Load sounds
	for i2, CurFireParameters in weapontbl.FireParams do
		NewTable.AmmoInClip[i2] = 0;--CurFireParameters.bullets_per_clip;
		-- TODO: Don't give player a full clip by default, pull the first clip from the pool
		--if (self.Ammo[CurFireParameters.AmmoType] ~= nil and self.Ammo[CurFireParameters.AmmoType] > 0) then
		--	NewTable.AmmoInClip[i2] = min(self.Ammo[CurFireParameters.AmmoType], CurFireParameters.bullets_per_clip);
		--	self.Ammo[CurFireParameters.AmmoType] = self.Ammo[CurFireParameters.AmmoType] - min(self.Ammo[CurFireParameters.AmmoType], CurFireParameters.bullets_per_clip);
		--end

		if(	(i2==1 or i2==2) and not bIgnoreLoadClips and
				self.Ammo[CurFireParameters.AmmoType] and self.Ammo[CurFireParameters.AmmoType]>0)then
			local amount;
			local distributed;
			local bpc=CurFireParameters.bullets_per_clip;

			amount=min(bpc,self.Ammo[CurFireParameters.AmmoType]);
			self.Ammo[CurFireParameters.AmmoType]=self.Ammo[CurFireParameters.AmmoType]-amount;
			
			NewTable.AmmoInClip[i2]=amount;
		end
		local flags = bor(SOUND_RELATIVE, SOUND_UNSCALABLE);

		-- Marco's NOTE: I'm adding here sound priority for weapon sounds. The last parameter
		-- in load3dsound is the sound priority, the range is from 0 to 255, with 255
		-- being maximum priority
		NewTable.SndInstances[i2] = { };
		if (type(CurFireParameters.DrySound) == "string") then
			NewTable.SndInstances[i2]["DrySound"] = Sound:Load3DSound(CurFireParameters.DrySound, flags,
			CurFireParameters.SoundMinMaxVol[1],
			CurFireParameters.SoundMinMaxVol[2], CurFireParameters.SoundMinMaxVol[3],128);
		end
		if (type(CurFireParameters.FireLoop) == "string") then
			NewTable.SndInstances[i2]["FireLoop"] = Sound:Load3DSound(CurFireParameters.FireLoop, flags,
			CurFireParameters.SoundMinMaxVol[1],
			CurFireParameters.SoundMinMaxVol[2], CurFireParameters.SoundMinMaxVol[3],200);
		end
		if (type(CurFireParameters.FireLoopStereo) == "string") then
			NewTable.SndInstances[i2]["FireLoopStereo"] = Sound:LoadSound(CurFireParameters.FireLoopStereo);
		end
		if (type(CurFireParameters.TrailOff) == "string") then
			NewTable.SndInstances[i2]["TrailOff"] = Sound:Load3DSound(CurFireParameters.TrailOff,flags,
			CurFireParameters.SoundMinMaxVol[1],
			CurFireParameters.SoundMinMaxVol[2], CurFireParameters.SoundMinMaxVol[3],128);
		end
		if (type(CurFireParameters.TrailOffStereo) == "string") then
			NewTable.SndInstances[i2]["TrailOffStereo"] = Sound:LoadSound(CurFireParameters.TrailOffStereo);
		end
		if (CurFireParameters.FireSounds) then
			NewTable.SndInstances[i2]["FireSounds"] = { };
			for iSingleSnd, CurSndFile in CurFireParameters.FireSounds do
				if (type(CurSndFile) == "string") then
					local CurrSound = Sound:Load3DSound(CurSndFile, flags,
       											CurFireParameters.SoundMinMaxVol[1],
														CurFireParameters.SoundMinMaxVol[2], CurFireParameters.SoundMinMaxVol[3],200);
					if (CurrSound) then
						Sound:SetSoundPitching(CurrSound, 100);
					end
					NewTable.SndInstances[i2]["FireSounds"][iSingleSnd] = CurrSound;
				end
			end
		end

		-- [marco] stereo sounds
		if (CurFireParameters.FireSoundsStereo) then
			NewTable.SndInstances[i2]["FireSoundsStereo"] = { };
			for iSingleSnd, CurSndFile in CurFireParameters.FireSoundsStereo do
				if (type(CurSndFile) == "string") then
					local CurrSound = Sound:LoadSound(CurSndFile);
					if (CurrSound) then
						Sound:SetSoundPitching(CurrSound, 100);
					end
					NewTable.SndInstances[i2]["FireSoundsStereo"][iSingleSnd] = CurrSound;
				end
			end
		end

	end
	
	-- Add to the weapon state of this player
	self.WeaponState[CurWeaponClsID]=NewTable;

	-- Make the weapons available which belong to the player's weapon pack
	local WeaponPackName = self.Properties.equipEquipment;

	if (WeaponPackName) then
		local PlayerPack = EquipPacks[WeaponPackName];
		if (PlayerPack ~= nil) then
			for iIdx, CurPackWeapon in PlayerPack do
				if (CurPackWeapon.Type == "Weapon" and CurPackWeapon.Name == wName) then
					self.cnt:MakeWeaponAvailable(CurWeaponClsID, 1);
					--System:LogToConsole(" --> Name: "..wName);
				end
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------
function BasicPlayer:HelmetOn()
	--self:AttachObjectToBone( 0, "hat_bone" );
--self.DrawObject(0,1);
	if(self.PropertiesInstance.bHelmetProtection and self.PropertiesInstance.bHelmetProtection==1) then
		self.hasHelmet = 1;
	end	
end

-----------------------------------------------------------------------------------------------------------
function BasicPlayer:HelmetOff()
	--self:DetachObjectToBone( "hat_bone" );
--	self.DrawObject(0,0);
	self.hasHelmet = 0;

end

-----------------------------------------------------------------------------------------------------------
function BasicPlayer:HelmetHitProceed( direction, impuls )

	-- we don't have helmets dropped anymore
	do return end

	if( random(0,3)>1 ) then
		do return end
	end

local helmet = Server.SpawnEntity("Helmet");
--	self.theHelmet = Server.SpawnEntity("Helmet");

	local pos = self:GetBonePos("hat_bone");
--	self.theHelmet.
	helmet:EnablePhysics( 1 );
	helmet:SetPos( pos );

	direction.z = direction.z + 5;

	helmet:AddImpulseObj(direction, impuls);
--	theHelmet.Activate(theHelmet, direction, impuls);
	helmet:DrawObject(0,1);

	BasicPlayer.HelmetOff( self );
end

function BasicPlayer:AddAmmo(AmmoType, Amount)

	if(self.Ammo[AmmoType] == nil) then
		System:Log("Unknown ammo type so far, add to WeaponSystem.lua-->AmmoAvailable");
		return
	end

	local wi = self.weapon_info;
	
	if(self.cnt.weapon and wi and self.cnt.weapon.FireParams[wi.FireMode+1].AmmoType==AmmoType)then
		self.cnt.ammo=self.cnt.ammo + Amount;
		self.Ammo[AmmoType] = self.cnt.ammo;
	elseif(GrenadesClasses[self.cnt.grenadetype]==AmmoType)then
		self.cnt.numofgrenades=self.cnt.numofgrenades + Amount;
		self.Ammo[AmmoType] = self.cnt.numofgrenades;
	else
		self.Ammo[AmmoType] = self.Ammo[AmmoType] + Amount;
	end
	--automatically switches grenade type
	for i,val in GrenadesClasses do
		if(AmmoType==val)then
			BasicPlayer.SelectGrenade(self,AmmoType);
		end
	end
end

-- get ammo from all weapons, which the player currently has
-- AmmoType should be a string, such as "SMG" or "ASSAULT"
function BasicPlayer:GetAmmoAmount(AmmoType)
	local stats = self.cnt;
	local curr_amount = self.Ammo[AmmoType];
	--calc real curr_amount----------------------------------------
	local wi = self.weapon_info;
	
	if (stats.weapon and wi and wi.FireMode and stats.weapon.FireParams[wi.FireMode+1].AmmoType == AmmoType) then
		curr_amount = stats.ammo;
	elseif((stats.grenadetype~=1) and (GrenadesClasses[stats.grenadetype] == AmmoType)) then
		curr_amount = stats.numofgrenades;
	end
	
	return curr_amount;
end

-----------------------------------------------------------------------------------------------------------
function BasicPlayer:Client_OnUpdate( DeltaTime )

--	--System.MeasureTime("CliSTART");
--
--	-- Cache some frequently accessed tables
--	local stats = self.cnt;
--	local my_player = _localplayer;
--
--
----	if( stats.light==1 ) then
----		local lPos = self:GetPos();
----		local lDir = self:GetAngles();
----		lPos.z = lPos.z + 1.9;
----		self:AddDynamicLight(lPos, 10, self.lColor[1], self.lColor[2],
----													self.lColor[3], 1, 1, 1, 0.3, 1, 0, self.lightFlag, lDir, 12 );
----	end
--
--
--	if (self == my_player) then
--
--		------------------------------------------
--		-- Main player specific update code
--		------------------------------------------
--
--		self.vLastPos = self:GetPos();
--
----		-- restrict angles
----		if ( stats.proning ) then
----			if (self.isProning==0) then
----				self.isProning=1;
----				--stats:SetAngleLimitBaseOnEnviroment();
----				stats:SetMinAngleLimitV( self.proneMinAngle );
----				stats:SetMaxAngleLimitV( self.proneMaxAngle );
----				Input:SetMouseSensitivityScale( 0.1 );
----			end
----		else
----			if (self.isProning==1) then
----				self.isProning=0;
----				--stats:SetAngleLimitBaseOnVertical();
----				stats:SetMinAngleLimitV( self.normMinAngle );
----				stats:SetMaxAngleLimitV( self.normMaxAngle );
----				Input:SetMouseSensitivityScale( 1.0 );
----			end
----		end
--
--
--	else
--		------------------------------------------
--		-- Non main player specific update code
--		------------------------------------------
--	end
end

-----------------------------------------------------------------------------------------------------------
function BasicPlayer:Client_DeadOnUpdate( DeltaTime )

	self:SetScriptUpdateRate(0);
	local stats = self.cnt;

  	-- tiago: added body heat, used in CryVision shader
  	self.fBodyHeat=self.fBodyHeat - _frametime*0.1;			

  	if(self.fBodyHeat<0.0) then 
    	self.fBodyHeat=0.0;
	end

	BasicPlayer.ProcessPlayerEffects(self);
  
--printf( "deafUpdate" );

	if (stats:HasCollided() == nil) then
		do return end
	end

	if (self.downSound == 0) then

		-- Would be nice to have a shorter and more elegant way to do that
		local CurWeaponInfo = self.weapon_info;
		if (CurWeaponInfo) then
			local CurFireMode = CurWeaponInfo.FireMode;
			local CurWeapon = self.cnt.weapon;
			if (CurWeapon) then
				local CurFireParams = CurWeapon.FireParams[CurFireMode+1];
				local SoundData = CurWeaponInfo.SndInstances[CurFireMode+1];
				if (SoundData) then
--					System:LogToConsole("--> Death Fire Loop Stop Stuff Called !!!");
					BasicWeapon.StopFireLoop(CurWeapon, self, CurFireParams, SoundData);
				end
			end
		end

		--self:SetShader( "" );
		self.downSound = 1;
		local normal = g_Vectors.up;
		local material=self.cnt:GetTreadedOnMaterial();

--printf( "deafUpdate HAS COLLIDED" );

		if(material ~= nil) then
			ExecuteMaterial(self:GetPos(),normal,material.player_drop,1);
		end
		
		self.BloodTimer = 0;
		
	end
end

-----------------------------------------------------------------------------------------------------------
function BasicPlayer:Server_OnUpdate( DeltaTime )
	--System.MeasureTime("SrvSTART");


	-- Precache some frequently used tables
--	local stats = self.cnt;
--
--	-- If not in vehicle and not at mounted weapon
--	-- restrict angles
--
--
--	if ( stats.proning ) then
--		if (self.isProning == 0) then
--			self.isProning=1;
--			stats:SetMinAngleLimitV( self.proneMinAngle );
--			stats:SetMaxAngleLimitV( self.proneMaxAngle );
--		end
--	else
--		if (self.isProning == 1) then
--			self.isProning=0;
--			stats:SetMinAngleLimitV( self.normMinAngle );
--			stats:SetMaxAngleLimitV( self.normMaxAngle );
--		end
--	end

--	-- Recover energy
--	if (self.EnergyChanged == nil) then
--		self.ChangeEnergy( self, DeltaTime * 1 );
--	else
--		self.EnergyChanged = nil;
--	end

	--System.MeasureTime("SrvEND");
end

-----------------------------------------------------------------------------------------------------------
function BasicPlayer:Server_OnEvent( EventId, Params )
	local handler=BasicPlayer.Server_EventHandler[EventId];
	if(handler)then
		return handler(self,Params)
	end
end

-----------------------------------------------------------------------------------------------------------
function BasicPlayer:Server_OnEventDead( EventId, Params )
	local handler=BasicPlayer.Server_EventHandlerDead[EventId];
	if(handler)then
		return handler(self,Params)
	end
end


-----------------------------------------------------------------------------------------------------------
function BasicPlayer:Client_OnEvent( EventId, Params)
	local handler=BasicPlayer.Client_EventHandler[EventId];
	if(handler)then
		return handler(self,Params)
	end
end

-----------------------------------------------------------------------------------------------------------
function BasicPlayer:CalcAttenuation(SoundScale)
	if (not SoundScale) then
		SoundScale=1;
	end
	do return SoundScale end

	if (self and _localplayer and (self~=_localplayer)) then
		merge(BasicPlayer.aux_vec, _localplayer:GetPos());
		local Pos=self:GetPos();
		if (System:IsPointIndoors(BasicPlayer.aux_vec) and System:IsPointIndoors(Pos)) then
			--System:Log("Pos("..Pos.x..", "..Pos.y..", "..Pos.z..")");
			--System:Log("LocalPlayerPos("..LocalPlayerPos.x..", "..LocalPlayerPos.y..", "..LocalPlayerPos.z..")");
			
			--filippo: RayWorldIntersection use start and end vector now, and also skip player from collision check.
--			BasicPlayer.aux_vec.x=BasicPlayer.aux_vec.x-Pos.x;
--			BasicPlayer.aux_vec.y=BasicPlayer.aux_vec.y-Pos.y;
--			BasicPlayer.aux_vec.z=BasicPlayer.aux_vec.z-Pos.z;
			--System:Log("Dir("..BasicPlayer.aux_vec.x..", "..BasicPlayer.aux_vec.y..", "..BasicPlayer.aux_vec.z..")");
			local Hits=System:RayWorldIntersection(Pos, BasicPlayer.aux_vec, 10 , self.id);
			
			local Attenuation=getn(Hits)*(20/100);
			SoundScale=SoundScale-Attenuation;
			--System:Log("Sound Ray Intersection ("..(Attenuation*100).." %% attenuated.");
		end
	end
	return SoundScale;
end

-----------------------------------------------------------------------------------------------------------
function BasicPlayer:PlaySoundEx(SoundHandle, SoundScale)
	SoundScale=BasicPlayer.CalcAttenuation(self, SoundScale);
	if (SoundScale>0) then
		self:PlaySound(SoundHandle, SoundScale);
	end
end

-----------------------------------------------------------------------------------------------------------
function BasicPlayer:PlayOneSound( soundList, chance)

	local randnum=random(1,100);
	if( (randnum<chance) and (soundList) ) then
		--System:Log("PLAYING A SOUND");

		local nsounds=getn(soundList);
		
		--if the table is empty return nil.
		if (nsounds<=0) then
			return nil;
		end
		
		local sounddesc=soundList[random(1,nsounds)]

		-- do this to try ro avoid repeating the same sound 		
		if(sounddesc[6]) then
			if( _time - sounddesc[6]<2 ) then
				sounddesc=soundList[random(1,nsounds)];
				if(sounddesc[6]) then
					if( _time - sounddesc[6]<2 ) then
						sounddesc=soundList[random(1,nsounds)];
					end
				end
			end
		end	

		self.lastsoundplayed=Sound:Load3DSound(sounddesc[1],sounddesc[2],sounddesc[3],sounddesc[4],sounddesc[5]);

		if (self.lastsoundplayed) then
			self:PlaySound(self.lastsoundplayed,1);
			sounddesc[6] = _time;
		end

		return self.lastsoundplayed;

		--BasicPlayer.PlaySoundEx(self,sound); 

	end

end

-----------------------------------------------------------------------------------------------------------
function BasicPlayer:SetDeathImpulse( hit )
  self.deathImpuls.x = hit.dir.x;
  self.deathImpuls.y = hit.dir.y;
  self.deathImpuls.z = hit.dir.z;

  self.headshot=0;

--printf(">>>>> %.2f",hit.impact_force_mul_final);
	if(hit.impact_force_mul_final)then
		self.deathImpuls.x = self.deathImpuls.x*hit.impact_force_mul_final;
		self.deathImpuls.y = self.deathImpuls.y*hit.impact_force_mul_final;
		self.deathImpuls.z = self.deathImpuls.z*hit.impact_force_mul_final;
		if (hit.target_material	and ((hit.target_material.type=="head") or (hit.target_material.type=="leg"))) then		  	
		  self.deathImpulseTorso = 0;
		  -- [marco] check if this was an headshot, to reward the player afterwards	
		  if (hit.target_material.type=="head") then
			self.headshot=1;
		  end		  
		else
  		  if( not hit.impact_force_mul_final_torso ) then
  		  	hit.impact_force_mul_final_torso  = 0;
  		  end	
		  self.deathImpulseTorso = hit.impact_force_mul_final_torso;
		  if (hit.impact_force_mul_final_torso>0) then
		    self.deathImpuls.x = self.deathImpuls.x*2.0;
		    self.deathImpuls.y = self.deathImpuls.y*2.0;
		    self.deathImpuls.z = self.deathImpuls.z*2.0;
		  end  
		end
	end

	if( hit.pos )  then				-- hit was in some point
		self.deathPoint.x = hit.pos.x;
		self.deathPoint.y = hit.pos.y;
		self.deathPoint.z = hit.pos.z;
		self.deathImpulsePart = hit.ipart;
		self.shooter=hit.shooter;
	else											-- just damage (fall)
		self.deathPoint.x = 0;
		self.deathPoint.y = 0;
		self.deathPoint.z = 0;
		self.deathImpulsePart = 0;
		self.shooter=nil;
	end

end

-----------------------------------------------------------------------------------------------------------
function BasicPlayer:Server_OnDamage( hit )

--	System:Log("BasicPlayer:Server_OnDamage type="..hit.damage_type);
--	if hit.pos then			-- no air damage doesn't have hit.pos
--		System:Log("BasicPlayer:Server_OnDamage pos="..hit.pos.x.." "..hit.pos.y.." "..hit.pos.z);
--	end

	BasicPlayer.SetDeathImpulse( self, hit );

	if (hit.damage_type == "normal" or hit.explosion or hit.damage_type == "healthonly") then
--		System:Log("GameRules:OnDamage(hit) from BasicPlayer:Server_OnDamage");
		GameRules:OnDamage(hit);
	end

-- don't process building damage done on players at all
	if (hit.damage_type ~= nil and hit.damage_type == "building") then
		return;
	end
	
	if(self.cnt.health ~= 0 and (not hit.explosion)) then

-- don't need this anymore - always appaly hit impuls
--		if (self.bNoImpulseOnDamage) then return end

		if( hit.ipart ) then
		  local skeleton_impulse_scale = 1;
		  if (self.BulletImpactParams.bone_impulse_scale) then
		    local bonename = self:GetBoneNameFromTable(hit.ipart);
		    for idx=1,getn(self.BulletImpactParams.bone_impulse_scale),2 do 
		      if (bonename==self.BulletImpactParams.bone_impulse_scale[idx]) then
		        skeleton_impulse_scale = self.BulletImpactParams.bone_impulse_scale[idx+1];
		        break;
		      end
		    end
		  end  
		  if (self.BulletImpactParams and self.BulletImpactParams.impulse_scale) then
		    skeleton_impulse_scale = skeleton_impulse_scale*self.BulletImpactParams.impulse_scale;
		  end
			self:AddImpulse( hit.ipart, hit.pos, hit.dir, hit.impact_force_mul, skeleton_impulse_scale );
			--System:Log("self:AddImpulse( hit.ipart, hit.pos, hit.dir,"..hit.impact_force_mul..")")
		else
			--System:Log("self:AddImpulse( -1, hit.pos, hit.dir,"..hit.impact_force_mul..")")
			self:AddImpulse( -1, hit.pos, hit.dir, hit.impact_force_mul );
		end
	end

end

-----------------------------------------------------------------------------------------------------------
function BasicPlayer:Server_OnDamageDead( hit )
--printf("server on Damage DEAD %.2f %.2f",hit.impact_force_mul_final,hit.impact_force_mul);
  if( Game:IsMultiplayer() ) then return; end	
	if( hit.ipart and (not hit.explosion)) then
		self:AddImpulse( hit.ipart, hit.pos, hit.dir, hit.impact_force_mul );
	else
		self:AddImpulse( -1, hit.pos, hit.dir, hit.impact_force_mul );
	end
end


-----------------------------------------------------------------------------------------------------------
function BasicPlayer:Client_OnDamage( hit )

  --System:LogToConsole("client damage "..hit.damage);
  --System:LogToConsole("melee damage type "..Hud.meleeDamageType);

--System.LogToConsole("client damage "..hit.weapon_death_anim_id);
--System.LogToConsole("deathImp "..hit.dir.x.." "..hit.dir.y.." "..hit.dir.z  );

--if (type(hit) == "table") then
--System:LogToConsole( "It was tableHit!" );
--else
--System:LogToConsole( "It was valueHit!  "..hit );
--do return end
--end

	-- don't process building damage done on players at all
	if (hit.damage_type ~= nil and hit.damage_type == "building") then
		return;
	end
	
	--dont play client side damage effect if the explosion is not really damaging the player.
	if (hit.explosion ~= nil) then
		
		local expl = self:IsAffectedByExplosion();
		
		if (expl<=0) then 
			--Hud:AddMessage(self:GetName().." skip pain sounds because not affected by explosion");
			return;
		end
	end

	BasicPlayer.SetDeathImpulse( self, hit );

	--target_material

	if (hit.damage>0) then
		if(not Sound:IsPlaying(self.painSound)) then
			self.painSound = BasicPlayer.PlayOneSound( self, self.painSounds, 70 );
		end
	end

--no pain animations now - use physics
	BasicPlayer.PlayPainAnimation( self, hit );

--	self:AddImpulse( hit.ipart, hit.pos, hit.dir, 500 );
--	self.AddImpulse( hit.ipart, hit.pos, hit.dir, hit.damage*5 );

	if ( self == _localplayer ) then	-- shake it, baby !
		local ShakeAxis = self.cnt:CalcDmgShakeAxis( hit.dir );
		if ( ShakeAxis ) then
			if ( ShakeAxis.y < -0.5 ) then Hud.dmgindicator = bor( Hud.dmgindicator, 1 ); end
			if ( ShakeAxis.y > 0.5 ) then Hud.dmgindicator = bor( Hud.dmgindicator, 2 ); end
			if ( ShakeAxis.x < -0.5 ) then Hud.dmgindicator = bor( Hud.dmgindicator, 4 ); end
			if ( ShakeAxis.x > 0.5 ) then Hud.dmgindicator = bor( Hud.dmgindicator, 8 ); end
			
			-- tiago: i've decreased shake amount to half..
			--local ShakeAmount = hit.damage * .05;	
			
			--filippo: cap shake between 0-13 (0 = 0 damage, 13 = 100 damage)
			local ShakeAmount = min(hit.damage,100.0);
			ShakeAmount = ShakeAmount/100.0*13.0;
			--Hud:AddMessage(hit.damage..","..ShakeAmount);
			
			if ( ShakeAmount > 45 ) then ShakeAmount = 45; end
			if(random(1,100)<50) then
				ShakeAmount = -ShakeAmount;
			end	
			--self.cnt:ShakeCamera( ShakeAxis, ShakeAmount, 3, .33);
			self.cnt:ShakeCamera( ShakeAxis, ShakeAmount, 2, .33);
		end
										
		-- [tiago]handle diferent screen damage fx's..
		if(hit.damage>0 and self.cnt.health ~= 0) then	-- fix, since player continues to get damage after dead.. make sure no screen fx
			local amplitude = min(hit.damage, 100.0) / 100.0;
			-- override previous hit damage indicators		
			if(hit.falling) then
				Hud.dmgindicator = bor( Hud.dmgindicator, 16 );
				self.cnt:TriggerHapticEffect("damage_fall", amplitude);
				self.cnt:TriggerBHapticsEffect("damage_fall", "damage_fall", 1.2 + amplitude);
			end
			
			if(hit.explosion) then				
				Hud:OnMiscDamage(hit.damage/5);			
				Hud:SetScreenDamageColor(0.25, 0.0, 0);		
				self.cnt:TriggerHapticEffect("damage_explosion", amplitude);
				self.cnt:TriggerBHapticsEffect("hit_by_explosion", "hit_by_explosion", amplitude, hit.pos, hit.dir);
			elseif	(hit.drowning) then						
				Hud:OnMiscDamage(hit.damage);							
				Hud:SetScreenDamageColor(0.6, 0.7, 0.9);			
				self.cnt:TriggerHapticEffect("damage_drowning", amplitude);
				self.cnt:TriggerBHapticsEffect("damage_drowning", "damage_drowning", 0.1);
			elseif	(hit.fire) then						
				Hud:OnMiscDamage(hit.damage*10);			
				Hud:SetScreenDamageColor(0.9, 0.8, 0.8);
				self.cnt:TriggerHapticEffect("damage_fire", amplitude);
				self.cnt:TriggerBHapticsEffect("damage_fire", "damage_fire", 0.6);
			elseif (Hud.meleeDamageType=="MeleeDamageNormal") then			
				Hud.meleeDamageType=nil;
				Hud:OnMiscDamage(hit.damage);					
				Hud:SetScreenDamageColor(0.9, 0.8, 0.8);
				self.cnt:TriggerHapticEffect("damage_melee", amplitude);
				self.cnt:TriggerBHapticsEffect("hit_by_melee", "hit_by_melee", amplitude, hit.pos, hit.dir);
			elseif (Hud.meleeDamageType=="MeleeDamageGas") then			
				Hud.meleeDamageType=nil;				
				Hud:OnMiscDamage(hit.damage);					
				Hud:SetScreenDamageColor(0.0, 0.4, 0.1);
				self.cnt:TriggerHapticEffect("damage_melee", amplitude);
			else			
				Hud:OnMiscDamage(hit.damage/30.0);					
				Hud:SetScreenDamageColor(0.9, 0.8, 0.8);
				self.cnt:TriggerHapticEffect("damage", amplitude);
				if (hit.weapon ~= nil) then
					local effect = "hit_by_bullet";
					if (hit.weapon.name == "SniperRifle") then
						effect = "hit_by_sniper";
					end
					if (hit.weapon.name == "Shotgun") then
						effect = "hit_by_shotgun";
					end
					self.cnt:TriggerBHapticsEffect(effect, effect, amplitude, hit.pos, hit.dir);
				end
			end
		end
		
	end
		

end


-----------------------------------------------------------------------------------------------------------
function BasicPlayer:DoStepSound()


--do return end


--	if( self.cnt.doStepSound == 1 ) then
		local pos=self:GetPos();
		local normal = g_Vectors.up;
		self.LastMaterial=self.cnt:GetTreadedOnMaterial();

 		if(self.LastMaterial ~= nil) then
 			if ((_time-self.LastFootStepTime)<0.20) then
 				return
 			end
 			
 			local doSoundEvent = 0;
 			if( Game:IsMultiplayer() and (self ~= _localplayer) )then
 				doSoundEvent = 1;
 			end	
 			
-- 			doSoundEvent = 1;
 				
 			self.LastFootStepTime=_time;
-- 			if(self~=_localplayer)then
-- 				System:LogToConsole("AI footstep");
-- 			else
-- 				System:LogToConsole("Player footstep");
--			 ssend
-- 			if(self.InWater==0) then
	
			--if its an AI that use a custom step sound return, because we already play the sound into "DoCustomStep" function.
			if (self.ai and BasicAI.DoCustomStep(self,self.LastMaterial,pos)) then
				return;
			end
	
			--if(not Game:IsPointInWater(self:GetPos())) then	-- player feet not under water 
			if(not Game:IsPointInWater(pos)) then	-- player feet not under water 
 				local SoundTable=self.LastMaterial.player_walk;
 				local SoundScale=BasicPlayer.soundScale.walk;
				local EventScale = BasicPlayer.soundEventRadius.walk;
				if( self.cnt.running ) then
--					AI.SoundEvent(self.id,pos,BasicPlayer.soundRadius.run,0,1,self.id);
					SoundTable=self.LastMaterial.player_run;
					SoundScale=BasicPlayer.soundScale.run;
					EventScale = BasicPlayer.soundEventRadius.run;
				elseif( self.cnt.crouching ) then
--					AI.SoundEvent(self.id,pos,BasicPlayer.soundRadius.crouch,0,1,self.id);
					SoundTable=self.LastMaterial.player_crouch;
					SoundScale=BasicPlayer.soundScale.crouch;
					EventScale = BasicPlayer.soundEventRadius.crouch;
					
				elseif( self.cnt.proning ) then
--					AI.SoundEvent(self.id,pos,BasicPlayer.soundRadius.prone,0,1,self.id);
					SoundTable=self.LastMaterial.player_prone;
					SoundScale=BasicPlayer.soundScale.prone;
					EventScale = BasicPlayer.soundEventRadius.prone;
				else
--					AI.SoundEvent(self.id,pos,BasicPlayer.soundRadius.walk,0,1,self.id);
					--SoundScale=BasicPlayer.soundScale.walk;
				end
				if (SoundTable) then
					ExecuteMaterial(pos, normal, SoundTable, 1, nil, nil, self.cnt);
					if( doSoundEvent == 1 and EventScale > 0) then
						-- to show it on the radar
						Game:SoundEvent(pos,EventScale,1,self.id);
					end
				end
				--System:LogToConsole("FOOTSTEP");
				-- lets play random equipment sounds if available
				if (self.EquipmentSoundProbability and self.EquipmentSounds) then
					local EquipmentSounds=getn(self.EquipmentSounds);
					if ((EquipmentSounds>0) and (random(1,100)<=self.EquipmentSoundProbability)) then
						local EquipmentSound=self.EquipmentSounds[random(1, EquipmentSounds)];
						--Sound:SetSoundPosition(EquipmentSound, pos);
						BasicPlayer.PlaySoundEx(self, EquipmentSound, SoundScale);
					end
				end
			else
				if ((self.Diving and self.Diving==0) or (self.Diving==nil)) then
					ExecuteMaterial(pos,normal,self.LastMaterial.player_walk_inwater,1, nil, nil, self.cnt);
					if( doSoundEvent == 1 and BasicPlayer.soundEventRadius.walk > 0) then
						-- to show it on the radar
						Game:SoundEvent(pos,BasicPlayer.soundEventRadius.walk,1,self.id);
					end
				end
--System:LogToConsole("\001 WATER FOOTSTEP");
			end
		else
			--System:LogToConsole("BasicPlayer:DoStepSound() nil material");
--			if(self.cnt.flying~=nil)then
--System:LogToConsole("\001 BasicPlayer:DoStepSound() nil material");
--			end
		end

end

-----------------------------------------------------------------------------------------------------------
function BasicPlayer:DoBushSound()

--	do return end	-- [lennert] this will execute footsteps twice in indoors !
--		local pos=self:GetPos();
--		local normal = g_Vectors.up;
--		local materialSoft=self.cnt:GetTouchedMaterial();

-- the following expression comment out all code between [[ and ]]
	bush_thing=[[
	if(materialSoft ~= nil) then
			self.BushInCounter = self.BushInCounter + 1;
 			if(self.InWater==0) then
				local soundScale = self.BushInCounter/self.BushSoundScale;
				if(soundScale > 1) then
					soundScale = 1;
				end

--System:LogToConsole( " bush soundScale "..soundScale );

				if( self.cnt.running ) then
					ExecuteMaterial(pos,normal,materialSoft.player_walk,BasicPlayer.soundScale.run*soundScale);
				elseif( self.cnt.crouching ) then
					ExecuteMaterial(pos,normal,materialSoft.player_walk,BasicPlayer.soundScale.crouch*soundScale);
				elseif( self.cnt.proning ) then
					ExecuteMaterial(pos,normal,materialSoft.player_walk,BasicPlayer.soundScale.prone*soundScale);
				else
					ExecuteMaterial(pos,normal,materialSoft.player_walk,BasicPlayer.soundScale.walk*soundScale);
				end
			end
		else
			self.BushInCounter = 0;
		end
		]]

		local pos=self:GetPos();
		local normal = g_Vectors.up;
		local materialSoft=self.cnt:GetTouchedMaterial();

		if(materialSoft ~= nil) then
 			if(self.InWater==0) then
				if( self.cnt.running ) then
					ExecuteMaterial(pos, normal, materialSoft.player_walk_by, 1, nil, nil, self.cnt);
--					ExecuteMaterial(pos,normal,materialSoft.player_walk,BasicPlayer.soundScale.run);
				elseif( self.cnt.crouching ) then
					ExecuteMaterial(pos, normal, materialSoft.player_walk_by, 1, nil, nil, self.cnt);
--					ExecuteMaterial(pos,normal,materialSoft.player_walk,BasicPlayer.soundScale.crouch);
				elseif( self.cnt.proning ) then
					ExecuteMaterial(pos, normal, materialSoft.player_walk_by, 1, nil, nil, self.cnt);				
--					ExecuteMaterial(pos,normal,materialSoft.player_walk,BasicPlayer.soundScale.prone);
				else
					ExecuteMaterial(pos, normal, materialSoft.player_walk_by, 1, nil, nil, self.cnt);
--					ExecuteMaterial(pos,normal,materialSoft.player_walk,BasicPlayer.soundScale.walk);
				end
			end


		end
--		self.bushSndTime = 0.7;
end


-----------------------------------------------------------------------------------------------------------
function BasicPlayer:DoStepSoundAI()	
	-- no footstep sound when in stealth mode

		local material=self.cnt:GetTreadedOnMaterial();
		--[filippo]
		local debugstring="";
		local soundradius=0;
		local playervelocity = self:GetVelocity();
		local velocitymodule = sqrt(playervelocity.x*playervelocity.x+playervelocity.y*playervelocity.y+playervelocity.z*playervelocity.z);

 		if(material ~= nil) then
				self.BushInCounterAI = self.BushInCounterAI + 1;
				local soundScale = self.BushInCounterAI/self.BushSoundScaleAI;
				if(soundScale > 1) then
					soundScale = 1;
				end

				local pos=self:GetPos();
-- 			if(self.InWater==0) then
				if( self.cnt.running ) then
					--[filippo]
					--to get if the player is sprint I check the average value between running speed and sprint speed, 
					--this because there could be problem near values around "self.move_params.speed_run"
					--local sprintbias = (self.move_params.speed_run*self.StaminaTable.sprintScale-self.move_params.speed_run)*0.5;
					
					local sprintbias=6;
					
					if (self.move_params~=nil) then
						sprintbias = self.move_params.speed_run+(self.move_params.speed_run*self.StaminaTable.sprintScale-self.move_params.speed_run)*0.5;
					end
										
					if (velocitymodule>sprintbias) then --player is sprinting
						soundradius = BasicPlayer.soundRadius.sprint*soundScale;
						debugstring = "sprint";
					else
						soundradius = BasicPlayer.soundRadius.run*soundScale;
						debugstring = "running";
					end
										
--					AI:SoundEvent(self.id,pos,BasicPlayer.soundRadius.run*soundScale,0,1,self.id);
--					Game:SoundEvent(pos,BasicPlayer.soundRadius.run*soundScale,0,self.id);
				elseif( self.cnt.crouching ) then
					--[filippo]
					soundradius = BasicPlayer.soundRadius.crouch*soundScale;
					debugstring = "crouch";
					
--					AI:SoundEvent(self.id,pos,BasicPlayer.soundRadius.crouch*soundScale,0,1,self.id);
--					Game:SoundEvent(pos,BasicPlayer.soundRadius.crouch*soundScale,0,self.id);
				elseif( self.cnt.proning ) then
					--[filippo]
					soundradius = BasicPlayer.soundRadius.prone*soundScale;
					debugstring = "prone";
					
--					AI:SoundEvent(self.id,pos,BasicPlayer.soundRadius.prone*soundScale,0,1,self.id);
--					Game:SoundEvent(pos,BasicPlayer.soundRadius.prone*soundScale,0,self.id);
				else
					--[filippo]
					soundradius = BasicPlayer.soundRadius.walk*soundScale;
					debugstring = "walk";
								
--					AI:SoundEvent(self.id,pos,BasicPlayer.soundRadius.walk*soundScale,0,1,self.id);
--					Game:SoundEvent(pos,BasicPlayer.soundRadius.walk*soundScale,0,self.id);
				end
			
				--[filippo]
				AI:SoundEvent(self.id,pos,soundradius,0,1,self.id);
				--for debug
				--Hud:AddMessage(debugstring.." radius:"..soundradius.." soundscale:"..soundScale.." velocity:"..velocitymodule);
		else
			self.BushInCounterAI = 0;
		end
end
-----------------------------------------------------------------------------------------------------------
function BasicPlayer:DoBushSoundAI()

	local stats = self.cnt;

	-- no footstep sound when in stealth mode
	local materialSoft=stats:GetTouchedMaterial();

	if(materialSoft ~= nil) then		
		local pos=self:GetPos();

			if( stats.running ) then
				AI:SoundEvent(self.id,pos,BasicPlayer.soundRadius.run,0,1,self.id);
--				Game:SoundEvent(pos,BasicPlayer.soundEventRadiusBush.run,1,self.id);
			elseif( stats.crouching ) then
				AI:SoundEvent(self.id,pos,BasicPlayer.soundRadius.crouch,0,1,self.id);
--				Game:SoundEvent(pos,BasicPlayer.soundEventRadiusBush.crouch,1,self.id);
			elseif( stats.proning ) then
				AI:SoundEvent(self.id,pos,BasicPlayer.soundRadius.prone,0,1,self.id);
--				Game:SoundEvent(pos,BasicPlayer.soundEventRadiusBush.prone,1,self.id);
			else
				AI:SoundEvent(self.id,pos,BasicPlayer.soundRadius.walk,0,1,self.id);
--				Game:SoundEvent(pos,BasicPlayer.soundEventRadiusBush.walk,1,self.id);
			end
	end
--	self.bushSndTimeAI = 0.7;
end



-----------------------------------------------------------------------------------------------------------
function BasicPlayer:DoLandSound()

--	if( self.cnt.doLandSound == 1 ) then
		local pos=self:GetPos();
		local normal = g_Vectors.up;
		local material=self.cnt:GetTreadedOnMaterial();
		if(material ~= nil) then
			if (Game:IsPointInWater(self:GetPos()) ~= nil) then	-- player feet under water
				ExecuteMaterial(pos,normal,material.player_walk_inwater,1);
			else
				ExecuteMaterial(pos,normal,material.player_walk,1);
			end
		end
		if( Game:IsMultiplayer() and (self ~= _localplayer) )then
			Game:SoundEvent(pos,BasicPlayer.soundEventRadius.jump,1,self.id);
		end
--	end
--	self.cnt.doLandSound = 0;
end


-----------------------------------------------------------------------------------------------------------
function BasicPlayer:UpdateInWaterSplash()
	if (self ~= _localplayer) then
		return
	end

	if (Game:IsPointInWater(self:GetPos()) ~= nil) then	-- player feet under water
		Sound:SetGroupScale(SOUNDSCALE_UNDERWATER, 1);
		local vCamPos = self:GetCameraPosition();		
		local bIsCameraUnderwater = Game:IsPointInWater(vCamPos);
		
		self.InWater = 1;

		-- If player is partialy in water, play swim/splash sounds do particles
		if (bIsCameraUnderwater==nil) then	-- partially under water

			--r_WaterRefractions=0;

			-- stop underwater sound
			if (self.sndUnderwaterNoise and Sound:IsPlaying(self.sndUnderwaterNoise)) then
				Sound:StopSound(self.sndUnderwaterNoise);
			end
			
			if (Sound:IsPlaying(self.sndUnderWaterSwim)) then
				Sound:StopSound(self.sndUnderWaterSwim);
			end
						
			if (self.Diving and self.Diving~=0) then
				Sound:PlaySound(self.sndBreathIn[random(1, getn(BasicPlayer.sndBreathIn))]);
			end
			self.Diving=0;
			if (not self.cnt.moving) then
				return
			end
--			if (self.LastMaterial==nil) then
			if (self.cnt:IsSwimming()) then
				
--System:Log("\001")				
				
				if ((self.SwimSound==nil) or (not Sound:IsPlaying(self.SwimSound))) then
	--				local iSoundIdx = random(1, getn(BasicPlayer.sndWaterSwim));
	--				self.SwimSound = BasicPlayer.sndWaterSwim[iSoundIdx];
					self.SwimSound = BasicPlayer.sndWaterSwim;
					if (self.SwimSound) then
						Sound:SetSoundLoop(self.SwimSound, 1);
						Sound:PlaySound(self.SwimSound);
					end
				end
			else
				if ((self.SwimSound~=nil) and (Sound:IsPlaying(self.SwimSound)==1)) then
					Sound:StopSound(self.SwimSound);
					self.SwimSound=nil;
				end
			end
			-- Spawn ripples if player enters water
			if (iLastWaterSurfaceParticleSpawnedTime == nil) then
				self.iLastWaterSurfaceParticleSpawnedTime = _time;
			end
			if (_time - self.iLastWaterSurfaceParticleSpawnedTime > 0.2) then
				local vVec = self:GetPos();
				vVec.z = Game:GetWaterHeight() + 0.02;	
				vVec.x = vVec.x + 0.25 - random(1, 100) / 200;
				vVec.y = vVec.y + 0.25 - random(1, 100) / 200;	
				Particle:CreateParticle( vVec, g_Vectors.up, BasicPlayer.WaterRipples );
				self.iLastWaterSurfaceParticleSpawnedTime = _time;
			end
		else		-- fully under water
			Sound:SetGroupScale(SOUNDSCALE_UNDERWATER, 0);
			self.Diving=1;

			-- If player is under water, play random under-water noises and stop
			-- the swim/splash sounds
			if ((self.SwimSound~=nil) and (Sound:IsPlaying(self.SwimSound)==1)) then
				Sound:StopSound(self.SwimSound);
				self.SwimSound=nil;
			end
			if ((Sound:IsPlaying(self.sndUnderwaterNoise)~=1)) then
				Sound:SetSoundLoop(self.sndUnderwaterNoise, 1);
				Sound:PlaySound(self.sndUnderwaterNoise);
			end
			-- if moving - play underwaterSwim sound		
			if ( self.cnt.moving ) then
				if (not Sound:IsPlaying(self.sndUnderWaterSwim)) then
					Sound:SetSoundLoop(self.sndUnderWaterSwim, 1);
					Sound:PlaySound(self.sndUnderWaterSwim);
				end
			elseif (Sound:IsPlaying(self.sndUnderWaterSwim)) then
				Sound:StopSound(self.sndUnderWaterSwim);
			end
		end
	else	-- not in water at all
		Sound:SetGroupScale(SOUNDSCALE_UNDERWATER, 1);
		self.InWater = 0;
		self.Diving=0;
		if ((self.SwimSound~=nil) and (Sound:IsPlaying(self.SwimSound)==1)) then
			Sound:StopSound(self.SwimSound);
			self.SwimSound=nil;
		end
		if ((self.sndUnderwaterNoise~=nil) and (Sound:IsPlaying(self.sndUnderwaterNoise)==1)) then
			Sound:StopSound(self.sndUnderwaterNoise);
		end
		if (self.sndUnderWaterSwim~=nil and Sound:IsPlaying(self.sndUnderWaterSwim)) then
			Sound:StopSound(self.sndUnderWaterSwim);
		end
	end
end


-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
--
-----------------------------------------------------------------------------------------------------------
function BasicPlayer:Reload()

	local stats = self.cnt;
	local CurWeaponInfo = self.weapon_info;
	local CurWeapon = stats.weapon;
	if(stats.weapon)then

		if (self.ai) then 
			if (stats.ammo_in_clip > self.fireparams.bullets_per_clip/2) then
				do return end
			end
		end

		BasicWeapon.Server.Reload( CurWeapon, self );
		BasicWeapon.Client.Reload( CurWeapon, self );
		stats.weapon_busy=CurWeapon.FireParams[CurWeaponInfo.FireMode+1].reload_time;
	end

end

-----------------------------------------------------------------------------------------------------------
function BasicPlayer:OnLoad(stm)
	self.cnt.ammo = 0;
	self.cnt.ammo_in_clip = 0;

	local mutated = stm:ReadBool();
	if (mutated) then
		self.iPlayerEffect = 6;
	end
	self.cnt.has_binoculars = stm:ReadBool();
	self.cnt.has_flashlight = stm:ReadBool();
	self.Energy=stm:ReadInt();
	self.MaxEnergy=stm:ReadInt();
	self.Refractive=stm:ReadBool();
	self.bShowOnRadar=stm:ReadBool();
	self.bEnemyInCombat=stm:ReadBool();
	local count=stm:ReadInt();
	while(count>0) do
		local weaponName = stm:ReadString();
		local idx = stm:ReadInt();
		System:Log("LOADING "..idx);
		local t=ReadFromStream(stm);
		local fm=stm:ReadInt();
		if(self.WeaponState[idx] == nil)then
			-- init the weapon
			BasicPlayer.ScriptInitWeapon(self, weaponName);
		end
		
		if(self.WeaponState[idx])then
			self.WeaponState[idx].AmmoInClip=t;
			self.WeaponState[idx].FireMode=fm;
		else
			System:Log("WARNING WEAPON STATE NOT FOUND ");
		end
		count=count-1
	end
	self.Ammo=ReadFromStream(stm);
	
--	local third_person_v=stm:ReadInt();
--System:Log("\001 loading >>>  third_person_v "..third_person_v);
--	-- restoring camera mode
--	if( third_person_v == 1 ) then
--		Game:SetThirdPerson(1);
--	end	

	--System:Log("LOAD - WeaponState");
	--dump(self.WeaponState);
	--System:Log("LOAD - Ammo");
	--dump(self.Ammo);

	BasicPlayer.fBodyHeat=1.0;
end

-----------------------------------------------------------------------------------------------------------
-- this makes sure that all cached ammo values of currently active weapons/grenades are
-- written back to the respective stores (Ammo and AmmoInClip in the weaponstate)
function BasicPlayer:SyncCachedAmmoValues()
	if (self.cnt.weapon and (self.fireparams ~= nil)) then
		self.Ammo[self.fireparams.AmmoType]=self.cnt.ammo;
		local weaponState = GetPlayerWeaponInfo(self);
		if (weaponState) then
			weaponState.AmmoInClip[self.firemodenum]=self.cnt.ammo_in_clip;
		end
	end
	-- make sure grenade ammo is up-to-date
	self.Ammo[GrenadesClasses[self.cnt.grenadetype]]=self.cnt.numofgrenades;
end
-----------------------------------------------------------------------------------------------------------
function BasicPlayer:OnSave(stm)

	--System:Log("AmmoSAVE: "..tostring(self.cnt.ammo).." "..tostring(self.cnt.ammo_in_clip));
	BasicPlayer.SyncCachedAmmoValues(self);
	
	--- is the player mutated?
	stm:WriteBool(self.iPlayerEffect and self.iPlayerEffect == 6);
	stm:WriteBool(self.cnt.has_binoculars);
	stm:WriteBool(self.cnt.has_flashlight);
	stm:WriteInt(self.Energy);
	stm:WriteInt(self.MaxEnergy);
	stm:WriteBool(self.Refractive);
	stm:WriteBool(self.bShowOnRadar);
	stm:WriteBool(self.bEnemyInCombat);
		
	local nentries=0;
	for i,val in self.WeaponState do
		if(type(i)=="number"
		and type(val.AmmoInClip)=="table")then nentries=nentries+1; end
	end
	stm:WriteInt(nentries);
	for i,val in self.WeaponState do
		if(type(i)=="number"
		and type(val.AmmoInClip)=="table")then
			--System:Log("SAVING "..i);
			stm:WriteString(val.Name);
			stm:WriteInt(i);
			WriteToStream(stm,val.AmmoInClip);
			stm:WriteInt(val.FireMode);
		end
	end
	
	--System:Log("SAVE - WeaponState");
	--dump(self.WeaponState);
	--System:Log("SAVE - Ammo");
	--dump(self.Ammo);
	
	WriteToStream(stm,self.Ammo);
	
	-- saving camera mode
--if(not self.cnt.first_person) then	
--System:Log("\001 saving >>>  third_person_v ");	
--else
--System:Log("\001 saving >>>  NO third_person_v ");	
--end
--	
--	if(self.cnt.first_person==nil and self==_localplayer)then	
--		stm:WriteInt( 1 );
--System:Log("\001 saving >>>  one");			
--	else	
--		stm:WriteInt( 0 );
--System:Log("\001 saving >>>  zero ");			
--	end	
end


--------------------------------------------------------------------------------------------------------
function BasicPlayer:ProcessCommand( Params )
	local Sender = System:GetEntity( Params.Sender );
	-- SAY
	if ( Params.CommandID == CMD_GO ) then
		Game:ShowIngameDialog(-1, "", "", 12,	"A new command has been received: $4Go to the location marked on your map !", 10);
		Game:SetNavPoint("Go", Params.Target);
	elseif ( Params.CommandID == CMD_ATTACK ) then
		Game:ShowIngameDialog(-1, "", "", 12,	"A new command has been received: $4Attack the location marked on your map !", 10);
		Game:SetNavPoint("Attack", Params.Target);
	elseif ( Params.CommandID == CMD_DEFEND ) then
		Game:ShowIngameDialog(-1, "", "", 12,	"A new command has been received: $4Defend the location marked on your map !", 10);
		Game:SetNavPoint("Defend", Params.Target);
	elseif ( Params.CommandID == CMD_COVER ) then
		Game:ShowIngameDialog(-1, "", "", 12,	"A new command has been received: $4Cover the location marked on your map !", 10);
		Game:SetNavPoint("Cover", Params.Target);
	elseif ( Params.CommandID == CMD_BARRAGEFIRE ) then
		Game:ShowIngameDialog(-1, "", "", 12,	"A new command has been received: $4Barrage Fire at the location marked on your map !", 10);
		Game:SetNavPoint("Barrage Fire", Params.Target);
	end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Server_SpawnGrenadeCallback =
{
	OnEvent = function( self, event, Params )
		local player = Params.player;
		if player.abortGrenadeThrow then
			player.abortGrenadeThrow = nil
			return
		end
		-- Lets just assume we are supposed to throw a grenade
		local Grenade = Server:SpawnEntity(GrenadesClasses[player.cnt.grenadetype]);

		if(not (player.cnt.grenadetype == 1))then
			player.cnt.numofgrenades = player.cnt.numofgrenades-1;
		end
		
		
		player.cnt:GetFirePosAngles(Params.pos, Params.angles, Params.dir);
		
		--grenade should spawn a bit forward than the player eye pos, this to prevent problems with the leaning for example.
		local testpos = g_Vectors.temp_v1;
		
		CopyVector(testpos,Params.pos);
		
		local pos = Params.pos;
		local dir = Params.dir;
		
		testpos.x = testpos.x + dir.x * 0.5;
		testpos.y = testpos.y + dir.y * 0.5;
		testpos.z = testpos.z + dir.z * 0.5;
		
		--test the shifted position, if its safe , use it.
		hits = System:RayWorldIntersection(pos, testpos, 1,ent_static+ent_sleeping_rigid+ent_rigid+ent_independent+ent_terrain,self.id,Grenade.id);
			
		if (getn(hits) == 0) then
			CopyVector(Params.pos,testpos);
		end
		--
	
		--projectiles (grenades, for ex) should inherit player's velocity
		--it's calculated in C code, here we should get the correct velocity already
		Grenade:Launch(player.cnt.weapon, player, Params.pos, Params.angles, Params.dir, Params.lifetime);		
	end
}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicPlayer:Server_OnFireGrenade(Params)
	local stats = self.cnt;
	
	if ((type(Params)=="table" and Params.underwater) or stats:IsSwimming() or stats.reloading) then return end
	
	if self.abortGrenadeThrow then
		self.abortGrenadeThrow = nil
	end

	if ((stats.grenadetype == 1) or stats.numofgrenades>0) then
		stats.weapon_busy=1.5;
	else
		System:Log("WARNING self.cnt.numofgrenades<0 this shouldn't happen");
	end
	
	local ThrowParams = new(Params);
	ThrowParams.player = self;
	Game:SetTimer( Server_SpawnGrenadeCallback, 12 * (1000/30), ThrowParams);
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicPlayer:Client_OnFireGrenade(Params)
	local stats = self.cnt;
	
	if((type(Params)=="table" and Params.underwater) or stats:IsSwimming() or stats.reloading)then return end
	
	if (not (stats.grenadetype == 1) and not (stats.numofgrenades>0)) then
		do return end;
	end
	
	if ((_localplayer == self) and (stats.weapon)) then
		stats.weapon:StartAnimation(0, "Grenade1"..self.weapon_info.FireMode+1,0,0);
	end
	
	stats.weapon_busy=1.5;
end

-- called to evaluate if the state of the player is drowning
-- return nil when the player is not drowning, or a hit table if he is drowning
-- the hit table can then be processed by damage functions (on server/client)
function BasicPlayer:IsDrowning()
	local stats = self.cnt;
	
	--filippo, the drowning check didnt count if the player is underwater or not, this caused drowning screen while jumping with low stamina.
	if (stats.stamina<=0 and stats.health>0 and stats.underwater>0) then	
--	if stats.stamina<=0 and stats.health>0  then			-- we are drowning - apply damage
--	if stats.underwater>self.drown_time then		

--		stats.health=stats.health-5*_frametime;
--		stats.health=stats.health-160*_frametime;		
--		if stats.health<0 then
--			stats.health=0;
--		end

		local	dmgScale = _frametime;
		-- let's cap it to prevent lots of damage if frame was long (was loading in this frame)
		if(dmgScale>0.03) then dmgScale = 0.03 end
		
--System:Log("BasicPlayer:IsDrowning  "..230*dmgScale.." "..dmgScale );
		return {
			dir = g_Vectors.v001,
			damage = 230*dmgScale,
			target = self,
			shooter = self,
			landed = 1,
			impact_force_mul_final=5,
			impact_force_mul=5,
			damage_type="healthonly",
			--damage_type="drowning",
			drowning=1,
		};
	else
		return nil;
	end
end

-------------------------------------------------------------------------
--
function BasicPlayer:Server_OnTimer()

	self:SetScriptUpdateRate(self.UpdateTime);

	local stats = self.cnt;

	local hit = BasicPlayer.IsDrowning(self);	
	if hit then self:Damage( hit ); end

	-- If not in vehicle and not at mounted weapon
	-- restrict angles
	if ( stats.proning ) then
		if (self.isProning == 0) then
			self.isProning=1;
			stats:SetMinAngleLimitV( self.proneMinAngle );
			stats:SetMaxAngleLimitV( self.proneMaxAngle );
		end
	else
		if (self.isProning == 1) then
			self.isProning=0;
			stats:SetMinAngleLimitV( self.normMinAngle );
			stats:SetMaxAngleLimitV( self.normMaxAngle );
		end
	end

	-- Update the energy
	if (self.EnergyIncreaseRate and self.ChangeEnergy) then
		self:ChangeEnergy(self.EnergyIncreaseRate * self.UpdateTime/1000.0);
	end

	if (stats.health < 1 and self == _localplayer and Game:ShowSaveGameMenu()) then
		-- changed by marcio
		-- this was causing the menu to popup after you died,
		-- the producers didn't want this
		--Game:ToggleMenu();
	else
--		self:SetTimer(self.UpdateTime);
		if (stats.moving ) then
			BasicPlayer.DoBushSoundAI(self);
		end
	end

	-- when in vehicle (boat) - see if collides with sometnig - release if yes
	BasicPlayer.UpdateCollisions(self);
		
	--until we dont have some dedicated functions for jumping use this to get if player has jumped
	BasicPlayer.PlayerJumped(self);
end


-------------------------------------------------------------------------
--
function BasicPlayer:OnEnterWater()

	-- player has just entered the water, check its velocity
	local vel =new(self:GetVelocity());	
	--System:LogToConsole("vel="..vel.x..","..vel.y..","..vel.z);
	if ((vel.z < -1.1)) then
		local pos=new(self:GetPos());
		--BasicPlayer.PlaySoundEx(self, self.sndWaterSplash);
		ExecuteMaterial(pos, g_Vectors.v001, CommonEffects.water_splash, 1);
		--System:LogToConsole("splash");
	end		
end

-------------------------------------------------------------------------
-- ProcessPlayerEffects: process/handles all shader based character effects
function BasicPlayer.ProcessPlayerEffects(entity)

	if(not entity) then
		return;
	end
	
	-------------------------
	-- process player effects
																
	-- only set, when shader changes !	
	local iEffectsElementsCount=getn(entity.pEffectStack);
	local iUpdate=0;
	
	if(entity.iPlayerEffect>0 and entity.pEffectStack[iEffectsElementsCount]~=entity.iPlayerEffect) then			
		-- remove current effect
		if(entity.iPlayerEffect==1) then
			if(iEffectsElementsCount>1) then 															
				tremove(entity.pEffectStack);				
				entity.iPlayerEffect=entity.pEffectStack[iEffectsElementsCount-1];				
			end
		else			
			-- add new effect						
			tinsert(entity.pEffectStack , entity.iPlayerEffect);								
		end				
		
		iUpdate=1;
		BasicPlayer.SetPlayerEffect(entity);					
	end
	
	if(entity==_localplayer and entity.iLastWeaponID~=_localplayer.cnt.weaponid) then			    			    				    																				
		entity.iLastWeaponID=_localplayer.cnt.weaponid;				
		iUpdate=1;
	end
	
	-- cryvision is special case, overlap all other shader effects
	if(entity.bPlayerHeatMask==1 or entity.bPlayerHeatMask==3) then							
		if(entity.bPlayerHeatMask==1 or iUpdate==1) then
			-- reset all
			entity:SetShader("", 4);														
			if(entity==_localplayer) then			    			    				    																		
					-- now set to character and arms		    	
		    	entity:SetShader("TemplCryVisionPlayer", 2); 	 		
		    	entity:SetSecondShader("", 4);  												    			    	
	  	else	  	
	  		-- set characters heat mask on 1st layer, and heat signature on 2nd layer
    		entity:SetShader("TemplCryVision_Mask", 0);	  	  	    		  	  		  	  					  		    		  		  	  			  	  			  	  			  	     			
    		entity:SetSecondShader("TemplCryVision", 2);    		    		
  		end		
  	  		
  		entity.bPlayerHeatMask=3;		
  	end
  	  				
  	if(entity.fLastBodyHeat~=entity.fBodyHeat) then
			entity.bUpdatePlayerEffectParams=1;			
			entity.fLastBodyHeat=entity.fBodyHeat;
		end
									  		
	elseif(entity.bPlayerHeatMask==2 or (entity==_localplayer and iUpdate==1)) then						
		entity.bPlayerHeatMask=0;
		-- restore old effects
		BasicPlayer.SetPlayerEffect(entity);		
	end
				
	-- update player effect params
	if(entity.bUpdatePlayerEffectParams==1) then
		BasicPlayer.UpdatePlayerEffectParams(entity);
		entity.bUpdatePlayerEffectParams=0;
	end		
end

-------------------------------------------------------------------------
-- SetPlayerEffect: set current character render effect
-- Notes: any new shader effect for characters, should be handled here to ensure
-- proper SetShader/SetSecondShader functionality, and shaders dependencies (eg: heat source, overcomes all other shaders)
-- available effects are:
-- 1. reset effect
-- 2. character color mask
-- 3. invulnerability
-- 4. heat source
-- 5. stealth
-- 6. mutated (note, should be used only with Jack model/localplayer)

-- Note: SetShader/SetSecondShader changed, now works like SetSecondShader(szShaderName, Mask)
-- where Mask= 0: character only, 1: character+attached, 2: character+arms, 3:character+arms+attached, 4: all

function BasicPlayer.SetPlayerEffect(entity)
	-- get current effect ID
	local iEffectID=entity.pEffectStack[getn(entity.pEffectStack)];

	entity:SetShader("", 4);	
	entity:SetSecondShader("", 4);  				
									
	if(iEffectID==3) then	  	-- iEffectID invulnerable ?																																	
		entity:SetSecondShader( "CharacterInvulnerability_Metal", 0);   										
	elseif(iEffectID==5) then			-- is in stealth ?	
		entity:SetShader( "MutantStealth", 4);					
	elseif(iEffectID==2) then			-- is colored ?			
		entity:SetSecondShader( "PlayerMaskModulate", 0);														
	elseif(iEffectID==6) then		-- mutated arms effect	
		entity:SetSecondShader( "TemplMutatedArms", 2);							
	end
	
end

function BasicPlayer.UpdatePlayerEffectParams(entity)

	-- get current effect ID
	local iEffectID=entity.pEffectStack[getn(entity.pEffectStack)];
	
	-- cryvision is special case
	if(entity.bPlayerHeatMask==1 or entity.bPlayerHeatMask==3) then	
		-- set shaders	
		local fHeat=entity.fBodyHeat+0.4;
		if(fHeat>0.85) then
			fHeat=0.85;
		end		
	
		if(entity==_localplayer) then			    			    				    																							 
    	entity:SetShaderFloat("BodyHeat", fHeat, 0, 0);   		    		  		  	  			    			    								
  	else	  	
  		entity:SetShaderFloat("BodyHeat", fHeat, 0, 0);
		end		
	end
													
	if(iEffectID==3) then	  	-- iEffectID invulnerable ?																																		
		-- no params to update		
	elseif(iEffectID==5) then			-- is in stealth ?		
		entity:SetShaderFloat("Refraction", entity.refractionValue , 0, 0);   	  		  	  			    																				
	elseif(iEffectID==2) then			-- is colored ?	
		local color=entity.cnt:GetColor();					
		entity:SetShaderFloat( "ColorR", color.x,0,0 );
		entity:SetShaderFloat( "ColorG", color.y,0,0 );
		entity:SetShaderFloat( "ColorB", color.z,0,0 );						
	elseif(iEffectID==6) then		-- mutated arms effect	
		-- no params to update						
	end
	
end
	
	
--
function BasicPlayer:Client_OnTimer()
	BasicPlayer.ProcessPlayerEffects(self);	


	
	self:SetScriptUpdateRate(self.UpdateTime);



	if( self.Client_OnTimerCustom ) then
		self:Client_OnTimerCustom();
	end
	
	local hit = BasicPlayer.IsDrowning(self);
	if (hit) then BasicPlayer.Client_OnDamage(self, hit); end

	local stats = self.cnt;

	if(self.ladder) then
		self.ladder:UpdatePlayerSound( self );
	end	
		

	-- check for local client only
	if(Hud and (self==_localplayer)) then
		-- Update the energy
		if (Game:IsMultiplayer() and self.EnergyIncreaseRate and self.ChangeEnergy) then
			self:ChangeEnergy(self.EnergyIncreaseRate * self.UpdateTime/1000.0);
		end
		
		-- spawn some bubbles when he drows			
		if (stats.underwater>0) then
			local Pos=self:GetPos();
			Pos.z=Pos.z+1.5;
			BasicWeapon.UnderwaterBubbles.count=16+random(1,64);		
			BasicWeapon.UnderwaterBubbles.fPosRandomOffset=1.5;
			Particle:CreateParticle(Pos, g_Vectors.v001, BasicWeapon.UnderwaterBubbles);		
			BasicWeapon.UnderwaterBubbles.count=1;
			BasicWeapon.UnderwaterBubbles.fPosRandomOffset=0;
	
	
			-- When the player is underwater, a Breath Meter appears on the HUD.
			-- this meter displays the amount of air the player has before he will
			-- begin to take damage.
				
				
--			Hud.breathlevel = stats.breath;
--			if (stats.underwater>self.drown_time)then
--				--System:Log("aaaauuughggghghghg auuughhghg");
--				Hud.breathlevel=0;
--			else						
--				Hud.breathlevel=(self.drown_time-stats.underwater)/(self.drown_time+1); -- avoid divisions by 0				
--			end			
--		else
--			Hud.breathlevel=1;						
--			Hud.staminalevel=self.cnt.stamina;				
		end
		
		Hud.breathlevel=stats.breath;						
		Hud.staminalevel=stats.stamina;				
	
--System:Log("\002 "..self.cnt.stamina.." "..self.cnt.breath);						
		
			-- there's some problem in stamina update, when inside water, stops being updated
			--Hud.staminalevel=self.cnt.stamina;				
	end
	
--	System:LogToConsole("--> Client Timer Event Received !");
	--System:LogToConsole("CLI OnTimer("..self.id..")");
--	self:SetTimer(self.UpdateTime);

	BasicPlayer.UpdateInWaterSplash(self);


	if( self.cnt.vel > .001 ) then
		self:ApplyForceToEnvironment(1.0, self.cnt.vel*0.05);
	end
		
--	self.bushSndTime = self.bushSndTime - DeltaTime;

--	if (stats.moving and self.bushSndTime <= 0) then
	if (stats.moving) then
		BasicPlayer.DoBushSound(self);
		--System.MeasureTime("DoBushSound");
	end
	
	-- play heavy breathing sound when exhausted...
	-- COMMENTED DUE TO BAD SOUNDING, PLEASE DO NOT REMOVE YET !!!
--	if (stats.running and self.ExhaustedBreathingSound) then
--		if (not self.ExhaustedStartTime) then
--			self.ExhaustedStartTime=0;
--		end
--		self.ExhaustedStartTime=self.ExhaustedStartTime+self.UpdateTime/1000;
--		if (self.ExhaustedStartTime>self.ExhaustedBreathingStart) then
--			if (not Sound:IsPlaying(self.ExhaustedBreathingSound)) then
--				System:LogToConsole("Start Breathing");
--				Sound:SetSoundLoop(self.ExhaustedBreathingSound, 1);
--				Sound:PlaySound(self.ExhaustedBreathingSound);
--				self.ExhaustedStopTime=0;
--			end
--		end
--	else
--		self.ExhaustedStartTime=0;
--		if (self.ExhaustedStopTime) then
--			System:LogToConsole("self.ExhaustedStopTime");
--			self.ExhaustedStopTime=self.ExhaustedStopTime+self.UpdateTime/1000;
--			if (self.ExhaustedStopTime>self.ExhaustedBreathingStop) then
--				System:LogToConsole("Stop Breathing");
--				Sound:SetSoundLoop(self.ExhaustedBreathingSound, 0);
--				self.ExhaustedStopTime=nil;
--				--Sound:StopSound(self.ExhaustedBreathingSound);
--			end
--		end
--	end

	if (self == _localplayer) then
		------------------------------------------
		-- Main player specific update code
		------------------------------------------
		self.vLastPos = self:GetPos();
		-- restrict angles
		if ( stats.proning ) then
			if (self.isProning==0) then
				self.isProning=1;
				--stats:SetAngleLimitBaseOnEnviroment();
				stats:SetMinAngleLimitV( self.proneMinAngle );
				stats:SetMaxAngleLimitV( self.proneMaxAngle );
--				Input:SetMouseSensitivityScale( 0.1 );
			end
		else
			if (self.isProning==1) then
				self.isProning=0;
				--stats:SetAngleLimitBaseOnVertical();
				stats:SetMinAngleLimitV( self.normMinAngle );
				stats:SetMaxAngleLimitV( self.normMaxAngle );
--				Input:SetMouseSensitivityScale( 1.0 );
			end
		end

		-- set send an sneaking-mood-event if we're crouching or proning
		if ( self.cnt.crouching or self.cnt.proning ) then
			Sound:AddMusicMoodEvent("Sneaking", MM_SNEAKING_TIMEOUT);
		end
		
		if(self.Energy < 1)then
			ClientStuff.vlayers:DeactivateActiveLayer("HeatVision");
		end

		-- disable some stuff when the player goes swimming
		if (self.cnt:IsSwimming()) then
			ClientStuff.vlayers:DeactivateActiveLayer("HeatVision");
			ClientStuff.vlayers:DeactivateActiveLayer("WeaponScope");
			ClientStuff.vlayers:DeactivateActiveLayer("Binoculars");

		-- out of air indication sounds			
--			if( self.cnt.breath < .3 ) then
--				if (Sound:IsPlaying(self.sndNoAir) ~= 1) then
--					self.tSndNoAir = self.tSndNoAir + 1;
--					if( self.tSndNoAir > 5 ) then
--						self:PlaySound(self.sndNoAir);
--						self.tSndNoAir = 0;
--					end
--						
--				end
--			end
		end

	end
	

	--until we dont have some dedicated functions for jumping use this to get if player has jumped
	BasicPlayer.PlayerJumped(self);
	
	BasicPlayer.PlayJumpSound(self);
	
	if (self.theVehicle) then
		BasicPlayer.DoSpecialVehicleAnimation(self);
	end
	
	--when player have 4 weapons ,and is near a weapon to pickup , display the message.
	if (self.pickup_ent) then
		
		--Hud.label = "@PressDropWeapon @"..self.cnt.weapon.name.." @AndPickUp @"..self.pickup_ent.weapon;
		--Hud.labeltime = self.UpdateTime/1000.0;
		
		local dist = EntitiesDistSq(self,self.pickup_ent);
		
		if (dist>self.pickup_dist+0.01) then
					
			self.pickup_ent = nil;	
			self.pickup_OnContact = nil;
			self.pickup_dist = 0;
			
		elseif (self.pickup_OnContact) then			
			
			self.pickup_OnContact(self.pickup_ent,self);
			Hud.labeltime = self.UpdateTime/1000.0;--keep the label message for a while.
		end						
	end
end


-------------------------------------------------------------------------
--
function BasicPlayer:Client_OnTimerDead()


--System:Log("\001 BasicPlayer:Client_OnTimerDead gore  >>  "..g_gore );

	-- no blood from dead body
	if ((g_gore == "0") or (g_gore == "1")) then return end

local deadUpdateTime=100;
	self:SetTimer(deadUpdateTime);
--	local pos = self:GetPos();
	local pos = self:GetBonePos("Bip01 Spine");
	if( not pos ) then
		pos = self:GetPos();
	end	


--
--System:Log("\001 >>>Client_OnTimerDead "..pos.x.." "..pos.y.." "..pos.z);

--
----	

	local terrain = System:GetTerrainElevation( pos );
	local waterLevel = Game:GetWaterHeight();

	if( Game:IsPointInWater(pos) and terrain<waterLevel ) then
--		
--System:Log("\001 >>>inWATER ---  ");
--		pos.z = pos.z + 1.2;
		waterLevel = waterLevel - .05;
		if(pos.z >waterLevel) then
			pos.z = waterLevel;	--
		end	
		Particle:SpawnEffect(pos, g_Vectors.up, "blood.on_water.a",1.0);
		
--pos = self:GetPos();
--pos.z = pos.z + 2;
--	Particle:SpawnEffect(pos, {x=0,y=0,z=1}, "smoke.vehicle_dust.a",1.0);	
--	Particle:SpawnEffect(pos, {x=0,y=0,z=1}, "blood.on_water.a",1.0);	
	
	else

--System:Log("\001 the blood "..self.BloodTimer);

		if(self.BloodTimer < 1000) then
			self.BloodTimer = self.BloodTimer + deadUpdateTime;
			if(self.BloodTimer >= 1000) then
--				pos = self:GetBonePos("Bip01 Spine");
--				if( not pos ) then
--					pos = self:GetPos();
--				end	
				pos.z = pos.z + .5;
				self.cnt:GetProjectedBloodPos(pos,g_Vectors.down,"GoreDecalsBld", 4);
			end
		end
	end
end


function BasicPlayer:PhysicalizeOnDemand()
  if(self.cnt.health ~= 0) then
    self:SetCharacterPhysicParams(0,"", PHYSICPARAM_SIMULATION,self.BulletImpactParams);  
  end
end

function BasicPlayer.SecondShader_Invulnerability(entity, amount, r, g, b) 
  -- hack: since this is called when player spawned and player not in heatvisionmask list, set flag on
	local bHeatLayerPresent=(ClientStuff and ClientStuff.vlayers);	
	if(bHeatLayerPresent and ClientStuff.vlayers:IsActive("HeatVision")) then	  
  	entity.bPlayerHeatMask=1;
  end
	  
   -- set invulnerability effect
	entity.iPlayerEffect=3;		
	BasicPlayer.ProcessPlayerEffects(entity);
end

function BasicPlayer.SecondShader_TeamColoring(entity)	
  -- hack: since this is called when player spawned and player not in heatvisionmask list, set flag on
	local bHeatLayerPresent=(ClientStuff and ClientStuff.vlayers);	
	if(bHeatLayerPresent and ClientStuff.vlayers:IsActive("HeatVision")) then	  
  	entity.bPlayerHeatMask=1;
  end
   
	-- set team coloring effect
	entity.iPlayerEffect=2;	
	BasicPlayer.ProcessPlayerEffects(entity);
end

function BasicPlayer.SecondShader_None(entity) 
  -- hack: since this is called when player spawned and player not in heatvisionmask list, set flag on
	local bHeatLayerPresent=(ClientStuff and ClientStuff.vlayers);	
	if(bHeatLayerPresent and ClientStuff.vlayers:IsActive("HeatVision")) then	  
  	entity.bPlayerHeatMask=1;  	
  end
  
	-- reset shader
	entity.iPlayerEffect=1;	
	BasicPlayer.ProcessPlayerEffects(entity);
end

-----------------------

BasicPlayer.Server_EventHandler={
	[ScriptEvent_FireModeChange]=function(self, Params)
		Params.shooter=self;

		return BasicWeapon.Server.OnEvent(self.cnt.weapon, ScriptEvent_FireModeChange, Params);
	end,
	[ScriptEvent_AnimationKey]=function(self,Params)
		if (type(Params) == "table") then
			if (Params.number) then 
				if ((Params.number == KEYFRAME_APPLY_MELEE) and (self.ai~=nil)) then 
					if (self.cnt.melee_attack == nil) then
						self.cnt.melee_attack = 1;
						local target = AI:GetAttentionTargetOf(self.id);
						if (type(target) == "table") then
							self.cnt.melee_target = target;

							if ( (self.Properties.bSingleMeleeKillAI == 1)  and (target.ai~=nil)) then
								self.melee_damage = 10000;
							else
								self.melee_damage = self.Properties.fMeleeDamage;
							end

						else
							self.cnt.melee_target = nil;
							self.melee_damage = self.Properties.fMeleeDamage;
						end


						if (self.ImpulseParameters) then 
							self.ImpulseParameters.pos = self:GetPos();
							local power = self.ImpulseParameters.impulsive_pressure;
							--self.ImpulseParameters.impulsive_pressure=2000;
							self:ApplyImpulseToEnvironment(self.ImpulseParameters);
							--self.ImpulseParameters.impulsive_pressure=power;
						end
					end
				elseif ((Params.number == KEYFRAME_JOB_ATTACH_MODEL_NOW) and (self.ai~=nil)) then 
					if (self.Behaviour) then 
						self.Behaviour:AttachNow(self);
					end
				elseif ((Params.number == KEYFRAME_BREATH_SOUND) and (self.ai~=nil)) then 
					if (Sound:IsPlaying(self.breath_sound)==nil) then 
						self.breath_sound = BasicPlayer.PlayOneSound( self, self.breathSounds, 110 );
					end
				elseif ((Params.number == KEYFRAME_ALLOW_AI_MOVE) and (self.ai~=nil)) then 
					AI:EnablePuppetMovement(self.id,1);
				elseif ((Params.number == KEYFRAME_HOLD_GUN) and (self.ai~=nil)) then 
					self.cnt:HoldGun();
				elseif ((Params.number == KEYFRAME_HOLSTER_GUN) and (self.ai~=nil)) then 
					self.cnt:HolsterGun();
				elseif ((Params.number > KEYFRAME_HOLSTER_GUN) and (self.ai~=nil)) then 
					--self.cnt.firing = 1;
					AI:FireOverride(self.id);
					self.ROCKET_ORIGIN_KEYFRAME = Params.number;
				end
			end
		end
		BasicPlayer.DoStepSoundAI(self);
	end,
	[ScriptEvent_Use]=function(self,Params)
		local entities=self:GetEntitiesInContact();
		local used;
		if(entities)then
			for id,ent in entities do
				if(ent.OnUse)then
					if (ent:OnUse(self)==1) then
						used=1;
					end
				end
			end
		end
		return used
	end,
	[ScriptEvent_CycleVehiclePos]=function(self,Params)
		if (self.theVehicle) then
			VC.CyclePosition(self.theVehicle, self);
		end
	end,
	[ScriptEvent_FireGrenade]=function(self,Params)

		--NOTE self.cnt.grenadetype=1 is the ROCK so unlimited ammo
		if(self.cnt.grenadetype==1 or (self.cnt.numofgrenades>0))then
			return BasicPlayer.Server_OnFireGrenade(self, Params);
		else
			return
		end
	end,
	[ScriptEvent_Land] = function(self,Params)
		
		BasicPlayer.HandleLanding(self,1);
	
		if(self.NoFallDamage) then return end
		local	fallDmg = Params/100;
		if(fallDmg>self.FallDmgS) then
			if (self.cnt.fallscale) then
				fallDmg = (fallDmg - self.FallDmgS)*self.FallDmgK*self.cnt.fallscale;
			else 
				fallDmg = (fallDmg - self.FallDmgS)*self.FallDmgK;
			end
			local	hit = {
				dir = g_Vectors.v001,
				damage = fallDmg,
				target = self,
				shooter = self,
				landed = 1,
				impact_force_mul_final=5,
				impact_force_mul=5,
				damage_type = "healthonly",
				falling=1,
			};
			self:Damage( hit );
		end
	end,
	[ScriptEvent_PhysCollision] = function(self,Params)

		local shooter = self;
		local isvehicle;
		if ((not Params.collider) or (not Params.collider.Properties) 
			or (not Params.collider.Properties.damage_players) 
			or (Params.collider.Properties.damage_players==0)) then
		  return
		end
		local	cldDmg = Params.damage*self.CollisionDmg*Params.collider.Properties.damage_players;

		if(Params.collider.IsVehicle == 1) then
			-- just left some vehicle - don't damage by vehicle 
			if(self.outOfVehicleTime and _time-self.outOfVehicleTime<2 ) then return end
			if( Params.collider.driverT and Params.collider.driverT.entity) then
				-- if this is vehicle drawen by Val - don't damage local player from it			
				if( self==_localplayer and
				    Params.collider.driverT.entity.Properties.special == 1) then return end
		
				shooter = Params.collider.driverT.entity;
				isvehicle = 1;
			end
			cldDmg = Params.damage*self.CollisionDmgCar;
		end	
		
		if( Params.collider.Properties.damage_scale ) then
			cldDmg = cldDmg*Params.collider.Properties.damage_scale;
		end	
		
		local	hit = {
			dir = new(Params.dir),
			ipart = -1,
			damage = cldDmg,
			target = self,
			shooter = shooter,
			landed = 1,
			impact_force_mul_final=5,
			impact_force_mul=5,
			impact_force_mul_final_torso=0,
			target_material={type="arm"},
			damage_type="normal",
			weapon = Params.collider,
			};
		hit.impact_force_mul_final = 0;
		if (Params.collider_mass >	self.PhysParams.mass) then
		  if ((Params.collider) and (Params.collider.Properties) and (Params.collider.Properties.hit_upward_vel)) then
		    hit.dir.x=0; hit.dir.y=0; hit.dir.z=1;
		    hit.impact_force_mul_final_torso = Params.collider.Properties.hit_upward_vel*self.PhysParams.mass;
		  else
		   	hit.impact_force_mul_final_torso = 0;--Params.collider_velocity*self.PhysParams.mass*1.3;
		  end  
		end
		self:Damage( hit );
	end,
	[ScriptEvent_CycleGrenade] = function(self,Params)
		--System:Log("CYCLING "..self.cnt.grenadetype);
		local curr=self.cnt.grenadetype;
		local gtypecount=count(GrenadesClasses);
		local n=0;
		local next=curr;

		repeat
			next=next+1;
			n=n+1;
			if(next>gtypecount)then
				next=1;
			end
		--next == 1 mean "rock" so always available
		until(next==1 or (self.Ammo[GrenadesClasses[next]] and self.Ammo[GrenadesClasses[next]]>0 and not(GrenadesClasses[next] == "FlareGrenade" and not self.ai)) or n>=gtypecount)


		self.Ammo[GrenadesClasses[curr]]=self.cnt.numofgrenades;
		self.cnt.numofgrenades=self.Ammo[GrenadesClasses[next]];
		self.cnt.grenadetype=next;
	end,
	[ScriptEvent_MeleeAttack]=function(self,Params)
		--System:Log("MELEE SERVER");
		self.cnt.weapon_busy=1;
		-- move the raycast in C++ and send just a event when an hit occur
		local t=Game:GetMeleeHit(Params);
		if(t)then
			if(t.target)then
				if(self.melee_damage)then
					t.damage=self.melee_damage
				else
					t.damage=100;
				end
				t.melee=1;
				t.damage_type = "normal";
				t.target:Damage(t);

				--System:Log("DRAW MELEE BLOOD 111");				
			end
			local MeleeHit=t.target_material.melee_punch;
			if (self.MeleeHitType and t.target_material[self.MeleeHitType]) then
				MeleeHit=t.target_material[self.MeleeHitType];
				--System:LogToConsole("player specific melee");
			else
				--System:LogToConsole("standard melee");
			end
			ExecuteMaterial(t.pos,t.normal,MeleeHit,1);
		else
			--System:Log("MISSED");
		end
	end,	
	[ScriptEvent_PhysicalizeOnDemand]=BasicPlayer.PhysicalizeOnDemand,
	[ScriptEvent_AllClear]=function(self,Params)
	end,
	[ScriptEvent_InVehicleAmmo] = function(self,Params)
	
		--System:Log("\001 ScriptEvent_InVehicleAmmo   "..self:GetName());	
	
		if( not self.theVehicle ) then return end
		
		--System:Log("\001 ScriptEvent_InVehicleAmmo  2 >> "..Params);
		if( Params == 1 ) then
			VC.VehicleAmmoEnter( self.theVehicle, self );
		else
			VC.VehicleAmmoLeave( self.theVehicle, self );
		end	
	end
};

-----------------------

BasicPlayer.Server_EventHandlerDead={
	[ScriptEvent_InVehicleAmmo] = function(self,Params)
	
		--System:Log("\001 ScriptEvent_InVehicleAmmo   "..self:GetName());	
		if( not self.theVehicle ) then return end
		
		--System:Log("\001 ScriptEvent_InVehicleAmmo  2 >> "..Params);
		if( Params == 1 ) then
			VC.VehicleAmmoEnter( self.theVehicle, self );
		else
			VC.VehicleAmmoLeave( self.theVehicle, self );
		end	
	end
};


BasicPlayer.Client_EventHandler={
	[ScriptEvent_FireModeChange]=function(self,Params)
		local WeaponParams =
		{
			shooter = self;
		};
		-- Call the weapon so it has the chance to abort any active
		-- processes going on for the old firemode
		return BasicWeapon.Client.OnEvent(self.cnt.weapon, ScriptEvent_FireModeChange, WeaponParams);
	end,
	[ScriptEvent_FlashLightSwitch]=function(self,Params)
--System:Log( "---------------------- fLight switched" );
		
		if(self.fLightSound == nil) then return end
		
		BasicPlayer.PlaySoundEx(self, self.fLightSound);
		
		--if(self==_localplayer) then
			if(self.FlashLightActive==0) then		
				self.FlashLightActive = 1;		
			else
				self.FlashLightActive = 0;
			end
		--end
		
	end,
	[ScriptEvent_Command]=BasicPlayer.ProcessCommand,
	[ScriptEvent_AnimationKey]=function(self,Params)
		if( type(Params) == "table" ) then 
			if( Params.userdata ) then
				if( Params.userdata~=0 ) then
--System:Log("Playing SOUND on ANI");
--System:Log("Playing SOUND on ANI "..Params.animation);
					BasicPlayer.PlaySoundEx(self, Params.userdata);
				end
			else
				BasicPlayer.DoStepSound( self );
			end
		else
			BasicPlayer.DoStepSound( self );
		end
	end,
	[ScriptEvent_SelectWeapon]=function(self,Params)
		if((self==_localplayer) and ClientStuff.vlayers:IsActive("Binoculars"))then
			ClientStuff.vlayers:DeactivateLayer("Binoculars",1);
		end
		if(not self.cnt.first_person and not self.current_mounted_weapon)then
			self:StartAnimation(0,"weaponswitch",1);
		end
		
		if(self == _localplayer)then			
			BasicPlayer.ProcessPlayerEffects(self);			
		end				
		
	end,
	[ScriptEvent_FireGrenade]=function(self,Params)
		local gclass=GrenadesClasses[self.cnt.grenadetype]
		--if(self.cnt.grenadetype == 1 or (gclass and self.Ammo[gclass]>0))then
		if(self.cnt.grenadetype==1 or self.cnt.numofgrenades>0) then
			return BasicPlayer.Client_OnFireGrenade(self, Params);
		end
	end,
	[ScriptEvent_MeleeAttack]=function(self,Params)
		--System:Log("MELEE CLIENT");
		--PLAY SOUND

		if(self.melee_sounds~=nil) then
			--System:Log("BasicPlayer.PlayOneSound( self, self.melee_sounds, 100 )");
			BasicPlayer.PlayOneSound( self, self.melee_sounds, 100 );
		end

		if(self.cnt.first_person)then
			if(self.cnt.weapon)then
				self.cnt.weapon:StartAnimation( 0, "Melee" , 0.1, 0);
			end
		else
			self:StartAnimation( 0, "amelee" , 0, 0);
		end
	end,
	[ScriptEvent_PhysicalizeOnDemand]=BasicPlayer.PhysicalizeOnDemand,
	[ScriptEvent_StanceChange]=function(self,Params)
	
		BasicPlayer.PlayChangeStanceSound(self);
	
		--if (self.StanceChangeSound) then
		--	Sound:PlaySound(self.StanceChangeSound);
		--end
	end,
	[ScriptEvent_EnterWater]=BasicPlayer.OnEnterWater,		
	[ScriptEvent_Expression]=function(self,Params)

--System:Log("ScriptEvent_Expression "..Params);

		if (self.EXPRESSIONS_ALLOWED) then 
			self:DoRandomExpressions(self.expressionsTable[Params+1], 0);
--System:Log("ScriptEvent_Expression >>>> "..self.expressionsTable[Params+1]);
		else
			self:DoRandomExpressions("Scripts/Expressions/NoRandomExpressions.lua", 0);
--System:Log("ScriptEvent_Expression << not EXPRESSIONS_ALLOWED ");
		end

	end,
	[ScriptEvent_InVehicleAnimation] = function(self,Params)
		--System:Log("\001 animationg InVehicle "..Params);
		if( not self.theVehicle ) then return end;	-- no vehicle - should not get the event
		
		if (self.UsingSpecialVehicleAnimation) then return end --we are playing some special vehicle anim? return.
		
		local inVclTabl = VC.FindUserTable( self.theVehicle, self );
		if( not inVclTabl ) then 
			System:Warning("ScriptEvent_InVehicleAnimation cant find user in the vehicle "..self.GetName());
			return 
		end;

		if(Params == self.prevInVehicleAnim) then return end
		
		if(self.ai and _time-inVclTabl.entertime < self.vhclATime) then return end
		
		if(inVclTabl.animations and inVclTabl.animations[Params] ) then
--System:Log("\001 animationg InVehicle playeing "..inVclTabl.animations[Params]);

			if(Params == 2) then	-- hit impact has to be blended in fast
				self:StartAnimation(0,inVclTabl.animations[Params],2,.25);
			else
				self:StartAnimation(0,inVclTabl.animations[Params],2,.5);
			end	
			self.prevInVehicleAnim = Params;
		else
--System:Log("\001 animationg InVehicle on animations  "..self.theVehicle.GetName());
		end
	end,
	[ScriptEvent_Land] = function(self,Params)
	
		BasicPlayer.HandleLanding(self);
		
		BasicPlayer.DoLandSound( self );
		
		local onfalldamage = nil;
		--if(self.NoFallDamage) then return end
		--if(self~=_localplayer) then return end		
		if(self.NoFallDamage==nil) then	
			
			local	fallDmg = Params/100;
			if(fallDmg>self.FallDmgS) then
--				fallDmg = (fallDmg - self.FallDmgS)*self.FallDmgK;
				if (self==_localplayer) then
					Hud.dmgindicator = bor( Hud.dmgindicator, 16 );
					Hud:OnMiscDamage(fallDmg*.4);
				end
			
				onfalldamage = 1;
			end	
		end
		
		BasicPlayer.PlayLandDamageSound(self,onfalldamage);
	end,
	[ScriptEvent_Jump]= function(self,Params)
		BasicPlayer.OnPlayerJump(self,Params);
	end,
};


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicPlayer:PlayPainAnimation( hit )

	if (BasicPlayer.IsAlive(self)==nil) then return; end
			
	if(hit.explosion)then return end 					-- no pain ani for explosions
	if(hit.shooter == self) then return end		-- no pain ani for falling/droving damage
	
	--AI and not a mutant, do pain expression.
	if (self.ai and self.MUTANT==nil) then 
		
		if (self.lastpainexpression==nil) then self.lastpainexpression = 0; end
		
		if (self.lastpainexpression<_time) then
			self:StartAnimation(0, "#full_angry_teeth", 0, 0.05, 1.0);
			--self:DoRandomExpressions(BasicPlayer.expressionsTable[4], 0);	
			self.lastpainexpression = _time + 0.1;
		end
	end
	
	if(hit.melee) then return end -- no pain ani for melee
	if(self.theVehicle) then return end -- no pain anim when driving
	if(self.cnt.proning) then return end --no pain anim when prone
		
	local zone = self.cnt:GetBoneHitZone(hit.ipart);	
	if(zone == 0) then zone = 1; end
	
	--if ((zone==5 or zone==6) and (self.cnt.crouching or self.cnt.proning or self.theVehicle)) then return; end
	
	local aniname = BasicPlayer.PainAnimations[zone];
	
	--System:Log("  pain ani ---------  "..zone.."  "..aniname);
	
	local animoffset = 1;
	
	if (zone==2) then--torso special case
		animoffset = random(1,3);
	end
	
	self:StartAnimation(0, aniname..animoffset, 4, 0.125, 1.25);
	if (self.ai) then
		local anim_dur = self:GetAnimationLength(aniname..animoffset);
		self:TriggerEvent(AIEVENT_ONBODYSENSOR,anim_dur+0.500);	-- account for blending times aswell
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicPlayer:SelectGrenade(name)
	local cyclefunc = self.Server_EventHandler[ScriptEvent_CycleGrenade];
	local currgrenade=GrenadesClasses[self.cnt.grenadetype];
	local selected;
	for i,val in GrenadesClasses do
		cyclefunc(self);
		if(GrenadesClasses[self.cnt.grenadetype]==name)then
			selected=1;
			break;
		end
	end
	if(not selected)then
		BasicPlayer.SelectGrenade(self,currgrenade);
	end
end

-- ARMOR Helpers --------------------------------------------------------------------------------------------------------------------------------------------
function BasicPlayer:HasFullArmor()
	local state = self.cnt;
	if (state == nil) then
		return nil;
	end
	
	if(state.armor >= state.max_armor) then
		return 1;
	else	
		return nil;
	end
end

function BasicPlayer:AddArmor(amount)
	local state = self.cnt;
	if (state == nil) then
		return nil;
	end
	
	state.armor = state.armor + amount;
	
	local pickupAmount = amount;
	local diff = state.max_armor - state.armor;
	
	if(diff < 0) then
		pickupAmount = amount - diff;
		state.armor = state.max_armor;
	end
	
	return pickupAmount;
end

-- move all ammo in the clips to the ammo stash
function BasicPlayer:EmptyClips(weaponid)
	local weaponstate = self.WeaponState;
	local ammo = self.Ammo
	
	if (weaponstate ~= nil and ammo ~= nil) then
		local state = weaponstate[weaponid];
		if (state ~= nil) then
			local weapontbl = getglobal(state.Name);

			for i, CurFireParameters in weapontbl.FireParams do
				if (self.Ammo[CurFireParameters.AmmoType] ~= nil and state.AmmoInClip[i] ~= nil) then
					self.Ammo[CurFireParameters.AmmoType] =  self.Ammo[CurFireParameters.AmmoType] + state.AmmoInClip[i];
					state.AmmoInClip[i] = 0;
				end
			end
		end
		-- also do this for grenades
		ammo[GrenadesClasses[self.cnt.grenadetype]]=self.cnt.numofgrenades;
	end
end


function BasicPlayer:DoProjectedGore( hit )

	-- not to spawn too many decals
	if( _time - self.decalTime < 0.5 ) then return end

	self.decalTime = _time;
	if (g_gore == "0") then return end
	self.cnt:GetProjectedBloodPos(hit.pos,hit.dir, "GoreDecals", 5);
	
	
--	local bloodHit=self.cnt:GetProjectedBloodPos(hit.pos,hit.dir,5);
	
--	if(bloodHit) then
--		local decal = GoreDecals[random(1,getn(GoreDecals))];
--			
--		local rotation=0;
--		local scale=decal.scale;
--		local lifetime=decal.lifetime;
--		if(decal.random_scale~=nil)then
--			scale=scale+((scale*0.01)*random(0,decal.random_scale));
--		end
--		if(decal.random_rotation~=nil)then
--			rotation=random(0,decal.random_rotation);
--		end
--		if(lifetime==nil)then
--			lifetime=16;
--		end
--		if(bloodHit.dist>1.) then
--			scale = scale*bloodHit.dist*2;
--		end	
--		if(bloodHit.target_id)	then
--			Particle:CreateDecal(bloodHit.pos, bloodHit.normal, scale, lifetime, decal.texture, decal.object, rotation, bloodHit.dir, bloodHit.target_id);
----			Particle:CreateDecal(bloodHit.pos, {x=-bloodHit.dir.x,y=-bloodHit.dir.y,z=-bloodHit.dir.z}, scale, lifetime, decal.texture, decal.object, rotation, bloodHit.dir, bloodHit.target_id);
--		else	
--			Particle:CreateDecal(bloodHit.pos, bloodHit.normal, scale, lifetime, decal.texture, decal.object, rotation, bloodHit.dir);
----			Particle:CreateDecal(bloodHit.pos, {x=-bloodHit.dir.x,y=-bloodHit.dir.y,z=-bloodHit.dir.z}, scale, lifetime, decal.texture, decal.object, rotation, bloodHit.dir);			
--		end
--	end	
end

function BasicPlayer:Server_OnShutDown( hit )

--	System:Log("BasicPlayer:Server_OnShutDown "..tostring(self.id).." "..tostring(self.idUnitHighlight));

	-- release vehicle if currently using
	if( self.theVehicle ) then
		VC.ReleaseUserOnShutdown( self.theVehicle, self );
	end	
	-- release mounted weapon if currently using
	if(self.current_mounted_weapon) then
		self.current_mounted_weapon:AbortUse();
	end	

	if self.idUnitHighlight then
		Server:RemoveEntity(self.idUnitHighlight);
	end
end


function BasicPlayer:Client_OnShutDown( hit )

	if( self.theVehicle ) then
		VC.ReleaseUserOnShutdown( self.theVehicle, self );
	end	
	
	if ((self.SwimSound~=nil) and (Sound:IsPlaying(self.SwimSound)==1)) then
		Sound:StopSound(self.SwimSound);
		self.SwimSound=nil;
	end
end

--------------------------------------------------------------------------------------------------------------
-- check point and five points around to see if 
-- player can stand there (no obstacles/walls)
function BasicPlayer:CanStandPos( pos )

	if( not self.cnt ) then return end

	if( not self.cnt:CanStand( pos ) ) then
		pos.z = pos.z+.5;
		if( not self.cnt:CanStand( pos ) ) then
			pos.x = pos.x+.5;
			if( not self.cnt:CanStand( pos ) ) then
				pos.x = pos.x-1;
				if( not self.cnt:CanStand( pos ) ) then
					pos.x = pos.x+.5;
					pos.y = pos.y+.5;
					if( not self.cnt:CanStand( pos ) ) then
						pos.y = pos.y-1;
						if( not self.cnt:CanStand( pos ) ) then
							return nil;	
						end
					end
				end
			end
		end
	end		
	return pos;
end

--filippo
function BasicPlayer:PlayChangeStanceSound()
		
	--if (self.cnt.proning == self.lastProne) then return; end
	
	if (self.lastStanceSound and self.lastStanceSound<_time) then
	
		local lightexertion = self.LightExertion;
		
		if (lightexertion) then
			self:PlaySound(lightexertion[random(1, getn(lightexertion))],1);
		end
	
		self.lastStanceSound = _time + 0.7;
		--self.lastProne = self.cnt.proning;
	end
end

function BasicPlayer:PlayJumpSound()

	if (self.hasJumped==1 and self.jumpSoundPlayed==0) then
		
		local jumpsounds = self.JumpSounds;
		
		if (jumpsounds) then			
									
			self:PlaySound(jumpsounds[random(1, getn(jumpsounds))],1);
		end
		
		self.jumpSoundPlayed = 1;
	end
end

function BasicPlayer:HandleLanding(serverside)
		
	--if is server side play AI sound.
	if (serverside and self.hasJumped == 1) then
		
		local ppos = self:GetPos();
		AI:SoundEvent(self.id,ppos,BasicPlayer.soundRadius.jump,0,1,self.id);
	end	
	
	self.hasJumped = 0;
	self.jumpSoundPlayed = 0;
end

function BasicPlayer:PlayerJumped()

	local pvel = self:GetVelocity();
			
	if (pvel.z>=1 and self.cnt.flying~=nil and self.hasJumped==0) then
		
		self.hasJumped = 1;
		self.jumpTime = _time;
	end
end

function BasicPlayer:PlayLandDamageSound(onfalldamage)
	
	if (onfalldamage) then
		
		if(not Sound:IsPlaying(self.painSound)) then
			self.painSound = BasicPlayer.PlayOneSound( self, self.painSounds, 100 );
		end
	else
	
		--local timedelta = _time - self.jumpTime;
		--local landhardsounds = self.LandHardSounds;
		local landsounds = self.LandSounds;
		
		if (landsounds) then
			self:PlaySound(landsounds[random(1, getn(landsounds))],1);
		end
		
		self.cnt:TriggerBHapticsEffect("damage_fall", "damage_fall", 0.6);
		
--		if (timedelta>=2 and landhardsounds) then
--			self:PlaySound(landhardsounds[random(1, getn(landhardsounds))],1);
--		elseif (timedelta>=1 and landsounds) then
--			self:PlaySound(landsounds[random(1, getn(landsounds))],1);
--		end
	end
end


--------------------------------------------------------------------------------------------------------------
-- when in vehicle (boat) - see if collides with sometnig - release if yes
-- do it only for boats - in cars player is inside vehicle geometry
function BasicPlayer:UpdateCollisions()

	if( not self.theVehicle ) then return end
	if( not self.theVehicle.IsBoat ) then return end
	
	local colliders = self:CheckCollisions(1);
		local used;
		
--System:Log("nContacts  ->>>>  "..count(colliders.contacts));
		
	if(count(colliders.contacts)>0)then		
	local vehicleTbl = VC.FindUserTable( self.theVehicle, self );
		if( vehicleTbl ) then
			VC.CanGetOut( self.theVehicle, vehicleTbl )	-- need this to find exit point (side or top)
			VC.ReleaseUser( self.theVehicle, vehicleTbl );
		end
	end		
	do return end
end

function BasicPlayer:PlayerContact(contact,serverside)

	--dont push client-side if is not MP
	if (serverside==0) then
		if (not Game:IsMultiplayer() or self==_localplayer) then return end
	end
		
	--AI dont push
	if (self.ai) then return end 	
	
	--push rate cap
	if (serverside==1) then
		if (self.nextPush and self.nextPush > _time) then return end
	else
		if (self.nextPush_Client and self.nextPush_Client > _time) then return end
	end
	
	--player is pressing use key?
	if(not self.cnt.use_pressed) then return end
	
	--pushing power, 90 its a good value for push objects, but at the moment we can push anything but boats.
	local pushpower = 90;
	
	--if canbepushed exist it can return 3 possible values: nil (cant be pushed), -1 (can be pushed with the player push power), n > 0 (a custom push power, boats use this)
	if (contact.CanBePushed) then
		
		local power = contact:CanBePushed();
		
		if (power==nil) then return end
		
		if (power>0) then pushpower = power; end
	else
		--there is no CanBepushed func, so return; if we want player push everything just comment the "return" or create some CanBepushed function to the entities that can be pushed.
		return
	end
		
	local ppos = self.tempvec;
	
	merge(ppos,self:GetPos());
	
	ppos.z = ppos.z + 1;
	
	if (not PointInsideBBox(ppos,contact,1.0)) then return end
		
	--self.cnt.use_pressed = nil;
	
	local impdir = self:GetDirectionVector();
	local bias = 0.3;
	
	--if player is looking down use a less push power
	if (impdir.z < -bias) then
		pushpower = pushpower * (1.0+bias+impdir.z);
	end
	
	--in any case push the entity a bit up
	if (impdir.z<0.5) then impdir.z = 0.5; end
	
	--Hud:AddMessage(pushpower);
		
	--FIXME: use a better impulse start position, now its the center of the entity
	--contact:AddImpulse( -1,ppos, impdir, pushpower );
	contact:AddImpulseObj( impdir, pushpower );
	
	--add a 0.3 sec delay between a push and the next
	if (serverside==1) then
		self.nextPush = _time + 0.3;
	else
		self.nextPush_Client = _time + 0.3;
	end
end

function BasicPlayer:OnPlayerJump(Params)

	if (self.ai) then 
		BasicAI.DoJump(self,Params);
	end
end

--this function play the "go back" vehicle animation if the player is looking in the opposite direction of the vehicle.
function BasicPlayer:DoSpecialVehicleAnimation()
	
	--ai dont have to deal with this stuff.
	if (self.ai) then return end
	
	local dir = self.tempvec;
	CopyVector(dir,self:GetDirectionVector(0));
	local vdir = self.theVehicle:GetDirectionVector(0);
		
	local dot = dotproduct3d(dir,vdir);
	--Hud:AddMessage(sprintf("%.1f",dot));
		
	--player is looking back
	if (dot > 0.3) then
		
		--6 is the index pos for the "go back" animation in the vehicle table.
		local animidx = 6;
		
		if (self.prevInVehicleAnim ~= animidx) then
		
			local inVclTabl = VC.FindUserTable( self.theVehicle, self );
	
			if (inVclTabl==nil) then return	end
			if (inVclTabl.animations==nil) then return end
		
			local anim = inVclTabl.animations[animidx];
		
			if (anim) then
				self:StartAnimation(0,anim,2,0.5);
			end
		
			self.prevInVehicleAnim = animidx;
		end
			
		self.UsingSpecialVehicleAnimation = 1;
	else
		self.UsingSpecialVehicleAnimation = nil;
	end
end


--------------------------------------------------------------------------------------------------------------

function BasicPlayer:OnSaveOverall(stm)

	if(self.current_mounted_weapon) then
		stm:WriteInt( self.current_mounted_weapon.id );
	else
		stm:WriteInt( 0 );	
	end	

	if(self.theRope) then
		stm:WriteInt( self.theRope.id );
	else
		stm:WriteInt( 0 );	
	end	
end

--------------------------------------------------------------------------------------------------------------

function BasicPlayer:OnLoadOverall(stm)


--System:Log(" BasicPlayer:OnLoadOverall >>> loading mwne ");

	local mntWeaponId = stm:ReadInt(  );
	self.current_mounted_weapon = System:GetEntity( mntWeaponId );
	if(self.current_mounted_weapon and self.current_mounted_weapon.SetGunner) then
		self.current_mounted_weapon:SetGunner( self );
	end
	
	local theRope = stm:ReadInt(  );
	
System:Log(" BasicPlayer:OnLoadOverall >>> loading  "..self:GetName().."  rope  "..theRope);	
	self.theRope = System:GetEntity( theRope );
	if(self.theRope) then
System:Log(" BasicPlayer:OnLoadOverall >>> rope found  "..self.theRope:GetName().." "..self.theRope.state);
		self.theRope.state = 0;
		self.theRope:GoDown( );
		self.theRope:DropTheEntity( self, 1 );
	end
end

--------------------------------------------------------------------------------------------------------------