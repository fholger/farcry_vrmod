
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//	
//  File: GameShared.h
//  Description: Stuff shared by game' source files.
//
//  History:
//  - August 9, 2001: Created by Alberto Demichelis
//	- February 2005: Modified by Marco Corbetta for SDK release
//	- October 2006: Modified by Marco Corbetta for SDK 1.4 release
//
//////////////////////////////////////////////////////////////////////

#ifndef GAME_GAMESHARED_H
#define GAME_GAMESHARED_H
#if _MSC_VER > 1000
# pragma once
#endif

//////////////////////////////////////////////////////////////////////////////////////////////
#define INVALID_WID		0	// Invalid WORD ID --- value for the CIDGenerator class

//////////////////////////////////////////////////////////////////////////////////////////////
// Actions

typedef unsigned char ACTIONTYPE;

#define ACTION_MOVE_LEFT				1
#define ACTION_MOVE_RIGHT				2
#define ACTION_MOVE_FORWARD			3
#define ACTION_MOVE_BACKWARD		4
#define ACTION_JUMP							5
#define ACTION_MOVEMODE					6
#define ACTION_FIRE0						7
#define ACTION_VEHICLE_BOOST		8	// orphaned

#define ACTION_SCORE_BOARD			8
#define ACTION_RELOAD						9
#define ACTION_USE							10
#define ACTION_TURNLR						11
#define ACTION_TURNUD						12
#define ACTION_WALK							13
#define ACTION_NEXT_WEAPON			14
#define ACTION_PREV_WEAPON			15
#define ACTION_LEANRIGHT				16
#define ACTION_HOLDBREATH				17
#define ACTION_FIREMODE					18
#define ACTION_LEANLEFT					19
#define ACTION_FIRE_GRENADE			20

#define ACTION_WEAPON_0					21
#define ACTION_WEAPON_1					(ACTION_WEAPON_0+1)
#define ACTION_WEAPON_2					(ACTION_WEAPON_0+2)
#define ACTION_WEAPON_3					(ACTION_WEAPON_0+3)
#define ACTION_WEAPON_4					(ACTION_WEAPON_0+4)

#define ACTION_CYCLE_GRENADE		(ACTION_WEAPON_0+9)
#define ACTION_DROPWEAPON				(ACTION_WEAPON_0+10)

#define ACTION_CONCENTRATION		32

#define ACTION_MOVELR           33
#define ACTION_MOVEFB           34

//client side only 
#define ACTION_ITEM_0						35
#define ACTION_ITEM_1						36
#define ACTION_ITEM_2						37
#define ACTION_ITEM_3						38
#define ACTION_ITEM_4						39
#define ACTION_ITEM_5						40
#define ACTION_ITEM_6						41
#define ACTION_ITEM_7						42
#define ACTION_ITEM_8						43

#define ACTION_ZOOM_TOGGLE			45
#define ACTION_ZOOM_IN					46
#define ACTION_ZOOM_OUT					47

#define ACTION_MOVEMODE2				49

#define ACTION_SAVEPOS					54
#define ACTION_LOADPOS					55
#define ACTION_FIRECANCEL				56

#define ACTION_FLASHLIGHT				57

// to switch between 1st and 3rd person mode while driving
// and shooting
#define ACTION_CHANGE_VIEW			58

// makes player run very fast
#define ACTION_RUNSPRINT				59

#define ACTION_MESSAGEMODE			60
#define ACTION_MESSAGEMODE2			61
#define ACTION_TAKESCREENSHOT		62

#define ACTION_MOVEMODE_TOGGLE	63
#define ACTION_AIM_TOGGLE				64

#define PLAYER_MAX_WEAPONS			9

//////////////////////////////////////////////////////////////////////////
typedef struct  
{
	int									m_nFireMode;		//< active firemode
	std::vector<int>		m_nAmmoInClip;	//< amount of ammo in the clip of that firemode 
} tWeaponPersistentData;

//////////////////////////////////////////////////////////////////////////
typedef struct  
{
	bool								m_bDataSaved;
	int									m_nHealth,m_nArmor;
	int									m_nSelectedWeaponID;
	int									m_nAmmo;				//< only valid if m_nSelectedWeaponID != -1
	int									m_nAmmoInClip;	//< only valid if m_nSelectedWeaponID != -1
	int									m_vWeaponSlots[PLAYER_MAX_WEAPONS];
	std::map<int, tWeaponPersistentData>	m_mapWeapons;
	std::map<string, int>	m_mapAmmo;
	std::list<string>	m_lItems;	 
} tPlayerPersistentData;

#endif // GAME_GAMESHARED_H
