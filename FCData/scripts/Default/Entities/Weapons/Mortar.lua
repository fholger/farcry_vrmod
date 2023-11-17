Game:CreateHapticsEffectFlat("mortar_fire", 0.4, 0.4, 0, 0.2);

Mortar = {
	name = "Mortar",

	fireCanceled = 0,
	
	PlayerSlowDown = 0.35,									-- factor to slow down the player when he holds that weapon
	---------------------------------------------------
	ActivateSound = Sound:Load3DSound("Sounds/Weapons/Mortar/mortarweapact.wav"),	-- sound to play when this weapon is selected
	---------------------------------------------------
	ZoomActive = 0,												-- initially always 0
	MaxZoomSteps = 1,
	ZoomSteps = { 10 },
	ZoomForceCrosshair = 1,
	
	FireParams ={													-- describes all supported firemodes
		{
			HasCrosshair=1,
			AmmoType="Unlimited",
			min_recoil=0,
			max_recoil=0,
			no_ammo=1,		
			projectile_class="MortarShell",
			reload_time= 2.0,
			fire_rate= 0.01,
			bullet_per_shot=1,
			bullets_per_clip=1,
			FModeActivationTime = 2.0,
			fire_activation=bor(FireActivation_OnPress,FireActivation_OnRelease),
			FireOnRelease = 1,
			
			FireSounds = {
				"Sounds/Weapons/Mortar/mortarfire1.WAV",
			},
			DrySound = "Sounds/Weapons/Mortar/DryFire.wav",
			HapticFireEffect = "mortar_fire",
			ProtubeKickPower = 1.0,
			ProtubeRumblePower = 0.8,
			ProtubeRumbleSeconds = 1.0,
			
			LightFlash = {
				fRadius = 5.0,
				vDiffRGBA = { r = 1.0, g = 1.0, b = 0.0, a = 1.0, },
				vSpecRGBA = { r = 0.3, g = 0.3, b = 0.3, a = 1.0, },
				fLifeTime = 0.75,
			},
	
			SoundMinMaxVol = { 255, 15, 100000 },
		},
	},
	
	-- remove this if not nedded for current weapon
	MuzzleFlash = {
		geometry_name = "Objects/Weapons/Muzzle_flash/mf_m4_fpv.cgf",
		bone_name = "spitfire",
		lifetime = 0.15,
	},
	MuzzleFlashTPV = {
		geometry_name = "Objects/Weapons/Muzzle_flash/mf_m4_tpv.cgf",
		bone_name = "spitfire",
		lifetime = 0.05,
	},

		SoundEvents={
		--	animname,	frame,	soundfile												---
		{	"reload1",	33,			Sound:LoadSound("Sounds/Weapons/mortar/mortar_33.wav")},
		{	"reload1",	46,			Sound:LoadSound("Sounds/Weapons/mortar/mortar_46.wav")},
		
	},

	TargetHelperImage = System:LoadImage("Textures/Hud/crosshair/g36.tga"),
	NoTargetImage = System:LoadImage("Textures/Hud/crosshair/noTarget.dds"),	
	temp_ang={x=0,y=0,z=0},
	temp_pos={x=0,y=0,z=0},
}

function ClampAngle(a)
	if(a.x>180)then a.x=a.x-360;
	elseif(a.x<-180)then a.x=a.x+360; end

	if(a.y>180)then a.y=a.y-360;
	elseif(a.y<-180)then a.y=a.y+360; end

	if(a.z>180)then a.z=a.z-360;
	elseif(a.z<-180)then a.z=a.z+360; end
end

CreateBasicWeapon(Mortar);

function Mortar.Client:OnEvent(EventId, Params)
	if (EventId == ScriptEvent_Fire) then
		if (Params.fire_event_type == FireActivation_OnPress) then
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
				self.vTargetSpot = new(TargetDescTable.pos);
				-- System.LogToConsole("OnEvent --> x:"..TargetDescTable.pos.x.." y:"..TargetDescTable.pos.y.." z:"..TargetDescTable.pos.z);
			else
				self.vTargetSpot=nil;
			end
			--return beacuse basic weapon shouldn't play any effects
			return
		elseif (Params.fire_event_type == FireActivation_OnRelease) then
			--System:Log("Client Release");
			self.clientrelease = 1;
			-- Player releasing the button, unmark the target
			self.vTargetSpot=nil;
			self.fireCanceled = 0;
		end
	elseif (EventId == ScriptEvent_FireCancel) then
		-- Player canceled fire, unmark the target
		self.vTargetSpot=nil;
		self.fireCanceled = 1;
		self.beginclientfire = nil;
		self.clientrelease = 0;
		return
	end
	if( self.fireCanceled == 1 or self.clientrelease ~= 1 or self.beginclientfire == 0)then	-- don't fire
		do return nil end;
	end	
	
	self.beginclientfire = 0;
	return BasicWeapon.Client.OnEvent(self, EventId, Params);
end

function Mortar.Client:OnEnhanceHUD()
	if (self.vTargetSpot) then
		
		local ppos=self.temp_pos;
		local vAngles = self.temp_ang;
		
		_localplayer.cnt:GetFirePosAngles(ppos,vAngles);
		ClampAngle(vAngles);
		local vDiff=DifferenceVectors(self.vTargetSpot, ppos);
		local fDistY = vDiff.z;
		vDiff.z=0;
		local fDistX=abs(sqrt(LengthSqVector(vDiff)));
		
		--System:Log("fireang ,"..vAngles.x..","..vAngles.y..","..vAngles.z.."## firePos ,"..ppos.x..","..ppos.y..","..ppos.z);
		local iTargetAngle = self.cnt:GetProjectileFiringAngle(140.0, 4*9.8, fDistX, fDistY);
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
		
		if(iTargetAngle==0)then
			System:DrawImageColor(self.NoTargetImage, 400 - 15, 300 - 15, 30, 30, 4, 1, 0, 0, 1);
--printf(" NO TARGET ");
--				self.cnt:SetWeaponCrosshair( "Textures/Hud/crosshair/sniper.tga", 0);						
		else
			System:DrawImageColor(self.TargetHelperImage, 400 - 15, iHeight - 15, 30, 30, 4, 1, 0, 0, 1);
			Game:WriteHudString(425,280,"trg="..sprintf("%0.2f",iTargetAngle),0.7,0.7,0.7,1,15,15);
			Game:WriteHudString(425,300,"ply="..sprintf("%0.2f",-vAngles.x),0.7,0.7,0.7,1,15,15);
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
					
					iTargetAngle = self.cnt:GetProjectileFiringAngle(140.0, 4*9.8, fDistX, fDistY);
				end

			if(iTargetAngle==0)then
				System:DrawImageColor(self.NoTargetImage, 400 - 15, 300 - 15, 30, 30, 4, 1, 0, 0, 1);
			end
		end			
	end
	
	BasicWeapon.Client.OnEnhanceHUD(self);
end

function Mortar.Server:OnEvent(EventId, Params)
	if (EventId == ScriptEvent_Fire) then
		--System:Log("Server FIRE");
		if (Params.fire_event_type == FireActivation_OnPress) then
			--System:Log("Server PRESS");
			self.beginfire = 1;
		end
		if (Params.fire_event_type == FireActivation_OnRelease and self.beginfire == 1) then
			--System:Log("Server RELEASE");
			self.beginfire = 0;
			self.fireCanceled = 0;
		else return end
	elseif (EventId == ScriptEvent_FireCancel) then
		-- Player canceled fire, 
		self.fireCanceled = 1;
		return
	end
	if( self.fireCanceled == 1 )then	-- don't fire
		self.beginfire = nil;
		do return nil end;
	end	
	--System:Log("Server ONEVENT");
	return BasicWeapon.Server.OnEvent(self, EventId, Params);
end

---------------------------------------------------------------
--ANIMTABLE
------------------
--SINGLE FIRE
Mortar.anim_table={}
Mortar.anim_table[1]={
	idle={
		"Idle11",
	},
	reload={
		"Reload1"	
	},
	fire={
		"Fire11",
		"Fire21",
	},
	activate={
		"Activate1"
	},
}