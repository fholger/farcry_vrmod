Script:LoadScript("scripts/materials/commoneffects.lua");
Materials["mat_canvas"] = {
	type="canvas",

-------------------------------------
	PhysicsSounds=PhysicsSoundsTable.Hard,
-------------------------------------	
	bullet_drop_single = CommonEffects.common_bullet_drop_single_ashphalt,
	bullet_drop_rapid = CommonEffects.common_bullet_drop_rapid_ashphalt,
-------------------------------------	
	bullet_hit = {
		sounds = {
			{"Sounds/Bullethits/Wsheet1.wav",SOUND_UNSCALABLE,200,5,60},
			{"Sounds/Bullethits/Wsheet2.wav",SOUND_UNSCALABLE,200,5,60},
			{"Sounds/Bullethits/Wsheet3.wav",SOUND_UNSCALABLE,200,5,60},
			{"Sounds/Bullethits/Wsheet4.wav",SOUND_UNSCALABLE,200,5,60},
		},
		
		decal = { 
			texture = System:LoadTexture("Textures/Decal/Default.tga"),
			scale = 0.025,
		},
		particles = {
			{ --HitSmoke 
				focus = 1.5,
				color = {0.29,0.19,0.0},
				speed = 0.25,
				count = 3, 
				size = 0.05, 
				size_speed=0.15,
				gravity=-1,
				lifetime=0.5,
				tid = System:LoadTexture("textures\\cloud1.dds"),
				frames=0,
				color_based_blending = 3
			},
		},
	},

	projectile_hit = CommonEffects.common_projectile_hit,
	mortar_hit = CommonEffects.common_mortar_hit,
	smokegrenade_hit = CommonEffects.common_smokegrenade_hit,
	flashgrenade_hit = CommonEffects.common_flashgrenade_hit,
	grenade_hit = CommonEffects.common_grenade_hit,
	melee_slash = {
		sounds = {
			{"sounds/weapons/machete/machetewood1.wav",SOUND_UNSCALABLE,185,5,30,{fRadius=10,fInterest=1,fThreat=0,},},
			{"sounds/weapons/machete/machetewood2.wav",SOUND_UNSCALABLE,185,5,30,{fRadius=10,fInterest=1,fThreat=0,},},
			{"sounds/weapons/machete/machetewood3.wav",SOUND_UNSCALABLE,185,5,30,{fRadius=10,fInterest=1,fThreat=0,},},
		},
		particles =  CommonEffects.common_machete_hit_canvas_part.particles,

	},

-------------------------------------
	player_walk = {
		sounds = {
			{"sounds/player/footsteps/rock/step1.wav",SOUND_UNSCALABLE,140,10,60},
			{"sounds/player/footsteps/rock/step2.wav",SOUND_UNSCALABLE,140,10,60},
			{"sounds/player/footsteps/rock/step3.wav",SOUND_UNSCALABLE,140,10,60},
			{"sounds/player/footsteps/rock/step4.wav",SOUND_UNSCALABLE,140,10,60},
		},
	},
	player_run = {
		sounds = {
			{"sounds/player/footsteps/rock/step1.wav",SOUND_UNSCALABLE,200,10,60},
			{"sounds/player/footsteps/rock/step2.wav",SOUND_UNSCALABLE,200,10,60},
			{"sounds/player/footsteps/rock/step3.wav",SOUND_UNSCALABLE,200,10,60},
			{"sounds/player/footsteps/rock/step4.wav",SOUND_UNSCALABLE,200,10,60},
		},
	},
	player_crouch = {
		sounds = {
			{"sounds/player/footsteps/rock/step1.wav",SOUND_UNSCALABLE,120,10,60},
			{"sounds/player/footsteps/rock/step2.wav",SOUND_UNSCALABLE,120,10,60},
			{"sounds/player/footsteps/rock/step3.wav",SOUND_UNSCALABLE,120,10,60},
			{"sounds/player/footsteps/rock/step4.wav",SOUND_UNSCALABLE,120,10,60},
		},
	},
	player_prone = {
		sounds = {
			{"sounds/player/footsteps/rock/step1.wav",SOUND_UNSCALABLE,120,10,60},
			{"sounds/player/footsteps/rock/step2.wav",SOUND_UNSCALABLE,120,10,60},
			{"sounds/player/footsteps/rock/step3.wav",SOUND_UNSCALABLE,120,10,60},
			{"sounds/player/footsteps/rock/step4.wav",SOUND_UNSCALABLE,120,10,60},
		},
	},
	player_walk_inwater = CommonEffects.player_walk_inwater,
	gameplay_physic = {
		piercing_resistence = 15,
		friction = 0.6,
		bouncyness= 0.2, --default 0
	},

	AI = {
		fImpactRadius = 1,
	},
			
}