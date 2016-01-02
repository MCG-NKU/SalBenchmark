//=================================================================================
//=================================================================================
//
// PictureHandler.cpp: implementation of the PictureHandler class.
//
// Copyright (c) 2007 Radhakrishna Achanta (asv.radhakrishna [at] gmail [dot] com)
// All rights reserved
//
//=================================================================================
//=================================================================================

#include "stdafx.h"
#include "PictureHandler.h"
#include <mbctype.h>  


//=================================================================================
// Construction/Destruction
//=================================================================================

PictureHandler::PictureHandler()
{
	StartUpGdiPlus();
}

PictureHandler::~PictureHandler()
{
	ShutDownGdiPlus();
}

//=================================================================================
//	StartUpGdiPlus()
//
//	Starts up GdiPlus. Can also be used for other things like memory allocation.
//=================================================================================
void PictureHandler::StartUpGdiPlus()
{
	m_gdiplusStartupInput = new GdiplusStartupInput();
	Status stat = GdiplusStartup(&m_gdiplusToken, m_gdiplusStartupInput, NULL);
	_ASSERT( stat == Ok );
}

//=================================================================================
//	ShutDownGdiPlus()
//
//	Shuts down GdiPlus. Can also be used for other things like memory deallocation.
//=================================================================================
void PictureHandler::ShutDownGdiPlus()
{
	if (m_gdiplusToken != NULL)
	{
		GdiplusShutdown(m_gdiplusToken);
		delete m_gdiplusStartupInput;
		m_gdiplusStartupInput = NULL;
		m_gdiplusToken = NULL;
	}
}


//=================================================================================
//	GetEncoderClsid()
//
//	The encoder CLSID provided depends on the format string provided;
//	L"image/jpeg" for JPEG CLSID and L"image/bmp" for BMP CLSID
//=================================================================================
int PictureHandler::GetEncoderClsid(const WCHAR* format, CLSID* pClsid)
{
	UINT  num = 0;          // number of image encoders
	UINT  size = 0;         // size of the image encoder array in bytes

	ImageCodecInfo* pImageCodecInfo = NULL;

	GetImageEncodersSize(&num, &size);
	if(size == 0)
		return -1;  // Failure

	pImageCodecInfo = (ImageCodecInfo*)(malloc(size));
	if(pImageCodecInfo == NULL)
		return -1;  // Failure

	GetImageEncoders(num, size, pImageCodecInfo);

	for(UINT j = 0; j < num; ++j)
	{
		if( wcscmp(pImageCodecInfo[j].MimeType, format) == 0 )
		{
			*pClsid = pImageCodecInfo[j].Clsid;
			free(pImageCodecInfo);
			return j;  // Success
		}    
	}

	free(pImageCodecInfo);
	return -1;  // Failure
}

//=================================================================================
//	Narrow2Wide()
//=================================================================================
wstring PictureHandler::Narrow2Wide(const std::string& narrowString)
{
	int m_codepage = _getmbcp();

	int numChars =
		::MultiByteToWideChar( m_codepage, 
		MB_PRECOMPOSED, 
		narrowString.c_str(), 
		-1, 
		0, 
		0
		);
	_ASSERT(numChars);
	//	TRACE("Number of characters in the string is %d", numChars);

	wchar_t* test = new wchar_t[numChars+1];
	numChars =
		::MultiByteToWideChar( m_codepage, 
		MB_PRECOMPOSED, 
		narrowString.c_str(), 
		-1, 
		test, 
		numChars
		);

	std::wstring temp(test);
	delete []test;

	return temp;
}


//=================================================================================
//	Wide2Narrow()
//=================================================================================
string PictureHandler::Wide2Narrow(const wstring& wideString)
{
	int m_codepage = ::_getmbcp();

	int result = ::WideCharToMultiByte( 
		m_codepage,  // Code page
		0,		// Default
		wideString.c_str(), // WCS buffer
		-1,		// Assume null terminated str, calclate length auto
		0,      // Buffer to receive MBCS string
		0,		// Length of MB buffer ( 0 -> return length required )
		0,		// lpdefaultChar
		0		// lpUsedDefaultChar
		);
	_ASSERT(result);
	char *test = new char[result+1]; 
	result = ::WideCharToMultiByte( 
		m_codepage,  // Code page
		0,		// Default
		wideString.c_str(), // WCS buffer
		-1,		// Assume null terminated str, calclate length auto
		test,   // Buffer to receive MBCS string
		result,	// Length of MB buffer ( 0 -> return length required )
		0,		// lpdefaultChar
		0		// lpUsedDefaultChar
		);

	std::string temp(test);
	delete []test;

	return temp;
}


//=================================================================================
//	GetPictureBuffer
//
//	Returns a buffer of the picture just opened
//=================================================================================
void PictureHandler::GetPictureBuffer(
	string&				filename,
	vector<UINT>&		imgBuffer,
	int&				width,
	int&				height)
{
	Bitmap* bmp				= Bitmap::FromFile((Narrow2Wide(filename)).c_str());
	BitmapData*	bmpData		= new BitmapData;
	height					= bmp->GetHeight();
	width					= bmp->GetWidth();
	long imgSize			= height*width;

	Gdiplus::Rect rect(0, 0, width, height);
	bmp->LockBits(
		&rect,
		ImageLockModeWrite,
		PixelFormat32bppARGB,
		bmpData);

	_ASSERT( bmpData->Stride/4 == width );

	imgBuffer.resize(imgSize);

	//memcpy( imgBuffer, (UINT*)bmpData.get()->Scan0, imgSize*sizeof(UINT) );
	UINT* tempBuff = (UINT*)bmpData->Scan0;
	for( int p = 0; p < imgSize; p++ ) imgBuffer[p] = tempBuff[p];

	bmp->UnlockBits(bmpData);
}


//=================================================================================
//	SavePicture
//
//	Saves the given buffer as a JPEG or BMP image depeding on which encoder CLSID
//	is used.
//=================================================================================
void PictureHandler::SavePicture(
	vector<UINT>&		imgBuffer,
	int					width,
	int					height,
	string&				outFilename,
	string&				saveLocation,
	int					format,
	const string&		str)// 0 is for BMP and 1 for JPEG
{
	int sz = width*height;
	UINT* uintBuffer = new UINT[sz];

	for( int p = 0; p < sz; p++ ) uintBuffer[p] = imgBuffer[p];

	Bitmap bmp(width, height, width*sizeof(UINT), PixelFormat32bppARGB, (unsigned char *)uintBuffer);

	//-----------------------------------------
	// Prepare path and save the result images
	//-----------------------------------------
	CLSID picClsid;
	if( 1 == format ) GetEncoderClsid(L"image/jpeg", &picClsid);
	if( 0 == format ) GetEncoderClsid(L"image/bmp",  &picClsid);

	//string path = "C:\\Temp\\";
	string path = saveLocation;
	//string fpath = Wide2Narrow(outFilename);
	char fname[_MAX_FNAME];
	_splitpath(outFilename.c_str(), NULL, NULL, fname, NULL);
	//int dummy(0);
	//_splitpath_s(outFilename.c_str(), NULL, dummy, NULL, dummy, fname, dummy, NULL, dummy);
	path += fname;

	//if( 0 == strcmp(str.c_str(),"") ) path.append(str);
	if( 0 != str.compare("") ) path.append(str);
	if( 1 == format ) path.append(".jpg");
	if( 0 == format ) path.append(".bmp");

	wstring wholepath = Narrow2Wide(path);
	const WCHAR* wp = wholepath.c_str();

	Status st = bmp.Save( wp, &picClsid, NULL );
	_ASSERT( st == Ok );

	if(uintBuffer) delete [] uintBuffer;
}