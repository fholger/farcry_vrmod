
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File: XVehicleSystem.cpp
//  Description: Vehicle system code
//
//  History:
//  - Created by Kirill Bulatsev
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "XVehicleSystem.h"
#include <algorithm>

//////////////////////////////////////////////////////////////////////
CVehicleSystem::CVehicleSystem()
{
}

//////////////////////////////////////////////////////////////////////
CVehicleSystem::~CVehicleSystem()
{
}

//////////////////////////////////////////////////////////////////////
void CVehicleSystem::AddVehicleClass( const EntityClassId classid)
{
	m_vVehicleClasses.push_back(classid);
}

//////////////////////////////////////////////////////////////////////
bool CVehicleSystem::IsVehicleClass(const EntityClassId classid)
{
	return ( m_vVehicleClasses.end() != std::find(m_vVehicleClasses.begin(),m_vVehicleClasses.end(), classid) );
}