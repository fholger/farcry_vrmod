/*********************************************************************NVMH2****
Path:  C:\Dev\devrel\Nv_sdk_4\Dx8_private\PhotoShop\dxt
File:  dxt.cpp

Copyright (C) 1999, 2000 NVIDIA Corporation
This file is provided without support, instruction, or implied warranty of any
kind.  NVIDIA makes no guarantee of its fitness for a particular purpose and is
not liable under any circumstances for any damages or loss whatsoever arising
from the use or inability to use this file or items derived from it.

Comments:


******************************************************************************/


#include "NVI_ImageLib.h"

#include "dxtlib.h"
#include <direct.h>
#include "string"
#include "getopt.h"
#include <fcntl.h>
#include <io.h>
#include <stdio.h>

#include <sys/stat.h>

int compress_tga(char * inputfile);

bool bImageMode = false;
static HFILE filein = 0;
bool timestamp = false;
bool strip = false;

bool list = false;
std::string listfile;


HFILE fileout;
extern char* optarg;

extern int optind;
#include <shlobj.h>

char * PopupDirectoryRequestor(const char * initialdir,
                               const char * title)
{
    static char temp[MAX_PATH];
    static char dir[MAX_PATH];
    
    BROWSEINFO bi;
    LPITEMIDLIST list;
    
    //HINSTANCE hInstance = GetModuleHandle(NULL);
    //gd3dApp->Create( hInstance  );
    
    bi.hwndOwner = 0; 
    bi.pidlRoot = 0; 
    bi.pszDisplayName = dir; 
    bi.lpszTitle = title; 
    bi.ulFlags = 0; 
    bi.lpfn = 0; 
    bi.lParam = 0; 
    bi.iImage = 0; 
    
    list = SHBrowseForFolder(&bi);
    
    if (list == 0)
        return 0;
    
    SHGetPathFromIDList(list, dir);
    
    return dir;
}


char * search[] =
{
    "*.tga",
    "*.bmp",
    "*.gif",
    "*.ppm",
    "*.jpg",
    "*.jpeg",
    "*.tif",
    "*.tiff",
    "*.cel",
    "*.dds",
    0,
};

void compress_all( bool popup )
{
    
    if (popup)
    {
        char * dir;
        dir = PopupDirectoryRequestor(0,0);
        if (dir == 0)
            return;
        _chdir(dir);
    }
    
    struct _finddata_t filetga;
    long hFile;
    

    int i = 0;
    while(search[i])
    {
        // Find first .c file in current directory 
        hFile = _findfirst( search[i], &filetga );
        if (hFile != -1)
        {
            
            compress_tga(filetga.name);
            
            
            // Find the rest of the .c files 
            while( _findnext( hFile, &filetga ) == 0 )
            {
                compress_tga(filetga.name);
            }
            
            _findclose( hFile );
        }
        i++;
    }
}
  

void compress_list(  )
{
    
    FILE *fp = fopen( listfile.c_str(), "r");
    
    if (fp == 0)
    {
        fprintf(stderr, "Can't open list file <%s>\n", listfile.c_str());
        return;
    }
    
    char buff[1000];
    while(fgets(buff, 1000, fp))
    {      
        // has a crlf at the end
        int t = strlen(buff);
        buff[t - 1] = 0;


        compress_tga(buff);
    }

    fclose(fp);

}
  







void usage()
{
    fprintf(stderr,"usage: nvdxt [-m] [-d] [-1c] [-1a] [-b] [-3] [-5] [-a] [-u1] [-u4] [-u5] [-u8] [-o <output dir>] [image_file] \n");
    fprintf(stderr,"m - generate MIP maps\n");
    fprintf(stderr,"b - browse for directory\n");
    fprintf(stderr,"d - add dithering\n");
    fprintf(stderr,"t - timestamp\n");
    fprintf(stderr,"l <filename> - list of files to convert\n");
    fprintf(stderr,"a - all image files in current directory\n");
    fprintf(stderr,"o - output directory\n\n");
    
    fprintf(stderr,"1c - DXT1 (color only)\n");
    fprintf(stderr,"1a - DXT1 (one bit alpha)\n");
    fprintf(stderr,"3 - DXT3\n");
    fprintf(stderr,"5 - DXT5\n\n");
    fprintf(stderr,"u1 - uncompressed 1:5:5:5\n");
    fprintf(stderr,"u4 - uncompressed 4:4:4:4\n");
    fprintf(stderr,"u5 - uncompressed 5:6:5\n");
    fprintf(stderr,"u8 - uncompressed 8:8:8:8\n");

    fprintf(stderr,"version 2.82\n");
}


bool bGenMipMaps = false;
DWORD TextureFormat = dDXT3;
bool bDither = false;

extern int errno;
std::string output_dirname;


HRESULT callback(void * data, int miplevel, DWORD size)
{
	DWORD * ptr = (DWORD *)data;
	for(int i=0; i< size/4; i++)
	{
		DWORD c = *ptr++;
	}

	
	return 0;
}

/*For a USizexVSize texture, I create a buffer of USize*VSize DWORD's and
fill it with 0xffffffff. I would expect this to give me an all white
texture. Instead, I get an orange texture with a bunch of lavender dots.
Coincidentally (well, not really), all the dots are on the bottom right
corner of a 4x4 block*/
    /*
void test()
{
	DWORD raw_data[128 * 128];

	for(int i=0; i< 128 * 128; i++)
	{
		raw_data[i] = 0xFFFFFFFF;
	}
    
    file = _open( "test.dds", _O_WRONLY | _O_BINARY | _O_CREAT,  _S_IWRITE );

    HRESULT hr = nvDXTcompress((unsigned char *)raw_data, //  pointer to data (24 or 32 bit)
            128, // width in texels
            128, // height in texels
            TF_DXT1,
            true,
            false,
            4, 
            0);
    

    _close(file);

	exit(0);
}        */

int main(int argc, char * argv[])
{
    
	//test();


    bool browse = false;
    char* inputfile;
    int c;
    
    if (argc == 1)
    {
        usage();
        return 0;
    }
    bool all_files = false;
    int rgb;
    
    output_dirname = ".";
    
    
    char b;
    while ((c = getopt(argc, argv, "stm1:35a?hbdu:o:l:")) != -1)
    {
        switch (c) 
        {
        case 'm':
            bGenMipMaps = true;
            break;
        case '1':
            b = *optarg;
            if (b == 'a')
                TextureFormat =  dDXT1a;
            else if (b == 'c')
                TextureFormat =  dDXT1;
            else
            {
                fprintf(stderr, "Must specify 'c' or 'a' after -1\n");
                return 0;    
            }
                
            break;
            
        case '3':
            TextureFormat =  dDXT3;
            break;
        case '5':
            TextureFormat =  dDXT5;
            break;
        case 'a':
            all_files = true;
            break;
        case 'b':
            browse = true;
            break;    

        case 'd':
            bDither = true;
            break;    
            
        case 'o':
            output_dirname = optarg;
            //fprintf(stderr, "output directory %s", output_dirname.c_str());
            fflush(stderr);
            break;
            
            
        case 'u':
            rgb = atoi(optarg);
            switch(rgb)
            {
            case 4:
                TextureFormat =  d4444;
                break;
            case 1:
                TextureFormat =  d1555;
                break;
            case 5:
                TextureFormat =  d565;
                break;
            case 8:
                TextureFormat =  d8888;
                break;
            }
            break;

         case 't':
             timestamp = true;
             break;

         case 'l':
             list = true;

             listfile = optarg;
             break;
         case 's':
             strip = true;
             break;



            
         case '?':
         case 'h':
             usage();
             return (-1);
        }
    } 
    
    int md = _mkdir(output_dirname.c_str());
    
    if (md == 0)
    {
        fprintf(stderr, "directory %s created\n", output_dirname.c_str());
        fflush(stderr);
    }
    else if (errno != EEXIST)
    {
        fprintf(stderr, "problem with output directory %s\n", output_dirname.c_str());
        return 0;
    } 
    else
    {
        fprintf(stderr, "output directory %s\n", output_dirname.c_str());
        fflush(stderr);
    }
    
    
    if (list)
    {
        compress_list();
    }
    else if (all_files)
    {
        compress_all(false);
    }
    else if (browse)
    {
        compress_all(true);
    }
    else if (optind < argc)
    {
        inputfile = argv[optind];
        compress_tga(inputfile);
    }
    
    return 0;
}



char * extensions[] =
{
    ".tga",
    ".bmp",
    ".gif",
    ".ppm",
    ".jpg",
    ".jpeg",
    ".tif",
    ".tiff",
    ".cel",
    ".dds",
    0,
};

int compress_tga(char * inputfile)
{
    unsigned long w, h; 
    int pitch;
    int planes = 4;
    bool dds = false;

    unsigned char * raw_data;
    NVI_TGA_File		tga;
    NVI_GraphicsFile	bmp;



    std::string temp;
    temp = strlwr(inputfile);

    //if (strip)
    {
        int pos;
        pos = temp.find_last_of("\\");

        if (pos == -1)
            pos = temp.find_last_of("/");

        std::string temp2;
        if (pos != -1)
        {
            temp2 = temp.substr(pos+1);
            temp = temp2;
        }


    }
        

    int isdds = temp.find(".dds");



    
    // determine output file name

    int i = 0;
    int pos = -1;
    while(extensions[i] != 0 && pos == -1)
    {
        pos = temp.find(extensions[i]);
        i++;
    }

    if (pos == -1)
    {
        fprintf(stderr, "Can't open input file <%s>\n", inputfile);
        return 0;
    }

    std::string ddsname, finalname_out;

    ddsname = temp.substr(0, pos);

    if (dds)
        ddsname.append("_");

    ddsname.append(".dds");

    finalname_out = output_dirname;
    finalname_out.append("\\");
    finalname_out += ddsname;


    struct _finddata_t filedataSrc;
    struct _finddata_t filedataDest;


    if (timestamp)
    {
        // compare times 

        long hFileSrc;
        long hFileDest;
        hFileSrc = _findfirst(inputfile, &filedataSrc );
        hFileDest = _findfirst(finalname_out.c_str(), &filedataDest );


        if (hFileDest != -1)
        {
            // if it exists and is newer then return
            if (filedataSrc.time_write < filedataDest.time_write)
            {
                fprintf(stderr, "<%s> is up to date\n", finalname_out.c_str());
                return 0;
            }
        }


    }


    fprintf(stderr, "%s --> ",inputfile);
    fflush(stderr);



    if (isdds != -1)
    {
        dds = true;
        filein = _open( inputfile, _O_RDONLY | _O_BINARY ,  _S_IREAD );
        
        if (filein == -1)
        {
            fprintf(stderr, "Can't open output file\n", inputfile);
            return 0;
        }
        
        int width;
        int height;
        int lTotalWidth; 
        int rowBytes;
        
        raw_data = nvDXTdecompress(width, height, planes, lTotalWidth, rowBytes);
        
        if (raw_data == 0)
        {
            fprintf(stderr, "Can't open output file\n", inputfile);
            return -1;
        }
        
        w = width;
        h = height;   
        pitch = lTotalWidth * planes;


        
    }
    else
    {
        raw_data = (unsigned char *)tga.ReadFile(inputfile, UL_GFX_PAD);
        w = tga.GetWidth();
        h = tga.GetHeight();
        
        //raw_data = read_tga(inputfile, w, h); 
        
        if (raw_data == 0)
        {
            raw_data = (unsigned char *)bmp.ReadFile(inputfile, UL_GFX_PAD);
            w = bmp.GetWidth();
            h = bmp.GetHeight();
            
            if (raw_data == 0)
            {
                fprintf(stderr, "Can't open input file\n");
                return -1;
            }
        }  
        pitch = w * 4;
    }
        



    bImageMode = false;


    int temp_width, temp_height ; 

    temp_width = w;
    temp_height = h;
    
    while (!(temp_width&1)) temp_width>>=1;
    while (!(temp_height&1)) temp_height>>=1;
    
    if((temp_width!=1)|(temp_height!=1))
    {
        // only a warning in uncompressed
        fprintf(stderr, "Image is not a power of 2 (%d x %d)\n", w, h);
        bImageMode = true;


        switch(TextureFormat)
        {
        case dDXT1:  
        case dDXT1a:
        case dDXT3:
        case dDXT5:
            return -1;
        default:
            fprintf(stderr, "MIP maps are disabled for this image\n");
            break;

        }
    }











    fileout = _open( finalname_out.c_str(), _O_WRONLY | _O_BINARY | _O_CREAT,  _S_IWRITE );

    fprintf(stderr, "%s\n", finalname_out.c_str());

    if (fileout== -1)
    {
        fprintf(stderr, "Can't open output file %s\n", finalname_out.c_str());
        return 0;
    }
        
              

    CompressionOptions options;

    options.MipMapsInImage = false;  // mip have been loaded in during read
    if (bImageMode)
        options.MipMapType = dNoMipMaps;      // dNoMipMaps, dUseExistingMipMaps, dGenerateMipMaps
    else
        options.MipMapType = dGenerateMipMaps;      // dNoMipMaps, dUseExistingMipMaps, dGenerateMipMaps

    options.BinaryAlpha = false;    // clamp alpha zero or one 

    options.NormalMap = false;      // only renormalize MIP maps

    options.AlphaBorder = false;    // make an alpha border
    options.Border = false;         // make a color border
    tPixel color;
    color.u = 0;
    options.BorderColor = color;        // color of border


    options.Fade = 0;               // fade to color over MIP maps
    options.FadeToColor = color;        // color to fade to
    options.FadeToMipMaps = 0;      // number of MIPs to fade over


    options.Dither = bDither;        // enable dithering during 16 bit conversion

	options.TextureType = dTextureType2D;    // regular decal, cube or volume  
	//dTextureType2D 
	//dTextureTypeCube 
	//dTextureTypeImage 

    options.TextureFormat = TextureFormat;
	//  dDXT1, dDXT1a, dDXT3, dDXT5, d4444, 
	//  d1555, 	d565,	d8888, 	d888, 	d555, 


    options.AlphaBorder = false;

        
    nvDXTcompress(raw_data, w, h, pitch, &options, planes, 0);



    if (filein)
        _close(filein);

    _close(fileout);

    //delete [] raw_data;

    return 0;
}
void WriteDTXnFile (DWORD count, void *buffer)
{
    _write(fileout, buffer, count);

}


void ReadDTXnFile (DWORD count, void *buffer)
{
        
    _read(filein, buffer, count);

}



/*void ReadDTXnFile (DWORD count, void *buffer)
{
    // stubbed, we are not reading files
}*/

