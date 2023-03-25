
//////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
// 
//	File: 
//
//  Description:  
//
//	History:
//
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////
// Small functions for validation and small checks and dumps

#ifndef _CCG_UTILS_HDR_
#define _CCG_UTILS_HDR_

inline bool validSize (unsigned nSize, unsigned nExpectedSize)
{
	if (nSize != nExpectedSize
		&&nSize != ((nExpectedSize+3)&~3))
	{
		dumpError ("Unexpected size: %d instead of %d", nSize, nExpectedSize);
		return false;
	}
	return true;
}

//////////////////////////////////////////////////////////////////////////
// Asserts the size of the array with the given expected number of elements
// and the given size in bytes. Takes into account the possible alignment
template <class T>
bool validArrSize(unsigned nSizeBytes, unsigned nElementsExpected)
{
	if (nSizeBytes != sizeof(T) * nElementsExpected
		&&nSizeBytes != (((sizeof(T) * nElementsExpected)+3)&~3)) // the nSizeBytes may be just aligned by 4-byte boundary
	{
		dumpError ("Unexpected number of entries (%g instead of %d)", float (nSizeBytes)/sizeof(T), nElementsExpected);
		return false;
	}
	else
		return true;
}


//////////////////////////////////////////////////////////////////////////
// Checks whether the array size in bytes of elements of type T is valid
// I.e. whether the size in bytes corresponds to integral number of elements
template <class T>
bool intArrSize (unsigned nSizeBytes)
{
	if (nSizeBytes % sizeof(T) != 0)
	{
		dumpError ("Non-integral number of entries (%d%%%d=%d)",nSizeBytes, sizeof(T),nSizeBytes % sizeof(T));
		return false;
	}
	else
		return true;
}


//////////////////////////////////////////////////////////////////////////
// Checks if the serialize funciton returned valid number of bytes (nReadBytes)
// comparing to what is in the stream (nSize). Outputs necessary warnings
inline bool validSerialize (unsigned nReadBytes, unsigned nSize)
{
	if (!nReadBytes)
	{
		dumpError ("Invalid data stream");
		return false;
	}

	if (nReadBytes > nSize)
	{
		dumpWarning ("MALFUNCTION in the SERIALIZE: read %d bytes out of %d available bytes in the bytestream.", nReadBytes, nSize);
		//return;
	}

	// perhaps we've read a bit less because of alignment...
	if (nReadBytes < nSize && ((nReadBytes+3)&~3)!=nSize)
	{
		dumpWarning("Only %d bytes were read out of %d byte data", nReadBytes, nSize);
	}
	return true;
}

inline void dumpPlus(const CryIRGB& color)
{
	dumpPlus ("(%d,%d,%d)", (int)color.r, (int)color.g, (int)color.b);
}

inline bool isFaceEqual (const unsigned short*n, const unsigned short*m)
{
	return 
		(n[0] == m[0] && n[1] == m[1] && n[2] == m[2])
		||(n[0] == m[1] && n[1] == m[2] && n[2] == m[0])
		||(n[0] == m[2] && n[1] == m[0] && n[2] == m[1]);
}

inline bool isFaceReverse (const unsigned short*n, const unsigned short*m)
{
	return 
		(n[0] == m[2] && n[1] == m[1] && n[2] == m[0])
		||(n[0] == m[1] && n[1] == m[0] && n[2] == m[2])
		||(n[0] == m[0] && n[1] == m[2] && n[2] == m[1]);
}

// returns true if the given set is actually a set from [0 to nNum) NOT INCLUSIVE
template <typename T>
inline bool isFullRange (const std::set<T>& setVerts, T nNum)
{
	if (setVerts.size() != nNum)
		return false;

	unsigned nVert = 0;
	std::set<T>::const_iterator it = setVerts.begin();

	while(nVert < nNum && it != setVerts.end())
		if (*(it++) != nVert++)
			return false;

	return it == setVerts.end() && nVert == nNum;
}

class CCFIntFaceSort
{
public:
	bool operator () (const CCFIntFace& left, const CCFIntFace& right)const
	{
		if (left.v[0] == right.v[0])
			if (left.v[1] == right.v[1])
				return left.v[2] < right.v[2];
			else
				return left.v[1] < right.v[1];
		else
			return left.v[0] < right.v[0];
	}
};


#endif