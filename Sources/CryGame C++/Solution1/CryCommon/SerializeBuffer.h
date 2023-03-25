
//////////////////////////////////////////////////////////////////////////
//
//	Crytek Source code 
//	Copyright (c) Crytek 2001-2004
//	
//	File: SerializeBuffer.h 
//	Description: Code to serialize Leaf buffers.
//
//	History:
//  - File created by Andrey Khonich
//	- February 2005: Modified by Marco Corbetta for SDK release	
//
//////////////////////////////////////////////////////////////////////////

#ifndef _SERIALIZEBUFFER_H_
#define _SERIALIZEBUFFER_H_

//////////////////////////////////////////////////////////////////////
void inline SaveBuffer(void * pData, int nSize, uchar * pSerialBuffer, int & nSaveBufferPos)
{
  if(pSerialBuffer)
  {
		// set the first 4 bytes of the buffer to the size of the buffer or to 0 if the data isn't available
		*(int*)(pSerialBuffer+nSaveBufferPos) = pData ? nSize : 0;
  }

  nSaveBufferPos += sizeof(int);

  if(pSerialBuffer)
  {
    if(nSize && pData)
      memcpy (pSerialBuffer + nSaveBufferPos, pData, nSize);
  }

  if(pData)
    nSaveBufferPos += nSize;
}

//////////////////////////////////////////////////////////////////////
bool inline LoadBuffer(void * pData, uint nMaxBytesToLoad, uchar * pSerialBuffer, int & nSaveBufferPos)
{
  int nSize = 0;
  if (nMaxBytesToLoad < 4)
	{
		nSaveBufferPos += 4;
    return false;
	}

  nSize = *(int*)(pSerialBuffer + nSaveBufferPos);
	nSaveBufferPos += 4;

  if((uint)nSize > nMaxBytesToLoad)
    return false;

  if(!nSize)
    return true;

  assert(pData);

  if(nSize)
    memcpy (pData, pSerialBuffer + nSaveBufferPos, nSize);

  nSaveBufferPos += nSize;

  return true;
}

#endif // _SERIALIZEBUFFER_H_