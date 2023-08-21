Hud={
	
	color={r=0.66,g=0.8,b=0.8},	
	color_top={r=0.66,g=1.0,b=1.0},	
	color_red={1, 0.0, 0.0,1}, --color_red={1, 0.3, 0.3,1}, previous red..
	color_blue={0.1 ,0.6,0.75,1},
	color_yellow={1,1,0,1},
	color_white={1,1,1,1},
	
	dmgindicator=0,
	dmgfront=0,
	dmgback=0,
	dmgleft=0,
	dmgright=0,
	sound_scale=1,
	hit=0,
	
	text_widthscale = 0.65,
	
	messages={},
	kill_messages={},
	tSubtitles={},
	fSubtlCurrY=0.0,
	fSubtlCurrDelay=0.0,
	grenade_blink=0,
	deafness_fadeout_time=5, -- lennert
	breathlevel=-1,			 -- marco
	staminalevel=-1,		 -- tiago

	blindingFade = 1,		 -- kirill
	
	-- Tiago: added
	radar_transparency = 0.0,        
	stamina_level = 64.5,
	breath_level = 64.5,
	
	radarObjective = nil,	-- current radar objective tag point e.g. {x=1,y=2,z=3}
	meleeDamageType=nil,	-- [tiago] melee damage type
	
	DisplayControl = {
		bShowRadar = 1,
		bBlinkRadar = 0,
		fBlinkUpdateRadar = 0,
		
		bShowProjectiles = 1,
		bBlinkProjectiles = 0,
		fBlinkUpdateProjectiles = 0,
		
		bShowBreathOM = 1,
		bBlinkBreathOM = 0,
		fBlinkUpdateBreathOM = 0,
		
		bShowWeapons = 1,
		bBlinkWeapons = 0,
		fBlinkUpdateWeapons = 0,
		
		bShowAmmo = 1,
		bBlinkAmmo = 0,
		fBlinkUpdateAmmo = 0,
		
		bShowStance = 1,				
		bBlinkStance = 0,		
		fBlinkUpdateStance = 0,		
		
		bShowEnergyMeter =1,		
		bBlinkEnergyMeter =0,	
		fBlinkUpdateEnergyMeter=0,		
	},

	idShowMissionObject=nil,			-- used to identify the one active Message entity, nil for non

	-- progress indicators
	Progress=
	{
		Player=							-- player progress indicator
		{
			LocalToken=nil,		-- nil if there is no progress to show e.g. "build progress"
			ValueX=nil,				-- 0..100 e.g. 50, nil if unused
			ValueY=nil,				-- 0..100 e.g. 50, nil if unused
			ValueZ=nil,				-- 0..100 e.g. 50, nil if unused
			EndTime=nil,			-- time when the indicator should disapper (nil if not used)
			Seconds=1.0,			-- amount of seconds this indicator should stay (nil=forever)
			Draw=nil,					-- draw function ... specified below
		},

		AssaultState=				-- progress indicator for showing the state of the Assault game (captured checkpoints)
		{
			LocalToken=nil,		-- nil if there is no progress to show e.g. 
			ValueX=nil,				-- 0..100 e.g. 50, nil if unused
			ValueY=nil,				-- 0..100 e.g. 50, nil if unused
			ValueZ=nil,				-- 0..100 e.g. 50, nil if unused
			EndTime=nil,			-- time when the indicator should disapper (nil if not used)
			Seconds=nil,			-- amount of seconds this indicator should stay (nil=forever)
			Draw=nil,					-- draw function ... specified below
		},
	},

	SndIdMPHit=nil,				-- sound id, for a Multiplayer hit, cannot be local because of garbage collector	
	
	-- Create Table for players.
	tblPlayers = {},								
	
	pViewLayersTbl= {},
	bActivateLayers=0,
}

	
-----------------------------------------------------------------------------
function Hud:DrawRightAlignedString(text_size, text_print, sizex, sizey, r, g, b, a, y, spacing)
	local w, h = Game:GetHudStringSize(text_size, sizex, sizey);
	local x = 800 - spacing - w;

	Game:WriteHudString(x, y, text_print, r, g, b, a, sizex, sizey);
end

-----------------------------------------------------------------------------
-- clamp value into specified range..
-----------------------------------------------------------------------------

function Hud:ClampToRange(val, minval, maxval) 
	if(val<minval) then
		val=minval;
	elseif(val>maxval)then
		val=maxval;
	end	
	return val;
end

-----------------------------------------------------------------------------
-- draw function for 'player' progress indicator
-----------------------------------------------------------------------------

Hud.Progress.Player.Draw = function(hud)
	%Game:SetHUDFont("hud", "ammo");
	local PTable = Hud.Progress.Player;
	local text=PTable.LocalToken;
	local strsizex,strsizey = Game:GetHudStringSize(text, 26, 26);
	local strwidth = strsizex;		
	local size=(strwidth+10)/200;
	
	-- text box
	local ypos=300-10;	

	local fStep=42/70;
	hud:DrawScoreBoard(400-(strwidth*0.5)-10, ypos, size, fStep, 100, hud.tmpscoreboard.bar_score, 1, 1, 1, 1, 0, 0);			
	ypos=ypos+42;
	hud:DrawScoreBoard(400-(strwidth*0.5)-10, ypos, size, 1, 100, hud.tmpscoreboard.bar_bottom, 1, 1, 1, 1, 0, 0);
		
	if(PTable.ValueX)then				-- progress was given
		local r=0;
		local g=0;
		local b=0;
		local progressStep=(PTable.ValueX/100);			
		g = 1.0 + (g-1.0) * progressStep;
		if(g>=1) then g=1; end;		
		r = r + (1.0-r) * progressStep;
		if(r>=1) then r=1; end;
						
		hud:DrawBar(400-(strwidth*0.5)-5, 320, progressStep*strwidth*1.28 ,32, 35, g, r, 0, 0.8);

	else												-- no progress was given (e.g. cannot build because construction are is blocked)

		hud:DrawElement(395, ypos-10, hud.pickups[19],  1, 1, 1, 0.9);		
		
	end
	
	Game:WriteHudString(400-(strwidth*0.5)+10, 300, text,  1, 1, 1, 1, 26, 26);			    -- information text 
end

-----------------------------------------------------------------------------
-- draw function for 'AssaultState' progress indicator
-----------------------------------------------------------------------------

Hud.Progress.AssaultState.Draw = function(hud)
	local PTable = Hud.Progress.AssaultState;
	local iItemCount=PTable.ValueZ;				-- e.g. 5 for 5 ASSAULTCheckpoints
	local iItemCurrent=0;
	local xStep=50; -- icon size is 50
	local x, y=35, 35; 

	local FrameTime=_frametime;
	
	while  iItemCurrent < iItemCount do
		if(iItemCurrent	== tonumber(PTable.ValueX)) then
			
			local iCurrState=tonumber(PTable.ValueY);	
			
			-- default and max scale
			local itemScale, itemMaxScale=0.66,0.85;
			
			-- state has changed ?
			if(hud.ProgressStateTime~=0.0) then
				hud.ProgressStateTime=hud.ProgressStateTime-FrameTime*2;
				
				-- scale item (using bezier..)
				local scaleSqrAmount=hud.ProgressStateTime*hud.ProgressStateTime;
				local invScaleAmount=1-hud.ProgressStateTime;
				local invSqrScaleAmount=invScaleAmount*invScaleAmount;
				itemScale=0.66*(invSqrScaleAmount+scaleSqrAmount)+2*itemMaxScale*invScaleAmount*hud.ProgressStateTime;
				
				-- reset animation
				if(hud.ProgressStateTime<0.0) then
					hud.ProgressStateTime=0.0;
					itemScale=0.66;								
				end
			end																			
			-- state changed ? activate scaling			
			if(hud.ProgressPreviousState~=iCurrState and hud.ProgressPreviousState~=-1 and iCurrState>0) then
				hud.ProgressStateTime=1.0;				
			end																						
			if(iCurrState==0) then							
				hud:DrawQuadMP(x, y, 0.66, 0.66, 100, hud.tmultiplayerhud.progressi_changing, 1, 1, 1, 1, 0, 0);
			elseif(iCurrState==1) then
				hud:DrawQuadMP(x, y, itemScale, itemScale, 100, hud.tmultiplayerhud.progressi_current, 1, 1, 1, 1, 0, 0);
			elseif(iCurrState==2) then
				hud:DrawQuadMP(x, y, itemScale, itemScale, 100, hud.tmultiplayerhud.progressi_01, 1, 1, 1, 1, 0, 0);									
			elseif(iCurrState==3) then
				hud:DrawQuadMP(x, y, itemScale, itemScale, 100, hud.tmultiplayerhud.progressi_02, 1, 1, 1, 1, 0, 0);									
			elseif(iCurrState==4) then
				hud:DrawQuadMP(x, y, itemScale, itemScale, 100, hud.tmultiplayerhud.progressi_03, 1, 1, 1, 1, 0, 0);													
			elseif(iCurrState==5) then
				hud:DrawQuadMP(x, y, itemScale, itemScale, 100, hud.tmultiplayerhud.progressi_04, 1, 1, 1, 1, 0, 0);													
			end		
			
			-- save current state
			hud.ProgressPreviousState= iCurrState;											
		elseif( iItemCurrent < tonumber(PTable.ValueX)) then
			hud:DrawQuadMP(x, y, 0.66, 0.66, 100, hud.tmultiplayerhud.progressi_done, 1, 1, 1, 1, 0, 0);					
		else
			hud:DrawQuadMP(x, y, 0.66, 0.66, 100, hud.tmultiplayerhud.progressi_unavailable, 1, 1, 1, 1, 0, 0);																
		end
															
		-- increment position
		x=x+xStep;				
					
		-- increment item count...
		iItemCurrent= iItemCurrent + 1;					
	end
	
	-- render..
	hud.mp_rend:Draw(hud.tx_multiplayerhud);
end

-----------------------------------------------------------------------------
-- set radar objective
-----------------------------------------------------------------------------

function Hud:SetRadarObjective(tagPointName)
   Hud:SetRadarObjectivePos( Game:GetTagPoint(tagPointName) );    
   self.bBlinkObjective=1;
end

-----------------------------------------------------------------------------
-- set radar objective to xyz position e.g. {x=1,y=2,z=3}
-----------------------------------------------------------------------------

function Hud:SetRadarObjectivePos(Pos)
   Hud.radarObjective=new(Pos);    
end

------------------------------------
-- Callback for sorting messages
------------------------------------
						
function message_compare(a,b)
	if(a and b) then			
		if(a.lifetime>b.lifetime)then 
			return 1
		end	
	end
end

-----------------------------------------------------------------------------
-- Process messages box, message list
-----------------------------------------------------------------------------

function Hud:ProcessAddMessage(tMsgList, text, lifetime, beep, killmsg) 					
		
	-- check for same timed messages, increase recent ones timming for correct sorting
	if(tMsgList and tMsgList[count(tMsgList)] and  tMsgList[1].lifetime) then
		if(tMsgList[1].lifetime>=6) then
			lifetime=tMsgList[1].lifetime+0.01; 		
		end
	end
						
	local isOnTop=0;
	if(not killmsg) then	
		isOnTop=1;		
	end
			
	tMsgList[count(tMsgList)+1]= {
		killmsg = killmsg,
		time=_time,
		text=text,
		lifetime=lifetime, 
		curr_ypos=0, 
		isTop=isOnTop,
	};
	
	-- only necessary for non-killmsg's
	if(not killmsg) then	
		local i=1;
		local k=count(tMsgList);
		while(i<k) do
			tMsgList[i].isTop=0;
			i=i+1;		
		end			
	end
	
	-- sort table items by lifetime	
	sort(tMsgList,%message_compare);				
	
	-- remove old messages
	while (count(tMsgList)>4) do
		tMsgList[count(tMsgList)]=nil;									
	end	

	if(cl_msg_notification=="1" and (not Game:IsMultiplayer()) and beep and beep==1) then
		Sound:PlaySound(self.NewMessageSnd);
	end
end

-----------------------------------------------------------------------------
-- add new messages to messages box
-----------------------------------------------------------------------------

function Hud:AddMessage(text,_lifetime, beep, killmsg)					
	-- need to process also kill messages in mp game
	-- NOTE: must have constant time (requested, don't change!)
	if(Game:IsMultiplayer() and killmsg and killmsg==1) then		
		self:ProcessAddMessage(self.kill_messages, text, 6, beep, 1);							
	else
		self:ProcessAddMessage(self.messages, text, 6, beep);					
	end					
end

-----------------------------------------------------------------------------
-- Set current screen center message
-----------------------------------------------------------------------------

function Hud:AddCenterMessage(text,time)
	self.centermessage=text;
	if(time)then
		self.centermessagetime=time;
	else
		self.centermessagetime=1;
	end
end

-----------------------------------------------------------------------------
-- Initialize sp hud texture, texture coordinates offsets
-----------------------------------------------------------------------------

function Hud:InitTexTable(tt)
	local tw,th=511,255;
	for i,val in tt do
		val.size={}
		val.size.w=val[3];
		val.size.h=val[4];
		val[1]=val[1]/tw;
		val[2]=val[2]/th;
		val[3]=val[1]+(val[3]/tw);
		val[4]=val[2]+(val[4]/th);
	end
end

-----------------------------------------------------------------------------
-- merge tables
-----------------------------------------------------------------------------

function merge_no_copy(dest,source)
	for i,val in source do
		if(type(dest[i])==type(val))then
			if(type(dest[i])~="table")then
				dest[i]=val;
			else
				merge_no_copy(dest[i],val);
			end
		end
	end
end

-----------------------------------------------------------------------------
-- save hud mission data
-----------------------------------------------------------------------------

function Hud:OnSave(stm)

	-- save radar objective
	if (self.radarObjective==nil) then
		stm:WriteBool(0);
	else
		stm:WriteBool(1);
		WriteToStream(stm, self.radarObjective);		
	end		
	
	-- save mission objective
	if(self.objectives==nil) then
		stm:WriteBool(0);
	else
		stm:WriteBool(1);
		WriteToStream(stm, self.objectives);			
	end		
	
	-- save hud messages
	if(Hud.messages==nil) then
		stm:WriteBool(0);
	else
		stm:WriteBool(1);
		WriteToStream(stm, Hud.messages);	
	end
		
	-- save hit damage data
	if(not self.hitdamagecounter) then
		stm:WriteBool(0);
	else
		stm:WriteBool(1);
		stm:WriteFloat(self.hitdamagecounter);		
	end				
	
	stm:WriteFloat(self.dmgfront);											
	stm:WriteFloat(self.dmgback);											
	stm:WriteFloat(self.dmgleft);											
	stm:WriteFloat(self.dmgright);											
				
	-- save hud state
	if(self.DisplayControl==nil) then
		stm:WriteBool(0);
	else
		stm:WriteBool(1);
		WriteToStream(stm, self.DisplayControl);				
	end
		    
  -- save flashbang state
  local bFlashBangActive=System:GetScreenFx("FlashBang");
  if(bFlashBangActive and bFlashBangActive==1) then
  	stm:WriteBool(1);  
	  local fFlashBangTimeScale=  System:GetScreenFxParamFloat("FlashBang", "FlashBangTimeScale");	
		stm:WriteFloat(fFlashBangTimeScale);			  	

	  local fFlashBangTimeOut=  System:GetScreenFxParamFloat("FlashBang", "FlashBangTimeOut");	
		stm:WriteFloat(fFlashBangTimeOut);			  	

	  local fFlashBangFlashPosX=  System:GetScreenFxParamFloat("FlashBang", "FlashBangFlashPosX");	
		stm:WriteFloat(fFlashBangFlashPosX);			  	
	  
	  local fFlashBangFlashPosY=  System:GetScreenFxParamFloat("FlashBang", "FlashBangFlashPosY");		  
		stm:WriteFloat(fFlashBangFlashPosY);			  	
	  
	  local fFlashBangFlashSizeX=  System:GetScreenFxParamFloat("FlashBang", "FlashBangFlashSizeX");	
		stm:WriteFloat(fFlashBangFlashSizeX);			  	
	  
	  local fFlashBangFlashSizeY=  System:GetScreenFxParamFloat("FlashBang", "FlashBangFlashSizeY");	    
		stm:WriteFloat(fFlashBangFlashSizeY);			  	
  else
  	stm:WriteBool(0);  
  end

	-- save deafness
	if (Hud.initial_deaftime==nil) then
		stm:WriteBool(0);
	else
		stm:WriteBool(1);
		stm:WriteFloat(Hud.initial_deaftime);
	end	

	if (Hud.deaf_time==nil) then
		stm:WriteBool(0);
	else
		stm:WriteBool(1);
		stm:WriteFloat(Hud.deaf_time);
	end	
    					
end

-----------------------------------------------------------------------------
-- load old hud mission data (to maintain saves games compatibility..)
-----------------------------------------------------------------------------

function Hud:OnLoadOld(stm)	

	-- load radar objective	
	local bObj=stm:ReadBool();
	if (bObj) then
		self.radarObjective=ReadFromStream(stm);
	end
	
	-- load mission objective	
	bObj=stm:ReadBool();	
	if (bObj) then		
		self.objectives=ReadFromStream(stm);
	end	
	
	-- load hud state..
	bObj=stm:ReadBool();	
	if(bObj) then		
		self.DisplayControl=ReadFromStream(stm);
	end
								
end

-----------------------------------------------------------------------------
-- load hud mission data
-----------------------------------------------------------------------------

function Hud:OnLoad(stm)	

	-- load radar objective	
	local bObj=stm:ReadBool();
	if (bObj) then
		self.radarObjective=ReadFromStream(stm);
	end
	
	-- load mission objective	
	bObj=stm:ReadBool();	
	if (bObj) then		
		self.objectives=ReadFromStream(stm);
	end	
	
	-- load messages
	bObj=stm:ReadBool();
	if(bObj) then
		Hud.messages=ReadFromStream(stm);
	end
	
	-- load hit damage data
	bObj=stm:ReadBool();	
	if(bObj) then		
		self.hitdamagecounter=stm:ReadFloat();		
	end	

	self.dmgfront=stm:ReadFloat();								
	self.dmgback=stm:ReadFloat();			
	self.dmgleft=stm:ReadFloat();				
	self.dmgright=stm:ReadFloat();					
		
	-- load hud state
	bObj=stm:ReadBool();	
	if(bObj) then		
		self.DisplayControl=ReadFromStream(stm);
	end

	-- load flashbang state
	bObj=stm:ReadBool();	
	if(bObj) then		
	  local fFlashBangTimeScale=stm:ReadFloat();								  
	  System:SetScreenFxParamFloat("FlashBang", "FlashBangTimeScale", fFlashBangTimeScale);	

	  local fFlashBangTimeOut=stm:ReadFloat();								  
	  System:SetScreenFxParamFloat("FlashBang", "FlashBangTimeOut", fFlashBangTimeOut);	
			  
	  local fFlashBangFlashPosX= stm:ReadFloat();								  
	  System:SetScreenFxParamFloat("FlashBang", "FlashBangFlashPosX", fFlashBangFlashPosX);	
			  
	  local fFlashBangFlashPosY= stm:ReadFloat();								  
	  System:SetScreenFxParamFloat("FlashBang", "FlashBangFlashPosY", fFlashBangFlashPosY);		  
			  
	  local fFlashBangFlashSizeX= stm:ReadFloat();								  
	  System:SetScreenFxParamFloat("FlashBang", "FlashBangFlashSizeX", fFlashBangFlashSizeX);			
	  
	  local fFlashBangFlashSizeY= stm:ReadFloat();								   
	  System:SetScreenFxParamFloat("FlashBang", "FlashBangFlashSizeY", fFlashBangFlashSizeY);	    		
	  
	  -- activate it
	  System:SetScreenFx("FlashBang", 1);	    			  
	  System:SetScreenFxParamFloat("FlashBang", "FlashBangForce", 1);	    				
	end

	-- load deafness
	bObj=stm:ReadBool();
	if (bObj) then
  		Hud.initial_deaftime=stm:ReadFloat();
	end

	bObj=stm:ReadBool();
	if (bObj) then
		Hud.deaf_time=stm:ReadFloat();
	end	

							
end

-----------------------------------------------------------------------------
-- Initialize all data
-----------------------------------------------------------------------------

function Hud:CommonInit()
	
	Language:LoadStringTable("HUD.xml");	
	Game:CreateVariable("hud_damageindicator",1);
	
	-- hud textures
	
	-- damage indicator icons	
	self.damage_icon_lr=System:LoadImage("Textures/hud/damage_gradL.dds");
	self.damage_icon_ud=System:LoadImage("Textures/hud/damage_gradT.dds");
	
	-- mission textures
	self.missioncheckbox=System:LoadImage("Textures/Hud/new/MissionBoxCheckbox.tga");
	self.missioncheckboxcomp=System:LoadImage("Textures/Hud/new/MissionCheckboxComp.tga");
	-- [Michael G.], texture not used???
	-- self.missionboxframe=System:LoadImage("Textures/Hud/new/MissionBoxFrame.tga");
	self.radimessageicon=System:LoadImage("Textures/Hud/new/RadiomessageIcon.tga");
	
	-- general use textures
	self.white_dot=System:LoadImage("Textures/hud/white_dot.tga");
	self.black_dot=System:LoadImage("Textures/hud/black_dot.tga");
	self.blue=System:LoadImage("Textures/hud/blue.dds");

	--	self.flashlight_blinding=System:LoadImage("Textures/flight");
	self.flashlight_blinding=System:LoadImage("Textures/fl");	

	-- keycard icons
	self.KeyItem= {
		System:LoadImage("Textures/hud/keyItem_red.dds"),
		System:LoadImage("Textures/hud/keyItem_green.dds"),
		System:LoadImage("Textures/hud/keyItem_blue.dds"),		
		System:LoadImage("Textures/hud/keyItem_yellow.dds"),
	}
	
	-- object icons
	self.ObjectItem= {
		System:LoadImage("Textures/hud/ExpItem.dds"),
		System:LoadImage("Textures/hud/PDAItem.dds"),
		System:LoadImage("Textures/hud/BombfuseItem.dds"),
		System:LoadImage("Textures/hud/scouttool_item.dds"),
	}
	
	self.underbreathvalue=1;	
		
  	-- radar textures
	self.Radar=System:LoadImage("Textures/hud/compass.dds");
	self.RadarMask=System:LoadImage("Textures/hud/compass_mask.dds");				
	self.RadarPlayerIcon=System:LoadImage("Textures/hud/RadarPlayer.dds");
	self.RadarEnemyInRangeIcon=System:LoadImage("Textures/hud/RadarEnemyInRange.dds");	
	self.RadarEnemyOutRangeIcon=System:LoadImage("Textures/hud/RadarEnemyOutRange.dds");	
	self.RadarSoundIcon=System:LoadImage("Textures/hud/RadarSound.dds");
	self.RadarObjectiveIcon=System:LoadImage("Textures/hud/RadarPlayer.dds");
	
	------------------------------------------------------------------------------------
	--	NEW HUD
	------------------------------------------------------------------------------------	
	
	local path="Textures/hud/";	
	self.rend=Game:CreateRenderer();
	
	-- hud main texture
	self.tx_hud=System:LoadImage(path.."hud.dds");

	-- temporary vars..	
	self.curr_stamina=100;
	self.curr_armor=0;
	self.curr_health=100;
	self.curr_healthAlpha=1;
	self.curr_vehicledamage=0;
	self.curr_vehicledamageAlpha=1;
	self.curr_stealth=0;
	self.curr_motiontrackerAlpha=1;
			
	-- hud main texture, position/offsets
	-- position(x,y), size(width,height)	
	self.txi={
		shape_bar={ 113, 40, 75, 27},		
		white_dot={1, 1, 2, 2},		
		health_bar={230, 204, 172, 51},				
		ammo_bar={404, 205, 109, 51},				
		health_inside={389, 11, 115, 10},		
		stamina_inside = { 376, 26, 116, 10},
		armor_inside={ 366, 41, 116, 10},						
		oxygen_frame={484,83,18,86},						
		shape_stealth_left = { 427, 135, 38, 67},	
		sealth_inside_left = { 429,  62, 33, 63},		
		shape_stealth_right = { 466, 134, 39, 68},	
		sealth_inside_right = { 469,  61, 33, 63},		
		shape_googles_energy = { 345, 146, 71, 21},
		googles_energy_inside = {349, 182, 64, 13},
		flashlight_on = {212, 170, 32, 32},
		motiontracker_border = { 341, 6, 30, 24 },
		motiontracker_signal = { 345, 31, 14, 14 },
	}
										
	self.tnum={
		[0]={ 7, 16, 8, 13},
		[1]={15, 16, 8, 13},
		[2]={25, 16, 8, 13},
		[3]={35, 16, 8, 13},
		[4]={47, 16, 8, 13},
		[5]={57, 16, 8, 13},
		[6]={68, 16, 8, 13},
		[7]={78, 16, 8, 13},
		[8]={88, 16, 8, 13},
		[9]={99, 16, 8, 13},
	}

	self.tnum_small={
		[0]={ 7, 36, 7, 10},
		[1]={14, 36, 7, 10},
		[2]={21, 36, 7, 10},
		[3]={29, 36, 7, 10},
		[4]={38, 36, 7, 10},
		[5]={46, 36, 7, 10},
		[6]={54, 36, 7, 10},
		[7]={62, 36, 7, 10},
		[8]={70, 36, 7, 10},
		[9]={78, 36, 7, 10},
	}

	self.tweapons={
		[21]=	{  1,  71,  53,  18},  -- Shocker
		[13]=	{  4, 104,  50,  16}, -- Machete
		[15]=	{  2, 136,  54,  14}, -- SniperRifle
		[20]=	{  0, 162,  57,  25}, -- M4
		[10]=	{ 12, 195,  32,  22}, -- Falcon
		[12]=	{ 56, 164,  56,  23}, -- MP5
		[11]=	{  0, 226,  58,  21}, -- AG36
		[14]=	{144, 195,  51,  18}, -- Shotgun
		[19]=	{145, 162,  52,  24}, -- P90
		[16]=	{144, 130,	52,  24}, -- OICW
		[18]=	{145,  99,	53,  26}, -- RL
		[22]=	{144,  71,	54,  20}, -- M249
		[29]=	{ 60, 103,	56,  17}, -- Wrench
		[27]={ 63, 105,51,  12}, -- EngineerTool (duplicated ?)
		[28]=	{ 68, 193,	25,  25}, -- MedicTool
		[30]=	{ 56, 221, 50, 24}, -- ScoutTool
	}

	self.mpKills={
		Shocker=	{  1,  71,  53,  18},  -- Shocker
		Machete=	{  4, 104,  50,  16}, -- Machete
		SniperRifle=	{  2, 136,  54,  14}, -- SniperRifle
		M4=	{  0, 162,  57,  25}, -- M4
		Falcon=	{ 12, 195,  32,  22}, -- Falcon
		MP5=	{ 56, 164,  56,  23}, -- MP5
		AG36=	{  0, 226,  58,  21}, -- AG36
		AG36Grenade ={  0, 226,  58,  21}, -- AG36
		Shotgun=	{144, 195,  51,  18}, -- Shotgun
		P90=	{145, 162,  52,  24}, -- P90
		OICW=	{144, 130,	52,  24}, -- OICW
		OICWGrenade = {144, 130,	52,  24}, -- OICW
		RL=	{145,  99,	53,  26}, -- RL
		Rocket=	{145,  99,	53,  26}, -- RL/Rocket
		M249=	{144,  71,	54,  20}, -- M249
		Wrench=	{ 60, 103,	56,  17}, -- Wrench
		EngineerTool=	{ 63, 105,	51,  12}, -- EngineerTool (duplicated ?)
		MedicTool=	{ 68, 193,	25,  25}, --MedicTool
		ScoutTool=	{ 56, 221, 50, 24}, -- ScoutTool				
		Suicided= { 110, 193, 24, 24},  -- Suicided		
		Vehicle = { 345, 63, 76, 34 }, -- vehicle damage				
		StickyExplosive = { 56, 221, 50, 24},				
		HandGrenade={167, 219, 22, 31},		-- grenade damage
		BaseHandGrenade={167, 219, 22, 31},		-- grenade damage
				
		VehicleMountedAutoMG = { 60, 133, 51, 21 },	-- mounted weapons
		MountedMiniGun= { 60, 133, 51, 21 },	-- mounted weapons
		VehicleMountedMG = { 60, 133, 51, 21 },	-- mounted weapons
		VehicleMountedRocketMG = { 60, 133, 51, 21 },
		VehicleRocket = { 60, 133, 51, 21 },		
		VehicleMountedRocket = { 60, 133, 51, 21 },
		MountedWeaponVehicle = { 60, 133, 51, 21 },
		MountedWeaponBase =  { 60, 133, 51, 21 },
		MountedMortar= { 60, 133, 51, 21 },
		Mounted= { 60, 133, 51, 21 },		
		MG = { 60, 133, 51, 21 },
		MountedWeaponMG  = { 60, 133, 51, 21 },		
		MortarMountedWeapon = { 60, 133, 51, 21 },
		COVERRL = { 60, 133, 51, 21 },
		Mortar = { 60, 133, 51, 21 },		
		Buggy = { 345, 63, 76, 34 }, -- vehicle damage		
		FWDVehicle = { 345, 63, 76, 34 }, -- vehicle damage		
		InflatableBoat = { 260, 142, 81, 32 }, -- vehicle damage		
		BoatPatrol = { 260, 142, 81, 32 }, -- vehicle damage	
		Boat = { 260, 142, 81, 32 }, -- vehicle damage							
	}
		
						
	self.tgrenades={
		Rock={109, 218, 22, 31},
		HandGrenade={167, 219, 22, 31},
		SmokeGrenade={193, 219, 22, 31},		
		FlashbangGrenade={142, 219, 22, 31},
	}
	
	self.wicons={
		melee={120, 118, 23, 24},
		auto={120, 92, 23, 24},
		single={120, 67, 23, 24},
		grenade={120, 143, 23, 24},
		rocket={120, 167, 23, 24},
	}
	
	self.scoreboard={
		background={159, 50, 2, 2},
		corner ={123, 1, 33, 33},
	}
	
	self.mischolders={		
		car_damage_frame= { 345, 63, 76, 34 },
		car_damage_inside= { 350, 107, 67, 24 },
		boat_damage_frame= { 260, 142, 81, 32 },
		boat_damage_inside= { 267, 177, 68, 20 },
		googles_energy_frame= { 1, 1, 1, 1 },
		googles_energy_inside= { 1, 1, 1, 1 },
	}
	
	self.pickups= {
		{ 64, 189, 32, 32}, -- health, 1
				
		{ 242, 6, 32, 32}, -- assault, 2
		{ 274, 6, 32, 32}, -- smg, 3
		{ 307, 6, 32, 32}, -- sniper, 4	
		
		{ 210, 38, 32, 32}, -- pistol, 5
		{ 242, 38, 32, 32}, -- shotgun, 6
		{ 274, 38, 32, 32}, -- flashbang grenade, 7
		{ 307, 38, 32, 32}, -- smoke grenade, 8
		
		{ 210, 70, 32, 32}, -- rocket, 9
		{ 242, 70, 32, 32}, -- ag36 grenade, 10
		{ 274, 70, 32, 32}, -- oicw grenade, 11
		{ 307, 70, 32, 32}, -- grenade, 12
		
		{ 210, 102, 32, 32}, -- cryvision googles, 13
		{ 242, 102, 32, 32}, -- armor, 14
		{ 274, 102, 32, 32}, -- binoculars, 15
		{ 307, 102, 32, 32}, -- rock, 16
		
		{ 210, 6, 32, 32}, -- flashlight, 17
		{ 177, 2, 32, 32}, -- universal ammo - 18
				
		{ 211, 137, 32, 32 }, -- red cross, 19				
	}
		
	self.ammoPickupsConversionTbl= {
		Pistol= 4,
		Assault= 1,
		SMG= 2,
		OICWGrenade= 10,
		Shotgun= 5,
		Rocket= 8,
		Sniper= 3, 
		AG36Grenade= 9,		
		HandGrenade=11,
		FlashbangGrenade=6,
		SmokeGrenade=7,						
	}
	
	self.genericPickupsConversionTbl= {
		13, -- armor
		 0, -- health
		15, -- rock
		11, -- grenade
		 6, -- flashbang grenade
		 7, -- smoke grenade
		16, -- flashlight
		17, -- universal ammo
	}
	
	self.tempUV={};
	
	self.bars={
	}
	
	self:InitTexTable(self.txi);
	self:InitTexTable(self.tnum);
	self:InitTexTable(self.tnum_small);	
	self:InitTexTable(self.tweapons);
	self:InitTexTable(self.wicons);
	self:InitTexTable(self.tgrenades);
	self:InitTexTable(self.scoreboard);
	self:InitTexTable(self.mischolders);
	self:InitTexTable(self.pickups);
	self:InitTexTable(self.mpKills);

	self.temp_txinfo=new(self.txi.health_inside);
	self.weapons_alpha=0;
	
	self.new_weapon=1;
	self.curr_weapon=1;
	
	self.currnew_weapon=1;
	self.currpl_weapon=1;
	
	self.currCrossAirScale=1.0;
	self.bBlinkEnergy=0;
	self.fBlinkEnergyUpdate=0;
	self.bBlinkArmor=0;
	self.fBlinkArmorUpdate=0;	
		
	self.bBlinkObjective=0;
	self.fBlinkObjectiveUpdate=0;
		
	-- mp progress indicator	
	self.mp_rend=Game:CreateRenderer(); -- note: optimization would be putting all mp textures on one here..
	self.mp_scoreboardrend=Game:CreateRenderer(); -- note: optimization would be putting all mp textures on one here..
	self.tx_multiplayerhud = System:LoadImage("textures/hud/multiplayer/captureflag_all.dds");
	self.tx_mpscoreboard = System:LoadImage("textures/hud/multiplayer/scoreboard.dds");			
	
	self.ProgressIndicatorSound=Sound:LoadSound("sounds/items/capture_siren.wav"); -- items/capture_siren |  dong.wav
	self.ProgressCapturedSound=Sound:LoadSound("sounds/explosions/mp_flare.wav");
	
	self.PlayCapturedSound=0;
	Sound:SetSoundLoop(self.ProgressCapturedSound, 0);
	Sound:SetSoundLoop(self.ProgressIndicatorSound, 0);
			
	self.ProgressPreviousState= -1;
	self.ProgressStateTime= 0;
	self.ProgressCurrentState= -1;
	self.ProgressCurrentStateItem= -1;

	
	self.tmultiplayerhud={
		progressi_done	=		{  1, 65, 62, 62},  -- done
		progressi_unavailable=	{ 64, 65, 62, 62},  -- unavailable
		progressi_current=		{129, 65, 62, 62},  -- current
		progressi_changing=		{193, 65, 62, 62},  -- changing
		progressi_01=			{  1,  1, 62, 62},  -- progress 1 
		progressi_02=			{ 65,  1, 62, 62},	-- progress 2
		progressi_03=			{129,  1, 62, 62},	-- progress 3
		progressi_04=			{193,  1, 62, 62},	-- progress 4 
	}	

	self.tmpscoreboard = {
		bar_score  = {0, 0, 256, 70}, 
		bar_info   = {0, 49, 256, 21}, 
		bar_player = {0, 76, 256, 21}, 		
		bar_bottom = {0, 102, 256, 26}, 		
	}
		
	self:InitTexTableMP(self.tmultiplayerhud);
	self:InitTexTableMP(self.tmpscoreboard);
				
	------------------------------------------------------------------------------------
	-- NEW HUD (end..)
	------------------------------------------------------------------------------------

	
	self.blindnessvalue=-1;	-- to make the player blind when a lightning strikes	
	self.hitdamagecounter=0; -- [tiago] used to count hit damage for screen fx..	
	Game:CreateVariable("hud_screendamagefx",1);
	Game:CreateVariable("hud_disableradar", 0);
	Game:CreateVariable("hud_fadeamount",1);

	self.blinding = 0;
	
	--System:Log("self.damage_icon_lr="..type(self.damage_icon_lr));
	Game:CreateVariable("hud_panoramic",0);
	Game:CreateVariable("hud_panoramic_height",100);
	Game:CreateVariable("hud_crosshair",1);
	
	self.EarRinging=Sound:LoadSound("Sounds/Player/deafnessLP.wav");
	Sound:SetSoundLoop(self.EarRinging, 1);
	Sound:RemoveFromScaleGroup(self.EarRinging, SOUNDSCALE_DEAFNESS);

	local sx=5;
	local sy=395;
	local sw=108;
	local sh=108/2;
	local s={
		{x=sx+1,y=sy,u=0,v=0},
		{x=sx+1,y=sy+sh,u=0,v=1},
		{x=sx+sw/2,y=sy,u=0.5,v=0},
		{x=sx+sw/2,y=sy+sh,u=0.5,v=1},
		{x=sx+sw-1,y=sy,u=1,v=0},
		{x=sx+sw-1,y=sy+sh,u=1,v=1},
	}
	local h={
		{x=11+1,y=525,u=0,v=0},
		{x=10+1,y=557,u=0,v=0.5},
		{x=42,y=525,u=0.5,v=0},
		{x=42,y=557,u=0.5,v=0.5},
		{x=74-1,y=525,u=1,v=0},
		{x=74-1,y=557,u=1,v=0.5},
	}
	local a={
		{x=10+1,y=557,u=0,v=0.5},
		{x=10+1,y=589,u=0,v=1},
		{x=42,y=557,u=0.5,v=0.5},
		{x=42,y=589,u=0.5,v=1},
		{x=74-1,y=557,u=1,v=0.5},
		{x=74-1,y=589,u=1,v=1},
	}
	
	-- tiago: initialize 
	self.radar_transparency = 1.0;
	self.stamina_level = 64.5;
	self.breath_level =64.5;	
	self.radarObjective = nil;
	
	ScoreBoardManager.SetVisible(0);
		
	-- create radar stuff...
	Game:CreateVariable("g_RadarRange",200);
	Game:CreateVariable("g_RadarRangeOutdoor", 200);
	Game:CreateVariable("g_RadarRangeIndoor",50);
	Game:CreateVariable("g_RadarRangeChangeSpeed",3);
	Game:CreateVariable("g_SuspenseRange",50);
	Game:CreateVariable("g_NearSuspenseRangeFactor",0.25);
	Game:CreateVariable("g_ShowConcentrationStats",0);
	Game:CreateVariable("g_ConcentrationAmbientVolume",0.7);
	Game:CreateVariable("g_ConcentrationMissionVolume",1.0);
	Game:CreateVariable("g_ConcentrationNormalVolume",0.9);
	Game:CreateVariable("g_ConcentrationFadeInTime",3);
	Game:CreateVariable("g_ConcentrationFadeOutTime",5);

	self.SndIdMPHit=Sound:LoadSound("Sounds/Multiplayer/hit.wav");	
	self.ProgressPreviousState=-1;
	self.ProgressStateTime=0;
	self.ProgressCurrentState=-1;
	self.ProgressCurrentStateItem= -1;
	
	self.NewMessageSnd=Sound:LoadSound("sounds/items/lock.wav");
	
	self.pPickupsTbl={};
	self.pPickupsCount=0;
	
	self.vColor= { r=0, g=0, b=0, a=0 };	
	
	self.labeltime = nil;
	
	self.sGameType=strupper(getglobal("g_GameType"));	
end

-------------------------------------------------------------------------
-- plays some mp specific sound
-------------------------------------------------------------------------

function Hud:PlayMultiplayerHitSound()
	--temporary disabled
	--Sound:PlaySound(self.SndIdMPHit);
end

-------------------------------------------------------------------------
-- Render hud texture icon
-------------------------------------------------------------------------
function Hud:DrawElement(x,y,element,r,g,b,a)	
	if (element==nil) then return; end
	
	local fValue=tonumber(hud_fadeamount);	
	if(fValue~=1.0) then
		self.rend:PushQuad(x,y,element.size.w,element.size.h,element,r,g,b, fValue);	
	else
		self.rend:PushQuad(x,y,element.size.w,element.size.h,element,r,g,b, a);	
	end
end

-----------------------------------------------------------------------------
-- multiplayer hud specific
-----------------------------------------------------------------------------

-------------------------------------------------------------------------
-- InitTexTableMP: initialize mp hud texture, texture coordinates offsets
-------------------------------------------------------------------------

function Hud:InitTexTableMP(tt)
	local tw,th=256,128;
	local offsetU, offsetV=2/256.0, 2/128.0;
	
	for i,val in tt do
		val.size={}
		val.size.w=val[3];
		val.size.h=val[4];
		val[1]=val[1]/tw+offsetU;
		val[2]=val[2]/th+offsetV;
		val[3]=val[1]+(val[3]/tw)-offsetU;
		val[4]=val[2]+(val[4]/th)-offsetV;
	end
end

--------------------------------------------------------------
-- DrawQuadMP: renders element/quad from texture (mp only)
--------------------------------------------------------------

function Hud:DrawQuadMP(x, y, scalex, scaley, val, texi, r, g, b, a, flipu, flipv)
	local t=new(texi);
	
	merge_no_copy(t,texi);
	texi=t;
	
	local scale=(val/100);
	if(scale>100)then scale=100; end
	local diff=1-scale;
	
	if(diff~=0 and flipu~=1) then
		local uoffs=abs(texi[3]-texi[1])*diff;
		texi[1]=texi[1]+uoffs;
		local worig=texi.size.w;
		texi.size.w=(worig*scale);
		x=x+(worig*diff);	
	end
	
	if(diff~=0 and flipu==1)then	
		local uoffs=abs(texi[3]-texi[1])*diff;
		texi[3]=texi[3]-uoffs;
		local worig=texi.size.w;
		texi.size.w=(worig*scale);	
	end
	
	if(flipv==1)then	  
		texi[2],texi[4]=texi[4],texi[2];
	end
	
	if(flipu==1)then
	  texi[1],texi[3]=texi[3],texi[1];
	end
			
	local fValue=tonumber(hud_fadeamount);	
	-- always center scaling..
	if(fValue~=1.0) then
		self.mp_rend:PushQuad(x-texi.size.w*scalex*0.5,y-texi.size.h*scaley*0.5,texi.size.w*scalex,texi.size.h*scaley,texi,r,g,b, fValue);	
	else
		self.mp_rend:PushQuad(x-texi.size.w*scalex*0.5,y-texi.size.h*scaley*0.5,texi.size.w*scalex,texi.size.h*scaley,texi,r,g,b, a);			
	end
end

--------------------------------------------------------------
-- DrawScoreBoard: renders element/quad from texture (mp only)
--------------------------------------------------------------

function Hud:DrawScoreBoard(x, y, scalex, scaley, val, texi, r, g, b, a, flipu, flipv)
	-- make sure all ok..
	if(not texi or not self.mp_scoreboardrend or not self.tx_mpscoreboard) then
		return;
	end
				
	local t=new(texi);
	
	merge_no_copy(t, texi);
	texi=t;
				
	local scale=(val/100);
	if(scale>100)then scale=100; end
	local diff=1-scale;
	
	if(diff~=0 and flipu~=1) then
		local uoffs=abs(texi[3]-texi[1])*diff;
		texi[1]=texi[1]+uoffs;
		local worig=texi.size.w;
		texi.size.w=(worig*scale);
		x=x+(worig*diff);	
	end
	
	if(diff~=0 and flipu==1)then	
		local uoffs=abs(texi[3]-texi[1])*diff;
		texi[3]=texi[3]-uoffs;
		local worig=texi.size.w;
		texi.size.w=(worig*scale);	
	end
	
	if(flipv==1)then	  
		texi[2],texi[4]=texi[4],texi[2];
	end
	
	if(flipu==1)then
	  texi[1],texi[3]=texi[3],texi[1];
	end
						
	self.mp_scoreboardrend:PushQuad(x, y, texi.size.w*scalex, texi.size.h*scaley, texi, r, g, b, a);					
	self.mp_scoreboardrend:Draw(self.tx_mpscoreboard);
end
			
------------------------------------
-- Callback for sorting pickup items
------------------------------------
						
function pickup_compare(a,b)
	if(a and b) then		
		if(a.Lifetime>b.Lifetime)then 
			return 1
		end	
	end
end

----------------------------------
-- Add a pickup to hud pickup list
----------------------------------

function Hud:AddPickup( pick_type, pick_amount)
	local lifetime=1.0;
	-- check for same timed messages, increase recent ones timming for correct sorting
	if(self.pPickupsTbl and self.pPickupsTbl[count(self.pPickupsTbl)] and self.pPickupsTbl[1].Lifetime) then
		if(self.pPickupsTbl[1].Lifetime>=1.0) then
			lifetime=self.pPickupsTbl[1].Lifetime+0.01; 		
		end
	end
	
	-- then add pickup to list
	self.pPickupsTbl[count(self.pPickupsTbl)+1]={ 
		Type= pick_type, 
		Amount= pick_amount, 
		Position= 0,
		Lifetime= lifetime,
	};			
					
	if(pick_amount~=-1) then		
		-- scale crossair
		self.currCrossAirScale=5.0;
	
		-- blink energy	
		if(pick_type==0) then
			self.bBlinkEnergy=1		
		end
		
		-- blink armor
		if(pick_type==13) then
			self.bBlinkArmor=1			
		end
	end
		
	-- sort table items by lifetime	
	sort(self.pPickupsTbl,%pickup_compare);			
	
	-- remove old pickups
	while (count(self.pPickupsTbl)>4) do
		self.pPickupsTbl[count(self.pPickupsTbl)]=nil;									
	end			
end

-------------------------------------------------------------
-- Convert from ammo type string, into apropriate hud icon id
-------------------------------------------------------------

function Hud:AmmoPickupsConversion(ammo_type)	
	local retVal=0;
	if(ammo_type) then
		retVal=self.ammoPickupsConversionTbl[ammo_type];
	end
	
	return retVal;
end

-------------------------------------------------------------
-- Convert from pickup type value, into apropriate hud icon id
-------------------------------------------------------------

function Hud:GenericPickupsConversion(pick_type)	
	local retVal=0;
	if(pick_type) then
		retVal=self.genericPickupsConversionTbl[pick_type];
	end
	
	return retVal;
end

---------------------------------
-- Process and render all pickups
---------------------------------

function Hud:DrawPickups()
	local fPos=0;
	-- check for same type pickups
	if(self.pPickupsTbl and type(self.pPickupsTbl)=="table") then
		for i, Pickup in self.pPickupsTbl do								
			if(Pickup.Lifetime>0.0) then				
				local lerp=_frametime*20;
				if(lerp>1.0) then
					lerp=1;
				end				
				
				local fLifetime=10*Pickup.Lifetime*Pickup.Lifetime;				
				if(fLifetime>1.0) then
					fLifetime=1.0;
				end
																			
				Pickup.Position=Pickup.Position+(fPos-Pickup.Position)*lerp;															
				self:DrawElement(720-Pickup.Position, 500, self.pickups[self.pPickupsTbl[i].Type+1],  1, 1, 1,fLifetime);					
												
				if(Pickup.Amount==-1) then
					-- not available
					self:DrawElement(720-Pickup.Position, 500, self.pickups[19],  1, 1, 1, fLifetime*0.9);																				
				elseif(Pickup.Amount>1) then
				   	-- item count
					self:DrawNumber(0, 3,730-Pickup.Position, 500+17, Pickup.Amount, 1,1,1, fLifetime);		
				else
					-- just one item
					self:DrawNumber(0, 3,730-Pickup.Position, 500+17, 1, 1,1,1, fLifetime);		
				end
				
				Pickup.Lifetime=Pickup.Lifetime-_frametime*0.25;
				
				-- clamp 
				if(Pickup.Lifetime<0.0) then
					Pickup.Lifetime=0.0;
				end
			
				fPos=fPos+40;		
															
			else			
				-- remove old pickups			
				local j=i;
				local k=count(self.pPickupsTbl);
													
				while (j <= k) do					
					self.pPickupsTbl[j]=self.pPickupsTbl[j+1];															
					j=j+1;
				end			
			end
		end						
	end	
	
	
	-- display flashlight
	if(_localplayer.FlashLightActive==1) then
			-- not available
			self:DrawElement(765, 501, self.txi.flashlight_on);																					
	end
			
end

-----------------------------------------------------
-- Display picked up icons
-----------------------------------------------------

function Hud:DrawItems(player)	
	local x=400;
	local y=510;
	
	local itemCount=0;
	local fValue=tonumber(hud_fadeamount);
	
	-- count total item numbers
	for i,val in player.keycards do			
		if (val>=1 and val<=4) then
			itemCount=itemCount+1;
		end
	end
	
	for i,val in player.explosives do			
		if (val==1) then
			itemCount=itemCount+1;
		end
	end
	
	for i, val in player.objects do
		if(val==1) then
			itemCount=itemCount+1;
		end	
	end
	
	-- always center items..
	x=x-itemCount*20;
	
	-- render keycards
	for i,val in player.keycards do			
		if (val==1) then			
			%System:DrawImageColor(self.KeyItem[i], x, y, 40, 20, 4,1,1,1, fValue);		
			x=x+40;
		end
	end
	
	-- render object items	
	for i,val in player.objects do					
		if (val==1) then
			-- items are: 1: pda, 2:bombfuse 3: pda batery, 4:undefined, etc..					
			x=x+8;		
			%System:DrawImageColor(self.ObjectItem[i+1], x, y-6, 32, 32, 4,1,1,1, fValue);		
			x=x+40;		
		end
	end
	
	-- render explosives
	for i,val in player.explosives do			
		if (val==1) then			
			%System:DrawImageColor(self.ObjectItem[1], x, y, 40, 20, 4,1,1,1, fValue);		
			x=x+40;
		end
	end
	
end

-----------------------------------------------------
-- Display labels
-----------------------------------------------------

function Hud:DrawLabel()
	if(self.label)then			
		%Game:SetHUDFont("default", "default");
		local strsizex,strsizey = Game:GetHudStringSize(self.label, 20, 20);
		%Game:WriteHudString(400-strsizex*0.5, 350, self.label, self.color.r, self.color.g, self.color.b, 1, 20, 20, 0);											
	end
	
	--if labeltime is specified dont remove immediately the label, but wait for the time specified.
	if (self.labeltime and self.labeltime>0) then
		self.labeltime = self.labeltime - _frametime;
	else
		self.label=nil;
		self.labeltime=nil;
	end
end

-----------------------------------------------------
-- Display a number
-----------------------------------------------------

function Hud:DrawNumber(font, ndigits,x,y,number,r,g,b,a)		
	if(number>999)then number=999; end
	local t=mod(number,100);
	local unit=mod(number,10);
	local hun=(number-t)/100;
	local dec=(t-unit)/10;
	if(ndigits>=3)then
		if(font==1) then		 	
			self:DrawElement(x, y,self.tnum[hun],r,g,b,a);			
			x=x+9;
		else
			if(hun>0) then
				self:DrawElement(x, y,self.tnum_small[hun],r,g,b,a);
			end
			x=x+5;
		end		
	end
	if(ndigits>=2)then
		if(font==1) then
			self:DrawElement(x, y,self.tnum[dec],r,g,b,a);
			x=x+9;
		else
			self:DrawElement(x, y,self.tnum_small[dec],r,g,b,a);
			x=x+5;		
		end
	end
	
	if(font==1) then
		self:DrawElement(x, y,self.tnum[unit],r,g,b,a);	
	else
		self:DrawElement(x, y,self.tnum_small[unit],r,g,b,a);		
	end
end

-----------------------------------------------------
-- Display energy/armor bars
-----------------------------------------------------

function Hud:DrawEnergy(player)
	--health gauge	
	-- if player is spectator skip
	if (player.entity_type =="spectator") then
	return;
	end
	local health=(player.cnt.health/player.cnt.max_health)*100;
	if(health<0) then
		health=0;
	elseif(health>100) then
		health=100;
	end
	
	local armor=(player.cnt.armor/player.cnt.max_armor)*100;
	if(armor<0) then
		armor=0;
	elseif(armor>100) then
		armor=100;
	end
	
	local stamina=self.staminalevel*100;
	if(stamina<0) then
		stamina=0;
	elseif(stamina>100) then
		stamina=100;
	end
	
	local FrameTime=_frametime;
		
	-- interpolate values
	self.curr_health=self.curr_health + (health-self.curr_health)*FrameTime*4;
	if(self.curr_health<0) then
		self.curr_health=0;
	elseif(self.curr_health>100) then
		self.curr_health=100;
	end

	self.curr_armor=self.curr_armor+(armor-self.curr_armor)*FrameTime*4;
	if(self.curr_armor<0) then
		self.curr_armor=0;
	elseif(self.curr_armor>100) then
		self.curr_armor=100;
	end
		
	self.curr_stamina=self.curr_stamina+(stamina-self.curr_stamina)*FrameTime*4;
	if(self.curr_stamina<0) then
		self.curr_stamina=0;
	elseif(self.curr_stamina>100) then
		self.curr_stamina=100;
	end
		
	-- update energy blinking
	if(self.bBlinkEnergy>=1) then
		self.fBlinkEnergyUpdate = self.fBlinkEnergyUpdate + 5*_frametime;
		if(self.fBlinkEnergyUpdate>1) then
			self.fBlinkEnergyUpdate=0;
			
			self.bBlinkEnergy=self.bBlinkEnergy+1;			
			if(self.bBlinkEnergy>4*3) then
				self.bBlinkEnergy=0;			
			end
		end
	else
		self.fBlinkEnergyUpdate=0;
	end
							
	if(self.curr_health>0.01) then
		-- display energy bars	
		if(health<30) then
			self.curr_healthAlpha=self.curr_healthAlpha+FrameTime*2;		
			if(self.curr_healthAlpha>1.0) then
				self.curr_healthAlpha=0;
			end
		else
			self.curr_healthAlpha=1;
		end
		
		--if(self.bBlinkEnergy==0 or self.fBlinkEnergyUpdate>0.5) then
			self:DrawGauge(583, 546, self.curr_health, 100, self.txi.health_inside, 0.7*0.709, 0.7*0.219, 0.7*0.233, 0.9*self.curr_healthAlpha, 0, 0);	
			
			self.vColor.r=0.709+self.fBlinkEnergyUpdate;
			self.vColor.g=0.219+self.fBlinkEnergyUpdate;
			self.vColor.b=0.233+self.fBlinkEnergyUpdate;
						
			-- clamp color to 1
			if(self.vColor.r>1.0) then self.vColor.r=1; end
			if(self.vColor.g>1.0) then self.vColor.g=1; end
			if(self.vColor.b>1.0) then self.vColor.b=1; end
			
			self:DrawGauge(583, 546, health, 100, self.txi.health_inside, self.vColor.r, self.vColor.g, self.vColor.b, 0.9*self.curr_healthAlpha, 0, 0);
		--end
	end

	-- update armor blinking
	if(self.bBlinkArmor>=1) then
		self.fBlinkArmorUpdate = self.fBlinkArmorUpdate + 5*_frametime;
		if(self.fBlinkArmorUpdate>1) then
			self.fBlinkArmorUpdate=0;
			
			self.bBlinkArmor=self.bBlinkArmor+1;			
			if(self.bBlinkArmor>4*3) then
				self.bBlinkArmor=0;			
			end
		end
	else
		self.fBlinkArmorUpdate=0;
	end
	
	if(self.curr_armor>0.01) then
		--if(self.bBlinkArmor==0 or self.fBlinkArmorUpdate>0.5) then
			self:DrawGauge(572, 561, self.curr_armor, 100, self.txi.health_inside, 0.7*0.776, 0.7*0.541, 0.7*0.258, 0.9, 0, 0);
						
			self.vColor.r=0.776+self.fBlinkArmorUpdate;
			self.vColor.g=0.541+self.fBlinkArmorUpdate;
			self.vColor.b=0.258+self.fBlinkArmorUpdate;
			-- clamp color to 1
			if(self.vColor.r>1.0) then self.vColor.r=1; end
			if(self.vColor.g>1.0) then self.vColor.g=1; end
			if(self.vColor.b>1.0) then self.vColor.b=1; end
			
			self:DrawGauge(572, 561, armor, 100, self.txi.health_inside, self.vColor.r, self.vColor.g, self.vColor.b, 0.9, 0, 0);
		--end
	end
	
	if(self.curr_stamina>0.01) then
		self:DrawGauge(560, 576, self.curr_stamina, 100, self.txi.health_inside, 0.258, 0.49, 0.807, 0.9, 0, 0);
	end
										
	-- display energy bars holder
	self:DrawElement(551, 541, self.txi.health_bar);						
end

-----------------------------------------------------
-- Display ammo 
-----------------------------------------------------

function Hud:DrawAmmo(player)		

	local w=player.cnt.weapon;
	local critical_ammo_count=0;
	if(player.fireparams and player.fireparams.bullets_per_clip)then
		critical_ammo_count=(player.fireparams.bullets_per_clip*0.3)
	end
		
	-- display ammo bar holder	
	self:DrawElement(696, 541, self.txi.ammo_bar);
	
	local ammo=999;
	
	-- display ammo amount
	if(player.fireparams and player.fireparams.AmmoType~="Unlimited")then	
		if(player.cnt.ammo<999)then ammo=player.cnt.ammo end
		--System:Log("critical_ammo_count="..critical_ammo_count)
		if(player.cnt.ammo_in_clip<=critical_ammo_count)then
			--%Game:WriteHudString(700,562, format("%03i/%03i",player.cnt.ammo_in_clip,ammo), 1, 0, 0, 35,37);
			
			self:DrawNumber(1, 3,737,550,player.cnt.ammo_in_clip,1,0,0,1);
			self:DrawNumber(1, 3,737,568,player.cnt.ammo);
		elseif(player.cnt.ammo_in_clip>0 and ammo>0)then
			self:DrawNumber(1, 3,737,550,player.cnt.ammo_in_clip);
			self:DrawNumber(1, 3,737,568,player.cnt.ammo);
			--%Game:WriteHudString(700,562, format("%03i/%03i",player.cnt.ammo_in_clip,ammo), self.color.r, self.color.g, self.color.b, 35,37);
		else
			self:DrawNumber(1, 3,737,550,player.cnt.ammo_in_clip);
			self:DrawNumber(1, 3,737,568,ammo);
		end
	end
	
	-- display firemode
	if(player.fireparams and player.fireparams.hud_icon )then		
		self:DrawElement(713,561,self.wicons[player.fireparams.hud_icon]);
	end	
	
	-- display grenades slot
	if (self.DisplayControl.bShowProjectiles == 1) then		
		local ngrenades;
		if(player.cnt.grenadetype~=1)then
				ngrenades=player.cnt.numofgrenades;
		end
		local class=GrenadesClasses[player.cnt.grenadetype]	
		
		self:DrawGrenadeSlot(player,769,549,ngrenades,class);	
	end
end

-----------------------------------------------------
-- Set current radar range
-----------------------------------------------------

function Hud:SetRadarRange(Range)
	self.DestinationRadarRange=Range;
end

-----------------------------------------------------
-- Set current radar player item color
-----------------------------------------------------

function Hud:SetPlayerColor( player,r,g,b,a )
	if (player.Color == nil) then
		player.Color = {};
	end
	player.Color.r = r;
	player.Color.g = g;
	player.Color.b = b;
	player.Color.a = a;
end

-----------------------------------------------------
-- Resets radar enemies state
-----------------------------------------------------

function Hud:ResetRadar(player)
	if(Game:IsMultiplayer() and player and Hud.tblPlayers) then
					
		local LocalPlayer=_localplayer;
		if(LocalPlayer and LocalPlayer.GetPos) then
			
			-- empty table
			for i, Player in Hud.tblPlayers do
				Hud.tblPlayers[i] = nil;
			end
			-- enemy data..
			local LocalPlayerPos=LocalPlayer:GetPos();		
			Game:GetPlayerEntitiesInRadius(LocalPlayerPos, 9999999999999999, Hud.tblPlayers );
					
			if(player==LocalPlayer) then
				-- if is local player, then reset entire list		
				for i, Player in Hud.tblPlayers do					
					if(Player.pEntity and Player.pEntity.id) then
						local pEntity=System:GetEntity(Player.pEntity.id);							
						if(pEntity) then
							pEntity.bShowOnRadar=nil;								
						end	
					end
				end
				
			else		
				-- reset guy that suicided/killed	
				for i, Player in Hud.tblPlayers do					
						if(Player.pEntity and Player.pEntity.id and player.id == Player.pEntity.id) then				
							local pEntity=System:GetEntity(Player.pEntity.id);							
							if(pEntity) then
								pEntity.bShowOnRadar=nil;								
							end	
						end
				end				
			end	
			
		end
		
	end
		
end

-----------------------------------------------------
-- Display radar
-----------------------------------------------------

function Hud:DrawRadar(x,y,w,h)

	if(hud_disableradar == "1") then
		return
	end
	
	local LocalPlayer=_localplayer;
	local LocalPlayerPos=LocalPlayer:GetPos();
	local FrameTime=_frametime;
		
	-- indoor/outdoor ?
	
	if (System:IsPointIndoors(LocalPlayerPos)) then
		Hud:SetRadarRange(tonumber(g_RadarRangeIndoor));
		--g_RadarRange=g_RadarRangeIndoor;
	else
		Hud:SetRadarRange(tonumber(g_RadarRangeOutdoor));
		--g_RadarRange=g_RadarRangeOutdoor;
	end
	
	-- adjust range
	if (self.DestinationRadarRange and (tonumber(self.DestinationRadarRange)~=tonumber(g_RadarRange)) and (FrameTime<1) and (tonumber(g_RadarRangeChangeSpeed)>0)) then
		g_RadarRange=tonumber(g_RadarRange)+(tonumber(self.DestinationRadarRange)-tonumber(g_RadarRange))*FrameTime*tonumber(g_RadarRangeChangeSpeed);
		g_SuspenseRange=g_RadarRange;
	end
	
	-- Make Sure Players table is empty.
	for i, Player in Hud.tblPlayers do
		Hud.tblPlayers[i] = nil;
	end
		
	-- enemy data..
	Game:GetPlayerEntitiesInRadius(LocalPlayerPos, tonumber(g_RadarRange*1.2), Hud.tblPlayers);
					
	-- Used for setting moods in DynamicMusic.	
	self.EnemyInSuspense = 0;
	self.EnemyInNearSuspense = 0;
	self.EnemyAlerted = 0;
	local SuspenseRange2=tonumber(g_SuspenseRange)*tonumber(g_SuspenseRange);
	local NearSuspenseRange2=SuspenseRange2*tonumber(g_NearSuspenseRangeFactor)*tonumber(g_NearSuspenseRangeFactor);
	
	-- radar fade in/out                        
	local alpha_step=0.5;
	Hud.radar_transparency = Hud.radar_transparency - alpha_step*FrameTime;				          
	if(Hud.radar_transparency<0.0) then
		Hud.radar_transparency=0.0;
	end				
						
	if (Hud.tblPlayers and type(Hud.tblPlayers)=="table") then
		for i, Player in Hud.tblPlayers do			
			if (Player.pEntity==LocalPlayer) then -- is player ? 
				Hud:SetPlayerColor( Player,0,0.9,0.8,Hud.radar_transparency );

			elseif ( Player.pEntity.Properties.species==LocalPlayer.Properties.species) then	--is enemy of friend ?
					  	-- radar fade in
		          	local alpha_step=1.0;                                   		          
		          	Hud.radar_transparency = Hud.radar_transparency + alpha_step*_frametime;		                  
		          	if(Hud.radar_transparency>1.0) then
		            	Hud.radar_transparency=1.0;
		          	end							
											
					-- check if in mp mode..
					if(Game:IsMultiplayer()) then					
						local LocalPlayerTeam=Game:GetEntityTeam(LocalPlayer.id);
						local team=Game:GetEntityTeam(Player.pEntity.id);					
																			
																			
						if(team and LocalPlayerTeam and (self.sGameType ~= "FFA") ) then						

							if(team=="red") then
								Hud:SetPlayerColor( Player, 1.0, 0.0, 0.0, Hud.radar_transparency);											
							elseif (team=="blue")then
								Hud:SetPlayerColor( Player, 0.0, 0.0, 1.0, Hud.radar_transparency);											
							else
								Hud:SetPlayerColor( Player, 1.0, 1.0, 1.0, Hud.radar_transparency);											
							end
																					
							-- not from same team, then only display entities tagged by motion tracker
							if(LocalPlayerTeam~=team and (not Player.pEntity.bShowOnRadar)) then
								Hud.tblPlayers[i]=nil;	
							end
						else
							-- then only display entities tagged by motion tracker
							if(Player.pEntity.bShowOnRadar) then									
								-- in FFA mode, display enemies always in red
								Hud:SetPlayerColor( Player, 1.0, 1.0, 1.0, Hud.radar_transparency);											
							else
								Hud.tblPlayers[i]=nil;					
							end
						end
					else					
						-- always display friendly characters						
						--if (Player.pEntity.bShowOnRadar) then	
							Hud:SetPlayerColor( Player, 1.0, 0.8, 1.0, Hud.radar_transparency);											
						--end
					end															
										
			elseif (Player.pEntity.Properties.bAffectSOM==1) then          												
				-- only display entities tagged by motion tracker
				if (Player.pEntity.bShowOnRadar) then						
				
					if (Player.fDistance2<SuspenseRange2) then
						self.EnemyInSuspense=1;
					end
					if (Player.fDistance2<NearSuspenseRange2) then
						self.EnemyInNearSuspense=1;
					end
									
			        -- radar fade in
			        local alpha_step=1.0;                                   			          
			        Hud.radar_transparency = Hud.radar_transparency + alpha_step*FrameTime;			                  
			        if(Hud.radar_transparency>1.0) then
		            	Hud.radar_transparency=1.0;
			        end
			        
			    	Hud:SetPlayerColor( Player,0,1,0,Hud.radar_transparency ); -- default is idle.
															
					-- if saw player, then always in combat mode
					if(Player.pEntity.bEnemyInCombat==1) then
						Hud:SetPlayerColor( Player,1,0,0,Hud.radar_transparency );
					else							
						local Target=AI:GetAttentionTargetOf(Player.pEntity.id);
						local TargetType=type(Target);					
						Player.pEntity.bEnemyInCombat = 0;	-- set default
						
						if ((TargetType=="table") and (Target==LocalPlayer)) then
							Hud:SetPlayerColor( Player,1,0,0,Hud.radar_transparency ); -- combat
							self.EnemyAlerted = 1;
							Player.pEntity.bEnemyInCombat = 1; 	-- enemy saw player
						elseif(TargetType=="number") then
						 	
						 	if(Target==AIOBJECT_DUMMY) then
						 	
						 		if(Player.pEntity.Behaviour.JOB==nil) then
									Hud:SetPlayerColor( Player,1,0.5,0,Hud.radar_transparency );	-- threatened					
									self.EnemyAlerted = 1;							
							  else
							  	Hud:SetPlayerColor( Player,0,1,0,Hud.radar_transparency );	-- doing something
							  end
							  
							elseif(Target==AIOBJECT_NONE) then							
								Hud:SetPlayerColor( Player,0,1,0,Hud.radar_transparency );	-- doing something															
							end
																				
						else
							-- no target ?							
							if(Player.pEntity.Behaviour.JOB==nil) then
								Hud:SetPlayerColor( Player,1,1,0,Hud.radar_transparency ); -- heared something								
							else
								Hud:SetPlayerColor( Player,0,1,0,Hud.radar_transparency ); -- doing something
							end												
						end								
					end
					
				else
					Hud.tblPlayers[i]=nil;
				end
				
			else
				Hud.tblPlayers[i]=nil;										
			end
		end
		
    	-- get/set radar objective    
		local RadarPosition= "NoObjective";
		
		-- update objective blinking
		if(self.bBlinkObjective>=1) then
			self.fBlinkObjectiveUpdate = self.fBlinkObjectiveUpdate + 5*_frametime;
			if(self.fBlinkObjectiveUpdate>1) then
				self.fBlinkObjectiveUpdate=0;			
				self.bBlinkObjective=self.bBlinkObjective+1;			
				if(self.bBlinkObjective>6*3) then
					self.bBlinkObjective=0;			
				end
			end
		else
			self.fBlinkObjectiveUpdate=0;
		end
		
		if(Hud.radarObjective~=nil and (self.bBlinkObjective==0 or self.fBlinkObjectiveUpdate>0.5)) then
		  RadarPosition= format("%g %g %g", Hud.radarObjective.x, Hud.radarObjective.y,Hud.radarObjective.z); 
		end
    
		-- render radar				
		Game:DrawRadar(x, y, w, h, tonumber(g_RadarRange), self.Radar, self.RadarMask, self.RadarPlayerIcon, 
		               self.RadarEnemyInRangeIcon, self.RadarEnemyOutRangeIcon, self.RadarSoundIcon, self.RadarObjectiveIcon, Hud.tblPlayers, RadarPosition);
	end
end

-----------------------------------------------------
-- Display stealthmeter
-----------------------------------------------------

function Hud:DrawStealthMeter(x,y)

  	-- no need to proceed if transparency is 0 or stealth/breath meter is disabled  	
  	if(self.DisplayControl.bShowEnergyMeter==0 or self.DisplayControl.bShowRadar == 0 or self.DisplayControl.fBlinkUpdateRadar>0.5) then
    	return;
   	end
                
	local color=self.color_blue;		
	local stealth_amount=AI:GetPerception();

	if (stealth_amount<5) then
		stealth_amount=stealth_amount*10;
	elseif (stealth_amount<10) then
		stealth_amount=((stealth_amount-5)/5)*25+50;
		color=self.color_yellow;
	elseif (stealth_amount>110) then
		stealth_amount=100;
		color=self.color_red;
	else
		stealth_amount=75;
		color=self.color_red;
	end			
	
	local FrameTime=_frametime;
	-- interpolate values
	self.curr_stealth=self.curr_stealth+(stealth_amount-self.curr_stealth)*FrameTime*4;
	self.curr_stealth=self:ClampToRange(self.curr_stealth, 0, 100);
	
	self:DrawElement(4-1, 522-6, self.txi.shape_stealth_left, 1, 1, 1, 0.9);						
	self:DrawElement(91.5, 522-6, self.txi.shape_stealth_right,1, 1, 1, 0.9);						
	
	if(self.curr_stealth>0.01) then
		self:DrawGauge(6-1, 523-6, 100, self.curr_stealth, self.txi.sealth_inside_left, 1, 1, 1, 0.9, 0, 0);
		self:DrawGauge(94.5, 523-6, 100, self.curr_stealth, self.txi.sealth_inside_right, 1, 1, 1, 0.9, 0, 0);
	end
end

-----------------------------------------------------
-- Display an icon
-----------------------------------------------------

function Hud:DrawGauge(x,y,hval, vval, texi,r,g,b,a,flipu, flipv)
	local t=self.temp_txinfo;
	merge_no_copy(t,texi);
	texi=t;
	local hscale=(hval/100);
	local vscale=(vval/100);
	if(hscale>100)then hscale=100; end
	if(vscale>100)then vscale=100; end
	local diff=1-hscale;
	local vdiff=1-vscale;
	
	if((diff~=0 or vdiff~=0) and flipu~=1) then
		local uoffs=abs(texi[3]-texi[1])*diff;
		texi[1]=texi[1]+uoffs;

		local voffs=abs(texi[4]-texi[2])*vdiff;
		texi[2]=texi[2]+voffs;
		
		local worig=texi.size.w;
		local horig=texi.size.h;
		
		texi.size.w=(worig*hscale);
		texi.size.h=(horig*vscale);
		
		x=x+(worig*diff);	
		y=y+(horig*vdiff);	
	end
  
    if((diff~=0 or vdiff~=0) and flipu==1)then	
		local uoffs=abs(texi[3]-texi[1])*diff;
		local voffs=abs(texi[4]-texi[2])*vdiff;
		
		texi[3]=texi[3]-uoffs;
		texi[4]=texi[4]-voffs;
		
		local worig=texi.size.w;
		local horig=texi.size.h;
		
		texi.size.w=(worig*hscale);
		texi.size.h=(horig*vscale);		  
    end
	
	if(flipv==1)then	  
		texi[2],texi[4]=texi[4],texi[2];
	end
	if(flipu==1)then
	  texi[1],texi[3]=texi[3],texi[1];
	end
	
	self:DrawElement(x,y,texi,r,g,b,a);
end

-----------------------------------------------------
-- Display a single color bar
-----------------------------------------------------

function Hud:DrawBar(x,y,w,h,val,r,g,b,a)
	local realh=h*(val/100);
	local realy=y+(h-realh);
	
	local fValue=tonumber(hud_fadeamount);	
	
	if(fValue~=1.0) then
		self.rend:PushQuad(x,realy,w,realh,self.txi.white_dot,r,g,b, fValue);	
	else
		self.rend:PushQuad(x,realy,w,realh,self.txi.white_dot,r,g,b, a);	
	end
end

-----------------------------------------------------
-- Display cross-air and damage direction indicators
-----------------------------------------------------

function Hud:DrawCrosshair(player)
	if(tonumber(hud_damageindicator)~=0)then		
				
		if(self.dmgindicator)then
			if ( band( self.dmgindicator, 16 ) > 0 ) then				
				self.dmgfront=1;
				self.dmgback=1;
				self.dmgleft=1;
				self.dmgright=1;
			else					
				if ( band( self.dmgindicator, 4 ) > 0 ) then
					self.dmgfront=1;
				end
				if ( band( self.dmgindicator, 8 ) > 0 ) then
					self.dmgback=1;
				end
				if ( band( self.dmgindicator, 1 ) > 0 ) then
					self.dmgleft=1;
				end
				if ( band( self.dmgindicator, 2 ) > 0 ) then
					self.dmgright=1;
				end
			end
		end
				
		local FrameTime=_frametime;
		-- something is wrong with frametime. Clamp it.
		if(FrameTime<0.002) then
			FrameTime=0.002;
		elseif(FrameTime>0.5) then 
			FrameTime=0.5;	
		end
		
		FrameTime=FrameTime*0.75;						
		local fTexOffset=0.5/256;
		
		if(self.dmgfront>0)then			
			%System:DrawImageColorCoords(self.damage_icon_ud, 0, 0, 800, 90, 4, 0.45, 0.1, 0,  self.dmgfront, 1+fTexOffset, 1+fTexOffset, fTexOffset, fTexOffset);	
			self.dmgfront=self.dmgfront-FrameTime;
			if(self.dmgfront<0) then self.dmgfront=0 end
		end
	
		if(self.dmgback>0)then			
			%System:DrawImageColorCoords(self.damage_icon_ud, 0, 600-90, 800, 90, 4, 0.45, 0.1, 0, self.dmgback, fTexOffset, fTexOffset, 1+fTexOffset, 1+fTexOffset);	
			self.dmgback=self.dmgback-FrameTime;
			if(self.dmgback<0) then self.dmgback=0 end
		end
			
		if(self.dmgleft>0)then			
			%System:DrawImageColorCoords(self.damage_icon_lr, 0, 0, 90, 600, 4, 0.45, 0.1, 0, self.dmgleft, fTexOffset, fTexOffset, 1-fTexOffset, 1-fTexOffset);	
			self.dmgleft=self.dmgleft-FrameTime;
			if(self.dmgleft<0) then self.dmgleft=0 end
		end
		
		if(self.dmgright>0)then			
			%System:DrawImageColorCoords(self.damage_icon_lr, 800-90, 0, 90, 600, 4, 0.45, 0.1, 0, self.dmgright, 1-fTexOffset, 1-fTexOffset, fTexOffset, fTexOffset);	
			self.dmgright=self.dmgright-FrameTime;
			if(self.dmgright<0) then self.dmgright=0 end
		end
		
		self.dmgindicator=0;		
		------------------------------
		------------------------------	
		local w=player.cnt.weapon;
		-- repoint if spec and host
		if (_localplayer.entity_type == "spectator") then --is spectator
			if (_localplayer.cnt.GetHost ) then --has host
				--if(gr_first_person_spectator == 1) then -- FPSpectator feature on
				
				local myhost = System:GetEntity(_localplayer.cnt:GetHost());
				if (myhost ~=nil) then
				w = myhost.cnt.weapon;
	 			end
			end
		end

		
		if(w )then
			--w.Client.OnEnhanceHUD(w, self.currCrossAirScale, Hud.hit);
			Hud.hit=Hud.hit-20*_frametime;
			--System:Log("DrawCrosshair is calling onenhancehud at line 2076 in hudcommon");
		end		
		
		
		self.currCrossAirScale=self.currCrossAirScale-_frametime*10;
		if(self.currCrossAirScale<1.0) then
			self.currCrossAirScale=1.0;
		end
		-------------------------------------------------
		-------------------------------------------------
	end				
end

-----------------------------------------------------------------------------
-- SetProgressIndicator() is removing the progress indicator
-- /param Name e.g. "Player" or "AssaultState" key in the table Hud.Progress
-- /param text e.g. "Build Percentage"
-- /param valuex 0..100
-- /param valuey nil if not used, otherwise 0..100
-- /param valuez nil if not used, otherwise 0..100
-----------------------------------------------------------------------------

function Hud:SetProgressIndicator(Name,localtoken,valuex,valuey,valuez)

	local PTable=self.Progress[Name];
	local CurrTime=_time;
	
	assert(PTable);
	
	PTable.LocalToken=localtoken;
	PTable.ValueX=valuex;
	PTable.ValueY=valuey;
	PTable.ValueZ=valuez;

	if PTable.Seconds then
		PTable.EndTime = CurrTime + PTable.Seconds;		-- indicator disappears after 1 sec
	else 
		PTable.EndTime = nil;
	end
	
	
	-- play progress sounds	
	if(PTable==Hud.Progress.AssaultState) then		
		local iItemCurrent=tonumber(PTable.ValueX);				
		if(self.ProgressCurrentStateItem==iItemCurrent or self.ProgressCurrentStateItem==-1) then				
			local iCurrState=tonumber(PTable.ValueY);				
			-- state changed ? activate sound			
			if(self.ProgressCurrentState~=iCurrState and self.ProgressCurrentState~=-1 and (iCurrState>0 and iCurrState<=5)) then
				-- play sound..										
				Sound:PlaySound(self.ProgressIndicatorSound);									
			end			
			-- save current state
			self.ProgressCurrentState= iCurrState;														
		elseif( self.ProgressCurrentStateItem<iItemCurrent) then		
			-- captured
			Sound:PlaySound(self.ProgressCapturedSound);			
		end										
		self.ProgressCurrentStateItem=iItemCurrent;
	end	
end

-----------------------------------------------------------------------------
-- Display current progress indicator (mp only)
-- /param name "Player" "AssaultState" (entry int the Hud:Progress Table)
-----------------------------------------------------------------------------

function Hud:DrawProgressIndicator(Name)

	local PTable=self.Progress[Name];
	
	assert(PTable);	

	if PTable.LocalToken then			-- is activated?

		local CurrTime=_time;
		if PTable.EndTime==nil or CurrTime<PTable.EndTime then					-- no end time or end time not reached		
			if (PTable.Draw) then
				PTable.Draw(self);
			end
		else
			PTable.LocalToken=nil;			-- end time reached - deactivate			
		end	
	end		
end

-----------------------------------------------------
-- Display current vehicle damage count
-----------------------------------------------------

function Hud:DrawVehicleBar(vehicle, health)
	if(health~=0 and (vehicle.IsCar or vehicle.IsBoat)) then			
		local LocalPlayer=_localplayer;
		local r, g, b=1, 1, 1;
		local healthStep=health;
		
		-- change color to warn player of serious vehicle damage
		if(healthStep<45) then
			r=1; g=0; b=0;		
		elseif(healthStep<75) then
			r=1; g=1; b=0.5;		
		end
			
		local FrameTime=_frametime;
		-- interpolate values
		self.curr_vehicledamage=self.curr_vehicledamage+(healthStep-self.curr_vehicledamage)*FrameTime*2;									
		self.curr_vehicledamage=self:ClampToRange(self.curr_vehicledamage, 0, 100);
		
		if(healthStep<45) then
			self.curr_vehicledamageAlpha=self.curr_vehicledamageAlpha+FrameTime*2;		
			if(self.curr_vehicledamageAlpha>1.0) then
				self.curr_vehicledamageAlpha=0;
			end
		else
			self.curr_vehicledamageAlpha=1;
		end
		
		local x, y=135, 530;
		if(LocalPlayer.items and not LocalPlayer.items.heatvisiongoggles) then
			y=545;
		end

		-- only cars/boats will display icon
		if(vehicle.IsCar) then
			-- display energy bar holder
			self:DrawElement(x, y, self.mischolders.car_damage_frame);					
			-- display energy bar
			self:DrawGauge(x+5, y+5, self.curr_vehicledamage, 100, self.mischolders.car_damage_inside, r, g, b, self.curr_vehicledamageAlpha, 0, 0);										
		elseif(vehicle.IsBoat) then		
			-- display energy bar holder
			self:DrawElement(x, y, self.mischolders.boat_damage_frame);					
			-- display energy bar
			self:DrawGauge(x+7, y+6, self.curr_vehicledamage, 100, self.mischolders.boat_damage_inside, r, g, b, self.curr_vehicledamageAlpha, 0, 0);												
		end		
	end			
end

-----------------------------------------------------
-- Display current mission box
-----------------------------------------------------

function Hud:MissionBox()	
	-- [marco] make it very big so all messages will always fit
	
	local w = 600;
	local h = 320;
	local boxx = (800-w)*0.5;
	local boxy = 100;
	local textspacing = 15;
	local y = boxy + textspacing;
	
	Hud:DrawFrameBox(boxx, boxy, w, h);	
	
	%Game:SetHUDFont("default", "default");
	
	-- top edge 
	local r, g, b;
	r=47.0/255;
	g=66.0/255;
	b=53.0/255;
	
	%System:DrawImageColor(self.white_dot, boxx-1, boxy-1, w+2, 1, 4, r, g, b, 1);
	-- bottom edge
	%System:DrawImageColor(self.white_dot, boxx-1, boxy+h, w+2, 1, 4, r, g, b, 1);
	-- left edge
	%System:DrawImageColor(self.white_dot, boxx-1, boxy-1, 1, h+2, 4,  r, g, b, 1);
	-- right edge
	%System:DrawImageColor(self.white_dot, boxx+w, boxy-1, 1, h+2, 4,  r, g, b, 1);
		
	-- main box						
	%System:DrawImageColor(nil, boxx, boxy, w, h, 4,1,1,1,1);
	
	for i,val in self.objectives do
		if(not val.completed)then
			%System:DrawImageColor(self.missioncheckbox, boxx+textspacing, y, 16, 16, 4,1,1,1,1);
			%Game:WriteHudString(boxx+textspacing+20, y-3, val.text, self.color.r, self.color.g, self.color.b, 1, 20,20);
		else
			%System:DrawImageColor(self.missioncheckboxcomp, boxx+textspacing, y, 16, 16, 4,0.35,0.35,0.39,1);
			%Game:WriteHudString(boxx+textspacing+20, y-3, val.text, 0.35, 0.35, 0.39, 1, 20,20);
		end
		y=y+30;
	end
end

-----------------------------------------------------
-- Display frame box
-----------------------------------------------------

function Hud:DrawFrameBox(x,y,w,h,a)
	local uv=self.tempUV;
	local bkx,bky,bkw,bkh=x, y, w, h;
	local ouv=self.scoreboard.corner;
	local cw,ch=self.scoreboard.corner.size.w,self.scoreboard.corner.size.h;
	local ctickness=6;	
	
	if(not a) then
		self.rend:PushQuad(bkx,bky,bkw,bkh ,self.scoreboard.background);
	else
		self.rend:PushQuad(bkx,bky,bkw,bkh ,self.scoreboard.background, 1, 1, 1, a);
	end
end

-----------------------------------------------------
-- Display kill icon (mp only)
-----------------------------------------------------

function Hud:DrawKillIcon(x, y, name, alpha)
	if(not name and not self.mpKills[name]) then 
		return 0; 
	end
	
	local pTex=self.mpKills[name];
	
	-- render mirrowed icons
	if(pTex)then	
		local t=self.temp_txinfo;
		merge_no_copy(t,pTex);
		pTex=t;
		
		-- swap coordinates
	    pTex[1],pTex[3]=pTex[3],pTex[1];	

		local sx=pTex.size.w;
		local sy=pTex.size.h;
		self.rend:PushQuad(x, y, sx*(14/sy), 14 , pTex, 1, 1, 1, alpha);
	else
		--System:LogError("DrawKillIcon "..tostring(name));
	end
	
	return 1; 
end

-----------------------------------------------------
-- Display messages box
-----------------------------------------------------

function Hud:DrawMessagesBox(tMsgList, xpos, ypos, killmsg) 
	
	local fTime=_frametime;	
	-- something is wrong with frametime. Clamp it.
	if(fTime<0.002) then
		fTime=0.002;
	elseif(fTime>0.5) then 
		fTime=0.5;	
	end
		
	local n=count(tMsgList);
	if(n>0)then
		local y=0;
		for i,msg in tMsgList do										
			if(msg.lifetime>0.0) then											
				-- lerp messages position
				local lerp=fTime*10;
				
				if(lerp>1.0) then
					lerp=1;
				end
				msg.curr_ypos=msg.curr_ypos+(y-msg.curr_ypos)*lerp;

				-- fade out old msg's
				local textalpha=(4*msg.lifetime*msg.lifetime*msg.lifetime)/6.0;

				if(textalpha>1.0) then
					textalpha=1;
				end
				if(textalpha<0.0) then
					textalpha=0;
				end
				
				local fValue=tonumber(getglobal("hud_fadeamount"));					
				--if(fValue~=1.0) then
					textalpha=textalpha*fValue;
				--end
				

				if (killmsg) then
					local trg = msg.text.target;
					local src = msg.text.shooter;
					local wpn = nil;
					local sit = msg.text.situation;
					local txtKiller, txtKilled, txt;
			
					if (tonumber(sit) == 1) then -- 0 = normal kill, 1 = suicide, 2 = teamkill						
						txtKiller = trg;
						wpn = "Suicided";
						txtKilled= nil;												
						
						txt = trg.." killed itself";
					else
						txtKiller = src;
						wpn= msg.text.weapon;
						txtKilled = trg;
						
						txt = src.." killed "..trg.." with "..wpn;
					end

					local strsizex,strsizey = Game:GetHudStringSize(txtKiller, 20, 20);							
					local currColor=nil;
					
					if(msg.isTop==1) then
						currColor=	self.color_top;						
					else
						currColor=	self.color;						
					end
					
					Game:WriteHudString(xpos, ypos-msg.curr_ypos, txtKiller, currColor.r, currColor.g, currColor.b, textalpha, 12, 12, 0);					
					self:DrawKillIcon(xpos+strsizex+10, ypos-msg.curr_ypos+1, wpn, textalpha);											

					if(txtKilled) then						
						local sx,sy=0, 0;					
						if(wpn and self.mpKills[wpn]) then
							sy=self.mpKills[wpn].size.h;
							sx=self.mpKills[wpn].size.w*(14/sy);												
						end

						Game:WriteHudString(xpos+strsizex+10+sx+10, ypos-msg.curr_ypos, txtKilled, currColor.r, currColor.g, currColor.b, textalpha, 20, 20, 0);
					end
					
					if (not msg.logged) then
						msg.logged = 1;
						System:Log("\001"..txt);
					end
				else																								
					-- output text
					if(msg.isTop==1) then
						Game:WriteHudString(xpos, ypos-msg.curr_ypos, msg.text, self.color_top.r, self.color_top.g, self.color_top.b, textalpha, 20, 20, 0);
					else
						Game:WriteHudString(xpos, ypos-msg.curr_ypos, msg.text, self.color.r, self.color.g, self.color.b, textalpha, 20, 20, 0);
					end
				end

				y=y+20;			
				
				msg.lifetime=msg.lifetime-fTime;											
			else				
				-- remove old messages				
				local j=i;
				local k=count(tMsgList);
												
				while (j <= k) do					
					tMsgList[j]=tMsgList[j+1];																							
					j=j+1;
				end			
			end
		end
	end
end

-----------------------------------------------------
-- Process all messages
-----------------------------------------------------

function Hud:MessagesBox()
	%Game:SetHUDFont("default", "default");		
	if(Game:IsMultiplayer()) then
		self:DrawMessagesBox(self.kill_messages, 20, 15+80+80, 1);
	end
	
	self:DrawMessagesBox(self.messages,  140, 440+4*20);	
end


function Hud:ResetSubtitles()
	for i, subtl in Hud.tSubtitles do
		Hud.tSubtitles[i] = nil;
	end			
	
	Hud.fSubtlCurrY=0.0;
	Hud.fSubtlCurrDelay=0.0;
end
-----------------------------------------------------------------------------
-- add new messages to subtitles box
-----------------------------------------------------------------------------

function Hud:AddSubtitle(text, _lifetime)					
	if(text) then
		local life=6;
		if(_lifetime) then
			life=_lifetime;
		end
		
		-- clamp minimum amount of time that subtitle displays
		if(life<2) then
			life=2;
		end
		 
		self:ProcessAddSubtitle(self.tSubtitles, text, life);
			
		-- used for debugging	
		--self:ProcessAddMessage(self.messages, format("subtime= %f",_lifetime), 6);					
	end
end

-----------------------------------------------------------------------------
-- Process subtitles box
-----------------------------------------------------------------------------

function Hud:ProcessAddSubtitle(tSubtList, text, lifetime) 							
						
	-- create new subtitle	
	tSubtList[count(tSubtList)+1]= {
		time=_time,
		text=text,
		lifetime=lifetime, 				
	};
			
	-- remove old subtitles	
	local k=count(tSubtList);								
	if(k>5) then
		local j=1;
		while (j <= 6) do					
			tSubtList[j]=tSubtList[j+1];														
			j=j+1;
		end			
	end
	
		
	local maxFrameBoxSize=700;	
	local fSizex,fMaxBoxSizey = Game:GetHudStringSize("test", 14, 14, maxFrameBoxSize);
	fmaxBoxSizey=(fMaxBoxSizey+8)*4;
	
	-- count total lines for box to cover
	local boxHeight=0;
	for i,msg in tSubtList do			
		-- output centered text	
		local strsizex,strsizey = Game:GetHudStringSize(msg.text, 14, 14, maxFrameBoxSize);		
		boxHeight=boxHeight+strsizey+8;						
	end

	local fFinalBoxHeight=boxHeight;		
	-- need to activate scrooling
	if(fFinalBoxHeight>fmaxBoxSizey) then
		Hud.fSubtlCurrDelay=_time;
	end
		
end

-----------------------------------------------------
-- Display subtitles box
-----------------------------------------------------

function Hud:DrawSubtitlesBox(tMsgList, xpos, ypos) 
	local n=count(tMsgList);
	if(n>0)then						
		local maxFrameBoxSize=700;
		
		local fSizex,fMaxBoxSizey = Game:GetHudStringSize("test", 14, 14, maxFrameBoxSize);
		fmaxBoxSizey=(fMaxBoxSizey+8)*4;
		
		-- count total lines for box to cover
		local boxHeight=0;
		for i,msg in tMsgList do			
			-- output centered text	
			local strsizex,strsizey = Game:GetHudStringSize(msg.text, 14, 14, maxFrameBoxSize);		
			boxHeight=boxHeight+strsizey+8;						
		end

		local fFinalBoxHeight=boxHeight;		
		-- need to activate scrooling
		if(fFinalBoxHeight>fmaxBoxSizey) then
			fFinalBoxHeight=fmaxBoxSizey;
		end
				
		-- render subtitle box				
		self:DrawFrameBox(20, 20-9-4, 800-40, fFinalBoxHeight);		
		self:FlushCommon();
		
		-- set scissoring area
		System:SetScissor(20, 20-9, 800-40, fFinalBoxHeight-8);
		
		local currTime=_time;
		
		local y=0;
		for i,msg in tMsgList do										
			if(msg) then
				if(currTime-msg.time<msg.lifetime) then	
				--if(msg.lifetime>0.0) then															
					local lifetime=msg.lifetime/_time-msg.time;
					-- fade out old msg's
					local textalpha=1; ---(30*lifetime*lifetime*lifetime);
												
					if(textalpha>1.0) then
						textalpha=1;
					end
					if(textalpha<0.0) then
						textalpha=0;
					end
					
					-- output centered text	
					local strsizex,strsizey = Game:GetHudStringSize(msg.text, 14, 14, maxFrameBoxSize);		
					
					-- just write text					
					Game:WriteHudString(400-strsizex*0.5, ypos+y-Hud.fSubtlCurrY, msg.text, 0, 0.75, 1, textalpha, 14, 14, 0, maxFrameBoxSize);						
					y= y + strsizey+8;														
																																
				else				
					-- remove old messages				
					local j=i;
					local k=count(tMsgList);
													
					while (j <= k) do					
						tMsgList[j]=tMsgList[j+1];														
						j=j+1;
					end			
				end
	
			end
		end
						
		-- need to activate scrolling					
		if(boxHeight-fmaxBoxSizey>0) then
			-- activate fake delay..
			if(Hud.fSubtlCurrDelay>0 and _time-Hud.fSubtlCurrDelay>1.0) then			
		    if(boxHeight-fmaxBoxSizey>Hud.fSubtlCurrY) then
					Hud.fSubtlCurrY=Hud.fSubtlCurrY+3.0*_frametime;
				else
					Hud.fSubtlCurrY=boxHeight-fmaxBoxSizey;
				end
				
			end
			
		else
			Hud.fSubtlCurrY=0;
			Hud.fSubtlCurrDelay=0.0;
		end
		
		-- reset scissoring
		System:SetScissor(0, 0, 0, 0);
	end
end

-----------------------------------------------------
-- Process subtitles
-----------------------------------------------------

function Hud:SubtitlesBox()
	%Game:SetHUDFont("default", "default");
	
	local subCount= count(self.tSubtitles);
	
	if(subCount>=1) then		
		self:DrawSubtitlesBox(self.tSubtitles,  100, 20-9);	
	end	
	
end

-----------------------------------------------------
-- Display all weapon slots
-----------------------------------------------------

function Hud:DrawWeaponSlots(player)

	local weapons=player.cnt:GetWeaponsSlots();
			
	-- main weapon slots
	if (Hud.weapons_alpha>0.0) then											
		local x,y=220,548;
		local alpha_scale=Hud.weapons_alpha;				
				
		self.curr_newweapon=self.new_weapon;
		
		-- save current weapon
		if(Hud.weapons_alpha==1.0) then		
			local tmp=self.new_weapon;

			if(self.currnew_weapon~=self.new_weapon) then
				self.curr_weapon=self.new_weapon;
			else
				self.curr_weapon=player.cnt:GetCurrWeaponId();				
			end
			
			if(self.currpl_weapon~=player.cnt:GetCurrWeaponId()) then
				self.curr_weapon=player.cnt:GetCurrWeaponId();				
			end			
		
			self.currnew_weapon=self.new_weapon;
			self.currpl_weapon=player.cnt:GetCurrWeaponId();									
		end		
						
		-- draw each slot
		for i,val in weapons do						
			if(val and type(val)=="table") then
				local currId=Game:GetWeaponClassIDByName(val.name);
				
				if(currId~=self.curr_weapon)then
					self:DrawWeapon(x, y, currId, 0.4*alpha_scale);					
				else				
					alpha_scale=alpha_scale*2;
					if(alpha_scale>1.0) then
						alpha_scale=1.0;
					end
					self:DrawWeapon(x, y, currId, alpha_scale);					
				end
				
				x=x+84;												
			else
				self:DrawWeapon(x, y, 0, 0.4*alpha_scale);			
				x=x+84;															
			end
		end

		local FrameTime=_frametime;
		Hud.weapons_alpha=Hud.weapons_alpha-(FrameTime*0.25);
		if(Hud.weapons_alpha<0)then
			Hud.weapons_alpha=0;			
		end
	end			
end

-----------------------------------------------------
-- Display a weapon slot
-----------------------------------------------------

function Hud:DrawWeapon(x,y,w,alpha)
	if(alpha<=0.0) then return end;

	self:DrawElement(x, y,self.txi.shape_bar,1,1,1,0.5*alpha);
	if(w and w and self.tweapons[w] )then
		local txi=self.txi.shape_bar;
		local weapon_txi=self.tweapons[w];
		local offsetX, offsetY= txi.size.w*0.5,txi.size.h*0.5;
		
		offsetX=offsetX-weapon_txi.size.w*0.5;
		offsetY=offsetY-weapon_txi.size.h*0.5;
		
		self:DrawElement(x+offsetX, y+offsetY, weapon_txi, 1, 1, 1, alpha);
	end
end

-----------------------------------------------------
-- Display grenate slots
-----------------------------------------------------

function Hud:DrawGrenadeSlot(player,x,y,num,grenade)
		
	if(grenade and self.tgrenades[grenade])then
		color=self.color_white;
				
		--if(player.cnt.holding_grenade)then
		--	local FrameTime=_frametime;
		--	self.grenade_blink=self.grenade_blink+FrameTime;
		--	if(self.grenade_blink>0.5)then
		--		if(self.grenade_blink>1)then self.grenade_blink=0; end
		--		color=self.color_red;
		--	else
		--		color=self.color_white;
		--	end
		--else
		color=self.color_white;
		--end
				
		self:DrawElement(x, y,self.tgrenades[grenade],color[1],color[2],color[3],color[4]);
		
		if(num)then
			if(num>9)then num=9 end
			self:DrawNumber(1, 1,x+10,y+12,num);
		end
	end
end

-----------------------------------------------------
-- Todo: check if this is still used
-----------------------------------------------------

function Hud:OnLightning()
	if (ClientStuff.vlayers:IsActive("NightVision")) then
		NightVision:OnLightning();
	end
end

-----------------------------------------------------
-- Set melee damage type
-----------------------------------------------------

function Hud:OnMeleeDamage(damage_type)
	--System:LogToConsole("client damage "..damage_type);
	if(damage_type) then
		Hud.meleeDamageType=damage_type;
	else
		Hud.meleeDamageType=nil;
	end    
end

-----------------------------------------------------
-- Reset screen damage effect
-----------------------------------------------------

function Hud:ResetDamage()
	self.hitdamagecounter=0;
	System:SetScreenFx("ScreenBlur", 0);
	System:SetScreenFxParamFloat("ScreenBlur", "ScreenBlurAmount", 0);
end

-----------------------------------------------------
-- Increment screen damage effect hit counter
-----------------------------------------------------

function Hud:OnMiscDamage(fDamageAmount)
	if(fDamageAmount>0.0) then
		self.hitdamagecounter=self.hitdamagecounter+fDamageAmount;
		
		-- clamp hit max
		if(self.hitdamagecounter>10) then
			self.hitdamagecounter=10;
		end
	end
end

-------------------------------------------
-- Set current screen damage effect color
-------------------------------------------

function Hud:SetScreenDamageColor(r, g, b) 
	System:SetScreenFxParamFloat("ScreenBlur", "ScreenBlurColorRed", r);
	System:SetScreenFxParamFloat("ScreenBlur", "ScreenBlurColorGreen", g);
	System:SetScreenFxParamFloat("ScreenBlur", "ScreenBlurColorBlue", b);				
end

-------------------------------------------
-- Display googles energy meter/batery time
-------------------------------------------

function Hud:DrawGooglesOMeter(x1,y1)
	local LocalPlayer=_localplayer;
			
	if(LocalPlayer.items and LocalPlayer.items.heatvisiongoggles) then
		if(LocalPlayer.Energy~=0) then								
			local x, y= 136, 553;

			local vehicle=LocalPlayer.cnt:GetCurVehicle(); 
			if(vehicle) then
			 	y=570;
			end
			
			self:DrawGauge(x+4, y+4, LocalPlayer.Energy, 100, self.txi.googles_energy_inside, 1, 1, 1, 0.9, 0, 0);									
			self:DrawElement(x, y, self.txi.shape_googles_energy);				
		end
	end
end

--------------------------------
-- Render all stuff in hud stack
--------------------------------

function Hud:FlushCommon()	
	self.rend:Draw(self.tx_hud);
end

-------------------------------------
-- Update common (mp/sp) hud elements
-------------------------------------

function Hud:OnUpdateCommonHudElements()
	local player=_localplayer;
	--first draw crosshair
	if hud_crosshair=="1" then
		self:DrawCrosshair(player);
	end
	--stop here if player is a spectator
	if (player.entity_type == "spectator") then return; end
	-----------------------
	-- display energy meter	
	
	self:DrawGooglesOMeter(136, 570);
	
	--------------------
	-- blink energy bars	
			
	if(self.DisplayControl.bBlinkEnergyMeter>=1) then
		self.DisplayControl.fBlinkUpdateEnergyMeter = self.DisplayControl.fBlinkUpdateEnergyMeter + 3*_frametime;
		if(self.DisplayControl.fBlinkUpdateEnergyMeter>1) then
			self.DisplayControl.fBlinkUpdateEnergyMeter=0;
			
			self.DisplayControl.bBlinkEnergyMeter=self.DisplayControl.bBlinkEnergyMeter+1;			
			if(self.DisplayControl.bBlinkEnergyMeter>6*3) then
				self.DisplayControl.bBlinkEnergyMeter=0;			
			end
		end
	else
		self.DisplayControl.fBlinkUpdateEnergyMeter=0;
	end
					
	---------------------
	-- render energy bars
		
	if (self.DisplayControl.bShowEnergyMeter==1) then
		if(self.DisplayControl.bBlinkEnergyMeter==0 or self.DisplayControl.fBlinkUpdateEnergyMeter>0.5) then 
			Hud:DrawEnergy(player);
		end
	end

	------------------
	-- blink ammo bars	
	------------------

	if(self.DisplayControl.bBlinkAmmo>=1) then
		self.DisplayControl.fBlinkUpdateAmmo = self.DisplayControl.fBlinkUpdateAmmo + 3*_frametime;
		if(self.DisplayControl.fBlinkUpdateAmmo>1) then
			self.DisplayControl.fBlinkUpdateAmmo=0;
			
			self.DisplayControl.bBlinkAmmo=self.DisplayControl.bBlinkAmmo+1;			
			if(self.DisplayControl.bBlinkAmmo>6*3) then
				self.DisplayControl.bBlinkAmmo=0;			
			end
		end
	else
		self.DisplayControl.fBlinkUpdateAmmo=0;
	end

	-------------------
	-- render ammo bars
					
	if (self.DisplayControl.bShowAmmo == 1) then
		if(self.DisplayControl.bBlinkAmmo==0 or self.DisplayControl.fBlinkUpdateAmmo>0.5) then
			self:DrawAmmo(player);
		end
	end

	-- render weapons slots (blinking not used here)
	if(self.DisplayControl.bShowWeapons  == 1) then
		self:DrawWeaponSlots(player);
	end


	local wscope=ClientStuff.vlayers:IsActive("WeaponScope");

	self:DrawLabel();
	
	
		
	for key,value in self.Progress do
		self:DrawProgressIndicator(key);		
	end
	
	local vehicle=player.cnt:GetCurVehicle();
	if(vehicle)then
		self:DrawVehicleBar(vehicle, vehicle.cnt.engineHealthReadOnly);
	end
	
	if self.idShowMissionObject then
		local ent=System:GetEntity(Hud.idShowMissionObject);
		ent:Render();
	end
	
	--------------
	-- blink radar
		
	if(self.DisplayControl.bBlinkRadar>=1) then
		self.DisplayControl.fBlinkUpdateRadar = self.DisplayControl.fBlinkUpdateRadar + 3*_frametime;
		if(self.DisplayControl.fBlinkUpdateRadar>1) then
			self.DisplayControl.fBlinkUpdateRadar=0;
			
			self.DisplayControl.bBlinkRadar=self.DisplayControl.bBlinkRadar+1;			
			if(self.DisplayControl.bBlinkRadar>6*3) then
				self.DisplayControl.bBlinkRadar=0;			
			end
		end
	else
		self.DisplayControl.fBlinkUpdateRadar=0;
	end

	---------------
	-- render radar
		
	if (self.DisplayControl.bShowRadar == 1) then
		if(self.DisplayControl.bBlinkRadar==0 or self.DisplayControl.fBlinkUpdateRadar>0.5) then
			self:DrawRadar(15, 480, 104, 102);
		end
	end		

	self:FlushCommon();
	
	-----------------
	-- render pickups	
	
	if(cl_hud_pickup_icons=="1") then
		Hud:DrawPickups();
	end
	
	------------
	-- reset hud	
	
	local fValue=tonumber(hud_fadeamount);	
	if(fValue==0.0) then
		--hud_fadeamount="1";
	end

	if(tonumber(getglobal("cl_motiontracker"))==1) then		
		if(ClientStuff and ClientStuff.vlayers and ClientStuff.vlayers:IsActive("Binoculars")) then	
			self.curr_motiontrackerAlpha=self.curr_motiontrackerAlpha+_frametime*2;		
			if(self.curr_motiontrackerAlpha>1.0) then
				self.curr_motiontrackerAlpha=0;
			end
			
			self:DrawElement(765, 470, self.txi.motiontracker_border, 1, 1, 1, 1);	
			self:DrawElement(765+(30-14)*0.5, 470+(24-14)*0.5, self.txi.motiontracker_signal, 1, 1, 1, self.curr_motiontrackerAlpha);	
		end
	end
				
end


