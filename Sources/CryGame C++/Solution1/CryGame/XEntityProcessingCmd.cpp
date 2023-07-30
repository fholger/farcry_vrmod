
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File: XEntityProcessingCmd.cpp
//  Description: Command processing helper class.
//
//  History:
//  - August 23, 2001: Created by Alberto Demichelis
//	- February 2005: Modified by Marco Corbetta for SDK release
//
//////////////////////////////////////////////////////////////////////////

#include "stdafx.h"
#include "XEntityProcessingCmd.h"

#define NO_QUANTIZED_ANGLES

//////////////////////////////////////////////////////////////////////////
CXEntityProcessingCmd::CXEntityProcessingCmd()
{
	m_vDeltaAngles[0] = 0.0f;
	m_vDeltaAngles[1] = 0.0f;
	m_vDeltaAngles[2] = 0.0f;
	m_nActionFlags[0]=0;
	m_nActionFlags[1]=0;
	m_nActionFlags[2]=0;
	m_fLeaning=0.0f;
	Reset();
}

//////////////////////////////////////////////////////////////////////////
CXEntityProcessingCmd::~CXEntityProcessingCmd()
{
}

//////////////////////////////////////////////////////////////////////////
void CXEntityProcessingCmd::AddAction(unsigned int nFlags)
{
	int nSlot=nFlags/32;

	m_nActionFlags[nSlot] |= (1<<(nFlags-1&31));
}

//////////////////////////////////////////////////////////////////////////
void CXEntityProcessingCmd::RemoveAction(unsigned int nFlags)
{
	int nSlot=nFlags/32;
	m_nActionFlags[nSlot] &= ~(1<<(nFlags-1&31));	
}

//////////////////////////////////////////////////////////////////////////
bool CXEntityProcessingCmd::CheckAction(unsigned int nFlags)
{
	int nSlot=nFlags/32;
	return (m_nActionFlags[nSlot] & (1<<(nFlags-1&31)))?true:false;
}

//////////////////////////////////////////////////////////////////////////
void CXEntityProcessingCmd::Reset()
{
	m_nActionFlags[0] = 0;
	m_nActionFlags[1] = 0;
	m_nActionFlags[2] = 0;
	m_iPhysicalTime = 0;
	m_nTimeSlices = 0;
	m_motionControlsEnabled = false;
	m_rightHandDominant = true;
}

//////////////////////////////////////////////////////////////////////////
Vec3d& CXEntityProcessingCmd::GetDeltaAngles()
{
	return m_vDeltaAngles;
}

//////////////////////////////////////////////////////////////////////////
void CXEntityProcessingCmd::SetDeltaAngles( const Vec3d &ang )
{
#ifndef NO_QUANTIZED_ANGLES
	Ang3d q=ang;
	unsigned short x=(q.x*0xFFFF/360);
	unsigned short y=(q.y*0xFFFF/360);
	unsigned short z=(q.z*0xFFFF/360);
	m_vDeltaAngles.x=((float)x*360)/0xFFFF;
	m_vDeltaAngles.y=((float)y*360)/0xFFFF;
	m_vDeltaAngles.z=((float)z*360)/0xFFFF;
#else
	m_vDeltaAngles = ang;
#endif
}

//////////////////////////////////////////////////////////////////////////
bool CXEntityProcessingCmd::Write( CStream &stm, IBitStream *pBitStream, bool bWriteAngles )
{
	if(!stm.WritePacked((unsigned int)m_iPhysicalTime))
		return false;

	if(!stm.WritePacked(m_nActionFlags[0]))
		return false;

	if(!stm.WritePacked(m_nActionFlags[1]))
		return false;

	if(!stm.WritePacked(m_nActionFlags[2]))
		return false;

	if (!pBitStream->WriteBitStream(stm, m_fMoveFwd, eSignedUnitValueLQ))
		return false;

	if (!pBitStream->WriteBitStream(stm, m_fMoveBack, eSignedUnitValueLQ))
		return false;

	if (!pBitStream->WriteBitStream(stm, m_fMoveLeft, eSignedUnitValueLQ))
		return false;

	if (!pBitStream->WriteBitStream(stm, m_fMoveRight, eSignedUnitValueLQ))
		return false;

	if (bWriteAngles)
	{
		stm.Write(true);

		if(!pBitStream->WriteBitStream(stm,m_vDeltaAngles,eEulerAnglesHQ))
			return false;

		if(!pBitStream->WriteBitStream(stm,m_fLeaning,eSignedUnitValueLQ))
			return false;

		stm.Write(m_motionControlsEnabled);

		if (m_motionControlsEnabled)
		{
			stm.Write(m_rightHandDominant);

			if (!pBitStream->WriteBitStream(stm, m_hmdPosition, eWorldPos))
				return false;

			if (!pBitStream->WriteBitStream(stm, m_hmdAnglesDeg, eEulerAnglesHQ))
				return false;

			for (int i = 0; i < 2; ++i)
			{
				if (!pBitStream->WriteBitStream(stm, m_controllerPosition[i], eWorldPos))
					return false;
				if (!pBitStream->WriteBitStream(stm, m_controllerAnglesDeg[i], eEulerAnglesHQ))
					return false;
			}
		}
	}
	else
		stm.Write(false);

	unsigned char i,nSameSlices;
	stm.Write(m_nTimeSlices);

	for(i=0,nSameSlices=1;i<m_nTimeSlices;i++) 
	{
		if (i<m_nTimeSlices-1 && m_fTimeSlices[i+1]==m_fTimeSlices[i])
		{
			nSameSlices++; continue;
		}
		stm.Write(nSameSlices);
		stm.Write(m_fTimeSlices[i]);
		nSameSlices = 1;
	}

	return true;
}

//////////////////////////////////////////////////////////////////////////
bool CXEntityProcessingCmd::Read( CStream &stm, IBitStream *pBitStream )
{
	if(!stm.ReadPacked((unsigned int&)m_iPhysicalTime))
		return false;

	if(!stm.ReadPacked(m_nActionFlags[0]))
		return false;

	if(!stm.ReadPacked(m_nActionFlags[1]))
		return false;

	if(!stm.ReadPacked(m_nActionFlags[2]))
		return false;

	if (!pBitStream->ReadBitStream(stm, m_fMoveFwd, eSignedUnitValueLQ))
		return false;

	if (!pBitStream->ReadBitStream(stm, m_fMoveBack, eSignedUnitValueLQ))
		return false;

	if (!pBitStream->ReadBitStream(stm, m_fMoveLeft, eSignedUnitValueLQ))
		return false;

	if (!pBitStream->ReadBitStream(stm, m_fMoveRight, eSignedUnitValueLQ))
		return false;

	bool bReadAngles;
	if (!stm.Read(bReadAngles))
		return false;
	
	if (bReadAngles)
	{
		if(!pBitStream->ReadBitStream(stm,m_vDeltaAngles,eEulerAnglesHQ))
			return false;

		if(!pBitStream->ReadBitStream(stm,m_fLeaning,eSignedUnitValueLQ))
			return false;

		if(!stm.Read(m_motionControlsEnabled))
			return false;

		if (m_motionControlsEnabled)
		{
			if (!stm.Read(m_rightHandDominant))
				return false;

			if (!pBitStream->ReadBitStream(stm, m_hmdPosition, eWorldPos))
				return false;

			if (!pBitStream->ReadBitStream(stm, m_hmdAnglesDeg, eEulerAnglesHQ))
				return false;

			for (int i = 0; i < 2; ++i)
			{
				if (!pBitStream->ReadBitStream(stm, m_controllerPosition[i], eWorldPos))
					return false;
				if (!pBitStream->ReadBitStream(stm, m_controllerAnglesDeg[i], eEulerAnglesHQ))
					return false;
			}
		}
	}

	float fCurSlice;
	unsigned char nSlices,nSameSlices,i;
	const int nMaxSlices = sizeof(m_fTimeSlices)/sizeof(m_fTimeSlices[0]);
	for(stm.Read(nSlices),m_nTimeSlices=0; nSlices>0 && m_nTimeSlices<nMaxSlices; nSlices-=nSameSlices)
	{
		stm.Read(nSameSlices);
		stm.Read(fCurSlice);
#if defined(LINUX)	
		if(_isnan(fCurSlice))
			break;
#endif
		for(i=0; i<nSameSlices && m_nTimeSlices<nMaxSlices; i++) 
			m_fTimeSlices[m_nTimeSlices++] = fCurSlice;
	}

	return true;
}
