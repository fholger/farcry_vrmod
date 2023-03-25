
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File: XSystemEntities.h
//  Description: 
//	 Stores data needed to spawn/remove the entities at runtime.
//
//  History:
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////

#ifndef XSYSTEMENTITIES_H
#define	XSYSTEMENTITIES_H

//////////////////////////////////////////////////////////////////////////
class CEntityStreamData
{
public:
	CEntityStreamData();
	~CEntityStreamData();

	XDOM::IXMLDOMNodePtr m_pNode;
	bool	m_bSpawn;
}; 

typedef std::list<CEntityStreamData> CEntityStreamDataList;
typedef CEntityStreamDataList::iterator CEntityStreamDataListIt;

#endif