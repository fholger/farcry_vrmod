#ifndef NVDXT_OPTIONS_H
#define NVDXT_OPTIONS_H
enum
{
    dSaveButton = 1,

	dDXT1 = 10,
	dTextureFormatStart = dDXT1,

	dDXT1a = 11,  // DXT1 with one bit alpha
	dDXT3 = 12,   // explicit alpha
	dDXT5 = 13,   // interpolated alpha

	d4444 = 14,   // a4 r4 g4 b4
	d1555 = 15,   // a1 r5 g5 b5
	d565 = 16,    // a0 r5 g6 b5
	d8888 = 17,   // a8 r8 g8 b8
	d888 = 18,    // a0 r8 g8 b8
	d555 = 19,    // a0 r5 g5 b5

	dTextureFormatLast = d555,


    // 3d viewing options
    d3DPreview = 21, 
    dViewDXT1 = 22,
    dViewDXT2 = 23,
    dViewDXT3 = 24,
    dViewDXT5 = 25,
    dViewA4R4G4B4 = 26,
    dViewA1R5G5B5 = 27,
    dViewR5G6B5 = 28,
    dViewA8R8G8B8 = 29,


    dGenerateMipMaps = 30,
	dUseExistingMipMaps = 31,
	dNoMipMaps = 32,

	dNormalMap = 33,

    dShowDifferences = 40,
    dShowFiltering = 41,
    dShowMipMapping = 42,

    dChangeClearColor = 50,
    dViewXBOX1c = 51,
    dViewXBOX1a = 52,
    dDither = 53,

    dLoadBackgroundImage = 54,
    dUseBackgroundImage = 55,

    dBinaryAlpha = 56,
    dAlphaBlending = 57,
    dFade = 58,
    dFadeToColor = 60,
    dAlphaBorder = 61,
    dBorder = 62,
    dBorderColor = 63,

    dZoom = 70,
    dFadeToMIPMaps = 71,

	dTextureType2D = 80,
	dTextureTypeStart = dTextureType2D,

	dTextureTypeCube = 81,
	dTextureTypeImage = 82,
	//dTextureTypeVolume = 83,  to be added
	dTextureTypeLast = dTextureTypeImage


};



#ifndef TRGBA
#define TRGBA
typedef	struct	
{
	BYTE	rgba[4];
} rgba_t;
#endif

#ifndef TPIXEL
#define TPIXEL
union tPixel
{
  unsigned long u;
  rgba_t c;
};
#endif


// Windows handle for our plug-in (seen as a dynamically linked library):
extern HANDLE hDllInstance;
class CMyD3DApplication;

typedef struct CompressionOptions
{
    bool        MipMapsInImage;  // mip have been loaded in during read
    short       MipMapType;      // dNoMipMaps, dUseExistingMipMaps, dGenerateMipMaps

    bool        BinaryAlpha;   // zero or one 

    bool        NormalMap;     // only renormalize MIP maps

    bool        AlphaBorder;   // make an alpha border
    bool        Border;        // make a color border
    tPixel      BorderColor;   // color of border


    bool        Fade;          // fade to color over MIP maps
    tPixel      FadeToColor;   // color to fade to
    int         FadeToMipMaps; // number of MIPs to fade over


    bool        Dither;        // enable dithering during 16 bit conversion


	short 		TextureType;    // regular decal, cube or volume  
	//dTextureType2D 
	//dTextureTypeCube 
	//dTextureTypeImage 

	short 		TextureFormat;
	//  dDXT1, dDXT1a, dDXT3, dDXT5, d4444, 
	//  d1555, 	d565,	d8888, 	d888, 	d555, 


} CompressionOptions;


#endif
