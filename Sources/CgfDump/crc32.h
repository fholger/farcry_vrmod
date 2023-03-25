
//////////////////////////////////////////////////////////////////////
//
// Copyright © 2000 - 2003 Richard A. Ellingson
// http://www.createwindow.com
// mailto:relling@antelecom.net
// 
//	File: 
//
//  Description:  
//
//	History:
//
//////////////////////////////////////////////////////////////////////

class Crc32Gen {
public:
	Crc32Gen();
	//! Creates a CRC from a text string 
	static unsigned int GetCRC32( const char *text );
	static unsigned int GetCRC32( const char *data,int size,unsigned int ulCRC );

protected:
	unsigned int crc32_table[256];  //!< Lookup table array 
	void init_CRC32_Table();  //!< Builds lookup table array 
	unsigned int reflect( unsigned int ref, char ch); //!< Reflects CRC bits in the lookup table 
	unsigned int get_CRC32( const char *data,int size,unsigned int ulCRC );
};
