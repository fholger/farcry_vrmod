-- all the common entering/leavin functions work with userTTables ( driverT, gunnerT, passengersTT[idx] )
-- passsed by caller.
--	
--	user's types has to be specifyed in the table
--	1 - driver
--	2 - gunner
--	3 - passenger




Script:LoadScript("scripts/AI/Anchor.lua");

VC = {
	v_000={x=0,y=0,z=0},
	emtrPos={x=0,y=0,z=0},
	bRecursiveBind = nil,

	SimParams = {

--		density = 1100,
--		water_density = 1000,
--		density = 300,
--		water_density = 200,

		density = 200,
		water_density = 295,
		damping = 0.3,
		water_damping = 1.5,
		water_resistance = 0,
		mat_time_step = 0.02,
		sleep_speed = 0.04,
	},
	
	particles_dir_vector = {x=0,y=0,z=1},
	
--	v_HandlerPos={x=0,y=0,z=0},

	temp_v1 = {x=0,y=0,z=0},
	temp_v2 = {x=0,y=0,z=0},
	temp_v3 = {x=0,y=0,z=0},
	temp_v4 = {x=0,y=0,z=0},
	temp_v5 = {x=0,y=0,z=0},
	temp_v6 = {x=0,y=0,z=0},
};

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
function VC:Event_OnDeath()
	BroadcastEvent(self, "OnDeath");
end

function VC:Event_Abandoned()
	if (Game:IsMultiplayer()) then
		BroadcastEvent(self, "Abandoned");
		self:GotoState("Abandoned");
--		System:Log("GOTOSTATE: ABANDONED");
	end
end

-- this summmarizes the client and server code for the Abandoned state
VC.AbandonedStateBlock = {
	OnBeginState = function(self)
		-- hide the vehicle
		self:AwakeEnvironment();
		self:Hide(1);
	end,
	OnEndState = function(self)
		self.IsPhisicalized = 0;
	end,
}

function VC:CreateVehicle()
	-- events
	self.Event_OnDeath = VC.Event_OnDeath;
	self.Event_Abandoned = VC.Event_Abandoned;

	-- add properties required for abandoned measurement
	if (self.Properties and self.Properties.fAbandonedTime == nil) then
		self.Properties.fAbandonedTime = 120.0;
	end
end

function VC:OnResetCommon()

	-- in MP only
	-- kill all contactees during first 3 updates (for respawinig in MP, telefraging)
	if (Game:IsMultiplayer()) then
		self.JustSpawned = 5;
	end	

	-- reset handbreak
	if ( self.IsCar ) then
		self.cnt:HandBreak(0);
	end	

	self:SetUpdateType( eUT_Always );
	if(self.Properties.bActive == 1) then
		self:GotoState( "Alive" );
	else	
		self:GotoState( "Inactive" );
	end

	self:ResetPhysics();
		
	self.fEngineHealth=100.0; -- reset to maximum
	self.bExploded=0;
	self.IsBroken = 0;

--	self:DrawCharacter(0,1);
--	self:Hide(0);

	self.nUsers = 0;
	self.bAbandoned = nil;
	self.fAbandonedTime = nil;

	if(self.cnt and self.Properties.bLightsOn) then
		self.cnt:EnableLights( self.Properties.bLightsOn );
	end
	
	--if(self.sliding_sound) then
	--	Sound:StopSound(self.sliding_sound);	
	--end	

	if(self.fireOn)then
		self:DeleteParticleEmitter(0);
		self.fireOn = nil;
	end

	self.flipTime = 0;

	VC.InitPieces(self);

	if( self.ammoMG ) then
		if(not self.Ammo)then
			self.Ammo = {};			
		end
		self.Ammo["VehicleMG"] = self.ammoMG;
	end
	if( self.ammoRL ) then
		if(not self.Ammo)then
			self.Ammo = {};			
		end
		self.Ammo["VehicleRocket"] = self.ammoRL;
	end
	self.DriverKilled = nil;
end

--////////////////////////////////////////////////////////////////////////////////////////
function VC:LimitViewAngles(player)

	do return end

	if (player==nil) then
		do return end
	end

	-- limit the view angles as defined in the properties

	local	VehicleAngles={x=0,y=0,z=180};

	-- check against the view limit

	-- don't limit horizontal angle if Properties.fLimitLRAngles >=180
	if(self.Properties.fLimitLRAngles < 180)	then	
		player.cnt:SetAngleLimitBase(VehicleAngles);
		player.cnt:SetMaxAngleLimitH(self.Properties.fLimitLRAngles);
		player.cnt:SetMinAngleLimitH(-self.Properties.fLimitLRAngles);
		player.cnt:EnableAngleLimitH( 1 );
	end	
	player.cnt:SetMinAngleLimitV(self.Properties.fLimitUDMinAngles);
	player.cnt:SetMaxAngleLimitV(self.Properties.fLimitUDMaxAngles);

	if (self.bGroundVehicle==1) then
		Game:SetCameraFov((70*3.14)/180.0);
	end
end

--////////////////////////////////////////////////////////////////////////////////////////
function VC:DisableViewAnglesLimit(player)

	do return end

	player.cnt:EnableAngleLimitH(0);
	player.cnt:SetMinAngleLimitV(player.normMinAngle );
	player.cnt:SetMaxAngleLimitV(player.normMaxAngle );

	if (self.bGroundVehicle==1) then
		Game:SetCameraFov((90*3.14)/180.0);
	end
end

--////////////////////////////////////////////////////////////////////////////////////////
function VC:PlayEngineOnOffSounds()

	-- check if we just left the vehicle, but only from the driver side
	-- this check is done in order to play the engine off sound when the player
	-- leaves the vehicle the first time
	-- since the server will drop the driver first, the check for the nil 
	-- driver will always work correctly
	if ((self.bDriverInTheVehicle==1) and (self.driverT.entity==nil)) then	
		Sound:SetSoundPosition(self.engine_off,self:GetPos());
		Sound:PlaySound(self.engine_off);

		-- reset to normal view angles once we leave the vehicle
		VC.DisableViewAnglesLimit(self,self.pPreviousDriver);
	end

	
	-- check if we just entered the vehicle, but only from the driver side
	-- this check is done in order to play the engine start sound when the player
	-- enters the vehicle the first time
	if ((self.bDriverInTheVehicle==0) and (self.driverT.state == 2) ) then --entity~=nil)) then	
		Sound:SetSoundPosition(self.engine_start,self:GetPos());
		Sound:PlaySound(self.engine_start);
		self.bDriverInTheVehicle=1;
		self.pPreviousDriver=self.driverT.entity;

		-- add angle limitation once inside the vehicle
		VC.LimitViewAngles(self,self.driverT.entity);
		
		if (self.driverT.entity == _localplayer) then
			_localplayer.cnt:TriggerHapticEffect("vehicle_engine");
		end
	end
	
	if (self.driverT.entity==nil) then
	-- reset the driver in vehicle flag
	   self.bDriverInTheVehicle=0;			
	end	
end

function VC:StopDriveSound()
	
	if (self.CurrentDriveSound~=nil) then
		Sound:StopSound(self.CurrentDriveSound);
		self.CurrentDriveSound = nil;
	end
end

function VC:PlayDriveSound(fCarSpeed,dt,velmul)

	if (fCarSpeed<3) then 
		VC.StopDriveSound(self);
		return; 
	end

	local DriveSound;
	local maxvolume_speed = 30;
	
	if (Game:IsPointInWater(self:GetPos())~=nil and self.drive_sound_move_water) then
		
		DriveSound=self.drive_sound_move_water;
		
		if (self.maxvolume_speed_water) then maxvolume_speed = self.maxvolume_speed_water; end
	else
		DriveSound=self.drive_sound_move;
		
		if (self.maxvolume_speed) then maxvolume_speed = self.maxvolume_speed; end
	end

	if (DriveSound~=self.CurrentDriveSound) then
		if (self.CurrentDriveSound~=nil) then
			Sound:StopSound(self.CurrentDriveSound);
		end
		if (Sound:IsPlaying(DriveSound)~=1) then
			Sound:SetSoundLoop(DriveSound, 1);
			--Sound:SetSoundVolume(DriveSound, fCarSpeed*23);
			self:PlaySound(DriveSound);							
		end
		self.CurrentDriveSound=DriveSound;
	end

	if (self.CurrentDriveSound) then
			
		-- this must be updated every time	
		local vol = 255;
		
		if (fCarSpeed < maxvolume_speed) then
			vol = 255 - ((maxvolume_speed - fCarSpeed)/maxvolume_speed)*255;
		end
					
		Sound:SetSoundVolume(self.CurrentDriveSound, vol);
		--System:Log(vol);
	end
end

--////////////////////////////////////////////////////////////////////////////////////////
function VC:PlayDrivingSounds(fCarSpeed,dt)
	
	if (self.idleengine) then
		VC.PlayDynDrivingSounds(self,fCarSpeed,dt);
		return;
	end

	if (self.geardn_sounds and self.gearup_sounds) then
		--filippo
		--VC.PlayDrivingSounds2(self,fCarSpeed);
		VC.PlayDrivingSounds3(self,fCarSpeed,dt);
		do return end;
	end

	-- play one of the 4 accell. sounds
	if (self.cnt:HasAccelerated() == 1) then
		local Snd=self.accelerate_sound[random(1, 4)];
		self:PlaySound(Snd);
	end
		
	if (self.bDriverInTheVehicle==1) then								
		--VC.PlayDriveSound(self,fCarSpeed,dt);		
		if (VC.VehicleOnGround(self)==nil) then
			VC.StopDriveSound(self);
		else
			VC.PlayDriveSound(self,fCarSpeed,dt,6);
		end
		
		-- if we are driving the vehicle, lets play the idle_loop sound
		Sound:SetSoundFrequency( self.drive_sound, 1000 + fCarSpeed*30);
		
		Sound:SetSoundPosition(self.drive_sound,self:GetPos());
		if( Sound:IsPlaying(self.drive_sound) ~=1 )then
			Sound:SetSoundLoop(self.drive_sound,1);			
			self:PlaySound(self.drive_sound);
		end	
		
	else 
		VC.StopDrivingSounds(self);
--		if( Sound:IsPlaying(self.drive_sound) == 1)then
--			Sound:StopSound(self.drive_sound);
--		end	
--		if (self.CurrentDriveSound and Sound:IsPlaying(self.CurrentDriveSound)==1) then
--			Sound:StopSound(self.CurrentDriveSound);
--			self.CurrentDriveSound=nil;
--		end	
	end

	-- breaking sounds
	if (self.cnt:IsBreaking() == 1 and fCarSpeed > 10) then

		if (Sound:IsPlaying(self.break_sound) ~= 1) then
			--Sound:SetSoundLoop(self.break_sound, 1);
			Sound:SetSoundVolume(self.break_sound,fCarSpeed*10);	-- set break sound volume depending on speed
			self:PlaySound(self.break_sound);
		end
	else
		Sound:StopSound(self.break_sound);
	end
end

--////////////////////////////////////////////////////////////////////////////////////////
function VC:PlayDrivingSounds2(fCarSpeed)
		
	if (self.bDriverInTheVehicle==1) then								
				
		local vstatus=self.cnt:GetVehicleStatus();
		local vgear=vstatus.gear+1;		
			
		if (vstatus.wheelcontact==0) then
			if (Sound:IsPlaying(self.nogroundcontact_sound)~=1) then
				self:PlaySound(self.nogroundcontact_sound);				
			end
		end
		
		if (self.currgear~=vgear) then

--			System:Log("gear="..vgear..",currgear="..self.currgear..",speed="..fCarSpeed);   --,RPM="..vstatus.engineRPM);
--			System:Log("changing from "..self.currgear.." to "..vgear);   

			Sound:StopSound(self.idle_sounds[self.currgear+1]); -- 0 is reverse sound
		
			if (self.currgear>0) then
				Sound:StopSound(self.gearup_sounds[self.currgear]);
			end

			Sound:StopSound(self.geardn_sounds[self.currgear+1]);			

			if (vgear>self.currgear) then		
				self:PlaySound(self.gearup_sounds[self.currgear+1]);				
--				System:Log("Playing sound gear UP "..(self.currgear+1)..", stopping sound UP "..(self.currgear)..",stopping sound DN "..(self.currgear+1));
			else
				self:PlaySound(self.geardn_sounds[self.currgear]); -- cannot go down from 0			
--				System:Log("Playing sound gear DOWN "..(self.currgear)..", stopping sound UP "..(self.currgear)..",stopping sound DN "..(self.currgear+1));
			end
										
			self.currgear=vgear;		
		else
			-- play idle sound after the gear up down is finished
			if ((Sound:IsPlaying(self.gearup_sounds[self.currgear])~=1) and
				(Sound:IsPlaying(self.geardn_sounds[self.currgear])~=1) and
				(Sound:IsPlaying(self.idle_sounds[self.currgear+1])~=1)) then
--				Sound:SetSoundLoop(self.idle_sounds[self.currgear+1], 1);
				self:PlaySound(self.idle_sounds[self.currgear+1]);
			end
		end
		
	else 		
		
		-- stop all sounds
		Sound:StopSound(self.idle_sounds[1]);
		Sound:StopSound(self.idle_sounds[2]);
		Sound:StopSound(self.idle_sounds[3]);
		Sound:StopSound(self.idle_sounds[4]);

		Sound:StopSound(self.gearup_sounds[1]);
		Sound:StopSound(self.gearup_sounds[2]);
		Sound:StopSound(self.gearup_sounds[3]);

		Sound:StopSound(self.geardn_sounds[1]);
		Sound:StopSound(self.geardn_sounds[2]);
		Sound:StopSound(self.geardn_sounds[3]);
	end

	-- breaking sounds
	if (self.cnt:IsBreaking() == 1 and fCarSpeed > 10) then
		
		if (Sound:IsPlaying(self.break_sound) ~= 1) then
			--Sound:SetSoundLoop(self.break_sound, 1);
			Sound:SetSoundVolume(self.break_sound,fCarSpeed*10);	-- set break sound volume depending on speed
			self:PlaySound(self.break_sound);
		end
	else
		Sound:StopSound(self.break_sound);
	end
end

--filippo
function VC:StopDrivingSounds(stopall)
	-- stop all sounds
--	Sound:StopSound(self.idle_sounds[1]);
--	Sound:StopSound(self.idle_sounds[2]);
--	Sound:StopSound(self.idle_sounds[3]);
--	Sound:StopSound(self.idle_sounds[4]);
--
--	Sound:StopSound(self.gearup_sounds[1]);
--	Sound:StopSound(self.gearup_sounds[2]);
--	Sound:StopSound(self.gearup_sounds[3]);
--
--	Sound:StopSound(self.geardn_sounds[1]);
--	Sound:StopSound(self.geardn_sounds[2]);
--	Sound:StopSound(self.geardn_sounds[3]);

	if (stopall and stopall == 1) then
		if(self.sliding_sound and Sound:IsPlaying(self.sliding_sound)==1) then
			Sound:StopSound(self.sliding_sound);	
		end	
		
		if(self.break_sound and Sound:IsPlaying(self.break_sound)==1) then
			Sound:StopSound(self.break_sound);	
		end
	end
	
	VC.StopDriveSound(self);
	
	if( Sound:IsPlaying(self.drive_sound) == 1)then
		Sound:StopSound(self.drive_sound);
	end	
	
	if( Sound:IsPlaying(self.engine_start) == 1)then
		Sound:StopSound(self.engine_start);
	end	

	if (self.lastidlesound~=nil) then Sound:StopSound(self.lastidlesound); end		
	if (self.lastgearsound~=nil) then Sound:StopSound(self.lastgearsound); end
			
	self.lastidlesound = nil;
	self.lastgearsound = nil;
		
	self.tempidleiterator = 1;
				
	self.currgear = 1;
	
	self.clutchfreqgoal = 0;
	self.clutchfreq = 0;
	self.enginefreqgoal = 350;
	self.enginefreq = 350;
	
	self.lastfreqtime = 0;
end

--filippo
function VC:PlayDrivingSounds3(fCarSpeed,dt)
			
	local vstatus=self.cnt:GetVehicleStatus();
	
	if (self.bDriverInTheVehicle==1) then								
				
		local vgear=vstatus.gear+1;
					
		if (self.nogroundcontact_sound~=nil and vstatus.wheelcontact==0) then
			if (Sound:IsPlaying(self.nogroundcontact_sound)~=1) then
				self:PlaySound(self.nogroundcontact_sound);				
			end
		end
				
		if (self.currgear~=vgear and self.nextgearchange<_time and fCarSpeed>3) then
			
			self.nextgearchange = _time + 0.5;
			self.tempidleiterator = 1;
			
			if (self.lastidlesound~=nil) then Sound:StopSound(self.lastidlesound); end
			if (self.lastgearsound~=nil) then Sound:StopSound(self.lastgearsound); end
									
--			System:Log("changing from gear:"..self.currgear.." to gear:"..vgear);		

			if (vgear==1) then --null gear?	
				self.lastgearsound = self.geardn_sounds[2];
			elseif (vgear>self.currgear) then	
--				System:Log("calling gearup "..self.currgear);							
				self.lastgearsound = self.gearup_sounds[self.currgear+1];			
			else
--				System:Log("calling geardown "..vgear);
				self.lastgearsound = self.geardn_sounds[vgear+1];
			end
			
			self:PlaySound(self.lastgearsound);
			self:PlaySound(self.clutch_sound);
										
			self.currgear=vgear;	
		elseif (self.idlesounds~=nil) then
			-- play idle sound after the gear up down is finished	
			if ((Sound:IsPlaying(self.lastgearsound)~=1) and (Sound:IsPlaying(self.lastidlesound)~=1)) then
				
				if (self.lastidlesound~=nil) then Sound:StopSound(self.lastidlesound); end
				
				local soundseq = self.idlesounds[self.currgear+1];
				
				if (soundseq~=nil) then
												
					local soundnum = getn(soundseq);
				
					--if (self.tempidleiterator==nil) then self.tempidleiterator = 1; end
					
					if (self.tempidleiterator>soundnum) then
						self.tempidleiterator = 1;
					end
					
					local soundtoplay = soundseq[self.tempidleiterator];
				
					self.lastidlesound = soundtoplay[1];
				
					if (soundtoplay[2] == 1) then 
						Sound:SetSoundLoop(self.lastidlesound, 1); 
					end
								
					self:PlaySound(self.lastidlesound);
					
					--System:Log("playing idle"..self.currgear..",soundseq "..self.tempidleiterator);
								
					if (self.tempidleiterator+1<=soundnum) then
						self.tempidleiterator = self.tempidleiterator+1;
					end
				end
				
				--if (self.currgear+1==getn(self.CarDef.gears)) then self:PlaySound(self.clutch_sound); end
			end
		elseif (self.idle_sounds~=nil) then
			-- play idle sound after the gear up down is finished	
			if ((Sound:IsPlaying(self.lastgearsound)~=1) and (Sound:IsPlaying(self.lastidlesound)~=1)) then
				
				if (self.lastidlesound~=nil) then Sound:StopSound(self.lastidlesound);	end
				
				self.lastidlesound = self.idle_sounds[self.currgear+1];
				Sound:SetSoundLoop(self.lastidlesound, 1);
				self:PlaySound(self.lastidlesound);
				
			end
		end
		
	else 		
		VC.StopDrivingSounds(self);
	end

	-- breaking sounds
	if (self.cnt:IsBreaking() == 1 and fCarSpeed > 10 and vstatus.wheelcontact~=0) then

		if (Sound:IsPlaying(self.break_sound) ~= 1) then
			--Sound:SetSoundLoop(self.break_sound, 1);
			Sound:SetSoundVolume(self.break_sound,fCarSpeed*10);	-- set break sound volume depending on speed
			self:PlaySound(self.break_sound);
		end
	--else
	--	Sound:StopSound(self.break_sound);
	end
	
	--flying/land sounds
	if (self.land_sound~=nil) then
			
		if (vstatus.wheelcontact==0) then --flying?			
			self.VehicleInAir = 1;
			self.timeinair = self.timeinair + dt;
		else
			if (self.VehicleInAir~=0 and self.timeinair>0.5) then--landed right now?
				self:PlaySound(self.land_sound);
			end
			
			self.VehicleInAir = 0;
			self.timeinair = 0;
		end
	end
end

--////////////////////////////////////////////////////////////////////////////////////////
function VC:CreateWaterParticles()

	if( self.cnt.inwater~=1 ) then return end

	local fBoatSpeed = self.cnt:GetVehicleVelocity();

	if (fBoatSpeed<2) then return end

	self.fPartUpdateTime = self.fPartUpdateTime + _frametime;
	if(self.fPartUpdateTime<.2) then return end
	self.fPartUpdateTime = 0;

	local partZ = Game:GetWaterHeight() + 0.15;

	local vVec = self:GetHelperPos("engine");
	vVec.z = partZ;	--   Game:GetWaterHeight() - 0.02;

	vVec.x = vVec.x + 0.5 - random();
	vVec.y = vVec.y + 0.5 - random();

	local  coeff = fBoatSpeed*0.01;

	--engine spray PARTICLES----------------
	
--	local	time = self.WaterFogTrail.lifetime;
--	local	size = self.WaterFogTrail.size;
	
--	self.WaterFogTrail.lifetime = time*coeff-random()+2;
--	if (self.WaterFogTrail.lifetime<0)then
--	 self.WaterFogTrail.lifetime=0 
--	end;

--	self.WaterFogTrail.size = size*coeff; 				
--	Particle:CreateParticle(vVec,{x=0, y=0, z=1},self.WaterFogTrail);
--	self.WaterFogTrail.lifetime = time;
--	self.WaterFogTrail.size = size;
 
	--splash PARTICLES----------------

	local vVec1 = self:GetHelperPos("splash");
	vVec1.z = partZ;	--   Game:GetWaterHeight() - 0.02;

	vVec1.x = vVec1.x + 0.5 - random();
	vVec1.y = vVec1.y + 0.5 - random();

	local	time = self.WaterSplashes.lifetime;
	local	size = self.WaterSplashes.size;
	
	self.WaterSplashes.lifetime = time*coeff-random()+2;
	self.WaterSplashes.size = size*coeff;	
	Particle:CreateParticle(vVec1,g_Vectors.v001,self.WaterSplashes);
	self.WaterSplashes.lifetime = time;
	self.WaterSplashes.size = size;	

	--wake PARTICLES----------------

	local vVec2 = self:GetHelperPos("wake");
	vVec1.z = partZ;	--   Game:GetWaterHeight() - 0.02;

	vVec2.x = vVec2.x + 0.5 - random();
	vVec2.y = vVec2.y + 0.5 - random();

	local	time = self.PropellerWake.lifetime;
	local	size = self.PropellerWake.size;
	
	self.PropellerWake.lifetime = time*coeff-random()+2;
	self.PropellerWake.size = size*coeff;	
	Particle:CreateParticle(vVec2,g_Vectors.v001,self.PropellerWake);
	self.PropellerWake.lifetime = time;
	self.PropellerWake.size = size;	

end

--////////////////////////////////////////////////////////////////////////////////////////
function VC:AddSeatVars()
	self.entity 		= nil;
	self.state			= 0;
	self.time				= 0;
	self.exittime		= 0;
	self.entertime	= 0;
end

--////////////////////////////////////////////////////////////////////////////////////////
function VC:InitSeats(parent)
	-- states
	self:RegisterState( "Alive" );
	self:RegisterState( "Inactive" );	
	self:RegisterState( "Dead" );
	self:RegisterState( "Abandoned" );
	
	if (not self.Client) then
		self.Client = {};
	end
	if (not self.Server) then
		self.Server = {};
	end
	
	self.Client.Abandoned = VC.AbandonedStateBlock;
	self.Server.Abandoned = VC.AbandonedStateBlock;
	
	self.flipTime = 0;
	

	if (parent ~= self) then
		if (parent.driverT and (self.driverT == parent.driverT)) then
			self.driverT = new(parent.driverT);
		end
		if (parent.gunnerT and (self.gunnerT == parent.gunnerT)) then
			self.gunnerT = new(parent.gunnerT);
		end
		if (parent.passengersTT and (self.passengersTT == parent.passengersTT)) then
			self.passengersTT = new(parent.passengersTT);
		end
	end

	if (self.driverT) then
		VC.AddSeatVars(self.driverT);
	end

	if (self.gunnerT) then
		VC.AddSeatVars(self.gunnerT);
	end
	
	if (self.passengersTT) then
		for i, passenger in self.passengersTT do
			VC.AddSeatVars(passenger);
		end
	end
end

--////////////////////////////////////////////////////////////////////////////////////////
--function VC:DoSuspensionSounds()
--
--	-- suspension compressopn ration for each wheel	in range [0,1]
--	local fCompression1 = self.cnt:GetWheelStatus( 0 );
--	local fCompression2 = self.cnt:GetWheelStatus( 1 );	
--	local fCompression3 = self.cnt:GetWheelStatus( 2 );	
--	local fCompression4 = self.cnt:GetWheelStatus( 3 );	
--	
--	local threshhold = .8;
--	
--	if( (self.suspWheel1-threshhold)*(fCompression1.compression-threshhold)<0 ) then
--		Sound:SetSoundPosition(self.compression_sound1,self:GetHelperPos("wheel1_lower"));
--		Sound:PlaySound(self.compression_sound1);				
--	end	
--
--	if( (self.suspWheel2-threshhold)*(fCompression2.compression-threshhold)<0 ) then
--		Sound:SetSoundPosition(self.compression_sound2,self:GetHelperPos("wheel2_lower"));
--		Sound:PlaySound(self.compression_sound2);				
--	end	
--
--	if( (self.suspWheel3-threshhold)*(fCompression3.compression-threshhold)<0 ) then
--		Sound:SetSoundPosition(self.compression_sound3,self:GetHelperPos("wheel3_lower"));
--		Sound:PlaySound(self.compression_sound3);				
--	end	
--
--	if( (self.suspWheel4-threshhold)*(fCompression4.compression-threshhold)<0 ) then
--		Sound:SetSoundPosition(self.compression_sound4,self:GetHelperPos("wheel4_lower"));
--		Sound:PlaySound(self.compression_sound4);				
--	end	
--
--
--	self.suspWheel1 = fCompression1.compression;
--	self.suspWheel2 = fCompression2.compression;	
--	self.suspWheel3 = fCompression3.compression;	
--	self.suspWheel4 = fCompression4.compression;	
--end

--////////////////////////////////////////////////////////////////////////////////////////
function VC:InitGroundVehiclePhysics()
	
	self.VehicleKiller = 1;--5;	--filippo: this was carKiller -- flag to make cars explode on collision with this one		
	
	local nWheelMaterial=Game:GetMaterialIDByName("mat_rubber");
--	System:Log("WheelMaterial="..nWheelMaterial);
		
	local wheeln = 4;
	if (self.CarDef.wheel_num) then wheeln = self.CarDef.wheel_num; end
		
	for i=1,wheeln do
		local wheel = sprintf("wheel%i",i);
		self.CarDef[wheel].surface_id=nWheelMaterial;
		--System:Log(sprintf("wheel%i surfid %i",i,self.CarDef[wheel].surface_id));
	end
	
--	self.CarDef.wheel1.surface_id=nWheelMaterial;
--	self.CarDef.wheel2.surface_id=nWheelMaterial;
--	self.CarDef.wheel3.surface_id=nWheelMaterial;
--	self.CarDef.wheel4.surface_id=nWheelMaterial;	
--	
--	--filippo:apply the same to the other 4 wheels, if them are defined
--	if (self.CarDef.wheel5~=nil) then self.CarDef.wheel5.surface_id=nWheelMaterial;	end
--	if (self.CarDef.wheel6~=nil) then self.CarDef.wheel6.surface_id=nWheelMaterial;	end
--	if (self.CarDef.wheel7~=nil) then self.CarDef.wheel7.surface_id=nWheelMaterial;	end
--	if (self.CarDef.wheel8~=nil) then self.CarDef.wheel8.surface_id=nWheelMaterial;	end
end

--////////////////////////////////////////////////////////////////////////////////////////
function VC:CreateGroundGoalPipes( )

	-- creating goalpipe for car_transport
	local pipeName = self:GetName().."transport";
	AI:CreateGoalPipe(pipeName);
	AI:PushGoal(pipeName,"ignoreall",0,1);
	AI:PushGoal(pipeName,"strafe",0,0);						--stop breaking
	AI:PushGoal(pipeName,"acqtarget",0,"");
	if(self.Properties.fApproachDist) then
	AI:PushGoal(pipeName,"approach",1,self.Properties.fApproachDist);
	else	
		AI:PushGoal(pipeName,"approach",1,20);
	end	
	AI:PushGoal(pipeName,"signal",0,1,"next_point",0);
	
	-- creating goalpipe for car_chase
	pipeName = self:GetName().."chase";
	AI:CreateGoalPipe(pipeName);
	AI:PushGoal(pipeName,"strafe",0,0);						--stop breaking
	AI:PushGoal(pipeName,"bodypos",0,1);		--	to update path when moving
	if(self.Properties.fattackStickDist) then
		AI:PushGoal(pipeName,"approach",1,self.Properties.fattackStickDist);
	else
		AI:PushGoal(pipeName,"approach",1,1);
	end	
	
	-- creating goalpipe for car_path
	local pipeName = self:GetName().."path";
	AI:CreateGoalPipe(pipeName);
	AI:PushGoal(pipeName,"ignoreall",0,1);
	AI:PushGoal(pipeName,"strafe",0,0);						--stop breaking
	AI:PushGoal(pipeName,"acqtarget",0,"");
	if(self.Properties.fApproachDist) then
		AI:PushGoal(pipeName,"approach",1,self.Properties.fApproachDist);
	else	
		AI:PushGoal(pipeName,"approach",1,20);
	end	
	AI:PushGoal(pipeName,"signal",0,1,"next_point",0);
	

end


--////////////////////////////////////////////////////////////////////////////////////////
function VC:InitGroundVehicleCommon(szModelName)

	VC.CreateGroundGoalPipes( self );

	if ((self.IsPhisicalized == 0)) then
		--self:InitPhis();
		self.CarDef.file=szModelName;

		-- CarDefNormal is obsolete
--		self.CarDef.wheel1=self.CarDefNormal.wheel1;
--		self.CarDef.wheel2=self.CarDefNormal.wheel2;
--		self.CarDef.wheel3=self.CarDefNormal.wheel3;
--		self.CarDef.wheel4=self.CarDefNormal.wheel4;
--		
--		--filippo:apply the same to the other 4 wheels, if them are defined
--		if (self.CarDefNormal.wheel5~=nil) then self.CarDef.wheel5=self.CarDefNormal.wheel5; end
--		if (self.CarDefNormal.wheel6~=nil) then self.CarDef.wheel6=self.CarDefNormal.wheel6; end
--		if (self.CarDefNormal.wheel7~=nil) then self.CarDef.wheel7=self.CarDefNormal.wheel7; end
--		if (self.CarDefNormal.wheel8~=nil) then self.CarDef.wheel8=self.CarDefNormal.wheel8; end
--		
--		self.CarDef.hull1.zoffset=self.CarDefNormal.hull1.zoffset;
--		--filippo:write also the yoffset
--		self.CarDef.hull1.yoffset=self.CarDefNormal.hull1.yoffset;
		
		--filippo:override params if they are specified: removed due to new (and more clean) use of "Properties.AICarDef" table.
--		if (self.Properties.OverrideParams~=nil and self.Properties.OverrideParams.bUse_override_params==1) then
--			VC.ReadOverrideParams(self);
--		end
		
		self:InitPhis(); -- needs to be here, otherwise material assignment is overwritten
		
		if (Game:IsMultiplayer()) then
		  self.CarDef.integration_type = 0;
		end

--		System:Log("loading filename="..szModelName);
		self:LoadVehicle( self.CarDef );
		self:SetPhysicParams(PHYSICPARAM_SIMULATION, self.CarDef);
		self:SetPhysicParams(PHYSICPARAM_VEHICLE, self.CarDef);
		self:SetPhysicParams(PHYSICPARAM_BUOYANCY, self.CarDef);
		self.cnt:SetDrivingParameters( self.CarDef );
		self.cnt:SetCameraParameters( self.CarDef );
		
		--filippo
		self.LastActiveParams = self.CarDef;
	
		-- make bbox little bigger - so that it woiuld be easier to get OnContact - to enter
		local	bbox =self:GetBBox();
		bbox.min.x = bbox.min.x*1.1;
		bbox.min.y = bbox.min.y*1.1;
		bbox.max.x = bbox.max.x*1.1;
		bbox.max.y = bbox.max.y*1.1;
--		self:SetBBox(bbox.min, bbox.max);

		-- loading destroyed model
		self:LoadObject( self.fileModelDead, 14, 1 );
		self:DrawObject( 14, 0 );

		self:DrawObject( 15,0 );
		self.IsPhisicalized = 1;
		
		self:DrawCharacter(0,1);
		self:Hide(0);
	end	

	if(self.fireOn)then
		self:DeleteParticleEmitter(0);
		self.fireOn = nil;
	end
	

	self.CurrentDriveSound=nil;
	self.IsVehicle = 1;
	self.inWarterTime = 0;
	self.lifeCounter = 0;
	--filippo
	self.IsBroken = 0;
	
--self:EnablePhysics(0);
	
end

--////////////////////////////////////////////////////////////////////////////////////////
function VC:ScaleGroundVehicleSpeed( scale )

	if ((self.IsPhisicalized == 1)) then
	local	carDarams = new(self.CarDef);
		carDarams.engine_maxrpm = carDarams.engine_maxrpm*scale;
		carDarams.engine_power = carDarams.engine_power*scale;
		carDarams.engine_power_back = carDarams.engine_power_back*scale;
		carDarams.damping_vehicle = carDarams.damping_vehicle/scale;		

		if(scale>1) then	-- make it more manuverable
			self.aiDriver = 1;
			carDarams.max_steer_v0 = carDarams.max_steer_v0 + scale*1; 
			carDarams.max_steer = carDarams.max_steer + scale*1; 

			if(carDarams.max_steer_v0 > 90) then
				carDarams.max_steer_v0 = 90;
			end	
			if(carDarams.max_steer > 90) then
				carDarams.max_steer = 90;
			end	
			
			carDarams.steer_speed = carDarams.steer_speed + scale*20;
			carDarams.steer_speed_valScale = 0;
		else
--			carDarams.engine_maxrpm = carDarams.engine_maxrpm*.65;
			self.aiDriver = nil;	
		end	

		if(carDarams.damping_vehicle>0.3) then
			carDarams.damping_vehicle = 0.3;
		end	
		self:SetPhysicParams(PHYSICPARAM_VEHICLE, carDarams);
		self.cnt:SetDrivingParameters( carDarams );
	end
end


--////////////////////////////////////////////////////////////////////////////////////////
function VC:InitGroundVehicleClient(szModelName)

--	System:Log("Client Buggy onInit");

	VC.InitGroundVehicleCommon(self,szModelName);
	self.hitAniTime = 0;
	
	self:RenderShadow( 1 ); -- enable rendering of shadow
	
	self.currgear=0+1; -- neutral
	
	--filippo: vars below are for dyndrivingsounds.
	self.lastfreqtime = 0;
	self.clutchfreqgoal = 0;
	self.clutchfreq = 0;
	self.enginefreqgoal = 350;
	self.enginefreq = 350;
	
	--filippo
	self.lastgearsound = nil;
	self.lastidlesound = nil;
	self.tempidleiterator = 1;
	self.VehicleInAir = 0;
	self.timeinair = 0;
	self.nextgearchange = 0;
	
	self.LastRippleEffect = 0;
	self.VehicleLights = 0;
end

--////////////////////////////////////////////////////////////////////////////////////////
function VC:InitGroundVehicleServer(szModelName)
		
	self.VehicleKiller = 1;--5;	-- flag to make cars explode on collision with this one		
	VC.InitGroundVehicleCommon(self,szModelName);
	
	--self:EnableSave(0);	
	
--	self:NetPresent(1);

end


--////////////////////////////////////////////////////////////////////////////////////////
function VC:OnContactClientDead(player)

	-- see if its a player
	if (player.type ~= "Player" ) then return end
	
	-- client effects only for local player
	if (player ~= _localplayer ) then return end
	-- do nothing for dead bodies
	if(player.cnt.health<=0) then return end	

	-- First of all, if this player is already bound to a position, do nothing
	if(player.theVehicle) then return end	-- this player is already in some (this) vehicle

	-- damage the player if the vehicle is exploded? not now
	Hud.label = "@vehicledamaged";
	do return end

end

--////////////////////////////////////////////////////////////////////////////////////////
function VC:OnContactClientT(player)

	-- see if its a player
	if (player.type ~= "Player" ) then return end
	
	-- do nothing if using mounted weapon now
	if (player.current_mounted_weapon) then return end
	
	-- can't enter if the vehicle is turned over
	if (self.flipTime>0) then return end
	
	-- First of all, if this player is already bound to a position, do nothing
	if(player.theVehicle) then return end	-- this player is already in some (this) vehicle

	-- client effects only for local player
	if (player ~= _localplayer ) then return end
	-- do nothing for dead bodies
	if(player.cnt.health<=0) then return end
	
	--its a boat that can be pushed? print message on client screen
	if (VC.CanBePushed(self)) then
		Hud.label = "@pushboat";
	end
	
	if (VC.VehicleUsable(self)==nil) then return end
	
	--check there is already a closer vehicle
	if (player.lasttouchedvehicle and player.lasttouchedvehicle~=self) then return; end

	local theTable = VC.GetAvailablePosition(self, player);
		
	if( theTable ) then
		
		if(not(player.outOfVehicleTime and _time-player.outOfVehicleTime<1) ) then
			Hud.label = theTable.message;
		end
	end	

	do return end

	local curMinDist = 100;

	-- driver --------------------------------------------------------------
	-- Check that there isnt a driver already and that we are close enough to the driver start position
	-- Get the position of where the "driver enter jeep" animation starts
	local dist = player:GetDistanceFromPoint( self:GetHelperPos(self.driverT.helper, 0) );
	if( self.driverT.entity == nil and (_time-self.driverT.exittime>2)) then
		Hud.label = self.driverT.message;
		curMinDist = dist;
	end

	-- passengers --------------------------------------------------------------
	for idx=1, self.passengerLimit do
		if( not self.passengersTT[idx].entity ) then
			dist = player:GetDistanceFromPoint( self:GetHelperPos(self.passengersTT[idx].helper, 0) );
			if( (_time-self.passengersTT[idx].exittime>2) and curMinDist>dist  ) then
				Hud.label = self.passengersTT[idx].message;
				curMinDist = dist;
			end
		end
	end

	-- gunner --------------------------------------------------------------
	-- Check that there isnt a gunner already and that we are close enough to the gunner start position
	if( not self.gunnerT ) then return end
	dist = player:GetDistanceFromPoint( self:GetHelperPos(VC:GetEnterPoint(self.gunnerT), 0) );
	if( self.gunnerT.entity == nil and curMinDist>dist and (_time-self.gunnerT.exittime>2)) then
		Hud.label = self.gunnerT.message;
	end

end


--////////////////////////////////////////////////////////////////////////////////////////
-- damage player on contact with wreck
function VC:OnContactServerDead(player)

	-- damage only players
	if (player.type ~= "Player" ) then return end	
	-- don't want to damage AIs
	if (player.ai ) then return end	
	-- do nothing for dead bodies
	if(player.cnt.health<=0) then return end	
	-- First of all, if this player is already bound to a position, do nothing
	if(player.theVehicle) then return end	-- this player is already in some (this) vehicle

	self.emtrPos=self:GetHelperPos("vehicle_damage2",0);

 	-- if no helper present - no effect spuwn
	if( self.emtrPos.x == 0 ) then return end

	local playerPos = player:GetPos();
--	playerPos.z = playerPos.z+.7;
	FastDifferenceVectors( playerPos, playerPos, self.emtrPos );
	playerPos.z = 0;
	
	local dist = LengthSqVector( playerPos );
	
	if( dist < 2 ) then
		local	hit = {
			dir = g_Vectors.up,
--			{x=0,y=0,z=1},
--			damage = (1-dist)*100,
			damage = 1,
			target = player,
			shooter = player,
			landed = 1,
			impact_force_mul_final=5,
			impact_force_mul=5,
			damage_type = "normal",
			fire=1,
		};
		player:Damage( hit );
	
		--fixme - not good for MP				
		--if( player == _localplayer ) then
		--	Hud:OnMiscDamage(10);
		--end	
	end
end


--////////////////////////////////////////////////////////////////////////////////////////
function VC:OnContactServerT(player)

	-- see if its a player
	if (player.type ~= "Player" ) then return end
	-- do nothing if using mounted weapon now
	if (player.current_mounted_weapon) then return end
	
	if ( self.JustSpawned ) then
		VC.KillPlayer( self, player );
	end
	

	-- can't enter if the vehicle is turned over
	if (self.flipTime>0) then return end

	-- First of all, if this player is already in a vehicle, do nothing
	if(player.theVehicle) then return end	-- this player is already in some (this) vehicle

	if (player.ai ) then return end		-- AI's don't enter by pressing use
	
	-- just left some vehicle
	if(player.outOfVehicleTime and _time-player.outOfVehicleTime<1 ) then return end
	
	if (VC.VehicleUsable(self)==nil) then return end
	
	--Candidatevehicle check if there is another vehicle in collision with player, and what vehicle is closer to player.
	if (VC.CandidateVehicle(self,player.lasttouchedvehicle,player)==nil) then return end
	--this vehicle is closer, save this info into the player.
	player.lasttouchedvehicle = self;
			
	-- if player does not want to enter - nothing to do here
	if(not player.cnt.use_pressed) then return end	-- not pressing use - can't enter
		
	local theTable = VC.GetAvailablePosition(self, player);
	
	if(theTable == nil) then return end
	
	if(not self.bParaglider ) then
		local inPos = self:GetHelperPos(theTable.in_helper);
		if(not VC.CanGetThere(self, player, inPos, .5 )) then return 0 end
	end	
	
	--now its possible to reset the pointer, we are going to enter into the vehicle.
	player.lasttouchedvehicle = nil;
	
	player.cnt.use_pressed = nil;
	theTable.entity = player;
	
--	System:Log("VC: OnContactServerT 1");

	VC.AddUserT(self, theTable);

	-- we did enter
	do return 1 end

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
--here goes old stuff - with proximity check for enter helpers

	local curMinDist = 100;
	local theTable = nil;
	local AddFunc = nil;

	-- driver --------------------------------------------------------------
	-- Check that there isnt a driver already and that we are close enough to the driver start position
	-- Get the position of where the "driver enter jeep" animation starts
	local dist = player:GetDistanceFromPoint( self:GetHelperPos(self.driverT.helper, 0) );	
	if( self.driverT.entity == nil and (_time-self.driverT.exittime>2)) then
		theTable = self.driverT;
		AddFunc = VC.AddDriverT;
		curMinDist = dist;
		
		player.cnt.use_pressed = nil;
--		self.driverT.entity = player;
--		VC.AddDriverT(self, self.driverT);
--		do return end			
	end
	-- passengers --------------------------------------------------------------
	local passengerEnter;
	for idx=1, self.passengerLimit do
		if( not self.passengersTT[idx].entity ) then
			dist = player:GetDistanceFromPoint( self:GetHelperPos(self.passengersTT[idx].helper, 0) );
			if( (_time-self.passengersTT[idx].exittime>2) and curMinDist>dist ) then
				
				theTable = self.passengersTT[idx];
				AddFunc = VC.AddPassengerT;
				curMinDist = dist;
				
				
				player.cnt.use_pressed = nil;
--				self.passengersTT[idx].entity = player;
--				VC.AddPassengerT( self, self.passengersTT[idx] );
--				do return end
			end
		end
	end
	-- gunner --------------------------------------------------------------
	-- Check that there isnt a gunner already and that we are close enough to the gunner start position
	if( self.gunnerT ) then 
		dist = player:GetDistanceFromPoint( self:GetHelperPos(VC:GetEnterPoint(self.gunnerT), 0) );
		if( self.gunnerT.entity == nil and curMinDist>dist and (_time-self.gunnerT.exittime>2)) then
			
			theTable = self.gunnerT;
			AddFunc = VC.AddGunnerT;
			
			player.cnt.use_pressed = nil;
	--		self.gunnerT.entity = player;
	--		VC.AddGunnerT(self, self.gunnerT);
	--		do return end
		end
	end
	if( theTable ) then
		player.cnt.use_pressed = nil;
		theTable.entity = player;
		AddFunc(self, theTable);
		return 1;
	end
	
	return 0;
end



--////////////////////////////////////////////////////////////////////////////////////////
function VC:InitBoatCommon()

	-- self:EnableSave(0); 	

	b_camera = 0;  -- controls which camera is used by default
	
	if (self.IsPhisicalized == 0) then

		-- PROTO: LoadBoat( fileName, fMass, nSurfaceID )
		-- filename, fMass corresponds roughly to a submergeable water value
		-- this function will also load the cgf and create the rigid body object	

		--System:LogToConsole("loading filename="..self.Properties.fileName);

--		self:LoadBoat(self.Properties.fileName, self.fMass, 0 );		
--		--draw this object	
--		self:DrawObject(0,1);
--
--		-- obviously it is physicalized now
--		self.IsPhisicalized = 1;
--
--		-- makes some code related stuff to properly initialize the boat
--		self.cnt:SetWaterVehicleParameters(self.b_speedv,self.b_turn);
--		
--		self:SetPhysicParams(PHYSICPARAM_SIMULATION, self.Properties);
--		self:SetPhysicParams(PHYSICPARAM_BUOYANCY, self.Properties);		
		
		if (self.szNormalModel ~= "") then
						
			self:LoadObject( self.szNormalModel, 0, 0 );
			self:CreateRigidBody( 0, self.boat_params.fMass, 0 , g_Vectors.v000 , 0 );
				
			self:DrawObject(0,1);
		end
		-- makes some code related stuff to properly initialize the boat
--		self.cnt:SetWaterVehicleParameters(self.b_speedv,self.b_turn);
--		self.cnt:SetWaterVehicleParameters(self.boat_params);
				
		self.cnt:SetWaterVehicleParameters(self.boat_params);
		
		self:SetPhysicParams( PHYSICPARAM_FLAGS, {flags_mask=pef_pushable_by_players, flags=0} );

		-- loading destroyed model
		self:LoadObject( self.fileModelDead, 14, 1 );
		self:DrawObject( 14, 0 );
		self:DrawObject( 15, 0 );
		
		self:DrawCharacter(0,1);
		self:Hide(0);

		self.IsPhisicalized = 1;
	end

	if(self.fireOn)then
		self:DeleteParticleEmitter(0);
		self.fireOn = nil;
	end

	self.fEngineHealth=100.0;	-- reset to maximum
	self.bExploded=0;
	self.cnt:SetVehicleEngineHealth(self.fEngineHealth);
	self.hitAniTime = 0;
	self.lifeCounter = 0;
	self.IsBroken = 0;
	
	self.VehicleKiller = 1;
	
	self.VehicleInAir = 0;
	self.timeinair = 0;
	self.VehicleLights = 0;
	
	self.IsVehicle = 1;
end

--////////////////////////////////////////////////////////////////////////////////////////
function VC:DestroyBoatCommon(szModelName)
	
	--[kirill] make boat use real rigidBody phis
	self.cnt:SetWaterVehicleParameters( );

end

--////////////////////////////////////////////////////////////////////////////////////////
function VC:OnDamageServer(hit)

--System:Log("VC:OnDamageServer "..self:GetName());

	if(self.Properties.bNoDamage and self.Properties.bNoDamage==1 )then return end

	if (hit.damage_type ~= "normal" and hit.damage_type ~= "collision" or hit.damage<=0) then return end

	local fDamage = hit.damage;

	if (hit.damage_type == "normal") then
		-- this is hit by knife/shocker - don't apply damage
		local shooter = hit.shooter;
		if (shooter and shooter.fireparams and shooter.fireparams.fire_mode_type == FireMode_Melee) then return end
		-- do not allow the driver to damage the car
--		if ((not self.bDamageByDriver) and  shooter==self.driverT.entity) then
--			do return end
--		end
		-- do not allow the gunner to damage the car
		if (shooter and self.gunnerT and shooter==self.gunnerT.entity) then return end
		-- special case - don't want to damage vehicle when player is locked in
		if(self.Properties.bLockUser == 1) then return end
		
		local isMulti = Game:IsMultiplayer();
		
		local DamageParams = self.DamageParams;
		if (not DamageParams) then DamageParams = self.Properties.DamageParams; end
		
		if( hit.explosion ) then
			
			if( shooter and hit.shooter.ai ) then
				fDamage = hit.damage*DamageParams.fDmgScaleAIExplosion;
			else	
				fDamage = hit.damage*DamageParams.fDmgScaleExplosion;
			end
		--check if the game allow bullet damage for vehicles.
		elseif ( not isMulti or (tonumber(getglobal("g_vehicleBulletDamage"))==1 and isMulti) or self.forceDmgBullet) then
		
			local scaleDamage = 1;
			
			--[kirill] different damage from AI's and human players
			if( shooter and hit.shooter.ai ) then
				fDamage = hit.damage*DamageParams.fDmgScaleAIBullet;	
			else
				--new damage sys, every kind of bullet do the same damage, only in MP.
				if (DamageParams.dmgBulletMP and isMulti) then
					fDamage = DamageParams.dmgBulletMP;
					scaleDamage = nil;
				else
					fDamage = hit.damage*DamageParams.fDmgScaleBullet;
				end
			end
			
			if (scaleDamage) then
				
				-- check the distance from the hit place
				local vDamagePos=self:GetHelperPos("vehicle_damage2",0); 
				local vHitPos=hit.pos;
			
				local fDist=0;
				fDist=fDist+(vDamagePos.x-vHitPos.x)*(vDamagePos.x-vHitPos.x);
				fDist=fDist+(vDamagePos.y-vHitPos.y)*(vDamagePos.y-vHitPos.y);
				fDist=fDist+(vDamagePos.z-vHitPos.z)*(vDamagePos.z-vHitPos.z);
	
				local	damageDistanceScale = 10;
	
				if( fDist>damageDistanceScale ) then
					fDist = damageDistanceScale;
				end
				
				--System:Log("Distance="..fDist);
	
				fDamage = fDamage*(damageDistanceScale+1-fDist)/(damageDistanceScale+1);
			end
		else
			fDamage = 0;	
		end
	end
		
	self.fEngineHealth=self.fEngineHealth-fDamage;
	if (self.fEngineHealth<0) then
		self.fEngineHealth=0;
	end	
	
	--System:Log("Damage="..fDamage..",Curr health="..self.fEngineHealth);

	self.shooterSSID = nil;

	if (hit.shooterSSID) then
		self.shooterSSID = hit.shooterSSID;
	elseif(hit.shooter) then
		local serverSlot = Server:GetServerSlotByEntityId(hit.shooter.id);
		if (serverSlot) then
			self.shooterSSID = serverSlot:GetId();																	-- serverslotid of the launching player
		end
	end

	if (self.fEngineHealth==0) then
		self:GotoState( "Dead" );
	end	
	
	self.cnt:SetVehicleEngineHealth(self.fEngineHealth);
end

--////////////////////////////////////////////////////////////////////////////////////////
function VC:OnCollideClient(hit)
	
--if(hit.impactVert>2 or hit.impactVert<-2 )	then
--System:Log("\001 VEHICLE ON COLLIDE, speed = "..hit.impactVert);
--end
--System:Log("\001 VEHICLE ON COLLIDE, speed = "..hit.fSpeed);

	-- [Kirill] do impact animation for people in the vehicle
	self.hitAniTime = .1;
	if(self.cnt.turnState == 1) then	-- impact moving back
		self.cnt:AnimateUsers( 7 );	
	else					-- moving forward
		self.cnt:AnimateUsers( 3 );
	end	

	if (hit.fSpeed and hit.fSpeed>20) or (hit.impactVert and hit.impactVert>4) or (hit.impact and hit.impact>2) then
		if (Sound:IsPlaying(self.crash_sound)~=1) then
			Sound:SetSoundPosition(self.crash_sound,hit.vPos);
			Sound:PlaySound(self.crash_sound);		
--			Sound:PlaySound(self.crash_sound,hit.fSpeed/10);					
		end
--		self.cnt:ShakePassengers(hit.vVel);
	end

	if (self.SplashSound and hit.waterresistance and (hit.waterresistance>0)) then
		if (Sound:IsPlaying(self.SplashSound)~=1) then
			self:PlaySound(self.SplashSound, hit.waterresistance*0.01);
		end
		--System:Log("Splash: "..hit.waterresistance*0.01);
	end

	if (hit.splashes and Materials.mat_water~=nil and (self.LastRippleEffect and self.LastRippleEffect<_time)) then
		
		local rand;
		for i,splash in hit.splashes do
			
			--filippo:as long as the effect is a fps waste because we call many ripple at a time just show 50% of the ripples.
			--plus be sure that this effect dont occurs more often than 0.2 sec
			rand = random(0,100);
			
			if (rand<50) then
				ExecuteMaterial(splash.center, VC.particles_dir_vector, Materials.mat_water.grenade_splash, 1);
			end
		end
		
		self.LastRippleEffect = _time + 0.2;
	end
end

--////////////////////////////////////////////////////////////////////////////////////////
function VC:OnCollideServer(hit)

	--filippo: now , when 2 vehicles collide, VehicleKiller (that is the old CarKiller var) tell us also the min value of hit.impact to check the collision.
	--for instance, boats have a lower Vehiclekiller because usually them are slower.		
	-- AND
	-- special case - don't want to damage vehicle from other vehicle's collision 
	--when player is locked in
	if (hit.collider and self.Properties.bLockUser ~= 1) then
		
		--Hud:AddMessage("first collider :"..self:GetName()..", second :"..hit.collider:GetName());
	
		local collider = hit.collider;
		local VehicleKiller = collider.VehicleKiller;	
		
		if (hit.impact and VehicleKiller and hit.impact>VehicleKiller) then
										
			if (collider.nextcollisiontime==nil) then collider.nextcollisiontime=0; end
		
			if (collider.nextcollisiontime<_time) then
				--local fDamage=hit.impact*3.5;
				--local fDamage=500;
				local	hitDmg = {
						damage = 0,--fDamage,
						damage_type="collision",
						};
				
				--if the vehicle have a custom collision damage use it, otherwise use a default "3.5"
				if (self.fOnCollideVehicleDamage) then
					hitDmg.damage = hit.impact*self.fOnCollideVehicleDamage;
				else
					hitDmg.damage = hit.impact*3.5;
				end				
			
				VC.OnDamageServer(self, hitDmg);
				
				--local veltable = {v={x=0,y=0,z=0},w={x=0,y=0,z=0}};
				--self:SetPhysicParams(PHYSICPARAM_VELOCITY, veltable );
				
				--if the vehicle have a custom collision damage use it, otherwise use a default "3.5"
				if (collider.fOnCollideVehicleDamage) then
					hitDmg.damage = hit.impact*collider.fOnCollideVehicleDamage;
				else
					hitDmg.damage = hit.impact*3.5;
				end				
				
				VC.OnDamageServer(collider, hitDmg);
				
				--collider:SetPhysicParams(PHYSICPARAM_VELOCITY, veltable );
			
				self.nextcollisiontime = _time + 0.5;
				collider.nextcollisiontime = _time + 0.5;
				
				--self.lastcollider = collider;
				--collider.lastcollider = self;
			end	
		end
	end	

	if ((hit.impactVert and hit.impactVert>6) or (hit.impact and hit.impact>6) ) then
		-- reduce energy
		local fDamage=self.fOnCollideGroundDamage*hit.impactVert;
		if(hit.impact ) then
			local fDamageH=self.fOnCollideDamage*hit.impact;
			if(fDamage < fDamageH) then
				fDamage = fDamageH;
			end
		end		
		local	hitDmg = {
			damage = fDamage,
			damage_type="collision",
			};
		VC.OnDamageServer(self, hitDmg);
	end	
	
--if(hit.impact ) then		
--System:Log("\001 car collided  "..hit.impact.." >> "..hit.impactVert.."  "..health.."  "..self.fEngineHealth);
--else
--System:Log("\001 car collided NOimpact >> "..hit.impactVert.."  "..health.."  "..self.fEngineHealth);
--end
	
	
end


--////////////////////////////////////////////////////////////////////////////////////////
function VC:ExecuteDamageModel( dt )
--System:Log("\002  ExecuteDamageModel "..self:GetName());
	
	self.partDmg_time = self.partDmg_time + dt;
	if ( self.partDmg_time > .1 ) then			------not every frame update	
		self.partDmg_time = 0;
	else return end
	
--System:Log("\001  >>>>>>>>>>>>>>> ExecuteDamageModel "..self.cnt.engineHealthReadOnly);	
	
	if (self.cnt.engineHealthReadOnly<30) then 					
		-- middle damage
		local vVec=self:GetHelperPos("vehicle_damage1",0); 
		if (not Game:IsPointInWater(vVec)) then			
			Particle:SpawnEffect(vVec,g_Vectors.v001, self.Damage2Effect);
		end			
	elseif (self.cnt.engineHealthReadOnly<60) then 					
		-- little damage
		local vVec=self:GetHelperPos("vehicle_damage1",0); 
		if (not Game:IsPointInWater(vVec)) then			
			Particle:SpawnEffect(vVec,g_Vectors.v001, self.Damage1Effect);
		end			
	end
end

function VC:UpdateHaptics(dt)
	if( self.bDriverInTheVehicle==1 and self.driverT and self.driverT.entity and self.driverT.entity==_localplayer) then
		if (self.cnt:HasAccelerated() == 1) then
			_localplayer.cnt:TriggerHapticEffect("vehicle_engine");
		end

		local fCarSpeed = self.cnt:GetVehicleVelocity();
		local amplitude = 0.4;
		if (fCarSpeed < 30) then
			amplitude = 0.1 + 0.3 * fCarSpeed / 30;
		end
		_localplayer.cnt:TriggerBHapticsEffect("vehicle_rumble", "vehicle_rumble", amplitude);
	end
end

-------------------------------------------------------------------------------------------------------------
--
--
function VC:UpdateClientAlive(dt)
	
	--System.Log("pState  "..self.passengerState.."  "..self.passengerPrevState);
	
	if(self.lifeCounter < 100) then
		self.lifeCounter = self.lifeCounter + 1;
	end	
	
	local fCarSpeed = self.cnt:GetVehicleVelocity();	

	VC.PlayEngineOnOffSounds(self);
	
	self.part_time = self.part_time + dt;
	if ( self.part_time > self.particles_updatefreq ) then		------not every frame update	
		self.part_time = 0;
		VC.DoParticlesSlip(self,fCarSpeed);
	end

	-- create damage particles and all that 
	VC.ExecuteDamageModel(self, dt);
	VC.PlayDrivingSounds(self,fCarSpeed,dt);
	
	VC.UpdateHaptics(self, dt);
	
	-- see if local player wants to exit, check if position is available
	if( _localplayer and _localplayer.cnt and _localplayer.cnt.use_pressed ) then
		local localPlayerTbl = VC.FindUserTable( self, _localplayer );
		if( localPlayerTbl ) then
			if( not VC.CanGetOut(self, localPlayerTbl) ) then
				Hud:AddMessage( "@cantexitvehicle" );
			end
		end
	end		
	
--if(self.gunnerT and self.gunnerT.entity) then
--System:Log("\002 gunnerTime >>> ".._time-self.gunnerT.entertime.." "..self.gunnerT.entity.vhclATime);
--end

	-- if there is a gunner and it's inside long enough - 
	-- move hands with IK
	if( 	self.gunnerT and self.gunnerT.entity and
		_time-self.gunnerT.entertime > self.gunnerT.entity.vhclATime
		) then
		
--System:Log("\001 gunnerTime ".._time-self.gunnerT.entertime);
		
		local offsDir=self.gunnerT.entity:GetDirectionVector();
		local handlerPos = self:GetHelperPos("gun",0);

		handlerPos.x = handlerPos.x + offsDir.x*.83;
		handlerPos.y = handlerPos.y + offsDir.y*.83;
		handlerPos.z = handlerPos.z + offsDir.z*.83;
		self.gunnerT.entity:SetHandsIKTarget( handlerPos );
	end
	
	VC.UpdateUsersAnimations(self,dt);
	
	VC.PlayMiscSounds(self,fCarSpeed,dt);
end

function VC:UpdateUsersAnimations(dt)
-- [kirill] do invehicle state animations for people insid
	-- animations names have to be specified in users tables in vehicle
	-- see humvee.driverT.animations
--System:Log("\001 >>> "..self.cnt.turnState);
	if(not self.hitAniTime) then
		self.hitAniTime = 0;
	end	
	if(self.hitAniTime>=0) then
		self.hitAniTime = self.hitAniTime - dt;
	end		
	-- if not in impact state, othervise - don't override current impact animation
	if(self.hitAniTime>0)then return end

	if( self.cnt.turnState == 1 ) then
		-- backing up
		self.cnt:AnimateUsers( 6 );
	elseif( self.cnt.turnState == 2 ) then
		-- turning left
		self.cnt:AnimateUsers( 4 );
	elseif( self.cnt.turnState == 3 ) then
		-- turning right
		self.cnt:AnimateUsers( 5 );
	elseif( self.cnt.turnState == 4 ) then
		-- breaking mowing forward
		self.cnt:AnimateUsers( 3 );
	elseif( self.cnt.turnState == 5 ) then
		-- breaking mowing backward
		self.cnt:AnimateUsers( 7 );
	else	
		-- idle
		if(self.cnt.velocity>1) then
			-- driwng forward
			self.cnt:AnimateUsers( 2 );
		else
			-- not mowing
			self.cnt:AnimateUsers( 1 );
		end
	end
end	


--////////////////////////////////////////////////////////////////////////////////////////
function VC:UpdateClientDead( dt )

	self.partDmg_time = self.partDmg_time + dt;
	if ( self.partDmg_time > .1 ) then			------not every frame update	
		self.partDmg_time = 0;
	else return end
	
--	vVec=self:GetHelperPos("vehicle_damage2",0); 
	local vVec=self:GetHelperPos("fire",0); 	
	if (not Game:IsPointInWater(vVec)) then	
--			Particle:SpawnEffect(vVec,{x=0, y=0, z=1}, self.DeadEffect);
		if(not self.fireOn)then
			vVec=self:GetHelperPos("vehicle_damage2",1); 
			self:CreateParticleEmitterEffect( 0,self.DeadEffect,.1,vVec,g_Vectors.v001,1 );
			self.fireOn = 1;
		end
	elseif(self.fireOn)then
		self:DeleteParticleEmitter(0);
		self.fireOn = nil;
	end
end

--////////////////////////////////////////////////////////////////////////////////////////
function VC:BlowUpServer()

	self:SwitchLight(0);	-- switch off attached lights
	if(self.Event_OnDeath)then
		self:Event_OnDeath();
	end
	
	if(self.piecesId and self.piecesId[1]) then
		VC.BreakOnPieces(self);
	else 
--		System:Log("WRACK SERVER");
		VC.BreakWrack(self);
	end

	local explPos=self:GetPos();
	--explPos.z=explPos.z+4; 

	explPos.x = explPos.x + ((100-random(0,200))/100)*2;
	explPos.y = explPos.y + ((100-random(0,200))/100)*2;

	local	 explDir={x=0, y=0, z=1};

	local ExplosionParams = {};
	ExplosionParams.pos = explPos;
	if(self.ExplosionParams) then
		ExplosionParams.damage= self.ExplosionParams.nDamage;
	else	
		ExplosionParams.damage= self.Properties.ExplosionParams.nDamage;
	end	
	ExplosionParams.rmin = self.Properties.ExplosionParams.fRadiusMin;
	ExplosionParams.rmax = self.Properties.ExplosionParams.fRadiusMax;
	ExplosionParams.radius = self.Properties.ExplosionParams.fRadius;
	ExplosionParams.impulsive_pressure = self.Properties.ExplosionParams.fImpulsivePressure*2;
-- occl
	ExplosionParams.rmin_occlusion=0.2;
	ExplosionParams.occlusion_res=32;
	ExplosionParams.occlusion_inflate=2;
-- occl
	ExplosionParams.shooter = self;
	ExplosionParams.shooterSSID = self.shooterSSID;
	ExplosionParams.weapon = self; --removed .id because there it needs the reference, not the id
	
	if (self.driverT and self.driverT.entity and (not self.shooterSSID)) then
		local serverSlot = Server:GetServerSlotByEntityId(self.driverT.entity.id);
	
		if (serverSlot) then
			ExplosionParams.shooterSSID = serverSlot:GetId();
			ExplosionParams.shooter = self.driverT.entity;
		end
	end

	Game:CreateExplosion( ExplosionParams );

	-- remove the driver/gunner/passengers (if any)
	VC.EveryoneOutForce(self);
	self.IsPhisicalized = 0; -- so that the next call to reset will reload the normal model

	self:EnableSave(0);
	VC.AIDriver( self, 0 );	
	
	if( self.IsBoat == 1 ) then
		VC.DestroyBoatCommon(self);
	end

	VC.RemoveWindows(self);
	self.bExploded = 1;
	
	self.bAbandoned = nil;
	self.fAbandonedTime = nil;
end


--////////////////////////////////////////////////////////////////////////////////////////
function VC:BlowUpClient()

	self:SwitchLight(0);	-- switch off attached lights
	self.particles_updatefreq=0.2,--0.1	--lowering particles update freq for big dead vehicle effect's particles

	self:RemoveDecals();

	if(self.piecesId and self.piecesId[1]) then
		VC.BreakOnPieces(self);
	else 
--		System:Log("WRACK CLIENT");
		VC.BreakWrack(self);
	end

--	System:Log("BLOW UP!");	


	-- don't create explosion if just spawn
	if( self.lifeCounter>10 ) then
		local explPos=self:GetPos();
		--explPos.z=explPos.z+4; 
	
		explPos.x = explPos.x + ((100-random(0,200))/100)*1;
		explPos.y = explPos.y + ((100-random(0,200))/100)*1;
		explPos.z = explPos.z + 0.5;
	
		local	 explDir={x=0, y=0, z=1};
	
		if ( not Game:IsPointInWater(explPos)) then
			Particle:SpawnEffect(explPos, explDir, self.ExplosionEffect);
		else
			Particle:SpawnEffect(explPos, explDir, "explosions.under_water_explosion.a");
		end
		
		-- raduis, r, g, b, lifetime, pos
		CreateEntityLight( self, 7, 1, 1, 0.7, 0.5, explPos );
	end

	self.IsPhisicalized = 0; -- so that the next call to reset will reload the normal model
	VC.AIDriver( self, 0 );	
	
	--if(self.sliding_sound) then
	--	Sound:StopSound(self.sliding_sound);	
	--end	

	if( self.IsBoat == 1 ) then
		VC.DestroyBoatCommon(self);
	end
	
	VC.StopDrivingSounds(self,1);

	self.bExploded = 1;
end



--////////////////////////////////////////////////////////////////////////////////////////
function VC:UpdateFlipOver(dt)

-- [kirill] ok, here we get Up vector of the vehicle (normalized), so that we can check z component, to
-- know if it's flipped over
local dir=self:GetDirectionVector(2);
--local dir=self:GetAngles();
	--filippo:
	--TOFIX:GetAngles return a strange y angle: so its impossible to check if vehicle is flip up-down,
	--a sort of solution is to check if no wheels are touching the ground and if the velocity of the vehicle is around 0,  
	--but in this case vehicles will blow in the editor, because usually them are stuck in the air.
	
--System:Log( "\001  >> "..dir.z);
--System:Log( "\001  >> "..self.flipTime);
	
	if( dir.z<.3 ) then
		self.flipTime = self.flipTime + dt;
	else	
		self.flipTime = 0;
	end	
		
	if(self.flipTime > 3)then 
		VC.EveryoneOutForce( self );
	end	
end

--////////////////////////////////////////////////////////////////////////////////////////
function VC:KillSelf()

	self.cnt:SetVehicleEngineHealth(0);
	self.shooterSSID = nil;								-- for multiplayer: no one gets the kill
	self:GotoState( "Dead" );

end


--////////////////////////////////////////////////////////////////////////////////////////
function VC:UpdateServerCommonT(dt)

	
	if(self.JustSpawned) then
		self.JustSpawned = self.JustSpawned - 1;
		if(self.JustSpawned<0) then
			self.JustSpawned = nil;
		end	
	end

	VC.UpdateFlipOver(self,dt);
	
	VC.UpdateFallDamage(self,dt);
	
	if(self.Properties.bLockUser ~= 1) then -- if it's swamp - explode fst - kill the player
		if(self.flipTime > 5)then 
			VC.KillSelf( self );
		end	
	else					-- if it's swamp - explode fst - kill the player
		if(self.flipTime > 2.5)then 
			VC.KillSelf( self );
		end	
	end	

	if(self.inWarterTime and self.inWarterTime > 15)then 
		-- special case - don't want to damage vehicle when player is locked in
		if(self.Properties.bLockUser ~= 1) then 
			VC.KillSelf( self );
		end	
	end	
	
	if( self.bDriverInTheVehicle==1 and self.driverT and self.driverT.entity and (self.driverT.entity==_localplayer or self.driverT.entity.Properties.special == 1 )) then
		if (self.Properties.fAISoundRadius) then 
			AI:SoundEvent(self.id,self:GetPos(),self.Properties.fAISoundRadius,1,0, self.driverT.entity.id);
		else
			AI:SoundEvent(self.id,self:GetPos(),30,1,0, self.driverT.entity.id);
		end
	end	

	if (self.nUsers and self.nUsers <= 0) then
		if (self.fAbandonedTime~=nil and self.fAbandonedTime < _time and self.bAbandoned == nil and self.Event_Abandoned) then
			--System:Log("XXX Event fAbandonedTime to "..tostring(self.fAbandonedTime));
			self.bAbandoned = 1;
			self:Event_Abandoned();
		end
	end
	
	local lockUser = 0;
	
	if(self.Properties.bLockUser == 1) then
		lockUser = 1;
	end	

	----------------------------------------------------------------------------
	-- If there is a driver in the vehicle
	if ( self.driverT and self.driverT.entity ) then
	-- We know there is a driver and he is finished climbing in
--		if( self.driverT.entity.cnt.use_pressed or self.driverT.entity.cnt.health<=0 ) then
		if( self.driverT.entity.cnt.health<=0  or
		   (self.driverT.entity.cnt.use_pressed and VC.CanGetOut(self, self.driverT)) ) then
			self.driverT.entity.cnt.use_pressed = nil;
			if (_time-self.driverT.entertime>.5) then
				--release driver
				VC.ReleaseUser( self, self.driverT );
--				VC.AIDriver( self, 1);
				do return end
			end	
		end
	end
	
	----------------------------------------------------------------------------
	-- If there is a passenger in the vehicle
	for idx=1, self.passengerLimit do
		if( self.passengersTT[idx].entity ) then
		-- We know there is a passenger and he is finished climbing in
			if( self.passengersTT[idx].entity.cnt.health<=0 or
			   (self.passengersTT[idx].entity.cnt.use_pressed and lockUser==0 and 
			    VC.CanGetOut(self, self.passengersTT[idx]))) then

				self.passengersTT[idx].entity.cnt.use_pressed = nil;

				if (_time-self.passengersTT[idx].entertime>.5) then
				--release passenger
					VC.ReleaseUser( self, self.passengersTT[idx] );
--					VC.ReleasePassenger( self, self.passengersTT[idx]);
				end
			end
		end
	end
	
	----------------------------------------------------------------------------
	-- If there is a gunner in the vehicle
	if ( self.gunnerT and self.gunnerT.entity ) then
	-- We know there is a gunner and he is finished climbing in
		if( self.gunnerT.entity.cnt.health<=0 or
		   (self.gunnerT.entity.cnt.use_pressed and lockUser==0 and 
		    VC.CanGetOut(self, self.gunnerT)) ) then
			self.gunnerT.entity.cnt.use_pressed = nil;
			
			if (_time-self.gunnerT.entertime>.5) then	
				--release gunner
--				local gunnerEntity = self.gunnerT.entity;
				VC.ReleaseUser( self, self.gunnerT );
				do return end
			end	
		end
	end
end
 


----------------------------------------------------------------------------------------------------------------------------
--
--
function VC:AIDriver( enable )

	if( enable == 0 ) then
		self:TriggerEvent(AIEVENT_DISABLE);
	else
		if ( self.bExploded==1 ) then return end	-- no triggering on if dead
		self:TriggerEvent(AIEVENT_ENABLE);
		if ( self.IsCar ) then
			self.cnt:HandBreak(0);
		end	
		return 1
	end
				
end

----------------------------------------------------------------------------------------------------------------------------
--
--
-- user's types
--	1 - driver
--	2 - gunner
--	3 - passenger


function VC:AddUserT( tbl )

--System:Log("\001  addin user >> "..tbl.type);
--System:Log("\001  const >> "..PVS_OUT.."  "..PVS_DRIVER.."  "..PVS_GUNNER.."  "..PVS_PASSENGER);

  self.bRecursiveBind = 1;
	local table_id = VC.GetTableId(self,tbl);

	tbl.entity.vhclATime = 3;
	tbl.entertime = _time;
	tbl.entity.theVehicle = self;

	-- if on ladder - get out of it
	if( tbl.entity.ladder ) then
		tbl.entity.ladder:OnLeaveArea( tbl.entity );
	end	

	if( tbl.in_anim ) then	-- if has entering animation - bind to vehicle now, otherwise - do jump, bind when jump finished
		self.cnt:SetUser(tbl.entity.id, tbl.helper, tbl.in_ani, tbl.type, table_id);
--		tbl.entity.vhclATime = tbl.entity:GetAnimationLength( tbl.in_ani );
--	else
--		tbl.entity.vhclATime = 0;
	end	
	
	if( tbl.entity.ai ) then
		if(self.Event_AIEntered) then
			self:Event_AIEntered();
		end		
		if(tbl.type == PVS_DRIVER) then
			if( self.IsBoat ) then
				self.cnt:SetWaterVehicleParameters(self.boat_paramsAI);
			elseif( self.IsCar ) then
				--filippo: TODO? why we are using this 2.7 value? we shouldn't use just forward_speed? its pretty confusing imho.
				--VC.ScaleGroundVehicleSpeed( self, 2.7 );
				
				--filippo
				self.LastActiveParams = nil;--since we still use ScaleGroundVehicleSpeed, reset LastActiveParams for the next time.
				
				self.aiDriver = 1;
				
				if (self.Properties.AICarDef~=nil and self.Properties.AICarDef.bAI_use and self.Properties.AICarDef.bAI_use==1) then
					VC.ChangeVehicleParams(self,self.Properties.AICarDef);
				end	
			end
		end	
		tbl.entity:SelectPipe(0,"h_gunner_fire");
		
		-- dont disable gunner if hi's attached on loading
		if( tbl.time> -10 or tbl.type~=PVS_GUNNER) then
			AI:Signal(0, 1, "desable_me",tbl.entity.id);
		end	
		
--		tbl.entity.EventToCall = "desable_me";
--		AI:Signal(0, 1, "entered_vehicle",tbl.entity.id);
----		tbl.entity:TriggerEvent(AIEVENT_DISABLE);
	else					-- it's player - disable AI control, make car slower
--		VC.AIDriver( self, 0 );	
		if(self.Event_PlayerEntered) then
			self:Event_PlayerEntered();
		end		
		if(tbl.type == PVS_DRIVER) then

			if(self.Event_DriverIn) then
				self:Event_DriverIn();
			end

			if( self.IsBoat ) then
				self.cnt:SetWaterVehicleParameters(self.boat_params);
			elseif( self.IsCar ) then
--				VC.ScaleGroundVehicleSpeed( self, self.Properties.forward_speed );
				
				--filippo: restore the original values once the player get in.
				self.aiDriver = nil;

				VC.ChangeVehicleParams(self,self.CarDef);
				-- reset handbreak
				self.cnt:HandBreak(0);
			end
		end	
		self.userCounter = self.userCounter+1;
		tbl.entity.lastVehicleCycleTime	= _time;
		VC.UserEntered( self, tbl );
		if(tbl.entity ==_localplayer)then

--			System:Log("Input:SetActionMap('vehicle 1 "..tostring(tbl.type));

			if((tbl.type == PVS_DRIVER or tbl.type == PVS_GUNNER) and (not self.CanShoot)) then

--				System:Log("Input:SetActionMap('vehicle 2");

				Input:SetActionMap("vehicle");	
			end	
			Sound:SetMusicTheme("Vehicle", 1);
		end
		
		AI:SetTheSkip( self.id );
		AI:Signal(0, 1, "PLAYER_ENTERED",self.id);
				
		if (tbl.entity == _localplayer) then
			VC:DeactivateLayers();
		end
	end	
	
	-- test
	
--	System:Log("VC: AddUserT 1 "..tostring(self.IsCar).." "..tostring(tbl.type));

	-- need to do this check coz in SP on loading checkpoint
	-- there is not _localplayer yet - so check fo .ai
	if(Game:IsMultiplayer()) then 

		if(_localplayer and (tbl.type == PVS_DRIVER or tbl.type == PVS_GUNNER) and tbl.entity==_localplayer and (not self.CanShoot)) then
			Input:SetActionMap("vehicle");
		end
	else
		if((not tbl.entity.ai) and (tbl.type == PVS_DRIVER or tbl.type == PVS_GUNNER) and (not self.CanShoot) ) then
			Input:SetActionMap("vehicle");
		end
	end

	self.bRecursiveBind = nil;
	return 1
end


----------------------------------------------------------------------------------------------------------------------------
--
--

----------------------------------------------------------------------------------------------------------------------------
--
--
function VC:AddPassengerHely( tbl )

	tbl.entertime = _time;
	tbl.entity.theVehicle = self;

	tbl.entity:ActivatePhysics(0);

	tbl.entity:SelectPipe(0,"c_driver");
	
	if(self.Properties.fStartDelay and self.Properties.fStartDelay<0) then	
		AI:Signal(0, 1, "entered_vehicle",tbl.entity.id);
	end
	tbl.entity:TriggerEvent(AIEVENT_DISABLE);
end	

-------------------------------------------------------------------------------------------------------------
--
function VC:AddGunnerHely( tbl )

	tbl.entertime = _time;
	tbl.entity.theVehicle = self;

	tbl.entity:ActivatePhysics(0);

	AI:AIBind(self.id, tbl.entity.id);	

--	tbl.entity:SelectPipe(0,"h_gunner_fire");
--	tbl.entity:TriggerEvent(AIEVENT_DISABLE);
	
	return 1
end				


----------------------------------------------------------------------------------------------------------------------------
--
--
function VC:ReleaseUser( tbl, inBoat )

	--release driver
	--call C function to release the driver
	--PROTO: nPlayerid, szHelperName,szAnimName

	--NOTE FOR DESIGNERS: If you want to change the position where the player exits
	--from the boat, add another helper with another name and put it here instead of
	--"driver_sit_pos", then re-export the cgf with the new helper

--System:Log("\001 releasing USER");

	if(self.driverT and self.driverT.entity == tbl.entity and self.driverT.entity == _localplayer )	then	-- signal to everyone
--System:Log("\001 releasing USER  >>>>>   PLAYER_LEFT_VEHICLE");
--		AI:Signal(SIGNALFILTER_ANYONEINCOMM, 1, "PLAYER_LEFT_VEHICLE", self.id);
		AI:FreeSignal(1,"PLAYER_LEFT_VEHICLE", self:GetPos(), self.Properties.commrange, self.driverT.entity);
	end

	if( not tbl.entity.ai )	then	-- 
		AI:SetTheSkip( 0 );
	end	

	-- see if the entity was destroyed before (on shutdown)
	if(tbl.entity.GetAngles == nil) then 
		System:Log("\001 VC:ReleaseUser  >>>>   user is currapted ");
		return 
	end
	
	self.bRecursiveBind = 1;
	local table_id = VC.GetTableId(self,tbl);
	
	--fixme new is not needed probably
	--but not a big deal since releaseUser done once in a while
	local ppos = new(tbl.entity:GetPos());

	local aang = new(tbl.entity:GetAngles());

	if( self.hely ) then		--it's a helycopter - not a CVehicle
	
		local pos = self:GetHelperPos(tbl.in_helper);
		self:Unbind(tbl.entity);
		tbl.entity:SetPos( pos );
		tbl.entity:ActivatePhysics(1);
		tbl.entity.cnt.AnimationSystemEnabled = 1;
		tbl.entity:DrawCharacter(0,1);
		if( tbl.entity.cnt.health<=0 ) then
			AI:Signal(0, 10, "ON_GROUND", self.id);
		end	
--	elseif( tbl.out_anim ) then
	elseif( tbl.helper ) then
		self.cnt:ReleaseUser(tbl.entity.id, tbl.helper, "sidle", tbl.out_ang, table_id);
	else
		self.cnt:ReleaseUser(tbl.entity.id, tbl.in_helper, "sidle", tbl.out_ang, table_id);
	end

	if(tbl.entity.ai and tbl.entity.cnt.health>0 ) then
		
--System:Log("\001 releasing USER  >>>>>   PLAYER_LEFT_VEHICLE");		
		
		tbl.entity:TriggerEvent(AIEVENT_ENABLE);
		if(self.IsBoat) then

--System:Log("\001 releasing USER  >>>>>   boast");		

--		local pos = tbl.entity:GetPos();
--		local selfDir=self:GetDirectionVector();
--		pos.x = pos.x+selfDir.x*2.5;
--		pos.y = pos.y-selfDir.y;
--		tbl.entity:SetPos(pos);


			AI:Signal(0, -1, "do_exit_vehicle", tbl.entity.id);
		else
		
			if(self.Properties.bSetInvestigate==1)then
				AI:Signal(0, -1, "exited_vehicle_investigate", tbl.entity.id);
			else	
				AI:Signal(0, -1, "exited_vehicle", tbl.entity.id);
			end	
			tbl.entity.HASBEACON = self.HASBEACON;
			tbl.entity.DriverKilled = self.DriverKilled;

		end
	end

	if(self.driverT and tbl.entity == self.driverT.entity) then
		AI:Signal(0, 1, "DRIVER_OUT", self.id);
		if(tbl.entity.cnt.health <= 0) then
			self.DriverKilled = 1;
		end	
	end

	if ( self.gunnerT and tbl.entity == self.gunnerT.entity and tbl.entity.ai )	then	-- it's a gunner
		AI:Signal(0, 1, "GUNNER_OUT", self.id);
		VC.RestoreGunnerProprties(self, tbl.entity );
	end

	-- if player - put it up a bit
	if( not tbl.entity.ai and tbl.entity.cnt.health>0 ) then
		
		local pos = new(tbl.entity:GetPos());
		
		-- if can't exit on side - go on top
		local exitPos = tbl.exitPos;
		
		if( exitPos and exitPos.x+exitPos.y+exitPos.z ~= 0 ) then
			CopyVector(pos,exitPos);
			--Hud:AddMessage(sprintf("using exitPos(%.1f,%.1f,%.1f)",exitPos.x,exitPos.y,exitPos.z));
			--pos = tbl.exitPos;--self:GetHelperPos(tbl.in_helper);
		else		
			pos.z = pos.z+1;
		end
		
		--filippo
		local impDir = self:GetVelocity();
		local fSpeedScale = self.cnt:GetVehicleVelocity();
		
		--if velocity is too high shift a bit the exit position, to prevent the physics to push away the player when vehicle and player collide.
		if (fSpeedScale>10) then
			
			--test the velocity between 10 and 30, and normalize it.
			local vdelta = (fSpeedScale-10.0)/20.0;
						
			if (vdelta>1.0) then vdelta=1.0; end
			
			--get the delta between the vehicle and the exitposition, a sort of direction vector.
			local vpos = new(self:GetPos());
					
			local deltapos={x = vpos.x-pos.x,
					y = vpos.y-pos.y,
					z = vpos.z-pos.z};
							
			NormalizeVector(deltapos);
		
			local savepos = new(pos);
			--shift the position a bit, about the ammount of speed (vdelta).
			pos.x = pos.x - deltapos.x * 0.75 * vdelta;
			pos.y = pos.y - deltapos.y * 0.75 * vdelta;
			pos.z = pos.z - deltapos.z * 0.75 * vdelta;
			
			--this shift is not safe, use the original position.
			if (not VC.CanGetThere( self, tbl.entity, pos )) then
				CopyVector(pos,savepos);
			end
		end		
		
		tbl.entity:SetPos(pos);
								
		pos = self:GetAngles();
--		pos.z = pos.z - 180 + aang.z;
		pos.z = aang.z;
--System:Log("\001 angle "..pos.z);
		tbl.entity:SetAngles(pos);
		
--		local impDir = self:GetDirectionVector();
--		local fSpeedScale = self.cnt:GetVehicleVelocity()*20;
			
		--if (fSpeedScale>10) then fSpeedScale = 10; end
				
		if (tbl.entity.PhysParams~=nil and tbl.entity.PhysParams.mass) then
			fSpeedScale = fSpeedScale*tbl.entity.PhysParams.mass*0.2;--p_leavevehicleimpuls;
		else
			fSpeedScale = fSpeedScale*15.0;--p_leavevehicleimpuls;
		end
		
		--System:Log("exit speed:"..fSpeedScale);
					
		tbl.entity:AddImpulseObj( impDir, fSpeedScale);
		
		--local veltable={v=impDir,w={0,0,0}};
		--veltable.v.z = 800;	
		--tbl.entity:SetPhysicParams(PHYSICPARAM_VELOCITY, veltable );
	end

	if( tbl.state == 0 and tbl.entity.ai ) then	-- user didn't entere yet
		self.userCounter = self.userCounter - 1;
--		if( self.driverT ) then
		if( self.userCounter == 0 and (not self.hely)) then	-- nobody to waite for
			self.driverWaiting = 0;
		end
		tbl.entity:SetPos(ppos);
	end

--	System:Log("Input:SetActionMap('default 1");

	if(tbl.entity==_localplayer and (tbl.type == PVS_DRIVER or tbl.type == PVS_GUNNER))then
	
--	System:Log("Input:SetActionMap('default 2");

		Input:SetActionMap("default");
		Sound:ResetMusicThemeOverride();
	end

	-- 
	tbl.entity.cnt:EnableAngleLimitH( 0 );

	tbl.entity.cnt:SetMinAngleLimitV( tbl.entity.normMinAngle );
	tbl.entity.cnt:SetMaxAngleLimitV( tbl.entity.normMaxAngle );

	if (tbl.entity == _localplayer) then
		VC:DeactivateLayers();
	end
	
	--[kirill]
	-- if player released from vehicle coz is dead - let's remove his weapons
	if(tbl.entity.cnt.health <= 0) then
		tbl.entity.cnt:DeselectWeapon();
	end	

	tbl.exittime = _time;
	tbl.entity.theVehicle = nil;
	tbl.entity.outOfVehicleTime = _time;
	tbl.state=0;
	tbl.entity = nil;

	if(self.troopersNumber) then
		self.troopersNumber = self.troopersNumber - 1;
	end	

	if (self.nUsers) then
		self.nUsers = self.nUsers - 1;
		
		if (self.nUsers <= 0) then
			self.fAbandonedTime = _time + self.Properties.fAbandonedTime;
--			System:Log("XXX Setting fAbandonedTime to "..tostring(self.fAbandonedTime));
		end
	end
	
	self.bRecursiveBind = nil;
	
end


-------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------
--



----------------------------------------------------------------------------------------------------------------------------
--
--




--
--
function VC:UpdateEnteringLeaving( dt )
	
	if( self.hely ) then
		if( self.userCounter == 0 and self.driverWaiting == 1 ) then
			AI:Signal(0, 1, "DRIVER_IN",self.id);
			self.driverWaiting=-1;
		end
	elseif( self.driverT ) then		-- if there is driver table - do driver stuff
		self.driverDelay = self.driverDelay-dt;	
		
--System:Log("VC:UpdateEnteringLeaving  "..self.driverWaiting.." "..self.userCounter.." "..self.driverDelay);
		
		if( self.driverWaiting==0 and self.driverDelay<=0) then
			AI:Signal(0, 1, "DRIVER_IN",self.id);
			self.driverWaiting=-1;
		end

		if( self.driverT.entity ) then
			VC.UpdateEnteringUser( self, dt, self.driverT );
		end
	end	
		-- there are alwways some passengers
	for idx=1, self.passengerLimit do
		VC.UpdateEnteringUser( self, dt, self.passengersTT[idx] );
	end
	if( self.gunnerT ) then		-- if there is gunner table - do gunner stuff
		VC.UpdateEnteringUser( self, dt, self.gunnerT );
	end
end

----------------------------------------------------------------------------------------------------------------------------
--
--	updates passngers and gunner
function VC:UpdateEnteringUser( dt, tbl )

	if( tbl.entity ) then 
		if( tbl.state==1 ) then
--System:Log( "\001 helyPass "..tbl.time);			
			tbl.time = tbl.time - dt;
			if( tbl.time <= 0 ) then
				VC.UserEntered( self, tbl );
--System:Log( "\001 ----------------------------------------------------------------------------------");
				if( self.driverT ) then
					if( self.driverT.entity == tbl.entity ) then -- it's a driver
						self.driverDelay = 2;
						if(self.Properties.fStartDelay) then
							self.driverDelay = self.Properties.fStartDelay;
						end	
						if( self.userCounter == 0) then	-- nobody to waite for
							self.driverWaiting = 0;
						else	
							self.driverWaiting = 1;
			--System:Log( "driver waiting "..self.userCounter  );
						end
					elseif( self.userCounter == 0 ) then
						self.driverWaiting = 0;
--		System:Log( "driver added passenger " );
					end
				end
			elseif( not tbl.in_anim and tbl.time >= 0 ) then	-- no entering animation - doing fake jump than
				VC.UpdateEnteringJump( self, dt, tbl );
			end
		elseif( tbl.state==4 ) then
			tbl.time = tbl.time - dt;
			if( tbl.time <= 0 ) then
				VC.ReleaseUser( self, tbl );
			end
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------
--
--	updates passngers and gunner
function VC:UpdateEnteringJump( dt, tbl )

--	tbl.time = tbl.time - _frametime;
	tbl.timePast = tbl.timePast + dt;
--System:Log( " JUMP "..tbl.time );		
	local pos = tbl.entity:GetPos();
	local dir=DifferenceVectors(pos, self:GetHelperPos( tbl.in_helper ));
	dir.z=0;
	NormalizeVector( dir );
	ScaleVectorInPlace( dir, self.entVel*_frametime );
	FastDifferenceVectors( pos, pos, dir);

	-- adding pseudo-jump arch

--System:Log( "\001 JUMP "..tbl.time.."  "..tbl.HT.."  "..tbl.HS );
	local tt = tbl.timePast - tbl.HT;
	tt = (tt*tt-tbl.HT*tbl.HT);
	pos.z = tbl.HO+tbl.HK*tbl.timePast - tt*tbl.HS;
	tbl.entity:SetPos( pos );
--System:Log( "\001 JUMP "..tbl.time.."  >>>  "..pos.x.." "..pos.y.." "..pos.z );	
	

--System:Log( "VC:UpdateEnteringJump target  "..self:GetName());	
	
end


----------------------------------------------------------------------------------------------------------------------------
--
--	updates passngers and gunner
function VC:UserEntered( tbl )

  local table_id = VC.GetTableId(self,tbl);
	if( not tbl.in_anim ) then	-- if has NO entering animation - bind to vehicle now,
		if( self.hely ) then	-- this is hely - it's not CVehicle
			self:Bind( tbl.entity, table_id );
			tbl.entity:SetAngles(self:GetAngles());				
		else
			self.cnt:SetUser(tbl.entity.id, tbl.helper, tbl.in_ani, tbl.type, table_id);
		end	
	end

	tbl.entity:SetPos(self:GetHelperPos(tbl.in_helper,1));
	tbl.entity:StartAnimation(0,tbl.sit_anim, 0, 0, 1);
	tbl.entity:ForceCharacterUpdate(0);
	
	tbl.state = 2;
	self.userCounter = self.userCounter-1;
	
	-- have to enable gunner and to select gunner pipe
	if(self.gunnerT == tbl ) then
		if( tbl.entity.ai ) then		-- it's AI - activete, set gunner pipe
			tbl.entity:TriggerEvent(AIEVENT_ENABLE);
			tbl.entity:SelectPipe(0,"h_gunner_fire");
		end
		if (self.mountedWeapon )	then 	-- enter the mounted weapon
			self.mountedWeapon:SetGunner( tbl.entity );
			self.mountedWeapon.lastusetime = _time;
		end		
		VC.SetGunnerProprties(self, tbl.entity);
	end	
	
	if(self.RestoringState ~= 1 ) then
		if(self.troopersNumber) then
			self.troopersNumber = self.troopersNumber + 1;
		end	
	end
	
	if (self.nUsers) then
--		System:Log("xXX Reset abandontime");
		self.nUsers = self.nUsers + 1;
		self.bAbandoned = nil;
		self.fAbandonedTime = nil;
	end
end	

----------------------------------------------------------------------------------------------------------------------------
--
--
function VC:InitApproach( tbl )

	tbl.entity.vhclATime = 500;

	self.userCounter = self.userCounter+1;
	tbl.state=0;

	if(self.Properties.fStartDelay and self.Properties.fStartDelay<0) then	return 0; end


	local name = nil;
--	local name = AI:FindObjectOfType(self.id,25,tbl.anchor);	
	if( self.hely ) then
		name = AI:FindObjectOfType(tbl.entity:GetPos(),self.Properties.commrange,tbl.anchor);
	else	
		name = AI:FindObjectOfType(self.id,25,tbl.anchor);
	end

--System:Log( "VC:InitApproach "..self:GetName() );
	
	if (name) then 
		
--System:Log( "approaching  "..name.." for  "..self:GetName() );
		
		tbl.entity.theVehicle = self;
		tbl.entity:SelectPipe(0,"b_user_getin",name);
		return 1 
	else
		return 0
	end
	
end


-------------------------------------------------------------------------------------------------------------
--
--
function VC:InitEnteringJump( tbl )

	local destination=self:GetHelperPos(tbl.in_helper);
	
	if( destination.x==0 and destination.y==0 ) then
		destination=self:GetPos();
	end	

	local dir = DifferenceVectors( destination, tbl.entity:GetPos() );
	local dist = sqrt(LengthSqVector(dir));
	local angl = self:GetAngles(); 
	
	
	-- safeguard for case when could not approach the entering anchor - just
	-- snap inside, no fake-jump
	if( dist>6 ) then
		tbl.state = 1;
		tbl.time = dist/self.entVel;
		tbl.time = 0;
		tbl.entity:SetPos( destination );
--System:Log( "\001 init JUMP >>> FAR <<< ");
	else
		ConvertVectorToCameraAngles(angl, dir);
		tbl.entity:SetAngles( angl );
	
		tbl.state = 1;
		tbl.time = dist/self.entVel;
		tbl.timePast = 0;
		tbl.HT = tbl.time*.5;
		tbl.HK = dir.z/tbl.time;
		tbl.HO = tbl.entity:GetPos().z;
		tbl.HS = 10/tbl.time;
	
--System:Log( "\001 init JUMP >>> "..tbl.HO.."  "..tbl.HS.."  "..tbl.HT );	
	
		tbl.entity:ActivatePhysics(0);
		tbl.entity.cnt.AnimationSystemEnabled = 0;
		tbl.entity:StartAnimation(0,"jump_air");		-- to have this as previous animation
		tbl.entity:StartAnimation(0,"jump_start");
	end
	
--System:Log( "VC:InitEnteringJump target  "..self:GetName().." time  "..tbl.time );

end

----------------------------------------------------------------------------------------------------------------------------
--
--
function VC:InitEntering( tbl )

--	if( tbl.in_ang ~= nil )then
--		tbl.entity:SetAngle({ x=0, y=0, z=tbl.in_ang });
--	end	
	tbl.entity.cnt.AnimationSystemEnabled = 0;
	tbl.state = 1;
--	tbl.time = 2;
	tbl.time = tbl.entity:GetAnimationLength(tbl.in_anim);
--System:Log("entering DELAY     "..tbl.entity:GetAnimationLength(tbl.in_anim));
	tbl.entity:SetDefaultIdleAnimations(0);
	tbl.entity:StartAnimation(0,tbl.in_anim, 0, .3, 1);

	
	if(self.Properties.fStartDelay and self.Properties.fStartDelay<0) then
		tbl.time = 0;
	end	

end



----------------------------------------------------------------------------------------------------------------------------
--
--
function VC:InitLeaving( tbl )
	
	
	-- don't want invehicle states animations to be player
	tbl.entity.vhclATime = _time-tbl.entertime+10;
--	tbl.entity:StartAnimation(0,"NULL",2);	
	tbl.entity:ResetAnimation(0);

	--System:Log("\001 OUT >>> "..tbl.entity.vhclATime);
	
	
	if( tbl.state == 0 or tbl.entity==_localplayer) then	-- didnot enter yet
								-- no animations for local player
		VC.ReleaseUser( self, tbl );
		return
	end		
	
	-- need this to orient gunner forward - so exiting animation will be player correctly
	if(tbl.entity.ai) then
		tbl.entity:SetAngles( {x=0,y=0,z=180} );
	end	
	
	tbl.entity:SelectPipe(0,"c_driver");
	AI:Signal(0, 1, "desable_me",tbl.entity.id);
	
	tbl.entity.cnt.AnimationSystemEnabled = 0;
--	tbl.entity:SelectPipe(0,"c_driver");
	tbl.state = 4;
	if( tbl.out_anim ) then
		tbl.time = tbl.entity:GetAnimationLength(tbl.out_anim);--2.1;
--System:Log("leaving DELAY     "..tbl.entity:GetAnimationLength(tbl.out_anim));		
	else	
		tbl.time = 0;
	end
	

--	tbl.time = self:GetAnimationLength(tbl.out_anim);
	
--	tbl.entity:StartAnimation(0,"sidle", 0, .0, 1);
	tbl.entity:SetDefaultIdleAnimations(0);			-- to keep last frame of animation on
	tbl.entity:SetPos(self:GetHelperPos(tbl.helper,1));
	tbl.entity:StartAnimation(0,tbl.out_anim, 0, .0, 1);
	tbl.entity:ForceCharacterUpdate(0);
	
end


----------------------------------------------------------------------------------------------------------------------------
--
--
function VC:KillPlayer( player )

	local	hit = {
	dir = {x=0, y=0, z=1},
	damage = 5000,
	target = player,
	shooter = player,
	landed = 1,
	impact_force_mul_final=5,
	impact_force_mul=5,
	damage_type = "normal",
	};
	player:Damage( hit );
end			
			

----------------------------------------------------------------------------------------------------------------------------
--
--
function VC:KillEveryone( )

	if( self.driverT and self.driverT.entity ) then
		VC.KillPlayer( self, self.driverT.entity );
	end
	if( self.gunnerT and self.gunnerT.entity ) then
		VC.KillPlayer( self, self.gunnerT.entity );
	end	
	for idx=1, self.passengerLimit do
		if( self.passengersTT[idx].entity ) then
		-- We know there is a passenger and he is finished climbing in
		--release passenger
			VC.KillPlayer( self, self.passengersTT[idx].entity );
		end
	end
end


----------------------------------------------------------------------------------------------------------------------------
--
--
function VC:EveryoneOutForce( )

	if( self.driverT and self.driverT.entity ) then
		--release user without be sure the test is ok is risky 1% of the times, because maybe the vehicle is stuck somewhere really hard and there is no exit position.
		VC.CanGetOut(self, self.driverT)	-- need this to find exit point (side or top)
		VC.ReleaseUser( self, self.driverT );
	end
	if( self.gunnerT and self.gunnerT.entity ) then
		--release user without be sure the test is ok is risky 1% of the times, because maybe the vehicle is stuck somewhere really hard and there is no exit position.
		VC.CanGetOut(self, self.gunnerT)	-- need this to find exit point (side or top)
		VC.ReleaseUser( self, self.gunnerT );
	end	
	if (self.passengersTT) then
		for idx=1, self.passengerLimit do
			if( self.passengersTT[idx].entity ) then
			-- We know there is a passenger and he is finished climbing in
			--release passenger
				--release user without be sure the test is ok is risky 1% of the times, because maybe the vehicle is stuck somewhere really hard and there is no exit position.
				VC.CanGetOut(self, self.passengersTT[idx])	-- need this to find exit point (side or top)
				VC.ReleaseUser( self, self.passengersTT[idx] );
			end
		end
	end
	self.userCounter = 0;
	self.driverWaiting = 1;
		
	VC.StopDrivingSounds(self,1);	
end


----------------------------------------------------------------------------------------------------------------------------
--
--
function VC:DropPeople( )

	VC.AIDriver( self, 0 );

	-- if AI driver left the vehicle - brake right there
	if(self.driverT and self.driverT.entity and self.driverT.entity.ai and self.IsCar) then
		self.cnt:HandBreak(1);
	end

	if(self.driverT.entity) then
		VC.InitLeaving( self, self.driverT );
	end
	
	if(self.gunnerT and self.gunnerT.entity) then
		VC.InitLeaving( self, self.gunnerT );
	end

	for idx=1, self.passengerLimit do
		if( self.passengersTT[idx].entity ) then
		-- We know there is a passenger and he is finished climbing in
		--release passenger
			VC.InitLeaving( self, self.passengersTT[idx] );
		end
	end		
	
	--if(self.sliding_sound) then
	--	Sound:StopSound(self.sliding_sound);	
	--end
end


----------------------------------------------------------------------------------------------------------------------------
--
--
function VC:CanAddPassenger( startFrom )
	-- passengers --------------------------------------------------------------
	local passengerEnter;
	for idx=startFrom, self.passengerLimit do
		if( not self.passengersTT[idx].entity ) then
			return self.passengersTT[idx];
		end	
	end
	return nil;
end	
	

----------------------------------------------------------------------------------------------------------------------------
--
--
function VC:ReleaseUserOnShutdown( player )

	local tbl = VC.FindUserTable( self, player );
	if( tbl ) then
		VC.ReleaseUser( self, tbl );
	end
end	

----------------------------------------------------------------------------------------------------------------------------
--
--
function VC:FindUserTable( player )

	if( self.driverT and self.driverT.entity == player ) then return self.driverT; 	end
	if( self.gunnerT and self.gunnerT.entity == player ) then return self.gunnerT; 	end	
	return VC.FindPassenger( self, player);
end	

	
----------------------------------------------------------------------------------------------------------------------------
--
--
function VC:FindPassenger( puppet )
	-- passengers --------------------------------------------------------------
	local passengerEnter;
	for idx=1, self.passengerLimit do
		if( self.passengersTT[idx].entity and self.passengersTT[idx].entity == puppet) then
			return self.passengersTT[idx];
		end
	end
	return nil;
end	

----------------------------------------------------------------------------------------------------------------------------
--
--
function VC:GetAvailablePosition( player )

	-- cant use it if AI is driving or is a gunner
	if( self.driverT and self.driverT.entity and (self.driverT.entity.Properties.special ~= 1 and
							self.driverT.entity.ai )) then
		do return nil end
	end
	if( self.gunnerT and self.gunnerT.entity and (self.gunnerT.entity.Properties.special ~= 1 and
							self.gunnerT.entity.ai )) then
		do return nil end
	end


--System:Log("\001 lock  "..self.Properties.bLockUser);

	if( VC.AllowedToDrive( self, player ) ) then
		if( VC:IsTableAvailable( self.driverT )) then
			return self.driverT
		end	
	end
	if( VC:IsTableAvailable( self.gunnerT )) then
		return self.gunnerT
	end	
	-- passengers --------------------------------------------------------------
	for idx=1, self.passengerLimit do
		if( VC:IsTableAvailable(self.passengersTT[idx]) ) then
			return self.passengersTT[idx];
		end
	end
	return nil;
end	

----------------------------------------------------------------------------------------------------------------------------
--
--
function VC:CyclePosition( user )

	-- can't change positions if locked
	if(self.Properties.bLockUser == 1) then return end

	if(user.lastVehicleCycleTime and _time-user.lastVehicleCycleTime<0.75)	then return end	-- just did cycle

local nextTable=nil;
local curTable=nil;
	-- fixme
	-- not good, but works
	-- should be changed if there is time

	if(self.driverT and self.driverT.entity == user) then	-- it's driver - try to switch to ganner
								-- if not available - passenger
System:Log("it's driver cycling");
		curTable = self.driverT;
		if( VC:IsTableAvailable( self.gunnerT )) then
			nextTable = self.gunnerT;
System:Log("--> be gunner now");
		else
			for idx=1, self.passengerLimit do
				if( VC:IsTableAvailable(self.passengersTT[idx]) ) then
					nextTable = self.passengersTT[idx];
System:Log("--> be passenger "..idx);
					idx = self.passengerLimit + 1;
				end
			end
		end
	elseif(self.gunnerT and self.gunnerT.entity == user) then	-- it's gunner - try to switch to passenger
									-- if not available - driver
System:Log("it's gunner cycling");									
		curTable = self.gunnerT;
		for idx=1, self.passengerLimit do
			if( VC:IsTableAvailable(self.passengersTT[idx]) ) then
				nextTable = self.passengersTT[idx];
				idx = self.passengerLimit + 1;
			end
		end
		if( not nextTable and VC.AllowedToDrive( self, user ) and VC:IsTableAvailable( self.driverT )) then
			nextTable = self.driverT;
		end
	else							-- it's passenger - try to switch to driver
								-- if not available - gunner
System:Log("it's passenger cycling");
		curTable = VC.FindPassenger( self, user );
		if( not nextTable and VC.AllowedToDrive( self, user ) and VC:IsTableAvailable( self.driverT )) then
			nextTable = self.driverT;
		elseif( VC:IsTableAvailable( self.gunnerT )) then
			nextTable = self.gunnerT;
		end
	end

	if( nextTable ) then
		nextTable.entity = user;
	
--		System:Log("VC: Cylcle 1");

		VC.ReleaseUser( self, curTable );	-- get out of prevouse position

--		System:Log("VC: Cylcle 2");

		VC.AddUserT( self, nextTable);		-- get in the new position
		user.lastVehicleCycleTime = _time;
	end	
end	


----------------------------------------------------------------------------------------------------------------------------
--
--
function VC:IsTableAvailable( tbl )

	if( tbl and tbl.entity == nil and _time-tbl.exittime>.3 ) then return 1 end	
	return nil 
end

----------------------------------------------------------------------------------------------------------------------------
--
--
function VC:InitAnchors(  )

	if(self.driverT) then
		AI:CreateBoundObject( self.id, self.driverT.anchor, self:GetHelperPos(VC:GetEnterPoint(self.driverT),1), self:GetAngles() );
	end	
	if(self.gunnerT) then
		AI:CreateBoundObject( self.id, self.gunnerT.anchor, self:GetHelperPos(VC:GetEnterPoint(self.gunnerT),1), self:GetAngles() );	
	end	
	for idx=1, self.passengerLimit do
		if( self.passengersTT[idx] ) then
			AI:CreateBoundObject( self.id, self.passengersTT[idx].anchor, self:GetHelperPos(VC:GetEnterPoint(self.passengersTT[idx]),1), self:GetAngles() );
		end
	end	
end

----------------------------------------------------------------------------------------------------------------------------
--
--
function VC:GetEnterPoint( tbl  )

	if( tbl.enterpoint ) then return tbl.enterpoint end
	return tbl.helper
		
	
end


--
--
-----------------------------------------------------------------------------------------------------
-- for ground vehicle - change friction based on vertical angle
function VC:UpdateWheelFriction( )

	do return end

	if(self.aiDriver) then return end
	if(Game:IsMultiplayer()) then return end

	local 	scale = 1 - self.cnt:GetVertDeviation();

--System:Log( " "..scale);
--	if( curAngle.z < 0 ) then
--		scale = 1 + curAngle.z*5;
--	else	
--		scale = 1 - curAngle.z*5;
--	end	
	
	if(scale<0) then
		scale = 0;
	end	
	if( scale<0.5 ) then
		
--		scale = scale - .4;
--		scale = 0;
		scale = scale*2;
		
--System:Log( " "..scale.." "..curAngle.z );

		if (self.wheelFrictionTable == nil) then
			self.wheelFrictionTable = {};
		end
			
		local table = self.wheelFrictionTable;
		-- CarDefNormal is obsolete
		--table.min_friction = self.CarDefNormal.wheel1.min_friction*scale;
		--table.max_friction = self.CarDefNormal.wheel1.max_friction*scale;
		table.min_friction = self.CarDef.wheel1.min_friction*scale;
		table.max_friction = self.CarDef.wheel1.max_friction*scale;
		
		table.wheel = 0;
		self:SetPhysicParams(PHYSICPARAM_WHEEL, table);
		table.wheel = 1;
		self:SetPhysicParams(PHYSICPARAM_WHEEL, table);
		table.wheel = 2;
		self:SetPhysicParams(PHYSICPARAM_WHEEL, table);
		table.wheel = 3;
		self:SetPhysicParams(PHYSICPARAM_WHEEL, table);
	end	
end

--
--
-----------------------------------------------------------------------------------------------------
-- check if ground vehicle is too deep in water for more than some time ( 1 sec )- to desable it
function VC:IsUnderWater( dt )
	local pos = self:GetPos();
	if(System:IsPointIndoors(pos)==1) then return 0; end
	
	local wlevel = Game:GetWaterHeight();
	
	if( pos.z+self.waterDepth<wlevel ) then	-- is under water
		if(dt) then
			self.inWarterTime = self.inWarterTime + dt;
		else
			return 1;	
		end	
	else
		self.inWarterTime = 0;
	end	
	
	if( self.inWarterTime>1 ) then
		return 1;
	end	
	return 0;
end


-----------------------------------------------------------------------------------------------------
-- check if AI can use the vehicle
function VC:FreeToUse( )

	if(self.bExploded == 1) then return 0 end
--	if( _localplayer.theVehicle == self ) then		-- used by player
--		return 0;
--	end	
	return 1;	
end


-----------------------------------------------------------------------------------------------------
-- find attack spot, approach it
function VC:BoatLandAttack( )

	local target = AI:GetAttentionTargetOf( self.id );
	
--System:Log( "\001 BoatLandAttack  ----------------- "..self:GetName() );	
	
	if(target and type(target)=="table" and target.GetPos) then
		
		local name = nil;
		name = AI:FindObjectOfType(target:GetPos(),100,AIAnchor.AIANCHOR_BOATATTACK_SPOT);
--System:Log( "\001 VC:BoatLandAttack "..self:GetName() );
		
		if (name) then 
--System:Log( "\001 BoatLandAttack  "..name.." for  "..self:GetName() );
			self:SelectPipe(0,"b_attack_land",name);
		end	
	end	
end

-----------------------------------------------------------------------------------------------------
-- find land spot, approach it - drop people
function VC:BoatLand( )

	local target = AI:GetAttentionTargetOf( self.id );
	
--System:Log( "\001 BoatLandAttack  ----------------- "..self:GetName() );	
	
	if(target and type(target)=="table" and target.GetPos) then
		
		local name = nil;
		name = AI:FindObjectOfType(target:GetPos(),100,AIAnchor.AIANCHOR_BOATATTACK_SPOT);
--System:Log( "\001 VC:BoatLandAttack "..self:GetName() );
		
		if (name) then 
--System:Log( "\001 BoatLandAttack  "..name.." for  "..self:GetName() );
			self:SelectPipe(0,"b_attack_land",name);
		end	
	end	
end



-----------------------------------------------------------------------------------------------------
-- update particles (dust, damage), some slip sounds
function VC:DoParticlesSlip( fCarSpeed )

	---------------------------------		
	if(fCarSpeed < 1.5) then return end --was 0.1
	
	self.slip_speed = 0;

	local wheeln = 4;
	if (self.CarDef.wheel_num) then wheeln = self.CarDef.wheel_num; end
	
	--for i=0, 3, 1 do
	for i=0,wheeln-1, 1 do
		local wheelstats = self.cnt:GetWheelStatus( i );
		self.slip_speed = self.slip_speed + wheelstats.vel;

					
		local rdir = VC.particles_dir_vector;
--		local rdir = wheelstats.dir;
--		rdir.z = 12;
--		NormalizeVector( rdir );
		local fDustScale = fCarSpeed / 20;
				
		if (Game:IsPointInWater(wheelstats.ptContact)~=nil) then	
		-- here if the wheel is in water	
		
--			local fwddir = wheelstats.dir;
			local fwddir = self:GetDirectionVector();
			fwddir.x = -fwddir.x;
			fwddir.y = -fwddir.y;
			fwddir.z = 1;
			NormalizeVector( fwddir );

--			local leftdir = new ( fwddir );
--			leftdir.x = -leftdir.y;
--			leftdir.y = leftdir.x;
--			local rightdir = new ( fwddir );
--			rightdir.x = rightdir.y;
--			rightdir.y = -rightdir.x;
		
			wheelstats.ptContact.z = wheelstats.ptContact.z+.3;
			if ( ( wheelstats.bContact ~= 0 ) and ( wheelstats.vel > 0.01 )) then
		
				-- do slip here sometime	
				if((wheelstats.vel>4)and(fCarSpeed>4)and(random(0,100)>50)) then 
	--				Particle:SpawnEffect(wheelstats.ptContact, wheelstats.dir, "smoke.vehicle_slip.");			
					Particle:SpawnEffect(wheelstats.ptContact, fwddir, "smoke.vehicle_water_slip.a");
				end
				
				-- do stones 
				-- Particle:SpawnEffect(wheelstats.ptContact, rdir, "smoke.vehicle_rocks.a",1.0);

				-- do traile
				wheelstats.ptContact.z = Game:GetWaterHeight() + 0.15;
				Particle:SpawnEffect(wheelstats.ptContact, g_Vectors.v001, "smoke.vehicle_water_trail.a",1.0);
			end
			--  do some "just normal movement" particles for the wheel
			if (( wheelstats.bContact ~= 0 ) and fCarSpeed > 4) then
				Particle:SpawnEffect(wheelstats.ptContact, fwddir, "smoke.vehicle_water_splash.a",1 );
			end
			
			Particle:SpawnEffect(wheelstats.ptContact, rdir, "smoke.vehicle_dust.",1 );
		else
			local material = Game:GetMaterialBySurfaceID(wheelstats.surfaceIndex);
				
			-- here if the wheel is on ground	
			if ( material and wheelstats.bContact ~= 0 ) then	
				
				--Hud:AddMessage(material.type);
				
				wheelstats.ptContact.z = wheelstats.ptContact.z+.3;
				
				if (material.VehicleParticleEffect and wheelstats.vel > 0.05) then--0.01
					--usually here we have particle effect like stones, debris etc 
					Particle:SpawnEffect(wheelstats.ptContact, rdir, material.VehicleParticleEffect,1.0);--"smoke.vehicle_rocks.a",1.0);
				end
			
				if (material.VehicleSmokeEffect and fCarSpeed > 4) then
					--here we usually make smoke
					Particle:SpawnEffect(wheelstats.ptContact, rdir, material.VehicleSmokeEffect,1.0);--"smoke.vehicle_dust.a",1 );
				end
			end
			
			-- no slip - looks bad		
--			-- do slip here sometime	
--			if((wheelstats.vel>4)and(fCarSpeed>4)and(random(0,100)>50)) then 
--				--Particle:SpawnEffect(wheelstats.ptContact, wheelstats.dir, "smoke.vehicle_slip.a");			
--				Particle:SpawnEffect(wheelstats.ptContact, rdir, "smoke.vehicle_slip.a");
--			end
		end	
				
		-- do suspension compressopn sound
		
	-- suspension compressopn ration for each wheel	in range [0,1]
	
		local suspTable = self.suspTable[i+1];
		
		if (suspTable) then
		
			local diff = suspTable.suspWheel-wheelstats.compression;
			if( diff<0 ) then diff = - diff; end
		
--			if( (suspTable.suspWheel-threshhold)*(wheelstats.compression-threshhold)<0 ) then
			if( diff > self.suspThreshold ) then
				local comprSound = self.suspSoundTable[random(1,4)];
				if (Sound:IsPlaying(comprSound) ~= 1) then
					Sound:SetSoundPosition(comprSound,self:GetHelperPos(suspTable.helper));
--					Sound:SetSoundPosition(self.compression_sound1,self:GetPos());
					Sound:PlaySound(comprSound);		
				end		
--				System:Log("\001 SUS SOUND ----------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  "..diff);
			end	
			
			suspTable.suspWheel = wheelstats.compression;
		end
	end
	
	--filippo
	local vstatus=self.cnt:GetVehicleStatus();
	
	-- total slip is big - do slip sounds
	--if (self.slip_speed > 4 and self.bExploded~=1 and self.driverT and self.driverT.entity and vstatus.wheelcontact~=0) then
	if (self.slip_speed > 12 and self.bExploded~=1 and vstatus.wheelcontact~=0) then		
		if (Sound:IsPlaying(self.sliding_sound) ~= 1) then
			--Sound:SetSoundLoop(self.sliding_sound, 1);
			Sound:SetSoundPosition(self.sliding_sound,self:GetPos());
			Sound:PlaySound(self.sliding_sound);
		end
	else
		Sound:StopSound(self.sliding_sound);
	end
end


----------------------------------------------------------------------------------------------------------------------------
--
--
----------------------------------------------------------------------------------------------------------------------------
--
--



----------------------------------------------------------------------------------------------------------------------------
--
--
function VC:GetTableId( aTable )
	if( aTable==self.driverT ) then
		return 0
	end	
	if( aTable==self.gunnerT ) then
		return 1
	end	
	-- passengers --------------------------------------------------------------
	for idx=1, self.passengerLimit do
		if( aTable==self.passengersTT[idx] ) then
			return idx+1;
		end
	end
	System:Log("GetTableId : unknown table");  
	return 0;
end	

function VC:OnBind( player, table_id )

--System:Log("OnBind  >><<<<<< "..table_id);
  local aTable;
  if (not player or player.type~="Player") then
    return
  end  
  if ( table_id==0 ) then 
    aTable = self.driverT;
    AI:Signal(0, 1, "wakeup", player.id);
  elseif ( table_id==1 ) then
    aTable = self.gunnerT;
--System:Log("binding GUNNER >><<<<<< "..player:GetName());    
    if(self.RestoringState == 1 ) then
    	-- it's helly - add gunner 
	VC.RebindGunner(self, aTable, player );
--System:Log("binding GUNNER 111 >><<<<<< ");    
    else
    	-- it's ground vehicle gunner will be added in AddUserT
	player:SelectPipe(0,"h_gunner_fire");
--	AI:Signal(0, 1, "select_gunner_pipe", player.id);
	AI:Signal(0, 1, "wakeup", player.id);
--System:Log("binding GUNNER 222 >><<<<<< ");
    end	
  elseif ( table_id<=self.passengerLimit+1 ) then
    aTable = self.passengersTT[table_id-1];
	player:SelectPipe(0,"c_driver");
	AI:Signal(0, 1, "wakeup", player.id);
  else
    return
  end
  
  if ( aTable.entity~=player and not self.bRecursiveBind ) then
	aTable.entity = player;
	aTable.time = -20;
	aTable.state = 1;

--	System:Log("VC: OnBind 1");

	VC.AddUserT( self, aTable );
	--
	-- this is done to restore player's leaving vehicle on QS/QL
	if ( player.leaveTheVehicle == 1 ) then 
		VC.ReleaseUser( self, aTable );
		player.leaveTheVehicle = nil;
		do return end
	end	
	AI:Signal(0, 1, "select_gunner_pipe", player.id);
	AI:Signal(0, 1, "entered_vehicle",player.id);
--		if(_localplayer and (aTable.type == PVS_DRIVER or aTable.type == PVS_GUNNER) and self.IsCar and player==_localplayer) then
--			Input:SetActionMap("vehicle");
--		end	
  end
end

function VC:RebindGunner( aTable, player )

	aTable.entity = player;

	player:SelectPipe(0,"h_gunner_fire");
	AI:Signal(0, 1, "wakeup", player.id);	
	AI:Signal(0, 1, "select_gunner_pipe", player.id);
	AI:Signal(0, 1, "entered_vehicle",player.id);
	AI:Signal(0, 1, "wakeup", player.id);	

	if (self.mountedWeapon )	then 	-- enter the mounted weapon
		self.mountedWeapon:SetGunner( aTable.entity );
		self.mountedWeapon.lastusetime = _time;
	end
	VC.SetGunnerProprties(self, player);
	VC.AddGunnerHely( self, aTable );
	
	player:SetPos( self:GetHelperPos(self.gunnerT.in_helper, 1));
end



function VC:OnUnBind( player, table_id )
  local aTable;
  if (not player or player.type~="Player") then
    return
  end  
  if ( table_id==0 ) then 
    aTable = self.driverT;
  elseif ( table_id==1 ) then
    aTable = self.gunnerT;
  elseif ( table_id<=self.passengerLimit+1 ) then
    aTable = self.passengersTT[table_id-1];
  else
    return
  end
  if ( aTable.entity==player and not self.bRecursiveBind ) then
--    System:Log("VC:OnUnbind "..table_id);  
    VC.ReleaseUser( self, aTable );
  end  
end

-- 
-- override gunner parametrs to make it more accurate/agressive/whatever when using mounted weapon
function VC:SetGunnerProprties( entity )


--System:Log("\001 VC:SetGunnerProprties >>>>>>>>>>>>>>>>>> ");

	if( not entity.ai ) then return end
--System:Log("\001 VC:SetGunnerProprties >>>>>>>>>>>>>>>>>> 1");	
	if( not self.Properties.GunnerParams ) then return end
--System:Log("\001 VC:SetGunnerProprties >>>>>>>>>>>>>>>>>> 2");
	
--	entity:ChangeAIParameter(AIPARAM_RESPONSIVENESS,self.Properties.GunnerParams.responsiveness);
	-- since responciveness is scaled now in c-code - make it lower here
	-- initially should not be more then 50 (coz of hardcoded c-check)
	if(self.Properties.GunnerParams.responsiveness > 50) then
		self.Properties.GunnerParams.responsiveness = 50;
	end		
	entity:ChangeAIParameter(AIPARAM_RESPONSIVENESS,self.Properties.GunnerParams.responsiveness*.2);	
	entity:ChangeAIParameter(AIPARAM_SIGHTRANGE,	self.Properties.GunnerParams.sightrange);
	entity:ChangeAIParameter(AIPARAM_ATTACKRANGE,	self.Properties.GunnerParams.attackrange);
	entity:ChangeAIParameter(AIPARAM_FOV,		self.Properties.GunnerParams.horizontal_fov);
--	entity:ChangeAIParameter(AIPARAM_AGGRESION,	self.Properties.GunnerParams.aggression);
--	entity:ChangeAIParameter(AIPARAM_ACCURACY,	self.Properties.GunnerParams.accuracy);

end

--
-- restore gunner parametrs after using mounted weapon
function VC:RestoreGunnerProprties( entity )

	if( not entity.ai ) then return end

	entity:ChangeAIParameter(AIPARAM_RESPONSIVENESS,entity.Properties.responsiveness);
	entity:ChangeAIParameter(AIPARAM_SIGHTRANGE,	entity.PropertiesInstance.sightrange);
	entity:ChangeAIParameter(AIPARAM_ATTACKRANGE,	entity.Properties.attackrange);
	entity:ChangeAIParameter(AIPARAM_FOV,		entity.Properties.horizontal_fov);
--	entity:ChangeAIParameter(AIPARAM_AGGRESION,	entity.Properties.aggression);
--	entity:ChangeAIParameter(AIPARAM_ACCURACY,	entity.Properties.accuracy);

end


-- 
-- override self parametrs to make it more accurate/agressive/whatever when attacking
function VC:SetAttackProperties( )

	if( not self.Properties.AttackParams ) then return end
	
	self:ChangeAIParameter(AIPARAM_SIGHTRANGE,	self.Properties.AttackParams.sightrange);
	self:ChangeAIParameter(AIPARAM_FOV,		self.Properties.AttackParams.horizontal_fov);

end


----------------------------------------------------------------------------------------------------------------------------
--
--	breakable windows stuff
--
function VC:RemoveWindows( removeNow )

	if(not self.windows) then return end

	for i, theWindow in self.windows do
		local windowEnt = System:GetEntity( theWindow.entityId );
		if( windowEnt ) then
			self:Unbind( windowEnt );
			if( removeNow ) then
				Server:RemoveEntity( theWindow.entityId, 1);	-- remove NOW
			else
				Server:RemoveEntity( theWindow.entityId );	-- don't remove NOW
			end
			theWindow.entityId = 0;
		end
	end	
	
	self.windows_initialized = nil;
	
end	

----------------------------------------------------------------------------------------------------------------------------
--
--	breakable windows stuff
--
function VC:ResetWindows()
	if(not self.windows) then return end

	for i, theWindow in self.windows do
		local windowEnt = System:GetEntity( theWindow.entityId );
		if( windowEnt ) then
			windowEnt:OnReset();
		end
	end	
	
end	
	
----------------------------------------------------------------------------------------------------------------------------
--
--	breakable windows stuff
--
function VC:InitWindows( )

	--[Kirill] use windows only in SP game
	if(Game:IsMultiplayer()) then return end

	if(not self.windows) then return end
	
	if (self.windows_initialized) then
		VC.ResetWindows(self);
		do return end;
	end

	--VC.RemoveWindows(self, 1);
	
	self.windows_initialized = 1;
	
	-- Make private copy of windows table.
	self.windows = new(self.windows);

	for i, theWindow in self.windows do
		
		local wndEntity = Server:SpawnEntity("BreakableObject");
		if( not wndEntity ) then
			--System:Log( "\001 Can't spawn CAR Window " );
			do return end;
		end	
		wndEntity.Properties.object_Model = theWindow.fileName;
		wndEntity.bBreakByCar = 0;
		wndEntity.Properties.nDamage=500;
		wndEntity.Properties.fBreakImpuls=10;
		wndEntity.Properties.DyingSound.sndFilename="SOUNDS\Bullethits\bglass2.wav";
		wndEntity:OnReset();
		self:Bind( wndEntity );
		local wndPos = self:GetHelperPos(theWindow.helperName,1);
		wndEntity:SetPos(wndPos);
		wndEntity:EnableSave(0);		
		theWindow.entityId = wndEntity.id;
	end
end

----------------------------------------------------------------------------------------------------------------------------
--
--	see if the player can be a driver
-- local player can not drive the car if the car has bLockUser flag - those cars 
function VC:AllowedToDrive( player )

	if( (not self.Properties.bLockUser) or self.Properties.bLockUser==0 or player ~= _localplayer) then
		return 1
	end
	
	return nil;	
end

-----------------------------------------------------------------------------------------------------
function VC:InitAutoWeapon( )

	self:LoadCharacter(self.fileGunModel, 0);
	self:ResetAnimation( 0 );
--	self:DrawCharacter(0,1); -- Show Character.

end
--NEW MUZZLE FLASH ATTACHMENT SYSTEM //for vehicles weapons	----------------------------------------------------------------------------------------------------------------------------------	
-- MuzzleFlashTimer turn off timer callback.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
MuzzleFlashTurnoffCallbackVC =
{
	OnEvent = function( self,event,Params )
		VC.ShowMuzzleFlash( Params.shooter,Params,0 );
	end
}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
function VC:ShowMuzzleFlash( MuzzleFlashParams,bEnable )
	
	if (self == nil) then
		return;
	end

	local geomName = "Objects\\Weapons\\MUZZLEFLASH\\muzzleflash.cgf";
	local boneName;
	local lifetime = 10;

	boneName = "spitfire";
	
	if (MuzzleFlashParams.MuzzleFlash.geometry_name) then
		geomName = MuzzleFlashParams.MuzzleFlash.geometry_name;
	end
	
	-- Life time must be in seconds.
	if (MuzzleFlashParams.MuzzleFlash.lifetime) then
		lifetime = MuzzleFlashParams.MuzzleFlash.lifetime * 1000;
	end
	if (MuzzleFlashParams.MuzzleFlash.bone_name) then
		boneName = MuzzleFlashParams.MuzzleFlash.bone_name;
	end
	
	MuzzleFlashParams.shooter = self;
	local rnd=random(1,2);
	if (bEnable == 1) then
		self:LoadObject( geomName,15,1 );
		self:AttachObjectToBone( 15, boneName,1 );
	else
		MuzzleFlashParams.shooter:DetachObjectToBone( boneName );
	end
	
	if (bEnable == 1) then
		-- This will result in a call to BasicWeapon.Client:TimerEvent
		Game:SetTimer( MuzzleFlashTurnoffCallbackVC,lifetime,MuzzleFlashParams );
	end
end

-------------------^end^-------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------------------------------------------------
--
----------------------------------------------------------------------------------------------------------------------------
--
function VC:InitPieces()

	--[Kirill] use pieces only in SP game
	if(Game:IsMultiplayer()) then return end

	VC.ResetPieces(self);
	
	--no model filename where to get pieces, return.
	if (self.fileModelPieces==nil) then return end
	
	-- If pieces already initialized. do not do it again.
	if (self.piecesId) then return end;
	
	local	loaded=1;
	self.piecesId={};
	local idx = 1;
	while loaded==1 do
		local piece=Server:SpawnEntity("Piece");
	--			local piece=nil;
		if(piece)then
--System:Log( "\001 loading Piece #"..idx );					
			self.piecesId[idx] = piece.id;
			loaded = piece.Load(piece,self.fileModelPieces, idx );
			idx = idx + 1;
		else
			break
		end
	end
	
	if(self.piecesId[idx-1]) then
		Server:RemoveEntity( self.piecesId[idx-1], 1 );
		self.piecesId[idx-1] = nil;
	end	
end



--------------------------------------------------------------------------------------------------------------
function VC:ResetPieces()

	if(not self.piecesId)then return end
	for idx,pieceId in self.piecesId do
		local pieceEnt = System:GetEntity( pieceId );
		if (pieceEnt and pieceEnt.Deactivate) then
			pieceEnt:Deactivate();
		end	
	end
end

--------------------------------------------------------------------------------------------------------------
function VC:RemovePieces()

	if(not self.piecesId)then return end
	for idx,pieceId in self.piecesId do
		Server:RemoveEntity( pieceId );
		pieceId = 0;
--		self.pieces[idx] = nil;
	end
	self.piecesId = {};
end

--------------------------------------------------------------------------------------------------------------
function VC:BreakOnPieces()
		
	if(self.IsBroken == 1) then return end
	self.IsBroken = 1;

	--System:Log("\001  VC:BreakPisece ");

	local pos=self:GetPos();
	local angle=self:GetAngles();
	local impDir = new(self:GetVelocity());
	--	impDir.x = -impDir.x;
	--	impDir.y = -impDir.y;
	--	impDir.z = -impDir.z;
	--local fSpeedScale = self.cnt:GetVehicleVelocity()*100;
		
	--filippo: velocity table , used in SetPhysicParams	
	impDir.z = impDir.z + random(100,500)*0.01;
		
	local veltable={v=impDir,w={0,0,0}};
	
	--System:Log( "\001 DoPiece ");	

	self:DetachObjectToBone( "spitfire" );	

	for idx,pieceId in self.piecesId do
		--System:Log( "\001 Piece #"..idx );
		local pieceEnt = System:GetEntity( pieceId );
		
		if( pieceEnt ) then
			--filippo
			pieceEnt:SetPhysicParams(PHYSICPARAM_VELOCITY, veltable );
						
			--pieceEnt:DrawObject(0,1); --already called in piece::activate		
			pieceEnt:EnablePhysics(1); --already called in piece::activate , but I dont figure why it must be called also here
			
			pieceEnt:SetPos( pos );
			pieceEnt:SetAngles( angle );		
	
			--filippo:addimpulse is replaced by SetPhysicParams few row above here
			--pieceEnt:AddImpulseObj( impDir, fSpeedScale);
			
			pieceEnt:SwitchLight(0);	-- switch off attached lights
			pieceEnt:Activate();
		end			
	end
	self:TriggerEvent(AIEVENT_AGENTDIED);	
	AI:RegisterWithAI(self.id,0);	
	self:Hide(1);
end


--------------------------------------------------------------------------------------------------------------
function VC:BreakWrack()

	if( self.IsBroken == 1) then return end
	self.IsBroken = 1;

--	System:Log("WRACK ISBROKEN");
	if(self.IsPhisicalized == 0) then return end

local	pos=self:GetPos();
local	angle=self:GetAngles();
local impDir = self:GetVelocity();
--	impDir.x = -impDir.x;
--	impDir.y = -impDir.y;
--	impDir.z = -impDir.z;
local fSpeedScale = self.cnt:GetVehicleVelocity()*100;

	self:DetachObjectToBone( "spitfire" );

	-- hide all the geometry
	self:DrawObject(-1,0);
	-- hide the weapon
	self:DrawCharacter(0,0);

	self:DrawObject(14,1);

--	System:Log("WRACK CREATERIGIDBODY");
	self:CreateRigidBody( 1, 0, 0, impDir, 14);

	-- if this is a car - wrack has to drown in water	
	if(self.IsCar) then
		VC.SimParams.density = 290;
		VC.SimParams.water_density = 200;
	else 	
		VC.SimParams.density = 200;
		VC.SimParams.water_density = 290;
	end	
	
	self:SetPhysicParams(PHYSICPARAM_SIMULATION, VC.SimParams);
	self:SetPhysicParams(PHYSICPARAM_BUOYANCY, VC.SimParams);

	self.IsPhisicalized = 0;
	self:TriggerEvent(AIEVENT_AGENTDIED);
	AI:RegisterWithAI(self.id,0);	
end


--------------------------------------------------------------------------------------------------------------
function VC:VehicleAmmoEnter( shooter )

	--System:Log("\001 VC:VehicleAmmoEnter >>>>>  "..shooter:GetName());

	if(not self.Ammo) then return end
		
	for name, amount in self.Ammo do	
		--System:Log("\001 >>>>>  "..name.." "..amount);
		BasicPlayer.AddAmmo(shooter, name, amount);
		self.Ammo[name] = 0;
	end
end


--------------------------------------------------------------------------------------------------------------
function VC:VehicleAmmoLeave( shooter )

	if(not self.Ammo) then return end

	--System:Log("\001 VC:VehicleAmmoLeave <<<<<  "..shooter:GetName());
	for name, amount in self.Ammo do
		local playerAmount = BasicPlayer.GetAmmoAmount(shooter, name);
		--System:Log("\001 <<<<<  "..name.." "..playerAmount);		
		BasicPlayer.AddAmmo(shooter, name, -playerAmount);
		self.Ammo[name] = playerAmount;
	end
end

--------------------------------------------------------------------------------------------------------------
function VC:SaveTable( tbl, stm )

	if(tbl and tbl.entity ) then
--		if(self.driverT.entity == _localplayer) then
--			stm:WriteInt(65535);
--		else
			stm:WriteInt(tbl.entity.id);
--		end
		if(tbl.state)then
			stm:WriteInt(tbl.state+1);
		else
			stm:WriteInt( 0 );
		end
	else	
		stm:WriteInt( 0 );
		stm:WriteInt( 0 );
	end
end

--------------------------------------------------------------------------------------------------------------
function VC:LoadTable( func, table, stm )

	local userId=0;
	local state=0;
	-- reading driver
	userId = stm:ReadInt();
	state = stm:ReadInt();
	if( table == nil ) then return end
	if(userId ~= 0) then
		if(state == 1) then 
			func(self, System:GetEntity( userId ));
		elseif(state == 5) then		-- leaving animation
--System:Log( "VC:LoadTable LEAVING THE VEHICLE ");
			table.state = 9;
			local thePlayer = System:GetEntity( userId );
			thePlayer.leaveTheVehicle = 1;
		elseif(state == 2) then		-- entering animation
--System:Log( "VC:LoadTable ENTREING THE VEHICLE");			
			table.state = state - 1;
			table.time = -1;
			VC.UpdateEnteringUser( self, 1, table );
			AI:Signal(0, 1, "DRIVER_IN",self.id);
		end	
	end
end

--------------------------------------------------------------------------------------------------------------
function VC:SaveCommon( stm )
--System:Log("VC:SaveCommon >>  "..self:GetName());
	-- save pathpoints
	stm:WriteInt(self.step);
	-- save driver	
	VC.SaveTable( self, self.driverT, stm );
	
	-- save gunner
	VC.SaveTable( self, self.gunnerT, stm );

	if(self.passengerLimit==0) then return end
	-- save passangers
	for idx=1, self.passengerLimit do
		VC.SaveTable( self, self.passengersTT[idx], stm );
	end
end

--------------------------------------------------------------------------------------------------------------
function VC:LoadCommon( stm )
--System:Log("VC:LoadCommon >>  "..self:GetName());
	-- load pathpoints
	self.step = stm:ReadInt(  );
	
	local userId=0;
	local state=0;
	-- reading driver
	VC.LoadTable( self, self.AddDriver, self.driverT, stm );
	-- reading gunner
	VC.LoadTable( self, self.AddGunner, self.gunnerT, stm );
	
	if(self.passengerLimit==0) then return end
	-- load passangers
	for idx=1, self.passengerLimit do
		VC.LoadTable( self, self.AddPassenger, self.passengersTT[idx], stm );
	end
end

--------------------------------------------------------------------------------------------------------------
function VC:SaveAmmo( stm )
	stm:WriteInt(self.Ammo["VehicleMG"]);
	stm:WriteInt(self.Ammo["VehicleRocket"]);
end

--------------------------------------------------------------------------------------------------------------
function VC:LoadAmmo( stm )

	if(not self.Ammo)then
		self.Ammo = {};			
	end
	self.Ammo["VehicleMG"] = stm:ReadInt();
	self.Ammo["VehicleRocket"] = stm:ReadInt();
end

--------------------------------------------------------------------------------------------------------------
-- check if user can get out of the vehicle or if there is some geometry around
function VC:CanGetOut( tbl )

	--first time create the exitPos vector, other times just reset it to 0
	if (tbl.exitPos==nil) then
		tbl.exitPos = {x=0,y=0,z=0};
	else
		tbl.exitPos.x = 0;
		tbl.exitPos.y = 0;
		tbl.exitPos.z = 0;
	end
	-- AI's always can get out of vehicle
	if( tbl.entity.ai ) then return 1 end
	
	local safePos = VC.temp_v1;
	
	CopyVector(safePos,self:GetHelperPos(tbl.helper));

--	local safePos=BasicPlayer.CanStandPos( tbl.entity, pos );
--	
--	if( not safePos ) then
--		pos = self:GetHelperPos(tbl.in_helper);
--		pos.z = pos.z+1;
--		safePos=BasicPlayer.CanStandPos( tbl.entity, pos );
--		tbl.exitUp = 1;
--		if( not safePos ) then
--			return nil;
--		end
--	end

	local saveZ = safePos.z;

	--special case for the paraglider, we dont want the exit position above the paraglider, so use a tbl.exitpos to specify the exact exit position.
	if (self.bParaglider) then
		
		safePos.z = saveZ - 2.0;
		
		if (VC.CanGetThere( self, tbl.entity, safePos,nil,1 )) then
			safePos.z = saveZ - 0.5;
			CopyVector(tbl.exitPos,safePos);
			return 1;
		end
	end
	
	safePos.z = saveZ;
	
	safePos.z = safePos.z + .5;
		
	--return VC.CanGetThere( self, tbl.entity, safePos );
	
	--cant exit from the standard position? try on top,left,right,forward and back.
	if (not VC.CanGetThere( self, tbl.entity, safePos,nil,2 )) then
		
		local bbox = self:GetLocalBBox(nil,nil);
		local max = bbox.max;
		
		--Hud:AddMessage("fwd:"..max.y..",right:"..max.x..",up:"..max.z);
		
		--check up------------------
		CopyVector(safePos,self:GetHelperPos(tbl.in_helper));
		local testdir = self:GetDirectionVector(2);
		
		local offsetamt = max.z;
		
		safePos.x = safePos.x + testdir.x*offsetamt;
		safePos.y = safePos.y + testdir.y*offsetamt;
		safePos.z = safePos.z + testdir.z*offsetamt;
		
		if (VC.CanGetThere( self, tbl.entity, safePos,nil,1 )) then
			CopyVector(tbl.exitPos,safePos);
			--Hud:AddMessage("up");
			--tbl.exitPos = new(safePos); 	
			return 1;
		end
		
		--check right------------------
		CopyVector(safePos,self:GetPos());
		testdir = self:GetDirectionVector(1);
		
		offsetamt = max.x+0.75;
		
		safePos.x = safePos.x - testdir.x*offsetamt;
		safePos.y = safePos.y - testdir.y*offsetamt;
		safePos.z = safePos.z - testdir.z*offsetamt;
		
		if (VC.CanGetThere( self, tbl.entity, safePos,nil,1 )) then
			CopyVector(tbl.exitPos,safePos);
			--Hud:AddMessage("right");
			return 1;
		end
		
		--check left------------------
		CopyVector(safePos,self:GetPos());
			
		safePos.x = safePos.x + testdir.x*offsetamt;
		safePos.y = safePos.y + testdir.y*offsetamt;
		safePos.z = safePos.z + testdir.z*offsetamt;
		
		if (VC.CanGetThere( self, tbl.entity, safePos,nil,1 )) then
			CopyVector(tbl.exitPos,safePos);
			--Hud:AddMessage("left");
			return 1;
		end
		
		--check forward------------------
		CopyVector(safePos,self:GetPos());
		testdir = self:GetDirectionVector(0);
		
		offsetamt = max.y+0.75;
		
		safePos.x = safePos.x - testdir.x*offsetamt;
		safePos.y = safePos.y - testdir.y*offsetamt;
		safePos.z = safePos.z - testdir.z*offsetamt;
		
		if (VC.CanGetThere( self, tbl.entity, safePos,nil,1 )) then
			CopyVector(tbl.exitPos,safePos);
			--Hud:AddMessage("forward");
			return 1;
		end
		
		--check back------------------
		CopyVector(safePos,self:GetPos());
			
		safePos.x = safePos.x + testdir.x*offsetamt;
		safePos.y = safePos.y + testdir.y*offsetamt;
		safePos.z = safePos.z + testdir.z*offsetamt;
		
		if (VC.CanGetThere( self, tbl.entity, safePos,nil,1 )) then
			CopyVector(tbl.exitPos,safePos);
			--Hud:AddMessage("back");
			return 1;
		end
	else
		--Hud:AddMessage("helper");
		return 1;
	end
	
	return nil;
	
--	if(not System:RayTraceCheck( tbl.entity:GetPos(), safePos, self.id, tbl.entity.id )) then
--		return nil;
--	end	
--	return 1;
end

--------------------------------------------------------------------------------------------------------------
-- check if user can get to dest - wothout intersection anything
function VC:CanGetThere( player, dest, offsetZ ,offsetZ2 )

	local src=player:GetPos();

	if (offsetZ) then
		src.z = src.z+offsetZ;
	end	
	
	local saveZ = dest.z;
	
	if (offsetZ2) then
		dest.z = dest.z+offsetZ2;
	end	
	
	if(System:RayTraceCheck( src, dest, self.id, player.id )) then
		
		dest.z = saveZ;
		return 1;
	end
	
	dest.z = saveZ;
		
	return nil;
end



----------------------------------------------------------------------------------------------------------------------------
--removed due to new (and more clean) use of "AICarDef" table.
--function VC:ReadOverrideParams()
--		
--	do return; end
--			
--	if (self==nil) then
--		return;
--	end
--			
--	self.CarDef.steer_relaxation_v0 = self.Properties.OverrideParams.fSteer_relax;
--	self.CarDef.steer_relaxation_kv = self.Properties.OverrideParams.fSteer_relax;
--	
--	self.CarDef.max_steer_v0 = self.Properties.OverrideParams.fSteer_range;
--		
--	self.CarDef.steer_speed = self.Properties.OverrideParams.fSteer_speed;
--	
--	self.CarDef.max_braking_friction = self.Properties.OverrideParams.fBraking_friction;
--		
--	self.CarDef.handbraking_value = self.Properties.OverrideParams.fBraking_ammount;
--	
--	self.CarDef.wheel1.min_friction = self.Properties.OverrideParams.fWheel_frict_min;
--	self.CarDef.wheel2.min_friction = self.Properties.OverrideParams.fWheel_frict_min;
--	self.CarDef.wheel3.min_friction = self.Properties.OverrideParams.fWheel_frict_min;
--	self.CarDef.wheel4.min_friction = self.Properties.OverrideParams.fWheel_frict_min;
--	
--	self.CarDef.wheel1.max_friction = self.Properties.OverrideParams.fWheel_frict_max;
--	self.CarDef.wheel2.max_friction = self.Properties.OverrideParams.fWheel_frict_max;
--	self.CarDef.wheel3.max_friction = self.Properties.OverrideParams.fWheel_frict_max;
--	self.CarDef.wheel4.max_friction = self.Properties.OverrideParams.fWheel_frict_max;
--end

function VC:VehicleOnGround()

	if (self.IsCar) then
		
		local vstatus = self.cnt:GetVehicleStatus();
		if (vstatus.wheelcontact==0) then return nil; end
		
	elseif (self.IsBoat) then
		
		if (self.cnt.inwater~=1) then return nil; end
	end
	
	return 1;
end

function VC:UpdateFallDamage(dt)

	local falldmg = self.fOnFallDamage;
	
	if (falldmg==nil or (falldmg~=nil and falldmg<=0)) then
		return;
	end

	local vstatus = self.cnt:GetVehicleStatus();

	if (self.lastairzvel==nil) then self.lastairzvel = 0; end
	
	local tempzvel = self.lastairzvel;

	if (vstatus.wheelcontact==0) then
		tempzvel=self:GetVelocity().z;
		--Hud:AddMessage(tempzvel);
	elseif (tempzvel<-3) then
		
		local fDamage = falldmg*tempzvel*tempzvel*0.5;
		
		local	hitDmg = {
			damage = fDamage,
			damage_type="collision",
			};
			
		VC.OnDamageServer(self, hitDmg);
		
		tempzvel = 0;
	end
	
	self.lastairzvel = tempzvel;
end

function VC:ChangeVehicleParams(newparams)
		
	if ((self.IsPhisicalized == 1)) then
				
		if (newparams == nil) then
			return;
		end

		--dont waste time in changing params if them are the same as last time.
		if (self.LastActiveParams == newparams) then
			return;
		end	
				
		local carNewParams = nil;
		
		--if we are using the carDef table dont duplicate and merge it.
		if (newparams == self.CarDef) then
			carNewParams = self.CarDef;
			--System:Log("using cardef");
		else
			carNewParams = new(self.CarDef);
			merge(carNewParams,newparams,1);
			--System:Log("using new params, merging");
		end
							
		self:SetPhysicParams(PHYSICPARAM_VEHICLE, carNewParams);
		self.cnt:SetDrivingParameters( carNewParams );
		
		System:Log("params changed");
		
		self.LastActiveParams = newparams;
	end
end

function VC:PlayDynDrivingSounds(fCarSpeed,dt)

	local vstatus = self.cnt:GetVehicleStatus();
	local wheelcontact = vstatus.wheelcontact;
					
	if (self.bDriverInTheVehicle==1) then								
				
		if (wheelcontact==0) then
			VC.StopDriveSound(self);
		else
			VC.PlayDriveSound(self,fCarSpeed,dt,6);
		end
					
		local vgear=vstatus.gear+1;
									
		if (self.currgear~=vgear and self.nextgearchange<_time and fCarSpeed>5 and wheelcontact~=0) then
			
			self.nextgearchange = _time + 1.5;
														
--			System:Log("changing from gear:"..self.currgear.." to gear:"..vgear);		
			
			if (self.clutchengine_frequencies and self.clutchengine_frequencies[vgear+1]) then
				self.clutchfreqgoal = self.clutchengine_frequencies[vgear+1];
			else
				self.clutchfreqgoal = 1000;
			end
			
			--System:Log(self.clutchfreqgoal);
													
			self:PlaySound(self.clutch_sound);
																		
			self.currgear=vgear;	
		end
		
		if (Sound:IsPlaying(self.lastidlesound)~=1 and Sound:IsPlaying(self.engine_start)~=1) then
				
			if (self.lastidlesound~=nil) then Sound:StopSound(self.lastidlesound); end
							
			self.lastidlesound = self.idleengine;
			Sound:SetSoundLoop(self.lastidlesound, 1); 					
			self:PlaySound(self.lastidlesound);
				
		elseif (self.lastidlesound~=nil) then
					
			local idleengine_ratios = self.idleengine_ratios;
							
			if (idleengine_ratios and idleengine_ratios[self.currgear+1]) then
				self.enginefreqgoal = (vstatus.engineRPM/100)*idleengine_ratios[self.currgear+1];
			else
				self.enginefreqgoal = vstatus.engineRPM/100;
			end
			
			--if flying use a higher engine frequency
			if (wheelcontact==0) then
				self.enginefreqgoal = self.enginefreqgoal + 350.0/(1.0+self.timeinair);
			end
				
			if (self.enginefreqgoal<350) then self.enginefreqgoal = 350; end
	
			---------------
			--update engine sound frequency.			
			local freqclutchdelta = self.clutchfreqgoal - self.clutchfreq;
	
			if (abs(freqclutchdelta)>1) then
				self.clutchfreq = self.clutchfreq + freqclutchdelta * dt * self.clutchfreqspeed;
			else
				self.clutchfreq = 0;
				self.clutchfreqgoal = 0;
			end
	
			local freqdelta = self.enginefreqgoal+self.clutchfreq - self.enginefreq;
			
			self.enginefreq = self.enginefreq + freqdelta * dt * self.enginefreqspeed;
	
			if (self.enginefreq<350) then self.enginefreq = 350; end	
			if (self.enginefreq>1350) then self.enginefreq = 1350; end	
			---------------		
				
			--change freq cap, like the boats.
			if (self.lastfreqtime < _time) then
				--System:Log(650+self.enginefreq);	
				Sound:SetSoundFrequency( self.lastidlesound, 650 + self.enginefreq);
				self.lastfreqtime = _time + 0.04;
			end
		end	
	else 		
		VC.StopDrivingSounds(self);
	end

	local break_sound = self.break_sound;

	-- breaking sounds
	if (break_sound~=nil) then
		if (self.cnt:IsBreaking() == 1 and fCarSpeed > 10 and wheelcontact~=0) then
			if (Sound:IsPlaying(break_sound) ~= 1) then
				--Sound:SetSoundLoop(self.break_sound, 1);
				Sound:SetSoundVolume(break_sound,fCarSpeed*10);	-- set break sound volume depending on speed
				self:PlaySound(break_sound);
			end
		else
			Sound:StopSound(break_sound);
		end
	end
						
	if (wheelcontact==0) then --flying?		
		--play some engine boost sound once leave the ground
		if (self.VehicleInAir==0) then
			self.clutchfreqgoal = 500;
		end
		
		self.VehicleInAir = 1;
		self.timeinair = self.timeinair + dt;
	else
		local land_sound = self.land_sound;
		--flying/land sounds			
		if (land_sound and self.VehicleInAir~=0 and self.timeinair>0.5) then--landed right now?
			--make land sound volume based on speed
			Sound:SetSoundVolume(land_sound,max(70,fCarSpeed*15));
			self:PlaySound(land_sound);
		end
			
		self.VehicleInAir = 0;
		self.timeinair = 0;
	end
end

function VC:PlayMiscSounds(fCarSpeed,dt)

	if (self.IsBoat) then
		
		if( self.cnt.inwater~=1 ) then 
			self.VehicleInAir = 1;
			self.timeinair = self.timeinair + dt;
		else
			local land_sound = self.land_sound;
			--landed from a jump? play splash/land sound.
			if (land_sound and self.VehicleInAir==1 and self.timeinair>0.5) then
				--make land sound volume based on speed
				Sound:SetSoundVolume(land_sound,max(70,fCarSpeed*15));
				self:PlaySound(land_sound);
			end
		
			self.VehicleInAir = 0;	
			self.timeinair = 0;
		end
	end
	
	if (self.light_sound) then
	
		local vstatus = self.cnt:GetVehicleStatus();
	
		if (self.VehicleLights ~= vstatus.headlights) then
		
			self.VehicleLights = vstatus.headlights;		
			self:PlaySound(self.light_sound);
		end
	end
end

--this function compare the distance between the player and the 2 vehicles in race to be used by him.
function VC:CandidateVehicle(competitor,player)
	
	if (competitor==nil) then return 1; end
	
	if (competitor.IsBoat==nil and competitor.IsCar==nil) then return 1; end
	
	if (competitor~=self) then 
		
--		local v1 = VC.temp_v1;--player forward vec
		local v2 = VC.temp_v2;--player - self
		local v3 = VC.temp_v3;--player - lasttouchedvehicle
		
		local v4 = VC.temp_v4;--player pos
		local v5 = VC.temp_v5;--self pos
		local v6 = VC.temp_v6;--lasttouchedvehicle pos
			
		merge(v4,player:GetPos());
		merge(v5,self:GetPos());
		merge(v6,competitor:GetPos());
		
--		v4 = player:GetPos();
--		v5 = self:GetPos());
--		v6 = competitor:GetPos();
		
--		v1 = player:GetDirectionVector();
		FastDifferenceVectors(v2,v4,v5);
		FastDifferenceVectors(v3,v4,v6);
			
--		NormalizeVector(v2);
--		NormalizeVector(v3);
		
--		local dot_player_self = dotproduct3d(v1,v2);
--		local dot_player_competitor = dotproduct3d(v1,v3);

		local dist_player_self = LengthSqVector(v2);
		local dist_player_competitor = LengthSqVector(v3);
				
--		Hud:AddMessage(sprintf("%s: %.1f, %s: %.1f",self:GetName(),dot_player_self,competitor:GetName(),dist_player_competitor));
		
--		if (dot_player_self>dist_player_competitor) then return nil; end
		if (dist_player_competitor<dist_player_self) then return nil; end
	end
		
	return 1;	
end

function VC:BoatInWater()
	--TODO:check also bbox to see if is most over water, this would be more precise.	
	if (self.cnt.inwater==1) then return 1; end
	--if (Game:IsPointInWater(self:GetPos())~=nil and self.cnt.inwater==1) then return 1; end
	
	return nil;
end

function VC:VehicleUsable()
	--is a boat and not in water? not usable
	if (self.IsBoat and not VC.BoatInWater(self)) then return nil; end
		
	return 1;
end

--canbepushed can return 3 kind of values:
--	- nil if the entity cant be pushed
--	- -1 or 0 if the push force to be used is the player standard
--	- a different value means a custom push force
function VC:CanBePushed()
	--destroyed? not physicalized? return
	if (self.IsPhisicalized==0 or self.bExploded==1) then return nil; end
	
	--isnt a boat? cant push, return
	if (self.IsBoat==nil) then return nil; end
	
	--the boat is in water, no need to push
	if (VC.BoatInWater(self)) then return nil; end
		
	if (self.pushpower) then 
		return self.pushpower;
	else
		return 400;
	end
end


--------------------------------------------------------------------------------------------------------------

function VC:DeactivateLayers()

	ClientStuff.vlayers:DeactivateLayer("WeaponScope",1);
	ClientStuff.vlayers:DeactivateLayer("MoTrack",1);	
	ClientStuff.vlayers:DeactivateLayer("Binoculars",1);	

--	ClientStuff.vlayers:DeactivateAll();

end



--------------------------------------------------------------------------------------------------------------

