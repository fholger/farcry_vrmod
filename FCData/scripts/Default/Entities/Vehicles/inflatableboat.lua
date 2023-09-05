-- inflatable boat script
-- created by Kirill Bulatsev
	InflatableBoat = {
--	type = "Vehicle",
	IsBoat = 1,

	CanShoot = 1,	-- player can shoot from his veapon while driving this vehicle - 
			-- don't change action map to vehicle when entering

	bNoImpuls=1,
	
	-- [kirill] vehicle gets different damage depending on who's shooter
	-- defines the intensity of the damage caused by the weapons to
	-- the vehicle	
	
	--
	DamageParams = {
		fDmgScaleAIBullet = 0.1,
		fDmgScaleAIExplosion = 0.1,
		fDmgScaleBullet = 0.2,
		fDmgScaleExplosion = 0.25,
	},
	ExplosionParams = {
	nDamage = 100,
	},
	--model to be used for destroyed vehicle
	fileModelDead = "objects/Vehicles/zodiacraft/zodiacraft_wreck.cgf",
	fPartUpdateTime=0,
	curPathStep = 0,

	--entering fake_jump/blending staff
	entVel = 9,
	
	userCounter = 0,
	driverWaiting = 0,
	driverDelay = 0,
	passengerLimit = 0,

	
	onPath = 0,
	
	-- previous state on the client before entering the vehicle
	bDriverInTheVehicle = 0,
	-- previous driver on the client before leaving the vehicle
	pPreviousDriver=nil,
	-- previous passenger state on the client before entering the vehicle
	bPassengerInTheVehicle = 0,
	-- previous passenger on the client before leaving the vehicle
	pPreviousPassenger=nil,

	IsPhisicalized = 0,	

----------------------------end---------------------------------------

	-- particle system to display when the vehicle is damaged stage 1
	Damage1Effect = "smoke.vehicle_damage1.a",
	-- particle system to display when the vehicle is damaged stage 2
	Damage2Effect = "smoke.vehicle_damage2.a",
	-- particle system to display when the vehicle explodes
	ExplosionEffect = "explosions.4WD_explosion.a",
	-- particle system to display when the vehicle is destroyed
	DeadEffect = "fire.burning_after_explosion.a",
	-- material to be used when vehicle is destroyed
	DeadMaterial = "Vehicles.Zodiacraft_Screwed",




	szNormalModel="objects/Vehicles/zodiacraft/zodiacraft.cgf",

	PropertiesInstance = {
		sightrange = 180,
		soundrange = 10,	-- rememeber that sound ranges intersect and sound range for AI doubles when in alert
		aibehavior_behaviour = "Boat_idle",		
		groupid = 154,
	},

	forceDmgBullet = 1, --if cvar g_vehicleBulletDamage = 0 vehicles are not affect by bullet damage,
			    --"forceDmgBullet" means to apply in any case the bullet damage.

	Properties = {		
	
		bNoDamage = 0,	-- this boat takes damage?
		bActive = 1,	-- if vehicle is initially active or needs to be activated 
				-- with Event_Activate first
		bTrackable=1,
--		fileName = "objects/Vehicles/zodiacraft/zodiacraft.cgf",			
		
		fAISoundRadius = 30,
		
		bUserPassanger = 0,
		bDrawDriver = 0,
		damping = 0.1,
		water_damping = 1.5,
		water_resistance = 0,
		fLimitLRAngles = 150,
		fLimitUDMinAngles = -45,
		fLimitUDMaxAngles = 40,


		ExplosionParams = {
			nDamage = 100,
			fRadiusMin = 2.0,
			fRadiusMax = 7, -- default 25.5
			fRadius = 7,    -- default 17 
			fImpulsivePressure = 200,
		},
		
-- those are AI related properties
		pointReinforce = "Drop",
		pointBackOff = "Base",
		aggression = 1.0,
		commrange = 100.0,
		cohesion = 5,
		attackrange = 70,
		horizontal_fov = 160,
		vertical_fov =90,
		eye_height = 2.1,
		max_health = 70,
		accuracy = 0.6,
		responsiveness = 7,
		species = 1,
		fSpeciesHostility = 2,
		fGroupHostility = 0,
		fPersistence = 0,
		aicharacter_character = "InflatableBoat",
		bodypos = 0,
		pathname = "none",
		pathsteps = 0,
		pathstart = 0,
		ReinforcePoint = "none",

		forward_speed = 1,	-- don't scale down fwd impuls - max speed
		
	},

--	b_speedv = 400,  -- controls Zodiac speed (movement impulse)
--	b_turn = 20,  -- controls how fast Zodiac turns (turning impulse)
--	fMass = 400,

--		Dumprot	 	= 2500,
--		Dumpv		= 300,
--		Dumpv		= 1000,
--		Turn		= 6000,
--		Speedv		= 8000,

---------------------------- HERE
	boat_params={
		Damprot	 	= 1000,	--turning damp
		Dampv		= 300,	--movement damp
		Dampvs		= 500,	--movement damp
		Dampvh		= 8000,	--
--		Dampw		= 1400,	--waves damp
		Dampw		= .22,	--waves damp		
		Turn		= 400,
		TurnMin		= 700,	--7000
		TurnVelScale	= 10,		
		
		Speedv		= 5000,	-- 5500,
		
		Speedturnmin	= .2,
		WaveM		= 300,	--fake waves momentum
		Stand		= 8000,	-- forsing to normal vertical position impuls
		TiltTurn	= 100,	--tilt momentum when turning
		TiltSpd		= 80,	--tilt momentum when speeding up
		TiltSpdA	= 0.06,	--tilt momentum when speeding up (acceleration thrhld)
		TiltSpdMinV	= 10.0,	--tilt momentum when speeding up (min speed to tilt when not accelerating)
		TiltSpdMinVTilt	= 0.37,	--tilt momentum when speeding up (how much to tilt when not accelerating)
		fMass 		= 400,
		Flying		= 0,
		
		StandInAir	= 400,	-- forsing to normal vertical position impuls , when inair
		gravity		= -9.81,--gravity , used whe the boat is jumping

		CameraDist	= 6,
	},

	boat_paramsAI={
		Damprot	 	= 2500,	--turning dump
		Dampv		= 300,	--movement dump
		Dampvs		= 300,	--movement dump
		Dampvh		= 10000,	--
--		Dampw		= 200,	--waves dump
		Dampw		= .09,	--waves damp				
		Turn		= 1000,
		TurnMin		= 1000,	--7000
		TurnVelScale	= 10,
		Speedv		= 10000,
		Speedturnmin	= 0.5,
		WaveM		= 500,	--fake waves momentum
		Stand		= 10000,	-- forsing to normal vertical position impuls
		TiltTurn	= 30,	--tilt momentum when turning
		TiltSpd		= 100,	--tilt momentum when speeding up		
		TiltSpdA	= 0.06,	--tilt momentum when speeding up (acceleration thrhld)
		TiltSpdMinV	= 10.0,	--tilt momentum when speeding up (min speed to tilt when not accelerating)
		TiltSpdMinVTilt	= 0.37,	--tilt momentum when speeding up (how much to tilt when not accelerating)
		fMass 		= 400,
		Flying		= 0,
		
		StandInAir	= 400,	-- forsing to normal vertical position impuls , when inair
		gravity		= -9.81,--gravity , used whe the boat is jumping
	},


	
	sound_time = 0,
	partDmg_time = 0,	
	

--// particles definitions
--////////////////////////////////////////////////////////////////////////////////////////

	WaterParticle = {--boat engines affecting the water (splashes behind the boat)
		focus = 20,
		speed = 2.0,
		count = 7,
		size = 1.8, 
		size_speed=0.01,
		gravity={x=0,y=0,z=-3.4},
		rotation={x=1,y=1,z=2},
		lifetime= 1.2,
		tid = System:LoadTexture("textures\\water_splash"),
		start_color = {1,1,1},
		end_color = {1,1,1},
		blend_type = 0,
		frames=0,
		draw_last=1,
			},

	WaterFogTrail=  {
				focus = 50,
				start_color = {1,1,1},
				end_color = {1,1,1}, 
				gravity = {x = 0.0,y = 0.0,z = -6.5}, --default z = -6.5
				rotation = {x = 0.0, y = 0.0, z = 2},
				speed = 12, -- default 12
				count = 6,
				size = 1, 
				size_speed=2.50, --default = 15
				lifetime= 1.0, --default = 3.5
				tid = System:LoadTexture("textures\\dirt2"),---clouda2.dds
				frames=1,
				blend_type = 0
			},
	WaterSplashes=
			{ --boat engines affecting the water (trail thats left behind the boat)
				focus = 60.0,
				start_color = {1,1,1},
				end_color = {1,1,1},
				gravity = {x = 0.0,y = 0.0,z = 0.0},
				rotation = {x = 0.0, y = 0.0, z = 0.5},
				speed = 2,
				count = 2,
				size = 5.0,
				size_speed=20,
				lifetime= 9.0,
				tid = System:LoadTexture("textures\\water_splash"),
				frames=1,
				blend_type = 0,
				particle_type=1
			},

	PropellerWake=
			{ --PropellerWake
				focus = 20.0,
				start_color = {1,1,1},
				end_color = {1,1,1},
				gravity = {x = 0.0,y = 0.0,z = 0.0}, 
				rotation = {x = 0.0, y = 0.0, z = 0.1}, 
				speed = 6,
				count = 2,
				size = 4.0,
				size_speed=4.0,
				lifetime= 6.0,
				tid = System:LoadTexture("textures\\water_splash"),
				frames=1,
				blend_type = 0,
				particle_type=1
			},

	
	bExploded=false,

	-- engine health, status of the vehicle
	-- default is set to maximum (1.0f)
	fEngineHealth = 100.0,

	-- damage inflicted to the vehicle when it collides
	fOnCollideDamage=0,
	-- damage inflicted to the vehicle when it collides with terrain (falls off)
	fOnCollideGroundDamage=0,
	--damage when colliding with another vehicle, this value is multiplied by the hit.impact value.
	fOnCollideVehicleDamage=5,

	bGroundVehicle=0,

	driverT = {
		type = PVS_DRIVER,
	
		helper = "driver",
		in_helper = "driver_sit_pos",
		sit_anim = "inflatable_driver_sit",
		anchor = AIAnchor.AIANCHOR_BOATENTER_SPOT,
		out_ang = -90,
		message = "@driverzodiac",
		timePast=0,
		HS=0,	-- used for fake jump arch calculatio - arch scale
		HK=0,	-- used for fake jump arch calculatio
		HO=0,	-- used for fake jump arch calculatio	
		HT=0,	-- used for fake jump arch calculatio
		
		animations = {
			"inflatable_driver_sit",		-- idle in animation
			"inflatable_driver_moving",		-- driving firward
			"inflatable_driver_forward_hit",	-- impact / break
			"inflatable_driver_leftturn",	-- turning left
			"inflatable_driver_rightturn",	-- turning right
			"inflatable_driver_reverse",	-- reversing
			"inflatable_driver_reverse_hit",	-- reversing impact / break
		},
	},

	passengersTT = {
		{
		type = PVS_PASSENGER,
		
		helper = "psngr_sit_pos01",
		in_helper = "psngr_sit_pos01",
--		helper = "driver",
--		in_helper = "driver",
		sit_anim = "vzsittingd",
		anchor = AIAnchor.AIANCHOR_BOATENTER_SPOT,
		out_ang = -90,
		message = "@passengerzodiac",
		timePast=0,
		HS=0,	-- used for fake jump arch calculatio - arch scale
		HK=0,	-- used for fake jump arch calculatio
		HO=0,	-- used for fake jump arch calculatio	
		HT=0,	-- used for fake jump arch calculatio
		},
	},
	
	--canbepushed, if player is in contact with some entity and he is pressing use, its checked this function.
	--can return 3 kind of values:
	--	- nil if the entity cant be pushed
	--	- -1 or 0 if the push force to be used is the player standard
	--	- a different value means a custom push force
	CanBePushed = VC.CanBePushed,
	
	pushpower = 500,
} 

VC.CreateVehicle(InflatableBoat);

--////////////////////////////////////////////////////////////////////////////////////////
function InflatableBoat:OnReset()
	VC.OnResetCommon(self);

	self:NetPresent(1);

	VC.EveryoneOutForce(self);

	self.onPath = 0;

	self.fEngineHealth = 100.0;
	
	self.bExploded=false;
	self.cnt:SetVehicleEngineHealth(self.fEngineHealth);

	self.fPartUpdateTime = 0;
	--AI stuff
	AI:RegisterWithAI(self.id, AIOBJECT_BOAT,self.Properties,self.PropertiesInstance);
--	self:RegisterWithAI(AIOBJECT_BOAT,self.Properties);	
--	AI_HandlersDefault:InitCharacter( self );
	VC.AIDriver( self, 0 );	
	
	-- Put physics asleep.
	self:AwakePhysics(0);
end

--////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////
--// CLIENT functions definitions
--////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////
InflatableBoat.Client = {
	OnInit = function(self)
		self:InitClient();
	end,
	OnShutDown = function(self)
		self:OnShutDown();
	end,
	
	Alive = {
		OnBeginState = function( self )	
			VC.InitBoatCommon(self);
		end,
		OnContact = function(self,player)
	 		self:OnContactClient(player);
		end,
		OnUpdate = function(self,dt)
	 		self:UpdateClientAlive(dt);
		end,
		OnCollide = VC.OnCollideClient,
		OnBind = VC.OnBind,
		OnUnBind = VC.OnUnBind,
	},
	Inactive = {
		OnBeginState = function( self )
			self:Hide(1);
		end,
		OnEndState = function( self )
			self.IsPhisicalized = 0;
		end,
	},
	Dead = {
		OnBeginState = function( self )
			VC.BlowUpClient(self);
		end,
		OnContact = function(self,player)
	 		self:OnContactClient(player);
		end,
		OnUpdate = VC.UpdateClientDead,
		OnCollide = VC.OnCollideClient,
		OnUnBind = VC.OnUnBind,
	},
}

--////////////////////////////////////////////////////////////////////////////////////////
function InflatableBoat:InitClient()
	VC.InitSeats(self, InflatableBoat);

	--// load sounds on client only 
	--////////////////////////////////////////////////////////////////////////////////////////
	
	self.ExplosionSound=Sound:Load3DSound("sounds\\weapons\\explosions\\mbarrel.wav",0,0,7,300);

	self.drive_sound = Sound:Load3DSound("sounds\\vehicle\\boat\\zod_idle.wav",0,255,30,150);
	self.drive_sound_move = Sound:Load3DSound("sounds\\vehicle\\boat\\splashLP.wav",0,200,30,150);
	self.maxvolume_speed = 10;

	self.accelerate_sound = {
		Sound:Load3DSound("sounds\\vehicle\\rev1.wav",0,0,7,100000),
		Sound:Load3DSound("sounds\\vehicle\\rev2.wav",0,0,7,100000),
		Sound:Load3DSound("sounds\\vehicle\\rev3.wav",0,0,7,100000),
		Sound:Load3DSound("sounds\\vehicle\\rev4.wav",0,0,7,100000),
	};


	self.engine_start = Sound:Load3DSound("sounds\\vehicle\\boat\\zod_start.wav",0,255,30,150);
	self.engine_off = Sound:Load3DSound("sounds\\vehicle\\boat\\zod_off.wav",0,255,30,150);
	self.crash_sound = Sound:Load3DSound("sounds\\vehicle\\boat\\rubber.wav",0,100,7,100);
	self.land_sound = Sound:Load3DSound("SOUNDS\\Vehicle\\boat\\boatsplash.wav",0,200,7,100);
	--self.break_sound = Sound:Load3DSound("sounds\\vehicle\\break1.wav",0,0,7,100000);
	--self.sliding_sound = Sound:Load3DSound("sounds\\vehicle\\break2.wav",0,0,7,100000);

	-- init common stuff for client and server
	VC.InitBoatCommon(self,self.szNormalModel);

end

--////////////////////////////////////////////////////////////////////////////////////////
function InflatableBoat:UpdateClientAlive(dt)

	if(self.lifeCounter < 100) then
		self.lifeCounter = self.lifeCounter + 1;
	end	

	VC.CreateWaterParticles(self);
	-- create particles and all that 
	VC.ExecuteDamageModel(self, dt);

	VC.PlayEngineOnOffSounds(self);

	-- plays the sounds, using a timestep of 0.04 		

	-- get vehicle's velocity
	local fCarSpeed = self.cnt:GetVehicleVelocity();
		
	self.sound_time = self.sound_time + dt;
	if ( self.sound_time > 0.04 ) then		
		
		-- reset timer
		self.sound_time = 0;
		
		VC.PlayDrivingSounds(self,fCarSpeed);

	end

	VC.UpdateHaptics(self, dt);
	
	VC.UpdateUsersAnimations(self,dt);
	
	VC.PlayMiscSounds(self,fCarSpeed,dt);
end

--////////////////////////////////////////////////////////////////////////////////////////
function InflatableBoat:OnContactClient( player )

	if( player==_localplayer and self.Properties.bUsable==0 ) then return end	
	VC.OnContactClientT(self,player);
end



--////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////
--// SERVER functions definitions
--////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////////////////////////////////////////////////////////////
InflatableBoat.Server = {
	OnInit = function(self)
		self:InitServer();
	end,
	OnEvent = function (self, id, params)
		self:OnEventServer( id, params);
	end,
	OnShutDown = function(self)
		self:OnShutDown();
	end,
	Alive = {
		OnBeginState = function( self )	
			VC.InitBoatCommon(self);
		end,
		OnContact = function(self,player)
	 		self:OnContactServer(player);
		end,
		OnDamage = VC.OnDamageServer,
		OnCollide = VC.OnCollideServer,
		OnUpdate = function(self,dt)
			self:UpdateServer(dt);
		end,
		
	},
	Inactive = {
	},
	Dead = {
		OnBeginState = function( self )
			VC.BlowUpServer(self);
		end,
		OnContact = function(self,player)
	 		VC.OnContactClientDead(self,player);
		end,			
	},
}

--////////////////////////////////////////////////////////////////////////////////////////
function InflatableBoat:InitServer()
	VC.InitSeats(self, InflatableBoat);
	
	-- init common stuff for client and server
	VC.InitBoatCommon(self,self.szNormalModel);

	self:OnReset();
end

-- called on the server when the player collides with the InflatableBoat
--////////////////////////////////////////////////////////////////////////////////////////
function InflatableBoat:OnContactServer( player )

	if( self.Properties.bUsable==0 ) then return end
	VC.OnContactServerT(self,player);
end


--////////////////////////////////////////////////////////////////////////////////////////
function InflatableBoat:UpdateServer(dt)


--System:Log("\004 InflatableBoat:UpdateServer");ß
	if( self.Properties.bUserPassanger == 1 ) then
		if( self.driver == nil ) then
			AI:Signal(SIGNALFILTER_GROUPONLY, 1, "wakeup", self.id);			
			AI:Signal(SIGNALFILTER_GROUPONLY, 1, "SHARED_ENTER_ME_VEHICLE", self.id);
		elseif(self.passenger ~= nil) then
			self:StartPath();
		end
	end

	VC.UpdateEnteringLeaving( self, dt );
	VC.UpdateServerCommonT( self, dt );

end


--////////////////////////////////////////////////////////////////////////////////////////
function InflatableBoat:OnEventServer( id, params)

	if (id == ScriptEvent_PhysicalizeOnDemand) then
		self:SetPhysicParams( PHYSICPARAM_FLAGS, {flags_mask=pef_pushable_by_players, flags=0} );
	end
	
end

--////////////////////////////////////////////////////////////////////////////////////////
function InflatableBoat:OnShutDown()
	VC.EveryoneOutForce(self);
	VC.RemovePieces(self);	
end



--////////////////////////////////////////////////////////////////////////////////////////
function InflatableBoat:OnSave(stm)
	stm:WriteInt(self.fEngineHealth);
end

--////////////////////////////////////////////////////////////////////////////////////////
function InflatableBoat:OnLoad(stm)
	self.fEngineHealth = stm:ReadInt();
end


--////////////////////////////////////////////////////////////////////////////////////////
function InflatableBoat:OnWrite( stm )
	
end

--////////////////////////////////////////////////////////////////////////////////////////
function InflatableBoat:OnRead( stm )

end

--////////////////////////////////////////////////////////////////////////////////////////


----------------------------------------------------------------------------------------------------------------------------
--
--
function InflatableBoat:RadioChatter()
end


----------------------------------------------------------------------------------------------------------------------------
--
--
--function InflatableBoat:LoadPeople()
--
----	self:AIDriver( 1 );
--	
--	AI:Signal(SIGNALFILTER_GROUPONLY, 1, "SHARED_ENTER_ME_VEHICLE", self.id);
--	self.dropState = 1;
--	
--end

----------------------------------------------------------------------------------------------------------------------------
--
-- to test
function InflatableBoat:StartPath(  )

--System:Log("\001 starting path");

	if( self.onPath == 1 ) then return end

	if(self.driver and self.passenger) then
		self.onPath = 1;
		
		self:Event_GoPath( );
--		BroadcastEvent( self,"StartAniPath" );
	end	
end

----------------------------------------------------------------------------------------------------------------------------
--
-- to test
function InflatableBoat:Event_StartAniPath( params )

System:LogToConsole("-----	got Event_StartAniPath -----");

end



----------------------------------------------------------------------------------------------------------------------------
--
function InflatableBoat:Event_GoPath( params )

--System:Log("\001  Humvee GoPath  ");

	self.curPathStep = self.Properties.pathstart-1;
	VC.AIDriver( self, 1 );	
	AI:Signal(0, 1, "GO_PATH", self.id);

end


----------------------------------------------------------------------------------------------------------------------------
--


-------------------------------------------------------------------------------------------------------------
--
--
function InflatableBoat:DoEnter( puppet )

	if( puppet == self.driverT.entity ) then		-- driver
		VC.AddUserT( self, self.driverT );
		VC.InitEnteringJump( self, self.driverT );
--	end
	else							-- passengers
		local tbl = VC.FindPassenger( self, puppet );
		if( not tbl ) then return end
		VC.AddUserT( self, tbl );
		VC.InitEnteringJump( self, tbl );
	end
	
end


-------------------------------------------------------------------------------------------------------------
--
--
function InflatableBoat:AddDriver( puppet )

	if (self.driverT.entity ~= nil)		then	-- already have a driver
		do return 0 end
	end
	
	self.driverT.entity = puppet;
	if( VC.InitApproach( self, self.driverT )==0 ) then	
		self:DoEnter( puppet );
	end	
	do return 1 end	
--	return VC.AddDriver( self, puppet);
end

-------------------------------------------------------------------------------------------------------------
--
--
function InflatableBoat:AddGunner( puppet )
	return 0		-- no gunner
--	return VC.AddDGunner( self, puppet);
end

----------------------------------------------------------------------------------------------------------------------------
--
function InflatableBoat:AddPassenger( puppet )

	do return 0	end	-- no passanger for now

	local pasTbl = VC.CanAddPassenger( self, 1 );

	if( not pasTbl ) then	return 0 end	-- no more passangers can be added
	
	pasTbl.entity = puppet;
	if( VC.InitApproach( self, pasTbl )==0 ) then
		self:DoEnter( puppet );
	end
	do return 1 end	
end


----------------------------------------------------------------------------------------------------------------------------
--
--
function InflatableBoat:LoadPeople()

	if(VC.FreeToUse( self )==0) then return end	-- can't use it - player is in

	if(self.driverT.entity and self.driverT.entity.ai) then
System:Log("boat LoadPeople  +++++ DRIVER IS IN ");
		
		AI:Signal(0, 1, "DRIVER_IN", self.id);
	end	
	
	AI:Signal(SIGNALFILTER_GROUPONLY, 1, "wakeup", self.id);
	AI:Signal(SIGNALFILTER_GROUPONLY, 1, "SHARED_ENTER_ME_VEHICLE", self.id);
	self.dropState = 1;
end



----------------------------------------------------------------------------------------------------------------------------
--

function InflatableBoat:Event_AddPlayer( params )

	if(_localplayer.theVehicle) then return end	-- this player is already in some (this) vehicle
	
	local theTable = VC.GetAvailablePosition(self);
	
	if(theTable == nil) then return end

	_localplayer.cnt.use_pressed = nil;
	theTable.entity = _localplayer;
	VC.AddUserT(self, theTable);	
	

	
end	

----------------------------------------------------------------------------------------------------------------------------
--
function InflatableBoat:Event_DriverIn( params )

	BroadcastEvent( self,"DriverIn" );
	
end	


-----------------------------------------------------------------------------------------------------
--
--
function InflatableBoat:Event_Activate( params )

	if(self.bExploded == 1) then return end
	
	self:GotoState( "Alive" );
end

----------------------------------------------------------------------------------------------------------------------------
--
--

--------------------------------------------------------------------------------------------------------
-- empty function to get reed of script error - it's called from behavours
function InflatableBoat:MakeAlerted()
end


--------------------------------------------------------------------------------------------------------------
