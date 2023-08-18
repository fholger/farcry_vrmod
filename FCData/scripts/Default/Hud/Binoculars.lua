--------------------------------------------------------------------
-- X-Isle Script File
-- Description: Defines the binoculars
-- Created by Lennert Schneider
--------------------------------------------------------------------

Binoculars = {
	IsActive = 0,
	ZoomActive = 0,												-- initially always 0
	LastZoom = 1,
}

-------------------------------------------------------
function Binoculars:OnInit()
	Binoculars.ZoomLevelChangeSound=Sound:LoadSound("Sounds/Items/BinoZoomChange.wav");
	Binoculars.StaticNoise=Sound:LoadSound("Sounds/radiovoices/aistatic.wav");

	local cur_r_TexResolution = tonumber( getglobal( "r_TexResolution" ) );
	if( cur_r_TexResolution >= 2 ) then -- lower res texture for low texture quality setting
		Binoculars.TID_Background=System:LoadImage("Textures/Hud/Binocular/binoculars_low.tga");
	else
		Binoculars.TID_Background=System:LoadImage("Textures/Hud/Binocular/binoculars_new.tga");
	end
	if( cur_r_TexResolution >= 1 ) then -- lower res texture for low/med texture quality setting
		Binoculars.TID_Compass=System:LoadImage("Textures/Hud/Binocular/binoculars_compass_low.tga");
	else
		Binoculars.TID_Compass=System:LoadImage("Textures/Hud/Binocular/binoculars_compass.tga");
	end

	--Binoculars.TID_Power=System:LoadImage("Textures/Hud/Binocular/binoculars_battery");
	Binoculars.TID_Equalizer=System:LoadImage("Textures/Hud/Binocular/equalizer");
	--Binoculars.TID_PowerGauge=System:LoadImage("Textures/Hud/Binocular/binoculars_energy");
	Binoculars.TID_Transition=System:LoadImage("Textures/Hud/Binocular/binoculars_transition");
	Binoculars.TID_RefrMask=System:LoadImage("Textures/blurmask.tga");
	Binoculars.Zoom={};
	Binoculars.Zoom[1]={};
	Binoculars.Zoom[1].Factor=2.0;
	Binoculars.Zoom[1].TID=System:LoadImage("Textures/Hud/Binocular/binoculars_zoom_2");
	Binoculars.Zoom[2]={};
	Binoculars.Zoom[2].Factor=4.0;
	Binoculars.Zoom[2].TID=System:LoadImage("Textures/Hud/Binocular/binoculars_zoom_4");
	Binoculars.Zoom[3]={};
	Binoculars.Zoom[3].Factor=6.0;
	Binoculars.Zoom[3].TID=System:LoadImage("Textures/Hud/Binocular/binoculars_zoom_6");
	Binoculars.Zoom[4]={};
	Binoculars.Zoom[4].Factor=8.0;
	Binoculars.Zoom[4].TID=System:LoadImage("Textures/Hud/Binocular/binoculars_zoom_8");
	Binoculars.Zoom[5]={};
	Binoculars.Zoom[5].Factor=10.0;
	Binoculars.Zoom[5].TID=System:LoadImage("Textures/Hud/Binocular/binoculars_zoom_10");
	Binoculars.Zoom[6]={};
	Binoculars.Zoom[6].Factor=12.0;
	Binoculars.Zoom[6].TID=System:LoadImage("Textures/Hud/Binocular/binoculars_zoom_12");
	Binoculars.Zoom[7]={};
	Binoculars.Zoom[7].Factor=24.0;
	Binoculars.Zoom[7].TID=System:LoadImage("Textures/Hud/Binocular/binoculars_zoom_24");
	Binoculars.CurrZoom=2;
end

-------------------------------------------------------
function Binoculars:OnShutdown()
	Binoculars.TID_Background=nil;
	Binoculars.TID_Compass=nil;
	--Binoculars.TID_Power=nil;
	Binoculars.TID_Equalizer=nil;
	--Binoculars.TID_PowerGauge=nil;
	Binoculars.ZoomLevelChangeSound=nil;
	Binoculars.Zoom=nil;
end

----------------------------------
function Binoculars:OnActivate()
--	System:Log("Binoculars:OnActivate()");

	-- make sure that the player is in first person mode
	Game:SetThirdPerson(0);

	if (Binoculars.StaticNoise) then
		Sound:SetSoundLoop(Binoculars.StaticNoise, 1);
		Sound:SetSoundVolume(Binoculars.StaticNoise, 25);
		Sound:PlaySound(Binoculars.StaticNoise);
	end
	
	ZoomView.Zoomable = 1;
	
	-- Hack:Only reset zoom data if binoculars deactivated. Else they are active already (after quickload)
	if(Binoculars.IsActive==0) then
		ZoomView.CurrZoomStep = Binoculars.LastZoom;
	else
		ZoomView.CurrZoomStep = self.LastZoomStep;
	end
	
	ZoomView.MaxZoomSteps = 7;
	ZoomView.ZoomSteps={
		Binoculars.Zoom[1].Factor,
		Binoculars.Zoom[2].Factor,
		Binoculars.Zoom[3].Factor,
		Binoculars.Zoom[4].Factor,
		Binoculars.Zoom[5].Factor,
		Binoculars.Zoom[6].Factor,
		Binoculars.Zoom[7].Factor,  
  };
	 	 
	-- Hack:Only reset zoom data if binoculars deactivated. Else they are active already (after quickload)
	if(Binoculars.IsActive==0) then
		Binoculars.LastZoomStep = -1;
		Binoculars.LastChangeTime = 0;
	end
	
	_localplayer.cnt.drawfpweapon=nil;
	--_localplayer:DrawCharacter(0,0);
	ZoomView:Activate("binozoom", nil);
	_localplayer.DisableSway = 1;
	ClientStuff.vlayers:ActivateLayer("MoTrack");
	
	Binoculars.IsActive=1;
end

----------------------------------
function Binoculars:OnDeactivate()
--	System:Log("Binoculars:OnDeactivate()");
	local MyPlayer = _localplayer;	
				
	if (Binoculars.StaticNoise) then
		Sound:StopSound(Binoculars.StaticNoise);
	end
	
	Sound:SetDirectionalAttenuation(MyPlayer:GetPos(), MyPlayer:GetAngles(), 0);
	Binoculars.IsActive=0;
	-- [MarcoK] M5 change request
	--Binoculars.LastZoom=ZoomView.CurrZoomStep;
	--Binoculars.LastZoom=1;
	ZoomView:Deactivate();
	MyPlayer.DisableSway = nil;
	ClientStuff.vlayers:DeactivateLayer("MoTrack");
	MyPlayer.cnt.drawfpweapon=1;
end

----------------------------------
function Binoculars:DrawOverlay()
	-- if we're using the binoculars send an OBSERVE-mood-event
	if (Binoculars.IsActive~=0) then
		Sound:AddMusicMoodEvent("Observe", MM_OBSERVE_TIMEOUT);
	end

	Sound:SetDirectionalAttenuation(Game:GetCameraPos(), Game:GetCameraAngles(), Game:GetCameraFov());

	ZoomStep=ZoomView.CurrZoomStep;
	if ( ZoomStep~=Binoculars.LastZoomStep ) then
		Sound:PlaySound(Binoculars.ZoomLevelChangeSound);
		Binoculars.LastZoomStep = ZoomStep;
		Binoculars.LastChangeTime = _time;
	end

	local StaticFactor=(_time-Binoculars.LastChangeTime)/0.3;
	if ( StaticFactor<1 ) then
--		System:DrawRectShader("NoiseMask", 0, 0, 800, 600, 0.5, 0.5, 0.5, 1.0-StaticFactor);
		local v=StaticFactor*2;
		System:DrawImageColorCoords( Binoculars.TID_Transition, 0, 0, 800, 600, 4, 1, 1, 1, 1.0-StaticFactor*StaticFactor, 0, 0.9+v, 1, v );
	end
	local myPlayer=_localplayer;
	local u=(-myPlayer:GetAngles().z+217)/360+0.27;
	System:DrawImageColorCoords( Binoculars.TID_Compass, 401, 185, 60, 16, 4, 1, 1, 1, 1, u-0.04, 1, u+0.04, 0 );

--	System:DrawRefractMask(Binoculars.TID_RefrMask,0,0,800,600);

	System:DrawImage( Binoculars.TID_Background, 0, 0, 800, 600, 4);
	--System:DrawImageColorCoords( Binoculars.TID_Background, 400, 0, 400, 600, 4, 1, 1, 1, 1, 0, 1, 1, 0 );
	--System:DrawImage( Binoculars.TID_Power, 675, 415, 24, 50, 4 );
	--local EqLength=Sound:GetDirectionalAttenuationMaxScale()*0.9+random(0,10)*0.01;	-- lets add some random value so the equalizer looks like it would really equalize something :p

	--System:DrawImageColorCoords( Binoculars.TID_Equalizer, 390, 390, 10+EqLength*60, 15, 4, 1, 1, 1, 1, 0, 1, EqLength, 0);
	--System:DrawImageColorCoords( Binoculars.TID_PowerGauge, 678, 435, 22, 30, 4, 1, 1, 1, 1, 0, 1, 1, 0 );

	--	System:DrawImageColorCoords( Binoculars.TID_PowerGauge, 679, 430, 16, 35, 4, 1, 1, 1, 1, 0, 1, 1, 0 );

	--System:DrawImage( Binoculars.Zoom[ZoomStep].TID, 34, 210, 20, 180, 4 );

	Game:SetHUDFont("radiosta", "binozoom");
	
	--Game:WriteHudStringFixed(50, 287, format( "%02dX",(Binoculars.Zoom[ZoomView.CurrZoomStep].Factor)),  0.0, 1, 0.9, 0.5, 20, 20, 0.6);
	Game:WriteHudString(50, 292, format( "%02dX",(Binoculars.Zoom[ZoomView.CurrZoomStep].Factor)),  0.0, 1, 0.9, 0.5, 15, 15);						
	
	-- Draw distance
	local int_pt=myPlayer.cnt:GetViewIntersection();

	if ( int_pt ) then
		local s=format( "%07.2fm", int_pt.len*1.5);
		--Game:WriteHudStringFixed(397, 232, s, 0.0, 1, 0.9, 0.5, 20, 20, 0.6);
		Game:WriteHudString(400, 232, s, 0.0, 1, 0.9, 0.5, 15, 15);						
		--System:LogToConsole("pos="..int_pt.x..","..int_pt.y..","..int_pt.z.."|"..int_pt.angles.x..","..int_pt.angles.y..","..int_pt.angles.z)
	else
		Game:WriteHudString(400, 232, "----.--m", 0.0, 1, 0.9, 0.5, 15, 15);						
		--Game:WriteHudStringFixed(397, 232, "----.--m", 0.0, 1, 0.9, 0.5, 20, 20, 0.6);
	end
end

-------------------------------------------------------
-- Restore binoculars data
function Binoculars:OnRestore(pRestoreTbl)
	self.IsActive = pRestoreTbl.IsActive;
	self.ZoomActive = pRestoreTbl.ZoomActive;
	self.LastZoom = pRestoreTbl.LastZoom;
	self.LastZoomStep = pRestoreTbl.LastZoomStep;
	self.LastChangeTime = pRestoreTbl.LastChangeTime;	
	self.CurrZoom = pRestoreTbl.CurrZoom;		
	self.Zoom = pRestoreTbl.Zoom;			

	-- make sure motion tracker disabled
	if(ClientStuff and ClientStuff.vlayers) then
		ClientStuff.vlayers:DeactivateLayer("MoTrack");		
	end
end
