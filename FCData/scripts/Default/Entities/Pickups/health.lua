Script:LoadScript("scripts/default/entities/pickups/basepickup.lua");

local funcPick=function (self, collider, entering)

--	printf("collider health is %d < %d >  tm< %d >", collider.cnt.health, self.Properties.Amount, self.Properties.RespawnTime);

	if(collider.cnt.health>=collider.cnt.max_health)then
		if (entering == 1) then
			if ((not self.lasttime) or (_time>(self.lasttime+6))) then
			
				-- send health cannot catch 
				local serverSlot = Server:GetServerSlotByEntityId(collider.id);
				if (serverSlot) then
					serverSlot:SendCommand("HUD P 2 -1"); -- hud, generic pick, health, not available
				end
				
				--self:NotifyMessage("@medi_pickup_not_possible", collider);
				self.lasttime=_time;
			end
		end
		return nil;
	end	

	collider.cnt.health = collider.cnt.health + floor(self.Properties.Amount*(collider.cnt.max_health/100.0));
	if(collider.cnt.health>collider.cnt.max_health)then
		collider.cnt.health=collider.cnt.max_health;
	end
	
	-- send health catch 
	local serverSlot = Server:GetServerSlotByEntityId(collider.id);
	if (serverSlot) then
		serverSlot:SendCommand("HUD P 2 "..self.Properties.Amount); -- hud, generic pick, health, not available
	end
	--self:NotifyMessage("@YouPickedUp "..self.Properties.Amount.." @UnitsOf @Health",collider);
	
	--play some healing sounds when players get health
	--local healingsounds = collider.HealingSounds;
	--if (healingsounds and getn(healingsounds)~=0) then
		--collider:PlaySound(healingsounds[random(1,getn(healingsounds))],1);
	--end

	-- multiplayer statistics
	local colliderSSID = (Server:GetServerSlotByEntityId(collider.id)):GetId();
	
	if (self.shooterSSID and colliderSSID~=self.shooterSSID) then-- if the health packed was launched by a player, and if this player is not the same that launched the heal
		if (self.LaunchedByTeam == Game:GetEntityTeam(collider.id)) then
			MPStatistics:AddStatisticsDataSSId(self.shooterSSID,"nHealed", 1);
		end		
	end
	
	return 1;
end

local params={
	func=funcPick,
	model="Objects/pickups/health/medikit.cgf",
	default_amount=50,
	sound="sounds/items/generic_pickup.wav",
	modelchoosable=nil,
	soundchoosable=nil,
	floating_icon="Objects/Pickups/health/health_icon.cga",
	bhaptics_effect="heal"
}

Health=CreateCustomPickup(params);


Health._OnInit=Health.Client.OnInit;
function Health.Client:OnInit()
	if (Player) then
		self.soundtbl=Player.HealingSounds;
	else
		self.soundtbl={Sound:Load3DSound("SOUNDS/player/relief1.wav",SOUND_UNSCALABLE,175,5,30),};
	end
	self:_OnInit();
	self:SetViewDistRatio(255);
end


Health.PhysParam = {
	mass = 10,
	size = 0.15,
	heading = {x=0,y=0,z=-1},
	initial_velocity = 6,
	k_air_resistance = 0,
	acc_thrust = 0,
	acc_lift = 0,
	--high friction material
	surface_idx = Game:GetMaterialIDByName("mat_pickup"),
	gravity = {x=0, y=0, z=-9.8 },
	collider_to_ignore = nil,
	flags = bor(particle_constant_orientation,particle_no_path_alignment, particle_no_roll, particle_traceable),
}




function Health:Launch( weapon, shooter, pos, angles, dir, target )

	self:SetPhysicParams( PHYSICPARAM_PARTICLE, self.PhysParam );
	self.autodelete = 1;
	self.deleteOnGameReset = 1;
	self:EnableSave(nil);
	self:GotoState("Dropped");
	-- fade away after 15 seconds
	self.Properties.FadeTime = 15;
	self.Properties.Amount = 45;--30
--	self:SetTimer(15000);

--  	dirs = {x=0,y=0,z=0};
--  	dirn = {x=dir.x,y=dir.y,z=dir.z}; 
--  	NormalizeVector(dirn); 
--  	FastScaleVector(dirn,dirn,0.15); FastScaleVector(dirs,dir,1.5);
--	local hits = System:RayWorldIntersection(pos,SumVectors(dirs,dirn),1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid);
--	if (hits and getn(hits)>0) then
--		pos = DifferenceVectors(hits[1].pos,dirn);
--	else
--	  pos.x = pos.x + dirs.x;
--	  pos.y = pos.y + dirs.y;
--	  pos.z = pos.z + dirs.z;
--	end

	local direction = g_Vectors.temp_v1;
	local dest = g_Vectors.temp_v2;
		
	CopyVector(direction,dir);
		
	dest.x = pos.x + direction.x * 1.5;
	dest.y = pos.y + direction.y * 1.5;
	dest.z = pos.z + direction.z * 1.5;
		
	local hits = System:RayWorldIntersection(pos,dest,1,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid,shooter.id);
		
	if (hits and getn(hits)>0) then
			
		local temp = hits[1].pos;
		
		dest.x = temp.x - direction.x * 0.15;
		dest.y = temp.y - direction.y * 0.15;
		dest.z = temp.z - direction.z * 0.15;
	end
	
	shooter:AwakeEnvironment();

	self:SetPos( dest );--pos );
	self:SetAngles( angles );
	self:NetPresent(1);
	
	-- the ID of the server slot who initiated the action
	-- used for statistics
	local serverSlot = Server:GetServerSlotByEntityId(shooter.id);
	
	if (serverSlot) then
		self.shooterSSID = serverSlot:GetId();
	end
	
	self.LaunchedByTeam=Game:GetEntityTeam(shooter.id);
end


