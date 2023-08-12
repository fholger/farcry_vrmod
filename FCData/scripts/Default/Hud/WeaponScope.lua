WeaponScope={
	overlay_func=nil,
	v_01010={x=0.11,y=0.09,z=0.05},
	v_M4={x=0.09,y=0.01,z=0.03},
	v_MP5={x=0.05,y=0.04,z=0.03},
	temp={},
	target_pos_temp={},
	LastZoom=1,
}
-------------------------------------------------------
function WeaponScope:OnActivate()
	local w=_localplayer.cnt.weapon;
	if(w)then
		--System:Log("Aiming = TRUE");
		_localplayer.cnt.aiming=1;
		w.ZoomActive = 1;

		self.PrevZoomStep = nil;
		if(w.ZoomOverlayFunc)then
			--System:Log("WeaponScope -> ZoomOverlayFunc");
			self.overlay_func=w.ZoomOverlayFunc;
		else
			--System:Log("WeaponScope -> Default OverlayFunc");
			self.overlay_func=DefaultZoomHUD.DrawHUD
			--FIX THIS
			DefaultZoomHUD.MulMask = _localplayer.fireparams.ScopeTexId
		end

		_localplayer.cnt.bForceWalk = 1;

		if ( w.MaxZoomSteps ) then
			ZoomView.MaxZoomSteps = w.MaxZoomSteps;
			ZoomView.ZoomSteps = w.ZoomSteps;
		else
			ZoomView.MaxZoomSteps = 3;
			ZoomView.ZoomSteps = { 2, 4, 6 };
		end

		if(w.DoesFTBSniping)then
			self.fade=_time;
			self.has_aimmode=1;
			ZoomView.CurrZoomStep = 1;
		elseif(w.AimMode)then
			self.fade=_time;
			self.has_aimmode=1;
			ZoomView.CurrZoomStep = 1;
		else
			self.has_aimmode=nil;
			ZoomView.CurrZoomStep=min(self.LastZoom,ZoomView.MaxZoomSteps);
			_localplayer.cnt.drawfpweapon=nil;
		end

		if(w.DoesFTBSniping)then
			_localplayer.cnt.weapon_busy = w:GetAnimationLength("StartSniping");
			w:StartAnimation(0,"StartSniping",0,0.3);
		else
			ZoomView:Activate(nil,w.Sway,w.ZoomFixedFactor,w.AimMode);
		end

	end
end
-------------------------------------------------------
function WeaponScope:OnDeactivate(nofade)
	--System:Log("WeaponScope:OnDeactivate");

	-- this check is necessary to allow 'double-clicking' of aim button
	if((not ClientStuff.vlayers:IsActive("WeaponScope")) or nofade ~= nil)then
		self.fade = nil;
		self.target_pos = nil;
		self.blend = nil;

		if(_localplayer.cnt.drawfpweapon~=1) then
			_localplayer.cnt.drawfpweapon=1;
		end

		local w=_localplayer.cnt.weapon;
		w.ZoomActive = 0;
		r_ScreenRefract=0
		-- [MarcoK] M5 change request
		--self.LastZoom=ZoomView.CurrZoomStep;
		self.LastZoom=1;
		ZoomView:Deactivate();
		_localplayer.cnt.bForceWalk=nil;

	  if(ClientStuff.vlayers:IsActive("Binoculars"))then
			_localplayer.cnt.drawfpweapon=nil;
	  end

		--System:Log("Aiming = NIL");
		_localplayer.cnt.aiming=nil;
		if (w) then
			w.cnt:SetFirstPersonWeaponPos(g_Vectors.v000, g_Vectors.v000);
		end
	end
end
-------------------------------------------------------
function WeaponScope:OnFadeOut()
	--System:Log("WeaponScope:OnFadeOut");
	local w=_localplayer.cnt.weapon;
	r_ScreenRefract=0
	if(not self.has_aimmode)then
		self:OnDeactivate();
		return 1
	elseif(ZoomView:FadeOut())then
		self:OnDeactivate();
		return 1;
	end

	if(self.has_aimmode)then
		local pos = self.temp;
		local srcPos;
		if (self.target_pos~=nil)then
			srcPos = self.target_pos;
		else
			srcPos = self.v_01010;
		end
		pos.x = srcPos.x;
		pos.y = srcPos.y;
		pos.z = srcPos.z;

		if(self.blend)then
			local theBlend = ZoomView.blend;
			--System:Log("theBlend "..tostring(theBlend));
			if (theBlend < 0) then
				theBlend = 0;
			end

			ScaleVectorInPlace(pos, theBlend);
			if (w) then
				w.cnt:SetFirstPersonWeaponPos(pos, g_Vectors.v000);
			end
		end
	end
end
-------------------------------------------------------
function WeaponScope:DrawOverlay()

	if((self.overlay_func and (not self.fade))
	or (self.fade and self.state~=1))then
		self:overlay_func(ZoomView.CurrZoomStep);
	end
	if (self.DoesFTBSniping and self.state~=1) then
		FTBSniping:OnEnhanceHUD();
	end
end
-------------------------------------------------------
function WeaponScope:OnUpdate()
	local w=_localplayer.cnt.weapon;
	if ((w.DoesFTBSniping and self.state==2) or (not w.DoesFTBSniping)) then
		ZoomView:OnUpdate();
	end

	ZoomView.StanceSwayModifier = 1.0;

	if (w.DoesFTBSniping) then

		if(_time-self.fade<0.4)then
			--System:Log("STATE 1");
			self.state=1;
			ZoomView:Reset()
		else
			if(self.state==1)then
				--System:Log("STATE 1 >> STATE 2");
				self.state=2;
				_localplayer.cnt.drawfpweapon=nil;
				ZoomView:Activate(nil,w.Sway,w.ZoomFixedFactor,w.AimMode);
				FTBSniping:OnActivate();
				r_ScreenRefract=2
			end
			if (_localplayer.cnt.proning) then
				ZoomView.StanceSwayModifier = _localplayer.SwayModifierProning;
			elseif (_localplayer.cnt.crouching) then
				ZoomView.StanceSwayModifier = _localplayer.SwayModifierCrouching;
			else
				ZoomView.StanceSwayModifier = 1.0;
			end
			FTBSniping:OnUpdate();
		end

	end
	if(w.AimMode)then
		if (self.target_pos == nil) then
			local pos = self.target_pos_temp;
			pos.x=self.v_01010.x;
			pos.y=self.v_01010.y;
			pos.z=self.v_01010.z;

			--adjust some specific weapon positions
			if(w.name=="M4")then
				pos.x=self.v_M4.x;
				pos.y=self.v_M4.y;
				pos.z=self.v_M4.z;
			elseif(w.name=="MP5")then
				pos.x=self.v_MP5.x;
				pos.y=self.v_MP5.y;
				pos.z=self.v_MP5.z;
			end

			self.target_pos = pos;
		end

		local pos = self.temp;
		pos.x = self.target_pos.x;
		pos.y = self.target_pos.y;
		pos.z = self.target_pos.z;

		if(self.fade)then
			if (self.blend == nil) then
				self.blend = 0;
			end
			--self.blend = self.blend + _frametime/0.4;
			self.blend = ZoomView.blend;
			if (self.blend > 1.0) then
				self.blend = 1.0;
			end
			ScaleVectorInPlace(pos, self.blend);
			w.cnt:SetFirstPersonWeaponPos(pos, g_Vectors.v000);
		end
	end
end
