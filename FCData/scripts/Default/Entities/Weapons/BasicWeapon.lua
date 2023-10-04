
Script:LoadScript("scripts/default/hud/DefaultZoomHUD.lua");
Script:LoadScript("scripts/default/hud/AimModeZoomHUD.lua");
Game:CreateVariable("w_firstpersontrail","1")

BasicWeapon = {
	UnderwaterBubbles = {
		focus = 0.2,
		color = {1,1,1},
		speed = 0.25,
		count = 1,
		size = 0.05, size_speed=0.0, -- default size 0.2
		gravity = { x = 0.0, y = 0.0, z = 2.6 },
		lifetime=1.5, -- default 2.5
		tid = System:LoadTexture("textures\\bubble.tga"),
		frames=0,
		color_based_blending = 1,
		fPosRandomOffset=0,
		particle_type = 2, -- [marco] avoid these bubbles to fly out of the water surface (2=PART_FLAG_UNDERWATER)
	},
	TracerBubbles = {
		focus = 0.2,
		color = {1,1,1},
		speed = 0.25,
		count = 1,
		size = 0.02, size_speed=0.0, -- default size 0.2
		gravity = { x = 0.0, y = 0.0, z = 2.6 },
		lifetime=1.5, -- default 2.5
		tid = System:LoadTexture("textures\\bubble.tga"),
		frames=0,
		color_based_blending = 1,
		fPosRandomOffset=0,
		particle_type = 2, -- [marco] avoid these bubbles to fly out of the water surface (2=PART_FLAG_UNDERWATER)
	},
	DefaultFireParms = {
		shoot_underwater = 0,
		aim_recoil_modifier = 1.0,
		aim_improvement = 0.0,
		auto_aiming_dist = 0,
		
		ai_mode = 0,					-- specifies whether this firemode is exclusively used by AI (==1)
		allow_hold_breath = 0,-- specifies whether it is possible to use the hold breath feature in zoom mode
		sprint_penalty = 0.7,	-- default decrease in accuracy when sprinting
		
		accuracy_modifier_standing = 1.0,
		accuracy_modifier_crouch = 0.7,
		accuracy_modifier_prone = 0.5,
		
		recoil_modifier_standing = 1.0,
		recoil_modifier_crouch = 0.5,
		recoil_modifier_prone = 0.1,
	},
	--temp tables
	temp_dir={x=0,y=0,z=0},
	temp_exitdir={x=0,y=0,z=0},
	temp_pos={x=0,y=0,z=0},
	temp_angles={x=0,y=0,z=0},
	temp_hitpt={x=0,y=0,z=0},
	VoidDist = 1000,		-- trace distance if no hit
	blip=Sound:LoadSound("SOUNDS/hit.wav",0,128),
	fireModeChangeSound = Sound:LoadSound("SOUNDS/items/WEAPON_FIRE_MODE.wav", 0, 128),
	Client = {},
	Server = {},
	
	-- temp tables.
	temp = {
		rotate_vector = {x=0,y=0,z=0},
		light_info = {},
	},

	--vehicle crosshair - now it's always in the middle of screen	
	CrossHairPos={xS=400,yS=300},

	scopeFlareInfo={
		lightShader = "ScopeFlare",
		shooterid=nil,
		orad=5.0,
		areaonly=1,	
		coronaScale = 0,
	},
	
	--cantshoot_sprite: showed when you cant shot where you aiming at
	cantshoot_sprite=System:LoadImage("Textures/hud/crosshair/cantshoot.dds"),	
	
	--weapons particle fx
	Particletemp = {
			focus = 0.0,
			speed = 0.0,
			count = 1,
			size = 1.0, 
			size_speed=0.0,
			lifetime=1.0,
			tid = nil,
			rotation = { x = 0.0, y = 0.0, z = 0.0 },
			gravity = { x = 0.0, y = 0.0, z = 0.0 },
			frames=0,
			blend_type = 2,
			AirResistance = 0,
			start_color = {1.0,1.0,1.0},
			end_color = {1.0,1.0,1.0},
			bLinearSizeSpeed = 1,
			--fadeintime = 1.0;
		},
		
	temp_v1 = {x=0,y=0,z=0},
	temp_v2 = {x=0,y=0,z=0},
	vcolor1 = {1.0,1.0,1.0},
};
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon:SyncVarCache(shooter)
	shooter.firemodenum=shooter.cnt.firemode+1;
	shooter.fireparams=self.cnt[shooter.cnt.firemode];
	shooter.sounddata=GetPlayerWeaponInfo(shooter).SndInstances[shooter.firemodenum];
end

function BasicWeapon:InitParams()
	if (self.name) then
		self:SetName( self.name );
	else
		self:SetName( "Nameless" );
	end
	
	--in multiplayer weapons can have totally different firemodes, first merge the fireparams we have inside the weapon script, 
	--even if the weapons have this special parameters for Multiplay.
	--DO NOT REMOVE, could be useful
--	if (Game:IsMultiplayer() and self.FireParams_Mp) then
--		
--		for i,firemode in self.FireParams do
--			
--			local mutli_params = self.FireParams_Mp[i];
--			
--			if (mutli_params) then
--				
--				merge(firemode,mutli_params);
--			end
--		end
--	end
		
	-- merging of weapon params	
	if(self.name)then
		if(WeaponsParams[self.name])then
			--System:Log("~~~~~~~~~~~~~~~~~~Initializing "..self.name);
			for i,val in self.FireParams do
				
				--local params=WeaponsParams[self.name][i];
				local params = nil;
				
				--keep retrocompatibility if the weaponsParams table dont contain 2 different tables, one for standard firemodes
				--and one for multiplayer changes
				if (WeaponsParams[self.name].Std and WeaponsParams[self.name].Std[i]) then
					params = WeaponsParams[self.name].Std[i];
				else
					params = WeaponsParams[self.name][i];
				end
							
				if(params)then
					--System:Log("~~~~~~~~~~~~~~~~~~Merging "..i);
					merge(val,params);
				end
				
				--now , if multiplayer, merge the special multiplayer fireparams table we have in the weaponsparams.lua
				if (Game:IsMultiplayer() and WeaponsParams[self.name].Mp) then
					
					--local params=WeaponsParams[self.name].Multi[i];
					local mutli_params = WeaponsParams[self.name].Mp[i];
					
					if (mutli_params) then			
									
						merge(val,mutli_params);
					end
				end
				--
				
				-- default tap fire rate is equal to normal fire rate
				if(val.tap_fire_rate == nil) then
					val.tap_fire_rate = val.fire_rate;
				end
				
				for def_key, def_val in BasicWeapon.DefaultFireParms do
					if (val[def_key] == nil) then
						val[def_key] = def_val;
					end
				end				

			end
		end
	end
	
	if (self.bFireParamsSet == nil) then
		self.bFireParamsSet = 1;
		for idx, element in self.FireParams do
			self.cnt:SetWeaponFireParams( element );
		end
	end	

	--kirill moved this from InitClient this has to be done on server as well - for dedicatedServer 	
	--System:Log("\003 BasicWeapon Init "..self.name);
	if( self.FireParams[1].type ) then
		self.cnt:SetHoldingType(self.FireParams[1].type);
	else 
		self.cnt:SetHoldingType( 1 );
	end		
	
end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon.Server:OnInit()
	--System:Log("BasicWeapon.Server:OnInit");
	BasicWeapon.InitParams(self);
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon.Client:OnInit()
	--System:Log("BasicWeapon.Client:OnInit");
	BasicWeapon.InitParams(self);
	self.nextfidgettime = nil;
	
	if (BasicWeapon.prevShift == nil) then
		BasicWeapon.prevShift = 0;
	end

	if (self.Sway == nil and self.ZoomNoSway ~= nil) then
		self.Sway=1.5;
	end
	
	if (self.special_bone_to_bind) then
		self.cnt:SetBindBone(self.special_bone_to_bind);
	else
		self.cnt:SetBindBone("weapon_bone");
	end
	
	--Attach animation key events to sounds(the table SoundEvents
	--is optionally implemented in the weapon script
	if(self.SoundEvents) then
		for i,event in self.SoundEvents do
			--System:Log("ADDING SOUND ["..self.name.."] <"..event[1]..">")
			self:SetAnimationKeyEvent(event[1],event[2],event[3]);
			if(event[4]~=nil)then
				Sound:SetSoundVolume(event[3],event[4]);
			end
		end
	else
		System:Log("WARNING SoundEvents empty ["..self.name.."]")
	end

	-- make sure MuzzleFlash CGFs are cached	
	for idx, element in self.FireParams do
		--first person
		if (element.MuzzleFlash and element.MuzzleFlash.geometry_name) then
			self.cnt:CacheObject(element.MuzzleFlash.geometry_name);
		end
		--third person
		if (element.MuzzleFlashTPV and element.MuzzleFlashTPV.geometry_name) then
			self.cnt:CacheObject(element.MuzzleFlashTPV.geometry_name);
		end
	end	
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon.Server:OnUpdate(delta, shooter)
	local stats = shooter.cnt;
	if((stats.underwater~=0 or stats:IsSwimming()) and
			stats.reloading) then
		stats.reloading = nil;
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon.Client:OnUpdate(delta, shooter)

	if (Game:IsMultiplayer() and _localplayer~=nil and _localplayer.type and tostring(cl_scope_flare) == "1" and self.DrawFlare) then
		local tpos = _localplayer:GetPos();
		local vCamPos = BasicWeapon.temp_pos;
		CopyVector(vCamPos, tpos);
		local vShooterPos = shooter:GetPos();
		
		local fFlareDistance=sqrt(	(vCamPos.x-vShooterPos.x)*(vCamPos.x-vShooterPos.x)+
							 		(vCamPos.y-vShooterPos.y)*(vCamPos.y-vShooterPos.y)+
							 		(vCamPos.z-vShooterPos.z)*(vCamPos.z-vShooterPos.z))
							 		
		-- 
		local fMinFlareDist=7;							-- in meters
		local fMaxFlareDist=10;							-- in meters
		local fFlareScale=0.75;							-- affects size and brightness overall
		local fFlareDistDownScale=0.02;			-- affects size and brightness in distance
							 	
		-- only display flare, at some distance							 									
		if(fFlareDistance>fMinFlareDist) then										
			BasicWeapon.scopeFlareInfo.shooterid=shooter.id;
						
			-- fade in/out flare
			local fScale=fFlareScale/(fFlareDistance*fFlareDistDownScale+1);
			
			if fFlareDistance<fMaxFlareDist then
				fScale = fScale * (fFlareDistance-fMinFlareDist)/(fMaxFlareDist-fMinFlareDist);
			end

			BasicWeapon.scopeFlareInfo.coronaScale=fScale;
							
			self:DrawScopeFlare(BasicWeapon.scopeFlareInfo);
		end
	end
	
	if (shooter == _localplayer) then
		local stats = shooter.cnt;
		
		if ((stats.running) and ClientStuff.vlayers:IsActive("WeaponScope") and
				self.AimMode~=1 and (not shooter.theVehicle) and (not shooter.cnt.lock_weapon)) then
			if (self.outOfScopeTime) then
				if (_time > self.outOfScopeTime) then
					ClientStuff.vlayers:DeactivateLayer("WeaponScope");
				end
			else
				-- schedule time to go out of scope mode
				self.outOfScopeTime = _time + 0.5;
			end
		else
			self.outOfScopeTime = nil;
		end
		if (not ClientStuff.vlayers:IsActive("WeaponScope")) then
			self.outOfScopeTime = nil;
		end

		if(stats.underwater~=0 and stats.reloading and shooter.playingReloadAnimation)then
			self:ResetAnimation(0);
			shooter.playingReloadAnimation = nil;
		end
		
		-- check if we are entering water
		if (stats.underwater ~= 0 and shooter.prevUnderwater==0) then
			-- stop the fireloop
			--System:Log("Entering water "..tostring(stats.underwater).." - "..tostring(shooter.prevUnderwater));
			BasicWeapon.Client.OnStopFiring(self, shooter);
		end

		-- track underwater state		
		if (stats.underwater ~= 0) then
			shooter.prevUnderwater = 1;
		else
			shooter.prevUnderwater = 0;
		end
		
		-- [marcok] please leave this code in
		local transition;
		if ((stats:IsSwimming() and stats:IsSwimming() ~= shooter.prevSwimming) or
				((stats.moving or stats.running) and (stats.moving or stats.running) ~= shooter.prevMoving)) then
			--System:Log("Transition");
			transition = 1;
		end
		
		shooter.prevSwimming = stats:IsSwimming();
		shooter.prevMoving = (stats.moving or stats.running);
		---------------------------------------
		-- Main Player Specific Behavior
		---------------------------------------
		local CurWeapon = stats.weapon;
		stats.dmgFireAccuracy = 100;
		-- Idle / fidget animations
		if (self.bDisableIdle == nil) then
			if (self:IsAnimationRunning() == nil or (transition and not shooter.playingReloadAnimation)) then
				shooter.playingReloadAnimation = nil;
				-- Once he begins swimming in the water (using the movement keys
				-- while on top of the water), the player arms will immediately switch 
				-- to a swimming animation, denying him the ability to shoot his gun unless 
				-- he stands still.
				if (stats:IsSwimming() and (stats.moving or stats.running)) then
					local blend = 0.0;
					if (transition) then
						blend = 0.3;
					end
					BasicWeapon.RandomAnimation(self,"swim",shooter.firemodenum, blend);
					self.nextfidgettime = nil;
				else
					if(not stats.firing)then
						if (self.nextfidgettime ~= nil and self.nextfidgettime < _time) then
							BasicWeapon.RandomAnimation(self,"fidget",shooter.firemodenum);
							self.nextfidgettime = nil;
						else
							BasicWeapon.RandomAnimation(self,"idle",shooter.firemodenum, 0.3);
						end
						
						if (stats.moving or stats.running or stats.aiming) then
							self.nextfidgettime = nil;
						end
					end
				end
				
				if (self.nextfidgettime == nil) then
					self.nextfidgettime = _time + 30 + random(1, 10);
				end
			end
		end
		
--		if(self.cross3D) then
--			local pos = _localplayer.cnt:GetCrosshairPos();
--			Particle:CreateParticle(pos,g_Vectors.v000,self.CrosshairParticles);
--			self.crossX = pos.xS;
--			self.crossY = pos.yS;
--		end	
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon:Hide(shooter)
	if (shooter == _localplayer) then
		shooter.cnt.drawfpweapon=nil;
		self:ResetAnimation(0);
		if (shooter.cnt.aiming) then
			ClientStuff.vlayers:DeactivateLayer("WeaponScope");
		end
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon:Show(shooter)
	if (shooter == _localplayer) then
		shooter.cnt.drawfpweapon=1;
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon.Server:OnFire( params )
	--System:Log("BasicWeapon.Server:OnFire");
	local retval;
	local wi;
	local ammo;
	local shooter = params.shooter;
	local stats = shooter.cnt;
	local ammo_left;
	
	--filippo: we dont want player shoot when in thirdperson and driving a vehicle without weapons (zodiac,paraglider,bigtruck)
	if (not BasicWeapon.CanFireInThirdPerson(self,shooter)) then
		return;
	end
	
	local unlimitedAmmo = 0;

	-- if shooter has killer flag - damage LocalPlayer with every shot
	if(shooter and shooter.killer) then
		local	hit = params;
		hit.damage = 100;
		hit.damage_type = "normal";
		hit.target = _localplayer;
		hit.landed = 1;
		_localplayer:Damage( hit );
	end
	
	if(shooter.fireparams.AmmoType == "Unlimited") then
	--[kirill] so, if shooter is killer with mounted weapon - it will damage localplayer with every shot, 
	-- no metter where it hits. Needed to prevent player from going somewhere (like out of the map)
		unlimitedAmmo = 1;
	end	

	-- For mounted weapons or other unlimited ammo weapons
	if (unlimitedAmmo == 1) then
		wi = nil;
		FireModeNum = 1;
		ammo = 1;
		ammo_left = 1;
	else
		wi = shooter.weapon_info;
		ammo = stats.ammo_in_clip;
		ammo_left = stats.ammo;			
	end

	if (ammo_left > 0 or ammo > 0) then
	
		if (ammo > 0) then
			-- Substract ammunition
			if toNumberOrZero(getglobal("gr_norl"))==1 then
				if tostring(self.name)=="RL" then
					return;
				end
			end
			if (Game:IsMultiplayer()) then
				local ss=MPStatistics:_GetServerSlotOfResponsiblePlayer(shooter);
				if ss then
					SVplayerTrack:SetBySs(ss,"bulletsfired", 1, 1);
				end
			end
			if (wi  and (unlimitedAmmo == 0)) then
				stats.ammo_in_clip = stats.ammo_in_clip - params.bullets;
				ammo = stats.ammo_in_clip;
			end
			
			local AISound = AIWeaponProperties[self.name];
			if (AISound and (shooter.sounddata.FireSounds or shooter.sounddata.FireLoop)) then
				-- generate event
				if (shooter.sounddata.FireLoop) then
					AI:SoundEvent(shooter.sounddata.FireLoop,shooter:GetPos(),AISound.VolumeRadius,AISound.fThreat,0,shooter.id);
				else
					AI:SoundEvent(shooter.sounddata.FireSounds[1],shooter:GetPos(),AISound.VolumeRadius,AISound.fThreat,0,shooter.id);
				end

				-- this should not generate any error in multiplayer
			--else
			--	if (AISound==nil) then
			--		System:LogToConsole("\003 [WEAPON WARNING] Weapon "..self.name.." has no AI properties table in the AIWeapons.lua (please add!)");
			--	else
			--		System:LogToConsole("\003 [WEAPON WARNING] Weapon "..self.name.." has no sounds registered in the shooter "..shooter:GetName());
			--	end	

			end

			retval = 1;
		end
		----------------------------------------------------------------------------
		-- AI EVENT clip nearly empty
		-- triggered if ammo in clip is less than 30% of total clip size
		----------------------------------------------------------------------------
		if ( ammo ==  floor(shooter.fireparams.bullets_per_clip*0.33) ) then
			AI:Signal(0,1,"OnClipNearlyEmpty",shooter.id);
		end

		if (ammo_left == 0 and ammo == 0 and self.switch_on_empty_ammo == 1) then
			--System:Log("RemoveWeapon");
			stats:MakeWeaponAvailable(self.classid,0);
			stats:SelectFirstWeapon();
		end
	end

	if (shooter.ai and stats.ammo < shooter.fireparams.bullets_per_clip) then
		stats.ammo = shooter.fireparams.bullets_per_clip;
		--AI:Signal(0,1,"OnNoAmmo",shooter.id);
	end
	
	if (retval == 1 and shooter and shooter.invulnerabilityTimer~=nil) then
--		System:Log("Player "..shooter:GetName().." was shooting, invulnerbility is now off");
	  	shooter.invulnerabilityTimer=0; -- Turn off invulnerability if this player causes damage
 	end
  
  	--play dry sounds that AI can heard
 	if (retval==nil) then
 		AI:SoundEvent(shooter.id,shooter:GetPos(),3,0.5,0.5,shooter.id);
 	end
 	
	-- Return value indicates if weapon can fire
	return retval;
end

function BasicWeapon:PlayShellsEjectionSound(shooter,material_field)
	if (self.bFiredShot == 1) then
		local material=shooter.cnt:GetTreadedOnMaterial();
		if (material~=nil) then
			local BulletHitZOffset=-1;		-- offset from gun to play the bullet-hit sound from...
			local BulletHitPos = shooter:GetPos();
			BulletHitPos.z=BulletHitPos.z+BulletHitZOffset;
			ExecuteMaterial(BulletHitPos, g_Vectors.v001, material[material_field], 1);
		end
		self.bFiredShot = nil;
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon.Client:OnStopFiring(shooter)
	BasicWeapon.StopFireLoop(self, shooter, shooter.fireparams, shooter.sounddata);
	if(shooter==_localplayer and shooter.cnt.canfire)then
		if (shooter.fireparams.BulletRejectType==BULLET_REJECT_TYPE_RAPID) then
			BasicWeapon.PlayShellsEjectionSound(self,shooter,"bullet_drop_rapid");
		elseif (shooter.fireparams.BulletRejectType==BULLET_REJECT_TYPE_SINGLE) then
			BasicWeapon.PlayShellsEjectionSound(self,shooter,"bullet_drop_single");			
		end
	end
	if(shooter ~=_localplayer and shooter.cnt.canfire) then
		-- Disable MuzzleFlash.
		local MuzzleFlashParams = shooter._MuzzleFlashParams;
		if (MuzzleFlashParams) then
			BasicWeapon.ShowMuzzleFlash( MuzzleFlashParams.weapon,MuzzleFlashParams,0 );
		end
	end
	self.bPlayedDrySound = nil;
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon.Client:OnFire( Params )
	--System:Log("BasicWeapon.Client:OnFire");
	local basic_weapon=BasicWeapon;
	local my_player=_localplayer;
	local shooter=Params.shooter;
	local sound=Sound;
	local cur_time=_time;
	local ReturnVal = nil;
	local FireModeNum;
	local WeaponStateData = shooter.weapon_info;
	local CurFireParams;
	local stats = shooter.cnt;
	local scope=ClientStuff.vlayers:IsActive("WeaponScope");

	self.nextfidgettime = nil;
		
	if (stats == nil or stats.weaponid == nil) then
		return;
	end

	if (not BasicPlayer.IsAlive(shooter)) then
		return;
	end

	if toNumberOrZero(getglobal("gr_norl"))==1 then
		if tostring(self.name)=="RL" then
			return;
		end
	end
	-- For mounted weapons or other unlimited ammo weapons
	if (self.FireParams[1].AmmoType == "Unlimited") then
		CurFireParams = self.FireParams[1];
	else
		CurFireParams = shooter.fireparams;
	end
		
	--filippo: we dont want player shoot when in thirdperson and driving a vehicle without weapons (zodiac,paraglider,bigtruck)
	if (not BasicWeapon.CanFireInThirdPerson(self,shooter,CurFireParams)) then
		
		--stop fire sounds and everything else need when player stop fire
		BasicWeapon.Client.OnStopFiring(self, shooter);
		
		return;
	end

	--[kirill]
	--fixme - marko, need unlimited ammo for gunners in heli
	if ( shooter.theVehicle and shooter.theVehicle.hely ) then
		self.bPlayedDrySound = nil;
	else
		if (not shooter.cnt.canfire) then
			if (not self.bPlayedDrySound and shooter.sounddata.DrySound and sound:IsPlaying(shooter.sounddata.DrySound) == nil) then
				shooter.cnt:PlaySound( shooter.sounddata.DrySound );
				self.bPlayedDrySound = 1;
			end
			return
		else
			self.bPlayedDrySound = nil;
		end
	end	

	-- Play animation
	if (shooter == my_player) then		
		
		--filippo:with long animation (30 frame for example) sometimes the fire animation is not called, so a reset is necessary
		--if (self.name == "Falcon") then
		self:ResetAnimation(0);	
		--end
		
		BasicWeapon.RandomAnimation(self,"fire",shooter.firemodenum);

		if (CurFireParams.HapticFireEffect ~= nil) then
			my_player.cnt:TriggerWeaponHapticEffect(CurFireParams.HapticFireEffect);
		end
		
		if (CurFireParams.BHapticsFireRight ~= nil) then
			my_player.cnt:TriggerBHapticsEffect(CurFireParams.BHapticsFireRight, CurFireParams.BHapticsFireLeft, CurFireParams.BHapticsIntensity);
			my_player.cnt:TriggerBHapticsEffect("recoilarm_r", "recoilarm_l", 1 + CurFireParams.BHapticsIntensity);
			my_player.cnt:TriggerBHapticsEffect("recoilvisor", "recoilvisor", 1 + CurFireParams.BHapticsIntensity);
		end
	end
	
	self.bFiredShot = 1;

	-- Obtain the muzzle flash bone
	local fire_pos = Params.pos;
	local bMountedWeapon = shooter.cnt.lock_weapon;
	local bVehicleWeapon = CurFireParams.vehicleWeapon;
	local bHely = nil;
	
	if( shooter.theVehicle and shooter.theVehicle.hely ) then
		bVehicleWeapon = nil;
		bHely = 1;
	end	

	if( bHely or ((not bVehicleWeapon) and bMountedWeapon) ) then
		fire_pos = shooter.cnt:GetTPVHelper(0, "spitfire");
	elseif ( bVehicleWeapon ) then
		fire_pos = shooter.cnt:GetTPVHelper(0, "spitfire");
	elseif ((stats.first_person and stats.weaponid > -1)) then
		if( bMountedWeapon )	then 	-- mounted weapon - just get helper
			fire_pos = shooter.cnt:GetTPVHelper(0, "spitfire");
		else
			fire_pos = self.cnt:GetBonePos("spitfire");
		end	
	else
		if (self.object) then
			fire_pos = shooter.cnt:GetTPVHelper(0, "spitfire");
		else
			fire_pos = shooter.cnt:GetHelperPos("weapon_bone");
			if (fire_pos ~= nil and fire_pos.x == 0 and fire_pos.y == 0 and fire_pos.z == 0) then
				fire_pos = nil;
			end
		end
 	end
 	
 	if (fire_pos == nil) then
 		fire_pos = Params.pos;
 	end
 	
	-- when we are looking through a weapon scope, the trail should come from the center 	
 	if (scope and (not self.AimMode) and (shooter == my_player)) then
		local vCamPos = my_player:GetCameraPosition();
		local vShooterPos = shooter:GetPos();

		FastDifferenceVectors(vCamPos, vCamPos, vShooterPos);
		ScaleVectorInPlace(vCamPos, 0.9);
 		fire_pos = SumVectors(shooter:GetPos(), vCamPos);
 	end

	-- Fire sound
	if ((CurFireParams.FireLoop or CurFireParams.FireLoopStereo) and CurFireParams.TrailOff) then
		--System:Log("Shot Loop");

		-- Sound is modelled as a loop with a trailoff		

		-- [marco] play stereo sounds for localplayer
		if (shooter==my_player and shooter.sounddata.FireLoopStereo) then
			if (shooter.sounddata.FireLoopStereo and sound:IsPlaying(shooter.sounddata.FireLoopStereo) == nil) then
				--System:Log("Loopy");
				sound:SetSoundLoop(shooter.sounddata.FireLoopStereo, 1);
				shooter.cnt:PlaySound(shooter.sounddata.FireLoopStereo);
			end
		else
			if (shooter.sounddata.FireLoop and sound:IsPlaying(shooter.sounddata.FireLoop) == nil) then
				--System:Log("Loopy not my player");
				sound:SetSoundLoop(shooter.sounddata.FireLoop, 1);
				shooter.cnt:PlaySound(shooter.sounddata.FireLoop);
			end
		end
	else
		--System:Log("Shot Single");
		-- Sound is modelled as a random series of different fire sounds
		local nSoundIdx = random(1, getn( shooter.sounddata.FireSounds ) );
		
		-- [marco] play stereo sounds for localplayer
		if (shooter==my_player and shooter.sounddata.FireSoundsStereo) then
			--System:Log("local sound stereo");		
			shooter.cnt:PlaySound(shooter.sounddata.FireSoundsStereo[nSoundIdx]);
		else
			shooter.cnt:PlaySound(shooter.sounddata.FireSounds[nSoundIdx]);
		end
	end

	-- sound event for the radar
	local AISound = AIWeaponProperties[self.name];
	if (AISound ~= nil) then
		Game:SoundEvent(shooter:GetPos(),AISound.VolumeRadius,AISound.fThreat,shooter.id);
	end

	-- Use a temporary member table to avoid a table creation		
	local vDirection = basic_weapon.temp_dir;
	local hasFakeHit = 0;
	if (Params.HitPt == nil or (Params.HitPt.x == 0 and Params.HitPt.y == 0 and Params.HitPt.z == 0) ) then
		hasFakeHit = 1;
		CopyVector( vDirection,Params.dir );
		ScaleVectorInPlace(vDirection, basic_weapon.VoidDist);
		vDirection.x = vDirection.x + Params.pos.x - fire_pos.x;
		vDirection.y = vDirection.y + Params.pos.y - fire_pos.y;
		vDirection.z = vDirection.z + Params.pos.z - fire_pos.z;
	else
		local pt = Params.HitPt;
		vDirection.x = pt.x - fire_pos.x;
		vDirection.y = pt.y - fire_pos.y;
		vDirection.z = pt.z - fire_pos.z;
	end
	
	-- Spawn a trail
	if(not (tonumber(w_firstpersontrail)==0 and shooter.cnt.first_person))then
		local trace = CurFireParams.Trace;
		if (trace) then
			-- moving trace
			trace.init_angles = basic_weapon.temp_angles;
			ConvertVectorToCameraAngles(trace.init_angles, vDirection);

			if(Params.HitDist == nil or Params.HitDist<0) then
				trace.lifetime = basic_weapon.VoidDist/trace.speed;
			else	
				trace.lifetime = Params.HitDist/trace.speed;
			end	
			--we don't want traces to bounce
			trace.bouncyness = 0;
--			trace.space_box = vDirection;
			trace.space_box = {x=0,y=0,z=0};
			if(vDirection.x<0) then trace.space_box.x = -vDirection.x; 
						else trace.space_box.x = vDirection.x; end
			if(vDirection.y<0) then trace.space_box.y = -vDirection.y;
						else trace.space_box.y = vDirection.y; end
			if(vDirection.z<0) then trace.space_box.z = -vDirection.z;
						else trace.space_box.z = vDirection.z; end
--			trace.space_box = {x=20, y=20, z=20};
			-- adding flag PART_FLAG_SPACELIMIT	2048 
			trace.particle_type = bor(trace.particle_type, 2048);
			Particle:CreateParticle(fire_pos, vDirection, trace);
		end
	end

--Particle system flags
--#define PART_FLAG_BILLBOARD     0 // usual particle
--#define PART_FLAG_HORIZONTAL    1 // flat horisontal rounds on the water
--#define PART_FLAG_UNDERWATER    2 // particle will be removed if go out from outdoor water
--#define PART_FLAG_LINEPARTICLE  4 // draw billboarded line from vPosition to vPosition+vDirection
--#define PART_FLAG_SWAP_XY       8 // alternative order of rotation (zxy)
--#define PART_SIZE_LINEAR       16 // change size liner with time
--#define PART_FLAG_NO_OFFSET    32 // disable centering of static objects
--#define PART_FLAG_DRAW_NEAR    64 // render particle in near (weapon) space

	if ((shooter~=_localplayer) or (not scope) or (self.AimMode and scope)) then
		-- Spawn smoke, bubbles, SpitFire etc.
		if (Game:IsPointInWater(Params.pos) == nil) then
			if (fire_pos) then
			
				--weaponfx	
				local weaponfx = tonumber(getglobal("cl_weapon_fx"));
				local firstperson = stats.first_person;
				
				--mounted and vehicle weapons ever act like we are in thirperson
				if (bMountedWeapon or bVehicleWeapon) then firstperson = nil; end
				
				--no smoke on low settings
				if(CurFireParams.SmokeEffect and weaponfx>0) then				
					BasicWeapon:HandleParticleEffect(CurFireParams.SmokeEffect,fire_pos,vDirection,firstperson,weaponfx);
				end
	
				--if there is no partile muzzle effect or cl_weapon_fx is set to 0 use normal muzzleflashes.
				--FIXME:temporarly removed from default the particle muzzleflashes , everyone is complaining about them.
				--btw, still usable with cl_weapon_fx 3.
				if(CurFireParams.MuzzleEffect and weaponfx>2) then				
					BasicWeapon:HandleParticleEffect(CurFireParams.MuzzleEffect,fire_pos,vDirection,firstperson,weaponfx);
					
				elseif(CurFireParams.MuzzleFlash) then
					
					CurFireParams.MuzzleFlash.init_angles = Params.angles;
					CurFireParams.MuzzleFlash.init_angles.y = random(0, 360);
					
					-- remember flags
					local flag = CurFireParams.MuzzleFlash.particle_type;
					-- if first person - chcange it
					
					-- NEW MUZZLE FLASH
					if (not shooter._MuzzleFlashParams) then
						shooter._MuzzleFlashParams = {};
					end
					local MuzzleFlashParams = shooter._MuzzleFlashParams;
					MuzzleFlashParams.weapon = self;
					MuzzleFlashParams.shooter = shooter;
					MuzzleFlashParams.bFirstPerson = nil;
					MuzzleFlashParams.MuzzleFlash = CurFireParams.MuzzleFlash;
					if (stats.first_person) then
						MuzzleFlashParams.bFirstPerson = 1;
					else
						if (CurFireParams.MuzzleFlashTPV) then
							MuzzleFlashParams.MuzzleFlash = CurFireParams.MuzzleFlashTPV;
						end
					end
					-- For mounted weapon.
					if (bMountedWeapon) then
						MuzzleFlashParams.weapon = shooter.current_mounted_weapon;
						MuzzleFlashParams.shooter = shooter.current_mounted_weapon;
						--MuzzleFlashParams.bFirstPerson = 1;
					end
					
					if ( bVehicleWeapon ) then
						MuzzleFlashParams.weapon = self;
						MuzzleFlashParams.shooter = self;
						MuzzleFlashParams.bFirstPerson = nil;
						VC.ShowMuzzleFlash( Params.shooter.theVehicle, MuzzleFlashParams, 1);
					else
						-- Check if muzzle flash for this shooter is already active.
						BasicWeapon.ShowMuzzleFlash( self,MuzzleFlashParams,1 );
					end	
				end	
				--if(CurFireParams.ExitSmoke) then
				--	Particle:CreateParticle( fire_pos, basic_weapon.normal_000, CurFireParams.ExitSmoke );
				--end	
			end
		end

		-- Shell Cases
		if (CurFireParams.ShellCases) then
			if (CurFireParams.ShellCases.geometry) then
				local bFirstPerson = 0;
				if (shooter == my_player) then
					if (shooter.cnt.first_person and shooter.cnt.weaponid > -1) then
			    			bFirstPerson = 1;
			   		end
				end

				local ShellCaseExitPt;
				
				if (bFirstPerson == 1) then
					--filippo: if is a vehicle weapon use the helper.
					if(stats.lock_weapon or bVehicleWeapon) then	-- mounted weapon - just get helper
						ShellCaseExitPt = stats:GetTPVHelper(0, "shells");
					else	
						ShellCaseExitPt = self.cnt:GetBonePos("shells");
					end	
				else
--					if(stats.lock_weapon) then	-- mounted weapon - just get helper
--						ShellCaseExitPt = self:GetHelperPos("shells");
--					else	
						ShellCaseExitPt = stats:GetTPVHelper(0, "shells");
--					end
				end

				if (ShellCaseExitPt and CurFireParams.ShellCases) then
					--filippo
					CurFireParams.ShellCases.init_angles = Params.angles;					
					CurFireParams.ShellCases.rotation = BasicWeapon.temp.rotate_vector;
					CurFireParams.ShellCases.rotation.x = random(-600,600)*0.1;
					CurFireParams.ShellCases.rotation.y = random(-600,600)*0.1;
					CurFireParams.ShellCases.rotation.z = random(-600,600)*0.1;
					CurFireParams.ShellCases.bouncyness = 0.25;
					--
					CurFireParams.ShellCases.focus = 10.5;
					CurFireParams.ShellCases.speed = 1.5;
					CurFireParams.ShellCases.particle_type = 32;
					CurFireParams.ShellCases.physics = 1;
										
					local vExitDirection = basic_weapon.temp_exitdir;
					vExitDirection.x = Params.dir.y;
					vExitDirection.y = -Params.dir.x;
					vExitDirection.z = random(0,150)*0.01;
					
--					CurFireParams.ShellCases.init_angles = Params.angles;
--					CurFireParams.ShellCases.speed = 2;
--					local vExitDirection = basic_weapon.temp_exitdir;
--					vExitDirection.x = Params.dir.y;
--					vExitDirection.y = -Params.dir.x;
--					vExitDirection.z = 0;
					
					Particle:CreateParticle(ShellCaseExitPt, vExitDirection, CurFireParams.ShellCases);
				else
					System:Log("ERROR: Weapon '"..self.name.."' Shells/Bone missing, artists fix !");
				end
			else
				System:Log("ERROR: No CGF File Specified For Shell Case Particle System !");
			end
		end
	end

	if (CurFireParams.ExitEffect) then
		Particle:SpawnEffect(fire_pos, vDirection, CurFireParams.ExitEffect, 1.0);
	end
	
	-- Spawn a trace of bubbles when underwater
	local doBubbles = 0;
	-- check start point
	if ( CurFireParams.fire_mode_type == FireMode_Instant and
			 (Game:IsPointInWater(Params.pos) or (hasFakeHit == 0 and Game:IsPointInWater(Params.HitPt))) and
			 shooter~=my_player) then
		doBubbles = 1;
	end
	
	if(tonumber(w_underwaterbubbles)==1 and doBubbles == 1)then		
		--ONLY IF IS UNDERWATER
		local vCurPosOnTrace=basic_weapon.temp_pos
		local vStep = Params.dir;
		CopyVector(vCurPosOnTrace,Params.pos);
		ScaleVector(vStep, 3);
		for i=0, 30 do
			FastSumVectors(vCurPosOnTrace,vCurPosOnTrace, vStep);
			if (Game:IsPointInWater(vCurPosOnTrace) == nil) then
				if (i ~= 0) then break;	end
				-- at this point we have to calculate the intersection with the water plane
				local waterLevel = Game:GetWaterHeight();
				local d = vStep.z;
				if (d > -0.0001 and d < 0.0001) then break;	end
				local t = -(vCurPosOnTrace.z-waterLevel)/d;
				vCurPosOnTrace.x = vCurPosOnTrace.x + Params.dir.x * t;
				vCurPosOnTrace.y = vCurPosOnTrace.y + Params.dir.y * t;
				vCurPosOnTrace.z = vCurPosOnTrace.z + Params.dir.z * t;
			end
			Particle:CreateParticle(vCurPosOnTrace, g_Vectors.v001, basic_weapon.TracerBubbles);
		end
	end
	
	--if underwater > 0 player is underwater
	if (stats.underwater<=0) then	
		--ONLY IF IS NOT UNDERWATER
		
		if ((shooter ~= _localplayer) or (_localplayer.FlashLightActive==0)) then

			-- make light flash when weapon is used
			local doProjectileLight = tonumber(getglobal("cl_weapon_light"));

			if (CurFireParams.LightFlash and doProjectileLight == 1) then -- no specular
				local diff=CurFireParams.LightFlash.vDiffRGBA;
				shooter:AddDynamicLight(fire_pos,CurFireParams.LightFlash.fRadius,diff.r*0.5,diff.g*0.5,diff.b*0.5,diff.a,0,0,0,0,
					CurFireParams.LightFlash.fLifeTime);
			elseif (CurFireParams.LightFlash and doProjectileLight == 2) then -- with specular
				-- vPos, fRadius, DiffR, DiffG, DiffB, DiffA, SpecR, SpecG, SpecB, SpecA, fLifeTime
				local diff=CurFireParams.LightFlash.vDiffRGBA;
				local spec=CurFireParams.LightFlash.vSpecRGBA;
				shooter:AddDynamicLight(fire_pos,CurFireParams.LightFlash.fRadius,diff.r*0.5,diff.g*0.5,diff.b*0.5,diff.a,spec.r*0.5,spec.g*0.5,spec.b*0.5,spec.a,
					CurFireParams.LightFlash.fLifeTime);
			end

		end
		
		if (Params.BulletPlayerPos and CurFireParams.whizz_sound) then
			local bSkip=0;
			if (CurFireParams.whizz_probability) then
				if (random(0, 1000)>CurFireParams.whizz_probability) then
					bSkip=1;
				end
			end
			if (bSkip==0) then
				local pWhizzSound=CurFireParams.whizz_sound[random(1, getn(CurFireParams.whizz_sound))];
				if (pWhizzSound) then
					Sound:SetSoundPosition(pWhizzSound, Params.BulletPlayerPos);
					Sound:PlaySound(pWhizzSound);
				end
			end
		end
	end
	ReturnVal = 1;
	
	if (self.DoesFTBSniping and (shooter==_localplayer)) then
		FTBSniping.OnFire(FTBSniping);
	end
	
	--filippo: apply view shake
	if (CurFireParams.weapon_viewshake ~= nil and CurFireParams.weapon_viewshake > 0) then
		--shooter.cnt:ShakeCameraL(0.010, CurFireParams.weapon_viewshake, CurFireParams.fire_rate);
		if (CurFireParams.weapon_viewshake_amt ~= nil) then
			shooter.cnt:ShakeCameraL(CurFireParams.weapon_viewshake_amt, CurFireParams.weapon_viewshake, CurFireParams.fire_rate);
		else
			shooter.cnt:ShakeCameraL(CurFireParams.weapon_viewshake * 0.001, CurFireParams.weapon_viewshake, CurFireParams.fire_rate);
		end
	end
	
	return ReturnVal;
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon.Server:OnHit( hit )
	--System:Log("BasicWeapon.Server:OnHit");
	-- augment hit table with damage type
	if (hit.shooter.fireparams.damage_type) then
		hit.damage_type = hit.shooter.fireparams.damage_type;
	else
		hit.damage_type = "normal";
	end

	if (hit.target_material) then
		-- spawn client side effect
		if( hit.target and hit.target.type == "Player" and hit.damage_type == "normal" and hit.target.invulnerabilityTimer==nil) then
			if (Game:IsMultiplayer()) then
			local ss=MPStatistics:_GetServerSlotOfResponsiblePlayer(hit.shooter);
			if ss then
				SVplayerTrack:SetBySs(ss,"bulletshit", 1 ,1);
				end
			end
			if BasicPlayer.IsAlive(hit.target) then
				Server:BroadcastCommand("FX", hit.pos, hit.normal, hit.shooter.id, 3);
--			else
--				Server:BroadcastCommand("FX", hit.pos, hit.normal, hit.shooter.id, 4);
			end
		end
    
		if ((hit.target_material.AI) and (hit.shooter~=nil)) then
			AI:FreeSignal(1,"OnBulletRain",hit.pos, hit.target_material.AI.fImpactRadius,hit.shooter.id);	
		end
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon.Client:OnHit( hit )
	local shooter = hit.shooter;
	
	-- augment hit table with damage type
	if (shooter.fireparams.damage_type) then
		hit.damage_type = shooter.fireparams.damage_type;
	else
		hit.damage_type = "normal";
	end
	
	if (hit.damage_type ~= "normal" and hit.damage_type ~= "building") then
		hit.target_material = nil;
	end

	-- hit effect
	local effect="bullet_hit";
	
	if (hit.target_material) then	

--		System:Log( "hit material >>  "..hit.target_material.type );
		
		if(shooter and shooter.fireparams.mat_effect)then
			effect=shooter.fireparams.mat_effect;
			if (hit.target_material[effect] == nil) then
				hit.target_material = Game:GetMaterialBySurfaceID(Game:GetMaterialIDByName("mat_default"));
			end
		end
	
		if( hit.target and hit.target.type == "Player" ) then
			if (Game:IsMultiplayer() and BasicPlayer.IsAlive(hit.target)) then
				hit.suppressParticleEffect = 1;
			end

			local doProjGore;			
			-- not use helmet material if no helmet			
			if(hit.target_material.type=="helmet")then
				if(hit.target.hasHelmet == 0) then
					hit.target_material = Game:GetMaterialBySurfaceID(Game:GetMaterialIDByName("mat_head"));
					doProjGore = 1;
				end
			else
				doProjGore = 1;
			end	

			-- draw blood decals on walls and terrain (not if we got hit by EngineerTool)
			if (doProjGore and hit.damage_type ~= "building") then
				BasicPlayer.DoProjectedGore( hit.target, hit );
			end
		end
		
		ExecuteMaterial2( hit ,effect);
		hit.suppressParticleEffect = nil;
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon.Server:OnEvent( EventId, Params )
	--System:Log("BasicWeapon.Server:OnEvent "..EventId);
	local EventSwitch=BasicWeapon.Server_EventHandler[EventId];
	if(EventSwitch)then
		return EventSwitch(self,Params);
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon.Client:OnEvent( EventId, Params )
	--System:Log("BasicWeapon.Client:OnEvent "..EventId);
	local EventSwitch=BasicWeapon.Client_EventHandler[EventId];
	if(EventSwitch)then
		return EventSwitch(self,Params);
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--NEW MUZZLE FLASH ATTACHMENT SYSTEM //TIMUR&MAX	----------------------------------------------------------------------------------------------------------------------------------	
-- MuzzleFlashTimer turn off timer callback.
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
MuzzleFlashTurnoffCallback =
{
	OnEvent = function( self,event,Params )
		if (Params) then
			BasicWeapon.ShowMuzzleFlash( Params.weapon,Params,0 );
		end
	end
}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------	
function BasicWeapon:ShowMuzzleFlash( MuzzleFlashParams,bEnable )
	local geomName = "Objects\\Weapons\\MUZZLEFLASH\\muzzleflash.cgf";
	local boneName;
	local target;
	local lifetime = 10;
	
	if (MuzzleFlashParams.bActive and bEnable == 1) then
		MuzzleFlashParams.bRepeat = 1;
		do return end;
	end
	
	if (MuzzleFlashParams.bFirstPerson) then
		boneName = "spitfire";
		target = MuzzleFlashParams.weapon;
	else
		boneName = "weapon_bone";
		target = MuzzleFlashParams.shooter;
	end
	
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
	
	-- If MuzzleFlash is active and fire was repeated.
	if (MuzzleFlashParams.bRepeat ~= nil and bEnable == 0) then
		MuzzleFlashParams.bRepeat = nil;
		MuzzleFlashParams.bActive = nil;
		-- Play Muzzle Flash just... abit longer 1/3rd of normal muzzle flash time, until next muzzle flash will be initialized if needed.
		Game:SetTimer( MuzzleFlashTurnoffCallback,lifetime*0.3,MuzzleFlashParams );
		do return end;
	end
	
	local rnd=random(1,2);
	if (bEnable == 1) then
		MuzzleFlashParams.bActive = 1;
		if (MuzzleFlashParams.bind_handle == nil) then
			target:LoadObject( geomName,2,1 );
			MuzzleFlashParams.bind_handle = target:AttachObjectToBone( 2, boneName,1 );
		end

		if (MuzzleFlashParams.aux_bind_handle == nil) then
			if (rnd==1) then
				MuzzleFlashParams.aux_bind_handle = target:AttachObjectToBone( 2, "aux_"..boneName,1 );
			end
		end
	else
		MuzzleFlashParams.bActive = nil;
		if (MuzzleFlashParams.bind_handle) then
			target:DetachObjectToBone( boneName,MuzzleFlashParams.bind_handle );
			MuzzleFlashParams.bind_handle = nil;
		end

		if (MuzzleFlashParams.aux_bind_handle) then
			target:DetachObjectToBone( "aux_"..boneName,MuzzleFlashParams.aux_bind_handle );
			MuzzleFlashParams.aux_bind_handle = nil;
		end
	end
	
	if (bEnable == 1) then
		-- This will result in a call to BasicWeapon.Client:TimerEvent
		Game:SetTimer( MuzzleFlashTurnoffCallback,lifetime,MuzzleFlashParams );
	end
end

-------------------^end^-------------------------------------------------------

function BasicWeapon.Server:FireModeChange(params)
	--System:Log("BasicWeapon.Server:FireModeChange -> "..tostring(params.firemode+1));
	-- Did we get the owner passed ?
	if (type(params) == "table" and params.shooter) then
		local shooter = params.shooter;
		if (shooter.cnt.reloading == nil) then
			local weaponState = GetPlayerWeaponInfo(shooter);
			local switchclip=1;
			if(shooter.fireparams.AmmoType==shooter.cnt.weapon.FireParams[params.firemode+1].AmmoType or params.ignoreammo)then
				switchclip=nil;
			end
			-- Make sure we can't fire etc. as long as we are changing
			shooter.cnt.weapon_busy=self:GetAnimationLength("Activate"..shooter.firemodenum)
			--
			if(switchclip)then
				shooter.Ammo[shooter.fireparams.AmmoType]=shooter.cnt.ammo;
				--System:Log("AMMOINCLIP: FireModeChange "..tostring(shooter.firemodenum).." -> "..tostring(shooter.cnt.ammo_in_clip));
				weaponState.AmmoInClip[shooter.firemodenum]=shooter.cnt.ammo_in_clip;
			end
			--
			shooter.weapon_busy= shooter.fireparams.FModeActivationTime;
			weaponState.FireMode=params.firemode;
			BasicWeapon.SyncVarCache(self,shooter);
			--
			if(switchclip)then
				shooter.cnt.ammo = shooter.Ammo[shooter.fireparams.AmmoType];
				shooter.cnt.ammo_in_clip = weaponState.AmmoInClip[shooter.firemodenum];
			end
			return 1
		end
	end
	return nil
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon.Client:FireModeChange(Params)
	--System:Log("BasicWeapon.Client:FireModeChange");
	-- Did we get the owner passed ?
	if (type(Params) == "table" and Params.shooter) then
		local shooter = Params.shooter;
		if (shooter.cnt.reloading == nil) then	
			BasicWeapon.SyncVarCache(self,shooter);
			if (shooter == _localplayer and ClientStuff.vlayers:IsActive("WeaponScope") and shooter.fireparams.no_zoom == 1) then
				ClientStuff.vlayers:DeactivateLayer("WeaponScope");
			end
			if (shooter == _localplayer and BasicWeapon.fireModeChangeSound and Params.ignoreammo == nil and self.FireParams[2]~=nil) then
				shooter.cnt:PlaySound( BasicWeapon.fireModeChangeSound );
			end
			-- Abort any reloading sequence and animation
			--self:StartAnimation(0, "Default", 0, 0);
			--self:ResetAnimation(0);
			
			-- Start activation animation for this firemode
			-- re-add these lines once we have firemode change animations
			--BasicWeapon.RandomAnimation(self,"modeactivate",shooter.firemodenum);
			-- Make sure we can't fire etc. as long as we are changing
			return 1
		end
	end
	return nil
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon:DrawCrosshair(r,g,b,accuracy, xpos, ypos)

	local factor = 0;
	if (_localplayer.entity_type == "spectator") then
		if (_localplayer.cnt.GetHost) then
			local ent = System:GetEntity(_localplayer.cnt:GetHost());
			factor = ent.cnt:CalculateAccuracyFactor(accuracy);
	 
		end
	
	else
	factor = _localplayer.cnt:CalculateAccuracyFactor(accuracy);
	end
	local xcent=400;
	local ycent=300;
	
	if( ypos ) then
		xcent=xpos;
		ycent=ypos;
	end

	local shift = xcent * tan(0.1308997)/tan(Game:GetCameraFov()/2.0) * factor;

	if (BasicWeapon.prevShift ~= nil) then
		shift = BasicWeapon.prevShift * 0.9 + shift * 0.1;
	end
	
	local fValue=1;
	
	if(hud_fadeamount and tonumber(hud_fadeamount)~=1) then
	  fValue=tonumber(hud_fadeamount);	
	end
	
	%System:Draw2DLine(xcent-7-shift,ycent,xcent-2-shift,ycent,r,g,b, fValue);
	%System:Draw2DLine(xcent+2+shift,ycent,xcent+7+shift,ycent,r,g,b, fValue);
	%System:Draw2DLine(xcent,ycent-2-shift,xcent,ycent-7-shift,r,g,b, fValue);
	%System:Draw2DLine(xcent,ycent+2+shift,xcent,ycent+7+shift,r,g,b, fValue);
	--small dot in the centre of screen.
	%System:Draw2DLine(xcent,ycent-0.5,xcent,ycent+0.5,r,g,b, fValue);
	--System:Log("Lines have been drawn for crosshair at line 1303");
	
	

	
	BasicWeapon.prevShift = shift;
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon.Client:OnEnhanceHUD(scale, bhit, xpos, ypos)
	local myplayer = _localplayer;
	
	if (myplayer.entity_type == "spectator" and myplayer.cnt.GetHost) then
		if (_localplayer.cnt:GetHost() == 0 ) then
		else
		myplayer = System:GetEntity(_localplayer.cnt:GetHost());
		end
	end
	
	-- some weapons (Mortar) don't have this parameter
	if (scale == nil) then
		scale = 1;
	end
	
	if (myplayer) then
		local stats = myplayer.cnt;
		--if (stats.first_person and myplayer.fireparams.HasCrosshair) then
		if ((stats.first_person or (myplayer.fireparams.draw_thirdperson~=nil and myplayer.fireparams.draw_thirdperson==1)) and myplayer.fireparams.HasCrosshair) then
			if ((not ClientStuff.vlayers:IsActive("Binoculars")) and (((not ClientStuff.vlayers:IsActive("WeaponScope")) or (self.AimMode)) or self.ZoomForceCrosshair)) then
				if(bhit and bhit>0)then
					BasicWeapon.DrawCrosshair(self,1,0,0,stats.accuracy*scale, xpos, ypos);
					--System:Log("Drawcrosshair called line 1332");
				elseif (stats.reloading or (stats.ammo_in_clip == 0 and stats.ammo == 0 and myplayer.fireparams.AmmoType ~= "Unlimited")) then
					BasicWeapon.DrawCrosshair(self,0.25,0.25,0,stats.accuracy*scale, xpos, ypos);
					--System:Log("Drawcrosshair called line 1335");
				else
					BasicWeapon.DrawCrosshair(self,1,1,0,stats.accuracy*scale, xpos, ypos);
					--System:Log("Drawcrosshair called line 1337");
				end
			end
		end
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon.Server:OnActivate(Params)
	-- Set player-related stuff...
	local shooter = Params.shooter;
	if (shooter) then
		local stats = shooter.cnt;
		local AmmoType;
		shooter.weapon_info=GetPlayerWeaponInfo(shooter);
		if( shooter.weapon_info) then
			BasicWeapon.SyncVarCache(self,shooter);
			AmmoType = shooter.fireparams.AmmoType;
			stats.ammo = shooter.Ammo[AmmoType];
			stats.ammo_in_clip = shooter.weapon_info.AmmoInClip[shooter.firemodenum];
			stats.weapon_busy=self:GetAnimationLength("Activate"..shooter.firemodenum)
		end
		self.OldSpeedScale = stats.speedscale;
		stats.speedscale = self.PlayerSlowDown;
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon.Client:OnActivate(Params)
	-- set player-related stuff...
	local shooter = Params.shooter;
	if (shooter) then
		local stats = shooter.cnt;
		
		shooter.weapon_info=GetPlayerWeaponInfo(shooter);
		if (shooter.weapon_info ~= nil) then
			BasicWeapon.SyncVarCache(self,shooter);
		end
		if (shooter == _localplayer and BasicPlayer.IsAlive(shooter)) then
			if (self.ActivateSound) then
				shooter.cnt:PlaySound( self.ActivateSound );
			end
			if (shooter.firemodenum ~= nil) then
				stats.weapon_busy=self:GetAnimationLength("Activate"..shooter.firemodenum)
				-- Look here
				BasicWeapon.RandomAnimation(self,"activate",shooter.firemodenum);
			end
			
			
			
			self.cnt:SetFirstPersonWeaponPos(g_Vectors.v000, g_Vectors.v000);
			
			-- if we are using binoculars, remove them when activating a new weapon
			if (ClientStuff.vlayers:IsActive("Binoculars")) then
				ClientStuff.vlayers:DeactivateLayer("Binoculars");
			end

			-- do not remove this
			BasicPlayer.ProcessPlayerEffects(shooter);
			
			BasicWeapon.Show(self,shooter);
		end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------		
		self.OldSpeedScale = stats.speedscale;
		stats.speedscale = self.PlayerSlowDown;
	end
	self.nextfidgettime = nil;
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon.Server:OnDeactivate(Params)
	-- Did we get the owner passed ?
	if (Params.shooter) then
		-- Abort any reloading sequence
		local shooter=Params.shooter;
		shooter.cnt.reloading = nil;
		shooter.Ammo[shooter.fireparams.AmmoType]=shooter.cnt.ammo;
		local weaponState = GetPlayerWeaponInfo(shooter);
		if (weaponState) then
			--System:Log("AMMOINCLIP: OnDeactivate "..tostring(shooter.firemodenum).." -> "..tostring(shooter.cnt.ammo_in_clip));
			weaponState.AmmoInClip[shooter.firemodenum]=shooter.cnt.ammo_in_clip;
			
			-- vehicle weapons don't retain any ammo
			if (shooter.fireparams.vehicleWeapon ~= nil) then
--				System:Log("Ammo writeback vehicle");
				-- empty all the ammo from the clip of the weapon
				BasicPlayer.EmptyClips(shooter, shooter.cnt.weaponid);				
			end
		end
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon.Client:OnDeactivate(Params)
	-- Did we get the owner passed ?
	if (type(Params) == "table" and Params.shooter == _localplayer) then
		-- Hide the weapon
		BasicWeapon.Hide(self, Params.shooter);
		if (ClientStuff.vlayers:IsActive("WeaponScope")) then
			ClientStuff.vlayers:DeactivateLayer("WeaponScope");
		end
		
		if (self.ActivateSound and Sound:IsPlaying(self.ActivateSound)) then
			Sound:StopSound( self.ActivateSound );
		end
	end
	-- kill the muzzleflash
	if (Params.shooter and Params.shooter._MuzzleFlashParams) then
		BasicWeapon.ShowMuzzleFlash( self, Params.shooter._MuzzleFlashParams, 0);
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon.Server:Drop( Params )
	local player=Params.Player;
	if( not player.cnt.weapon) then return end
	if(GameRules.bSuppressDropWeapon) then return end	-- some mods may want this behaviour
	local weapon=player.cnt.weapon;
	local cid=Game:GetEntityClassIDByClassName("Pickup"..weapon.name);
	if(cid)then
		local pos = SumVectors(player:GetPos(),{x=0.0,y=0.0,z=1.5});
		-- adjust spawn height based on player stance
		if (player.cnt.crouching) then
			pos = SumVectors(pos, {x=0.0,y=0.0,z=-0.5});
		elseif (player.cnt.proning) then
			pos = SumVectors(pos, {x=0.0,y=0.0,z=-1.0});
		end
		
--		local dir = player:GetDirectionVector();
--		
--		dir.z = 0.0;
--		--DroppedItem:SetPos(SumVectors(Offset, ScaleVector(Direction, 1.5)));
--	  dirs = {x=0,y=0,z=0};
--	  dirn = {x=dir.x,y=dir.y,z=dir.z}; 
--	  NormalizeVector(dirn); 
--	  FastScaleVector(dirn,dirn,0.15); FastScaleVector(dirs,dir,1.5);
--		local hits = System:RayWorldIntersection(pos,SumVectors(dirs,dirn),1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid);
--		if (hits and getn(hits)>0) then
--			pos = DifferenceVectors(hits[1].pos,dirn);
--		else
--		  pos.x = pos.x + dirs.x;
--		  pos.y = pos.y + dirs.y;
--		  pos.z = pos.z + dirs.z;
--		end

		local dir = BasicWeapon.temp_v1;
		local dest = BasicWeapon.temp_v2;
		
		CopyVector(dir,player:GetDirectionVector());
		
		dest.x = pos.x + dir.x * 1.5;
		dest.y = pos.y + dir.y * 1.5;
		dest.z = pos.z + dir.z * 1.5;
		
		local hits = System:RayWorldIntersection(pos,dest,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid,player.id);
		
		if (hits and getn(hits)>0) then
			
			local temp = hits[1].pos;
			
			dest.x = temp.x - dir.x * 0.15;
			dest.y = temp.y - dir.y * 0.15;
			dest.z = temp.z - dir.z * 0.15;
		end
		
		-- Create the dropped item
		local ed={
			classid=cid,
			pos=dest,--pos,
		}
		
		local DroppedItem = Server:SpawnEntity(ed);
		DroppedItem.autodelete=1;
		DroppedItem:EnableSave(1);
		if GameRules.GetPickupFadeTime then
			DroppedItem:SetFadeTime(GameRules:GetPickupFadeTime());
		end
		
		DroppedItem:GotoState("Dropped");

		-- write back current ammo backlog
		player.Ammo[player.fireparams.AmmoType]=player.cnt.ammo;
		-- update ammo in clips		
		local wi = GetPlayerWeaponInfo(player);
		if (wi) then
			if (self.FireParams[2] and self.FireParams[2].AmmoType == self.FireParams[1].AmmoType and player.firemodenum == 2) then
				wi.AmmoInClip[1]=player.cnt.ammo_in_clip;
			end
			wi.AmmoInClip[player.firemodenum]=player.cnt.ammo_in_clip;
		end
		player.cnt.ammo_in_clip=0;
		
		-- now we store the ammo for each firemode
		if (self.FireParams[1]) then
			DroppedItem.Properties.Amount=wi.AmmoInClip[1];
			wi.AmmoInClip[1]=0;
		end
		if (self.FireParams[2] and self.FireParams[2].AmmoType ~= self.FireParams[1].AmmoType) then
			--System:Log("amount2 "..tostring(wi.AmmoInClip[2]));
			DroppedItem.Properties.Amount2=wi.AmmoInClip[2];
			wi.AmmoInClip[2]=0;
		end
	
		-- take away the weapon		
		if (not Params.suppressSwitchWeapon) then
			player.cnt:MakeWeaponAvailable(self.classid,0);
			player.cnt:SelectFirstWeapon();
		end
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon.Server:WeaponReady(shooter)
	local stats = shooter.cnt;
	if(stats.reloading)then
		local fireparams = shooter.fireparams;
		-- Finished
		stats.reloading = nil;
		-- Obtain fire params to get ammo type and clip size
		if toNumberOrZero(getglobal("gr_realistic_reload"))==1 then
			stats.ammo_in_clip=0;
		end
		stats.ammo = stats.ammo + stats.ammo_in_clip;
		if (stats.ammo >= fireparams.bullets_per_clip) then
			-- Got enough ammo left to fill a clip
			stats.ammo = stats.ammo - fireparams.bullets_per_clip;
			stats.ammo_in_clip = fireparams.bullets_per_clip;
		elseif (stats.ammo > 0) then
			-- Partially fill the clip
			stats.ammo_in_clip = stats.ammo;
			stats.ammo = 0;
		end
		-- ammo has changed, so update Ammo table
		shooter.Ammo[fireparams.AmmoType] = stats.ammo;
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon.Server:Reload(shooter)
	local stats = shooter.cnt;
	if (not stats.reloading) then
		local w = stats.weapon;
		if (w and stats.ammo_in_clip < shooter.fireparams.bullets_per_clip and stats.ammo > 0) then
			shooter.abortGrenadeThrow = 1;
			stats.weapon_busy = shooter.fireparams.reload_time;
			-- In the case of a partial reload, put all remaining ammo from the clip into the ammo pool
			--if (stats.ammo > 0) then
			--	stats.ammo = stats.ammo + stats.ammo_in_clip;
			--	stats.ammo_in_clip = 0;
			--end
			stats.reloading=1
			AI:Signal(0,1,"OnReload",shooter.id);

			local anim_name = "s";
			if (shooter.cnt.crouching) then 
				anim_name = "c";
			end

			anim_name = anim_name.."reload";
			if (self.name == "Falcon") then
				anim_name = anim_name.."_DE";
			end

			if (shooter.ai) then	
				local dur = shooter:GetAnimationLength(anim_name);
				if (AI:IsMoving(shooter.id)==1) then 
					--Hud:AddMessage("Using moving reload");
					anim_name = anim_name.."_moving";
					dur = shooter:GetAnimationLength(anim_name);
				else
					--Hud:AddMessage("Stopping movement");
					AI:EnablePuppetMovement(shooter.id,0,dur);
				end
				shooter:TriggerEvent(AIEVENT_ONBODYSENSOR,dur);
			end
		end
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon.Client:Reload(shooter )
	
	local stats = shooter.cnt;
	
	if (shooter.fireparams.no_reload) then return; end
	
	if (not stats.reloading) then
		if (stats.ammo_in_clip < shooter.fireparams.bullets_per_clip) then
			local ReloadAnimName = "Reload"..(shooter.firemodenum);
			if (stats.ammo > 0) then
				if (shooter == _localplayer and stats.first_person) then
					if(ClientStuff.vlayers:IsActive("WeaponScope") or ClientStuff.vlayers:IsFading("WeaponScope"))then
						ClientStuff.vlayers:DeactivateLayer("WeaponScope",1);
					end
					stats.weapon_busy = shooter.fireparams.reload_time;
					BasicWeapon.RandomAnimation(self,"reload",shooter.firemodenum);
					shooter.playingReloadAnimation = 1;
				end
				-- always play 3rd person animation (because we might see ourself in a mirror)

				--filippo:check if is a mounted weapon, if so dont play player reload anim.
				local CurFireParams;
			
				if (self.FireParams[1].AmmoType == "Unlimited") then
					CurFireParams = self.FireParams[1];
				else
					CurFireParams = shooter.fireparams;
				end
			
				if (CurFireParams.vehicleWeapon==1) then
					return;
				end

				local anim_name = "s";
				if (shooter.cnt.crouching) then 
					anim_name = "c";
				end

				anim_name = anim_name.."reload";
				if (self.name == "Falcon") then
					anim_name = anim_name.."_DE";
				end

				if (shooter.ai==nil) then 
					anim_name = anim_name.."_moving";
				else
					if (AI:IsMoving(shooter.id)==1) then 
						anim_name = anim_name.."_moving";
					end
				end

				--Hud:AddMessage("Starting anim "..anim_name);
				shooter:StartAnimation(0,anim_name,4);
			end
		end
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon.Client:OnAnimationKey(Params)
	if (Params.userdata) then
		Sound:PlaySound(Params.userdata);
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function BasicWeapon:StopFireLoop(shooter, fireparams, sound_data)
	local sound=Sound;	

	if (shooter==_localplayer and sound_data.FireLoopStereo) then
		if ((sound_data ~= nil) and sound:IsPlaying(sound_data.FireLoopStereo)) then			
			--System:Log("Traily");
			sound:StopSound(sound_data.FireLoopStereo);		
			shooter.cnt:PlaySound(sound_data.TrailOffStereo);
		end
	else
		if ((sound_data ~= nil) and sound:IsPlaying(sound_data.FireLoop)) then
			sound:StopSound(sound_data.FireLoop);					
			shooter.cnt:PlaySound(sound_data.TrailOff);
			if (fireparams) then
				sound:SetSoundVolume(sound_data.TrailOff,fireparams.SoundMinMaxVol[1]);
				sound:SetMinMaxDistance(sound_data.TrailOff,fireparams.SoundMinMaxVol[2],fireparams.SoundMinMaxVol[3]);
			end
		end
	end
end

-- This function augments a passed weapon table with the
-- necessary Client and Server callbacks
function CreateBasicWeapon(weapon)
	-- add default Server callback tables
	if (weapon.Server == nil) then
		weapon.Server = {};
	end
	-- copy over the functions
	for i,val in BasicWeapon.Server do
		weapon.Server[i] = val;
	end

	-- add default Client callback tables
	if (weapon.Client == nil) then
		weapon.Client = {};
	end
	-- copy over the functions
	for i,val in BasicWeapon.Client do
		weapon.Client[i] = val;
	end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
BasicWeapon.Server_EventHandler={
	[ScriptEvent_Activate]=BasicWeapon.Server.OnActivate,
	[ScriptEvent_Deactivate]=BasicWeapon.Server.OnDeactivate,
	[ScriptEvent_DropItem]=BasicWeapon.Server.Drop,
	[ScriptEvent_FireModeChange]=BasicWeapon.Server.FireModeChange,
	[ScriptEvent_WeaponReady]=BasicWeapon.Server.WeaponReady,
	[ScriptEvent_Hit]=BasicWeapon.Server.OnHit,
	[ScriptEvent_Fire]=BasicWeapon.Server.OnFire,
	[ScriptEvent_FireCancel]=BasicWeapon.Server.OnFireCancel,
	[ScriptEvent_Reload]=BasicWeapon.Server.Reload,
}
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
BasicWeapon.Client_EventHandler={
	[ScriptEvent_AnimationKey]=BasicWeapon.Client.OnAnimationKey,
	[ScriptEvent_Activate]=BasicWeapon.Client.OnActivate,
	[ScriptEvent_Deactivate]=BasicWeapon.Client.OnDeactivate,
	[ScriptEvent_FireModeChange]=BasicWeapon.Client.FireModeChange,
	[ScriptEvent_Hit]=BasicWeapon.Client.OnHit,
	[ScriptEvent_Fire]=BasicWeapon.Client.OnFire,
	[ScriptEvent_StopFiring]=BasicWeapon.Client.OnStopFiring,
	[ScriptEvent_FireCancel]=BasicWeapon.Client.OnFireCancel,
	[ScriptEvent_Reload]=BasicWeapon.Client.Reload,
}

function BasicWeapon:RandomAnimation(anim,firemode, blendtime)
	if (blendtime == nil) then blendtime = 0 end
	
	if(self.anim_table)then
		local at=self.anim_table[firemode]
		if(at)then
			local t=at[anim];
			if(t)then
				self:StartAnimation(0, t[random(1,getn(t))], 0, blendtime);
			--else
			--	System:Log("BasicWeapon:RandomAnimation("..anim..","..firemode..") NO ANIM");
			end
		--else
		--	System:Log("BasicWeapon:RandomAnimation("..anim..","..firemode..") NO ANIM TABLE");
		end
	--else
	--	System:Log("BasicWeapon:RandomAnimation("..anim..","..firemode..") self.anim_table is nil");
	end
end

-- crosshair for auto weapons mounted on vehicles
function BasicWeapon:DoAutoCrosshair(scale, bHit)

	local bAvailable = nil;
	if (_localplayer.entity_type == "spectator") then
		if (_localplayer.cnt.GetHost) then
		local ent = System:GetEntity(_localplayer.cnt:GetHost());
		bAvailable = ent.cnt:GetCrosshairState();
		end
	else
	bAvailable = _localplayer.cnt:GetCrosshairState();
	end
	-- the crosshair is out of the screen 
	--System:Log("\001 >>> fMode  ".._localplayer.cnt.firemode);

	local posX = 400;
	local posY = 300;
	local aimDist = 0.0;
	if (_localplayer.entity_type ~= "spectator") then
		aimDist =self.FireParams[_localplayer.cnt.firemode+1].auto_aiming_dist;
	end
	--local aimDist = self.FireParams[1].auto_aiming_dist;	
	
	--System:Log("\001 >>> aAimDist  "..aimDist);
	
	--filippo
	if (bAvailable==nil) then
		
		if (BasicWeapon.cantshoot_sprite) then
			local cantshootradius = 25;
			%System:DrawImageColor(BasicWeapon.cantshoot_sprite, posX-cantshootradius, posY-cantshootradius, cantshootradius*2, cantshootradius*2, 4, 1, 0.25, 0.25, 0.5);
		end
		
		return; 
	end
	
	if( aimDist == 0.0 ) then

		BasicWeapon.Client.OnEnhanceHUD(self, scale, bHit, posX, posY);
		--BasicWeapon.Client:OnEnhanceHUD(bHit, BasicWeapon:CrossHairPos.xS, BasicWeapon:CrossHairPos.yS);		
		return 
	end
	
	local r=1;
	local g=1;
	local b=.25;
	
	if(bHit and bHit>0)then
		r=1;
		g=.25;
		b=.25;
	end

--	if( pos.locked == 1 ) then
--		r=.1;
--		g=1;
--		b=.1;
--	end	
	
	--filippo, if weapon have autoaim_sprite , use it ,if not use the classic square reticule
	local autoaim_sprite = self.FireParams[_localplayer.cnt.firemode+1].autoaim_sprite;
	
	if (autoaim_sprite) then
		%System:DrawImageColor(autoaim_sprite, posX-aimDist, posY-aimDist, aimDist*2, aimDist*2, 4, r, g, b, 1);
	else	
		local x1 = posX - aimDist;
		local y1 = posY - aimDist;
		local x2 = posX + aimDist;
		local y2 = posY + aimDist;
	
		%System:Draw2DLine(x1,y1,x2,y1,r,g,b,1);
		%System:Draw2DLine(x1,y2,x2,y2,r,g,b,1);	
		%System:Draw2DLine(x1,y1,x1,y2,r,g,b,1);	
		%System:Draw2DLine(x2,y1,x2,y2,r,g,b,1);
	end
	
	--filippo, draw the little cross
	local outerradius=7;
	local innerradius=3;
	
	%System:Draw2DLine(posX-innerradius,posY,posX-outerradius,posY,r,g,b,1);
	%System:Draw2DLine(posX+innerradius,posY,posX+outerradius,posY,r,g,b,1);	
	%System:Draw2DLine(posX,posY-innerradius,posX,posY-outerradius,r,g,b,1);	
	%System:Draw2DLine(posX,posY+innerradius,posX,posY+outerradius,r,g,b,1);
end

function BasicWeapon:HandleParticleEffect(effect,pos,dir,firstperson,weaponfx)
	
	local sprite = effect.sprite;
	
	if (sprite==nil) then return; end
	
	local temppos = BasicWeapon.temp_v1;
	local tempdir = BasicWeapon.temp_v2;
	local tempparticle = BasicWeapon.Particletemp;
	
	local steps = effect.steps;
	local stepoffset = effect.stepsoffset;
		
	local randomfactor = 50;
	local rnd1 = 1.0;
	local rnd2 = 1.0;
	
	local rotation = effect.rotation;
	
	local lastsprite = nil;
	local lastsize = nil;
	
	local onesprite = 1;
	
	local extrascale = 1.0;
	
	--if sprite is a table we are using multiple and/or random set of sprites.
	if (type(sprite)=="table") then 
		onesprite = 0;
	else
		lastsprite = sprite;
	end
		
	if (effect.randomfactor) then
		randomfactor = effect.randomfactor;
	end
		
	temppos.x = pos.x;
	temppos.y = pos.y;
	temppos.z = pos.z;
	
	tempdir.x = dir.x;
	tempdir.y = dir.y;
	tempdir.z = dir.z;
	
	NormalizeVector(tempdir);
	
	--particles in first person are shifted forward for some reasons, so shift the startpos 20 cm back
	if (firstperson) then
		temppos.x = temppos.x - tempdir.x * 0.2;
		temppos.y = temppos.y - tempdir.y * 0.2;
		temppos.z = temppos.z - tempdir.z * 0.2;
	else
		--usually thirdperson effects need to be bigger, so scale them by 1.5
		extrascale = 1.5;
	end
				
	--custom particle color?			
	if (effect.color) then
		tempparticle.start_color = effect.color;
		tempparticle.end_color = effect.color;
	else
		tempparticle.start_color = BasicWeapon.vcolor1;
		tempparticle.end_color = BasicWeapon.vcolor1;
	end
		
	local wfx=0;
	
	if (weaponfx) then
		wfx = weaponfx;
	else
	 	wfx = tonumber(getglobal("cl_weapon_fx"));
	end
	
	if (wfx<2) then steps = max(steps / (3-wfx),1); end
		
	tempparticle.focus = effect.focus;
	tempparticle.gravity.z = effect.gravity;
	tempparticle.AirResistance = effect.AirResistance;
	
	--frametime 0.1 = 10fps
	--frametime 0.05 = 20fps
	--frametime 0.033 = 30fps
	--frametime 0.02 = 50fps
	--frametime 0.0166 = 60fps
	--as long as particles dont follow very well the fps use lifetimefix to correct life/speed/size;
	--the reference is about 60 fps, that means a lifetimefix of 1.0
	local lifetimefix = 1.0 - ((_frametime - 0.0166)/(0.1 - 0.0166));
	if (lifetimefix < 0.1) then lifetimefix = 0.1; end
		
	for i=0, steps-1 do
		
		--use just 2 random number
		if (randomfactor~=0) then
			rnd1 = random(100-randomfactor,100+randomfactor)*0.01;
			rnd2 = random(100-randomfactor,100+randomfactor)*0.01;
		end
		--Hud:AddMessage(""..effect.size[i+1]);
		
		--if we are using different sprites, check if we can use a random sprite.
		if (onesprite==0) then
			if (sprite[i+1]) then
				lastsprite = sprite[i+1];
				
				if (type(lastsprite)=="table") then
					
					local spriten = getn(lastsprite);
										
					if (spriten<=0) then return end
					
					lastsprite = lastsprite[random(1,spriten)];
				end
			end
		end
		
		--lastsprite nil? return.
		if (lastsprite == nil) then return end
		
		if (effect.size[i+1]) then
			lastsize = effect.size[i+1];
		end		
		
		tempparticle.speed = effect.speed*rnd1;
		tempparticle.size = lastsize*rnd2*extrascale*lifetimefix;
		tempparticle.size_speed = effect.size_speed*rnd1*lifetimefix;
		tempparticle.lifetime = effect.lifetime*rnd2*lifetimefix;	
		
		tempparticle.tid = lastsprite;
		tempparticle.rotation.z = random(-rotation*10,rotation*10)*0.1;
			
		Particle:CreateParticle( temppos, tempdir, tempparticle );
		
		--go straight with the position.
		temppos.x = temppos.x + tempdir.x * stepoffset * extrascale;
		temppos.y = temppos.y + tempdir.y * stepoffset * extrascale;
		temppos.z = temppos.z + tempdir.z * stepoffset * extrascale;
	end
end

function BasicWeapon:CanFireInThirdPerson(shooter,CurFireParams)

	if( shooter.ai ) then return 1; end
	
	if (shooter~=_localplayer) then return 1; end

	local FireParams = CurFireParams;

	if (FireParams==nil) then
		-- For mounted weapons or other unlimited ammo weapons
		if (self.FireParams[1].AmmoType == "Unlimited") then
			FireParams = self.FireParams[1];
		else
			FireParams = shooter.fireparams;
		end
	end

	if (shooter.theVehicle and not FireParams.vehicleWeapon and not shooter.cnt.first_person) then
		return nil;
	end
	
	return 1;
end
