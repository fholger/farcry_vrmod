
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File: Bugsflock.h
//  Description: Bugs manager class.
//
//  History:
//  - 11/4/2003: Created by Timur Davidenko
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#ifndef __bugsflock_h__
#define __bugsflock_h__
#pragma once

#include "Flock.h"

//////////////////////////////////////////////////////////////////////
/*! Single Bug.
*/
class CBoidBug : public CBoidObject
{
public:
	CBoidBug( SBoidContext &bc );
	void Update( float dt,SBoidContext &bc );
	void Render( SRendParams &rp,CCamera &cam,SBoidContext &bc );
private:
	void UpdateBugsBehavior( float dt,SBoidContext &bc );
	void UpdateDragonflyBehavior( float dt,SBoidContext &bc );
	void UpdateFrogsBehavior( float dt,SBoidContext &bc );	
	friend class CBugsFlock;
	int m_objectId;

	// Flags.
	unsigned m_onGround : 1;	//! True if landed on ground.
};

//////////////////////////////////////////////////////////////////////
/*!	Bugs Flock, is a specialized flock type for all kind of small bugs and flies around player.
*/
class CBugsFlock : public CFlock
{
public:
	CBugsFlock( int id,CFlockManager *flockMgr );
	~CBugsFlock();

	virtual void CreateBoids( SBoidsCreateContext &ctx );
	virtual void PreloadInstanceResources(Vec3d vPrevPortalPos, float fPrevPortalDistance, float fTime);
protected:
	void ReleaseObjects();
	friend class CBoidBug;
	std::vector<IStatObj*> m_objects;
};

#endif // __bugsflock_h__
