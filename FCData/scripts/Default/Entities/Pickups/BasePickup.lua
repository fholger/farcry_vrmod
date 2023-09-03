BasePickup={
	Properties = {
		Amount = 15,
		Amount2 = 1,
		RespawnTime = 0,
		FadeTime = 0,			-- in seconds
		bPlayerOnly = 1,
		bShowFloatingIcon = 0,
		bAwakePhysics = 1,
		Availability = 0,	-- availability depending on difficult level (game_Difficulty)
					-- 0 = All levels of difficulty (appears no matter what)
					-- 1 = Easy only				
					-- 2 = Easy and Medium				
					-- 3 = Easy, Medium, and Challenging				
					-- 4 = Easy, Medium, Challenging, and Brutal
	},
	model = "",
	sound = "Sounds/Weapons/aw50/awammo.wav",
	soundobj =nil,
	
	ta={x=0,y=0,z=0},
	tp={x=0,y=0,z=0},
}

------------------------------------------------------
function BasePickup:Event_Picked()
end

------------------------------------------------------
function BasePickup:Event_Unhide()

--	self:DrawObject( 0, 1 );
	self:Hide(0);

end

------------------------------------------------------
function BasePickup:Event_Hide()

	self:Hide(1);

end


------------------------------------------------------
function BasePickup:OnSave(stm)
	--WriteToStream(stm,self.Properties);
end
------------------------------------------------------
function BasePickup:OnLoad(stm)
	--self.Properties=ReadFromStream(stm);
	--self:OnReset();

	self:LoadGeometry();
	--self:GotoState("Active");
end
------------------------------------------------------
function BasePickup:OnReset()
	self.geometry = nil;
	self.physicalized = nil;
	self:LoadGeometry();
	self:Physicalize();
	self:GotoState("Active");
end

function BasePickup:OnMultiplayerReset()
	self:GotoState("Active");
end

function BasePickup:Physicalize(spawner)
	if(self.physics and (self.Properties.RespawnTime==0 or self.Properties.AlwaysPhysicalize))then
		if(not self.physicalized or spawner ~= nil)then
			local particle_params = {
				mass = 10,
				size = 0.15,
				heading = {x=0,y=0,z=-1},
				initial_velocity = 0,
				k_air_resistance = 0,
				acc_thrust = 0,
				acc_lift = 0,
				--high friction material
				surface_idx = Game:GetMaterialIDByName("mat_pickup"),
				gravity = {x=0, y=0, z=-9.8 },
				collider_to_ignore = spawner,
				flags = bor(particle_constant_orientation,particle_no_path_alignment, particle_no_roll, particle_traceable),
			}
			self.physicalized=1;
			self:CreateParticlePhys( 10, 10, 0 );
			self:SetPhysicParams(PHYSICPARAM_PARTICLE,particle_params);
		end
	end

	self:AwakePhysics(self.Properties.bAwakePhysics);
end

function BasePickup:SetFadeTime(val)
	self.Properties.FadeTime = tonumber(val);
	self:SetTimer(self.Properties.FadeTime * 1000);
end

function BasePickup:NotifyMessage(msg,target,lifetime)
	--if(self.Properties.bPlayerOnly~=0)then
	if (target==nil) then
		Hud:AddMessage(msg);
	else
	--	if(target)then
			local slot=Server:GetServerSlotByEntityId(target.id)
			if(slot)then
				if (lifetime) then
					slot:SendText(msg,lifetime)
				else
					slot:SendText(msg);
				end
			end
	end
--	end
end

function BasePickup:AttemptPick(collider, entering)
	if(collider.type ~= "Player")then	return end
	if(collider.cnt.health<1)then return end
	if(collider.theVehicle)then return end		-- no pickups when in vehicles
	if(GameRules:IsInteractionPossible(collider,self)==nil)then return end
	
	local picked = self:Pick(collider, entering, self.ammo_type, self.Properties.Amount);

	if (picked or self.ammopicked) then
		if (picked or self.Properties.RespawnTime>0) then
			self.ammopicked = nil;
		end
		if(not self.doesnt_expire)then
			self:GotoState("Picked");
		end
	end
end

function BasePickup:LoadGeometry()
	if(not self.geometry)then
		self.geometry=1;
		if (self.bModelIsChoosable) then
			self:LoadObject(self.Properties.object_Model, 0, 1);
		else
			self:LoadObject(self.model, 0, 1);
		end
			self:DrawObject( 0, 1 );
	end
	
	if(self.objectangles)then
		self:SetObjectAngles(0, self.objectangles)
	end
	
	if(self.objectpos)then
		self:SetObjectPos(0, self.objectpos)
	elseif(self.rotate90)then
		self:SetObjectPos(0,{x=0,y=0,z=0.1})
	end
end
------------------------------------------------------
-- game_Difficulty 
--	game_Difficulty==0 -- easy
-- 	game_Difficulty==1 -- medium
--	game_Difficulty==2 -- hard

function BasePickup:IsAvailable()

	-- must be ib editor - always on
	if not getglobal("game_DifficultyLevel") then return 1 end

	--System:Log(" >>> Availability  "..self.Properties.Availability.." diffL "..game_DifficultyLevel);

	if(self.Properties.Availability == 0) then return 1 end

	if(self.Properties.Availability < tonumber(game_DifficultyLevel)+1) then return nil end

	do return 1 end
end


------------------------------------------------------
BasePickup.Server={
	OnInit = function(self)
		self.geometry=nil;
		
		self:EnableUpdate(0);
		
		if (self.initialAmount==nil and self.Properties.Amount) then
			self.initialAmount = self.Properties.Amount;
		end
		
		if (self.initialAmount2==nil and self.Properties.Amount2) then
			self.initialAmount2 = self.Properties.Amount2;
		end
		
		if( not self:IsAvailable() ) then return end
		
		--self:SetUpdateType( eUT_PhysicsVisible );
		self:SetUpdateType( eUT_Physics );
		self:TrackColliders(1);

		self:RegisterState("Active");
		self:RegisterState("Picked");
		self:RegisterState("Inactive");
		self:RegisterState("Dropped");
		self:GotoState("Active");	
		self:NetPresent(nil);
		self:OnReset();
		self.ammopicked = nil;

		if(self.Properties.RespawnTime>0 and not self.vOrigPos)then
			self.vOrigPos = new (self:GetPos());
		end
	end,
	Active={
		OnBeginState = function(self)
			self.ammopicked = nil;
			self.hadFullSlots = nil;
			self:Physicalize();
			
			if (self.vOrigPos) then
				self:SetPos(self.vOrigPos);
			end
			
			if (self.Properties.FadeTime > 0) then
				self:SetTimer(self.Properties.FadeTime * 1000);
			end
		end,
		OnContact = function(self, collider)
			BasePickup.AttemptPick(self, collider, nil);
		end,
		OnEnterArea = function(self, collider)
			BasePickup.AttemptPick(self, collider, 1);
		end,
		OnLeaveArea = function(self, collider)
			self.hadFullSlots = nil;
		end,
		OnTimer = function(self)
			Server:RemoveEntity(self.id);
		end,
	},
	Dropped={
		OnBeginState = function(self)
			self.hadFullSlots = nil;
			self:Physicalize();
			self:SetTimer(1000);
		end,
		OnTimer = function(self)
			self:GotoState("Active");
		end,
	},
	Picked={
		----------------------------------
		OnBeginState = function(self)
			BroadcastEvent(self, "Picked");
			
			self:SetTimer(50);
		end,
		----------------------------------
		OnTimer = function(self)
			if (self.ammopicked) then
				self:GotoState("Active");
			else
				if(self.autodelete)then
					Server:RemoveEntity(self.id);
				end
				self:GotoState("Inactive");
			end
		end,
	},
	Inactive={
		----------------------------------
		OnBeginState = function(self)
			if(self.Properties.RespawnTime<=0)then
				self:EnableSave(nil);
			end
			if(self.Properties.RespawnTime>0)then self:SetTimer(self.Properties.RespawnTime*1000) end;
		end,
		----------------------------------
		OnTimer = function(self)
			if (self.initialAmount) then
				self.Properties.Amount = self.initialAmount;
			end
			if (self.initialAmount2) then
				self.Properties.Amount2 = self.initialAmount2;
			end
			self:GotoState("Active");
		end,
	},
}
------------------------------------------------------
BasePickup.Client={
	OnInit = function(self)
		self.geometry=nil;
		
		self:EnableUpdate(0);
		
		if( not self:IsAvailable() ) then return end		
		
		self:SetUpdateType( eUT_Physics );
		self:TrackColliders(1);
		
		self:RegisterState("Active");
		self:RegisterState("Picked");
		self:RegisterState("Inactive");
		self:RegisterState("Dropped");
		if (self.bSoundIsChoosable) then
			self.soundobj=Sound:Load3DSound(self.Properties.sound_Sound);
		else
			self.soundobj=Sound:Load3DSound(self.sound);
		end
		if(self.icon)then
			self.icon=System:LoadImage(self.icon);
		end
		if(self.floating_icon and self.Properties.bShowFloatingIcon == 1)then
			self:LoadCharacter(self.floating_icon,0);
		end
		
		self:LoadGeometry();
		self:Physicalize();
		if(self.Properties.RespawnTime>0 and not self.vOrigPos)then
			self.vOrigPos = new (self:GetPos());
		end
	end,
	Active={
		----------------------------------
		OnBeginState = function(self)
				self:DrawObject( 0, 1 );
				if (self.vOrigPos) then
					self:SetPos(self.vOrigPos);
				end

				if (self.Properties.bShowFloatingIcon == 1) then
					self:DrawCharacter(0,1);
				end
				self.zdelta=random(0,1);
				self.zup=random(0,1);
		end,
		OnContact = function(self, collider)
			
			--if is not the localplayer there is no reason to execute the whole thing.
			if (collider ~= _localplayer) then return end
			self.player = collider

			--Hud:AddMessage(self:GetName().." collide with "..collider:GetName());
			
			if(collider.theVehicle)then return end		-- no pickups when in vehicles
			
			local ws = nil;
			
			-- collider.cnt.GetWeaponsSlots is not for a spectator
			if (collider.cnt and collider.cnt.GetWeaponsSlots) then
				ws = collider.cnt:GetWeaponsSlots();
			end
			
			if (self.weapon and ws) then
				
				local count=0;
				local has_weapon;
				
				for i,val in ws do 
					if(val~=0) then 
						count=count+1;
						if(val.name==self.weapon) then has_weapon=1; break; end
					end 
				end
				
				--if((count==4 or has_weapon) and collider.cnt.weapon and (has_weapon~=1) and collider == _localplayer and not collider.cnt.lock_weapon) then
				if((count==4 or has_weapon) and collider.cnt.weapon and (has_weapon~=1) and not collider.cnt.lock_weapon) then
					
					Hud.label = "@PressDropWeapon @"..collider.cnt.weapon.name.." @AndPickUp @"..self.weapon;
					
					--with an updatetype such "eUT_Physics", the entity will be updated only when the collider move, so the text
					--message will be lost, to solve this without change the updatetype we save into the player class the info about
					--this entity, so its possible to update constantly the collision by checking the distance between the player and 
					--the pickup.
					if (collider.pickup_ent ~= self) then
					
						collider.pickup_ent = self;						
						collider.pickup_OnContact = self.Client.Active.OnContact;
						collider.pickup_dist = EntitiesDistSq(self,collider);
					end
				end
			end
		end
		--OnUpdate = function(self)
			--self.zdelta=(self.zdelta+_frametime);
			--self.zup=self.zup+_frametime*0.5;
			--if(self.down)then
				--if(self.zup>=2)then self.zup=0; self.down=nil; self.zdelta=0; return end
				--self.tp.z=(2-self.zup)*0.2;
			--else
				--if(self.zup>=2)then self.zup=0; self.down=1; self.zdelta=0; return end
				--self.tp.z=self.zup*0.2;
			--end
			--self.ta.z=mod(self.zdelta,2)*180;
			--self:SetObjectPos(0,self.tp)
			--self:SetObjectAngles(0,self.ta)
		--end
	},
	Dropped={
	},
	Picked={
		OnBeginState = function(self)
			if(self.soundobj and (not self.sound_played)) then
			
				local sound;
				
				if (type(self.soundtbl) == "table") then
					sound = self.soundtbl[random(1,getn(self.soundtbl))];
				else
					sound = self.soundobj;
				end
				
				Sound:SetSoundVolume(sound,255);
				Sound:SetSoundPosition(sound,self:GetPos());
				Sound:PlaySound(sound, 1);
				self.sound_played=1;
				
				if (self.player == _localplayer) then
					local effect = "pickup";
					if (self.bhaptics_effect ~= nil) then
						effect = self.bhaptics_effect;
					end
					self.player.cnt:TriggerBHapticsEffect(effect, effect, 0.5);
				end
			end
		end,
		OnEndState = function (self)
			self.sound_played=nil;
		end,
		----------------------------------
	},
	Inactive={
		OnBeginState = function(self)
				self:DrawObject( 0, 0 );
				self:DrawCharacter(0,0);
		end,
	},
}

-- loads ammo into the correct clip of a weapon ... returns the amount of ammo to add
-- to the regular ammo store
function __LoadAmmoIntoClips(self, collider, weaponid, ammo_type, ammo_amount)
	if(ammo_type == nil or ammo_type=="Unlimited")then
		return nil;
	end
	
	local amount = ammo_amount;
	local weaponState = collider.WeaponState;
	
	-- get the player's weapon state for this weapon
	if (weaponState ~= nil) then
		local weaponInfo = weaponState[weaponid];
		if (weaponInfo == nil) then
			BasicPlayer.ScriptInitWeapon(collider, self.weapon, 1);
			weaponInfo = weaponState[weaponid];
		end
		
		if (weaponInfo ~= nil) then
			local weaponTable = getglobal(weaponInfo.Name);
			local distributed = nil;
			
			-- now we find the fire mode of the weapon, which uses this ammo type
			for i, fireMode in weaponTable.FireParams do
				if (fireMode.AmmoType == ammo_type and fireMode.ai_mode==0 and not distributed) then
					local bpc = fireMode.bullets_per_clip - weaponInfo.AmmoInClip[i];
					local to_add = min(bpc, amount);					
											
					amount = amount - to_add;
					--System:Log("LEFT AMMO INNER: "..tostring(amount));
					weaponInfo.AmmoInClip[i] = weaponInfo.AmmoInClip[i] + to_add;
					distributed = 1;
					
					if (collider.cnt.weapon and collider.cnt.weaponid == weaponid and
							collider.cnt.weapon.FireParams[weaponInfo.FireMode+1].AmmoType == ammo_type) then
						collider.cnt.ammo_in_clip = weaponInfo.AmmoInClip[i];
					end
				end
			end
		end
	end
	
	-- return left over ammo
	--System:Log("LEFT AMMO: "..tostring(amount));
	return amount;
end

function __PickAmmo(self,collider, entering, ammo_type, amount)
	if(ammo_type == nil or ammo_type=="Unlimited")then
		return nil;
	end

	local max_ammo=MaxAmmo[ammo_type];
	local to_add=amount;

	local curr_amount = collider:GetAmmoAmount(ammo_type);
	local serverSlot = Server:GetServerSlotByEntityId(collider.id);
	
	if ((not max_ammo) or curr_amount>=max_ammo) then
		if (entering == 1) then
			if ((not self.lasttime) or (_time>(self.lasttime+6))) then
				--self:NotifyMessage("@pickup_not_possible [ @"..ammo_type.." ] @ammo_pickup_not_possible_trail", collider);
				
				-- send not possible ammo catch 	
				if (serverSlot) then
					serverSlot:SendCommand("HUD A "..ammo_type.." -1");
				end
				
				self.lasttime=_time;
			end
		end
		return nil;
	end

	if(curr_amount+to_add>max_ammo)then
		to_add=max_ammo-curr_amount;
	end

	if(to_add<=0)then 
		--ADD denial information
--		Hud.cannot_pickup=1;
		return nil;
	end
	
	--System:Log("TOADD "..tostring(to_add));
	collider:AddAmmo(ammo_type, to_add);	
	
	-- send ammo catch 	
	if (serverSlot) then
		serverSlot:SendCommand("HUD A "..ammo_type.." "..to_add);
	end	
	
	return (amount-to_add);
end
------------------------------------------------------
function __PickWeapon(self,collider, entering)
	local classid=Game:GetWeaponClassIDByName(self.weapon)
	local ws=collider.cnt:GetWeaponsSlots();
	local count=0;
	local has_weapon;
	local wpicked,apicked,apicked2;
	for i,val in ws do 
		if(val~=0) then 
			count=count+1;
			if(val.name==self.weapon)then has_weapon=1; break; end
		end 
	end
	
	if (count == 4) then
		self.hadFullSlots = 1;
	end
	
	if(count<4 and (not has_weapon))then
		if (collider.cnt.MakeWeaponAvailable) then 
			collider.cnt:MakeWeaponAvailable(classid);
			if (collider.cnt.weapon == nil) then
				collider.cnt:SelectFirstWeapon();
			else
				if (tonumber(p_weapon_switch) == 1 or (self.hadFullSlots == 1 and count == 3)) then
					collider.cnt:SetCurrWeapon(classid);
				end
			end
		
			--self:NotifyMessage("@YouPickedUpA @"..self.weapon, collider);
			
			-- send weapon catch 
			local serverSlot = Server:GetServerSlotByEntityId(collider.id);
			if (serverSlot) then
				serverSlot:SendCommand("HUD W "..classid);
			end
		
			wpicked=1;
		end
	end
	
	local ammo_amount  = self.Properties.Amount;
	local ammo_amount2 = self.Properties.Amount2;
	
	--System:Log("ammo1 "..tostring(ammo_amount));
	
	-- load correct ammo amount into the clips of the weapon
	if (wpicked) then
		--System:Log("wpicked 1");
		ammo_amount  = __LoadAmmoIntoClips(self, collider, classid, self.ammo_type, ammo_amount);
		ammo_amount2 = __LoadAmmoIntoClips(self, collider, classid, self.ammo_type2, ammo_amount2);
	end
	
	--System:Log("ammo2 "..tostring(ammo_amount));

	-- always get ammo and leave the rest in the pickup	
	local apicked = %__PickAmmo(self,collider, entering, self.ammo_type, ammo_amount);
	if (apicked==nil) then
		self.Properties.Amount = ammo_amount;
	else
		self.Properties.Amount = apicked;
	end
	local apicked2 = %__PickAmmo(self,collider, entering, self.ammo_type2, ammo_amount2);
	if (apicked2==nil) then
		self.Properties.Amount2 = ammo_amount2;
	else
		self.Properties.Amount2 = apicked2;
	end
	
	if (apicked or apicked2) then
		self.ammopicked = 1;
	end
	
	if(wpicked) then return 1; end
end
------------------------------------------------------
function CreateAmmoPickup(params)
	local ret=new(BasePickup);
	ret.ammo_type=params.ammotype;
	ret.model=params.model;
	ret.physics=1;
	--if(icon)then
		--ret.icon=icon;
		--ret.Client.Active.OnUpdate=_ClientActiveUpdate;
	--end
	if(params.default_amount)then
		ret.Properties.Amount=params.default_amount;
	end
	if(params.sound)then
		ret.sound=params.sound;
	end
	if(params.objectpos)then
		ret.objectpos = params.objectpos;
	end
	ret.Pick=__PickAmmo;
	ret.floating_icon="Objects/Pickups/Ammo/ammo_icon.cga";
	
	return ret;
end
------------------------------------------------------
function CreateWeaponPickup(params)
	local ret=new(BasePickup);
	ret.weapon=params.weapon;
	ret.model=params.model;
	ret.ammo_type=params.ammotype;
	ret.ammo_type2=params.ammotype2;
	ret.physics=1;
	if(params.default_amount)then
		ret.Properties.Amount=params.default_amount;
	end
	if(params.default_amount2)then
		ret.Properties.Amount2=params.default_amount2;
	end
	if(params.sound)then
		ret.sound=params.sound;
	end
	if(params.objectangles)then
		ret.objectangles = params.objectangles;
	end
	if(params.objectpos)then
		ret.objectpos = params.objectpos;
	end
	ret.Pick=__PickWeapon;
	ret.rotate90=1;
	ret.floating_icon="Objects/Pickups/Ammo/ammo_icon.cga";
	
	return ret;
end
------------------------------------------------------
function CreateCustomPickup(params)
	local ret=new(BasePickup);
	ret.bModelIsChoosable=params.modelchoosable;
	if (ret.bModelIsChoosable) then
		ret.Properties.object_Model=params.model;
	end
	ret.physics=1;
	ret.model=params.model;
	ret.bSoundIsChoosable=params.soundchoosable;
	if (ret.bSoundIsChoosable) then
		ret.Properties.sound_Sound=params.sound;
	end
	if(params.sound)then
		ret.sound=params.sound;
	end
	if(params.default_amount)then
		ret.Properties.Amount=params.default_amount;
	end
	if(params.default_amount2)then
		ret.Properties.Amount2=params.default_amount2;
	end
	if(params.objectpos)then
		ret.objectpos = params.objectpos;
	end
	ret.floating_icon=params.floating_icon;
	ret.Pick=params.func;
	ret.doesnt_expire=params.doesnt_expire;
	ret.bhaptics_effect=params.bhaptics_effect;
	
	return ret;
end
