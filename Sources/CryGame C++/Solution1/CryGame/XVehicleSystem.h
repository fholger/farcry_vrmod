
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//	File: XVehicleSystem.h
//	Description: - vehicle system class declaration  - 
//	A simple class that takes care of the class id's of the vehicles
//	
//	History:
//	- Created by Petar Kotevski
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#ifndef _CVEHICLESYSTEM_
#define _CVEHICLESYSTEM_

#include <vector>

typedef std::vector<EntityClassId> VehicleClassVector;

//////////////////////////////////////////////////////////////////////
class CVehicleSystem
{

	VehicleClassVector	m_vVehicleClasses;

public:
	CVehicleSystem();
	~CVehicleSystem();

	void AddVehicleClass(const EntityClassId classid);
	bool IsVehicleClass(const EntityClassId classid);
};


#endif // _CVEHICLESYSTEM_






