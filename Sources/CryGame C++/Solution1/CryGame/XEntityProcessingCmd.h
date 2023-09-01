
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//
//  File: XEntityProcessingCmd.h
//  Description: Command processing helper class.
//
//  History:
//  - August 23, 2001: Created by Alberto Demichelis
//	- February 2005: Modified by Marco Corbetta for SDK release
//	- October 2006: Modified by Marco Corbetta for SDK 1.4 release
//
//////////////////////////////////////////////////////////////////////

#ifndef GAME_XENTITYPROCESSINGCMD_H
#define GAME_XENTITYPROCESSINGCMD_H

//////////////////////////////////////////////////////////////////////
//! Structure used to hold the commands
class CXEntityProcessingCmd
{
public:
	//! constructor
	CXEntityProcessingCmd();
	//! destructor
	virtual ~CXEntityProcessingCmd();

	void Release() { delete this; }
	
	// Flag management... 
	void AddAction(unsigned int nFlags);
	void RemoveAction(unsigned int nFlags);
	void Reset();
	bool CheckAction(unsigned int nFlags);

	// Angles...
	Vec3& GetDeltaAngles();
	void SetDeltaAngles( const Vec3 &ang );
	void SetPhysicalTime(int iPTime)//,float fTimeSlice)
	{
		m_iPhysicalTime=iPTime;		
	}
	int GetPhysicalTime()
	{
		return m_iPhysicalTime;
	}
	void SetLeaning(float fLeaning){m_fLeaning=fLeaning;}
	float GetLeaning(){return m_fLeaning;}

	int AddTimeSlice(float *pfSlice,int nSlices=1)
	{
		for(int i=0; i<nSlices && m_nTimeSlices<sizeof(m_fTimeSlices)/sizeof(m_fTimeSlices[0]); i++,m_nTimeSlices++)
			m_fTimeSlices[m_nTimeSlices] = pfSlice[i];
		return m_nTimeSlices;
	}
	int InsertTimeSlice(float fSlice,int iBefore=0)
	{
		m_nTimeSlices = min(m_nTimeSlices+1,sizeof(m_fTimeSlices)/sizeof(m_fTimeSlices[0]));
		for(int i=m_nTimeSlices; i>iBefore; i--)
			m_fTimeSlices[i] = m_fTimeSlices[i-1];
		m_fTimeSlices[iBefore] = fSlice;
		return m_nTimeSlices;
	}
	int GetTimeSlices(float *&pfSlices)
	{
		pfSlices = m_fTimeSlices;
		return m_nTimeSlices;
	}
	void ResetTimeSlices() { m_nTimeSlices=0; }

	void SetPhysDelta(float fServerDelta,float fClientDelta=0)
	{
		m_fServerDelta=fServerDelta;
		m_fClientDelta=fClientDelta;
	}
	float GetServerPhysDelta(){return m_fServerDelta;}
	float GetClientPhysDelta(){return m_fClientDelta;}

	//! \param pBitStream must not be 0 (compressed or uncompressed)
	bool Write( CStream &stm, IBitStream *pBitStream, bool bWriteAngles );

	//! \param pBitStream must not be 0 (compressed or uncompressed)
	bool Read( CStream &stm, IBitStream *pBitStream );

	void SetMoveFwd(float fVal)   { m_fMoveFwd=fVal;    }
	void SetMoveBack(float fVal)  { m_fMoveBack=fVal;   }
	void SetMoveLeft(float fVal)  { m_fMoveLeft=fVal;   }
	void SetMoveRight(float fVal) { m_fMoveRight=fVal;  }
	float GetMoveFwd()            { return m_fMoveFwd;  }
	float GetMoveBack()           { return m_fMoveBack; }
	float GetMoveLeft()           { return m_fMoveLeft; }
	float GetMoveRight()          { return m_fMoveRight;}

	void SetMotionControls(bool enabled, bool rightHandDominant)
	{
		m_motionControlsEnabled = enabled;
		m_rightHandDominant = rightHandDominant;
	}

	void SetHmdTransform(const Vec3& pos, const Ang3& anglesDeg, float refHeight)
	{
		m_hmdPosition = pos;
		m_hmdAnglesDeg = anglesDeg;
		m_hmdRefHeight = refHeight;
	}

	void SetControllerTransform(int controller, const Vec3& pos, const Ang3& anglesDeg)
	{
		m_controllerPosition[controller] = pos;
		m_controllerAnglesDeg[controller] = anglesDeg;
	}

	bool UseMotionControls() const { return m_motionControlsEnabled; }
	bool IsRightHandDominant() const { return m_rightHandDominant; }
	const Vec3& GetHmdPos() const { return m_hmdPosition; }
	const Ang3& GetHmdAnglesDeg() const { return m_hmdAnglesDeg; }
	float GetHmdRefHeight() const { return m_hmdRefHeight; }
	const Vec3& GetControllerPos(int controller) const { return m_controllerPosition[controller]; }
	const Ang3& GetControllerAnglesDeg(int controller) const { return m_controllerAnglesDeg[controller]; }

	Matrix34 GetHmdTransform() const
	{
		Matrix34 m = Matrix34::CreateRotationXYZ(Deg2Rad(m_hmdAnglesDeg));
		m.SetTranslation(m_hmdPosition);
		return m;
	}

	Matrix34 GetControllerTransform(int controller) const
	{
		Matrix34 m = Matrix34::CreateRotationXYZ(Deg2Rad(m_controllerAnglesDeg[controller]));
		m.SetTranslation(m_controllerPosition[controller]);
		return m;
	}
	 
public: 

	unsigned int			m_nActionFlags[3];	//!< Timedemo recorded needs access to these.

private: 	

	int								m_iPhysicalTime;		//!<
	Ang3							m_vDeltaAngles;			//!<
	float							m_fTimeSlices[32];	//!<
	unsigned char			m_nTimeSlices;			//!<

	float             m_fMoveFwd;         // 
	float             m_fMoveBack;
	float             m_fMoveLeft;
	float             m_fMoveRight;

	bool m_motionControlsEnabled;
	bool m_rightHandDominant;
	// transforms for HMD and controllers, relative to player
	Vec3 m_hmdPosition;
	Ang3 m_hmdAnglesDeg;
	float m_hmdRefHeight;
	Vec3 m_controllerPosition[2];
	Ang3 m_controllerAnglesDeg[2];

	// non serialized variables 

	float							m_fServerDelta;			//!<
	float							m_fClientDelta;			//!<
	float							m_fLeaning;					//!<
};

#endif // GAME_XENTITYPROCESSINGCMD_H
