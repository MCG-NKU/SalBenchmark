//=================================================================================
//=================================================================================
//
// PictureHandler.h: interface for the PictureHandler class.
//
// Copyright (c) 2007 Radhakrishna Achanta (asv.radhakrishna [at] gmail [dot] com)
// All rights reserved
//
//=================================================================================
//=================================================================================

#if !defined(PICTUREHANDLER_INCLUDED_)
#define PICTUREHANDLER_INCLUDED_

#include <gdiplus.h>
#include <vector>
#include <algorithm>

namespace Gdiplus	{
	class  Bitmap;
	class  Graphics;
	struct GdiplusStartupInput;
}

using namespace Gdiplus;
using namespace std;
//using namespace boost;


class PictureHandler  
{
public:
	PictureHandler();
	virtual ~PictureHandler();

	void							GetPictureBuffer(
		string&				filename,
		vector<UINT>&		outBuff,
		int&				width,
		int&				height);

	void							SavePicture(
		vector<UINT>&		imgBuffer,
		int					width,
		int					height,
		string&				outFilename,
		string&				saveLocation,
		int					format,
		const string&		str = "");// 0 is for BMP and 1 for JPEG

	wstring							Narrow2Wide(
		const string&		narrowString);

	string							Wide2Narrow(
		const wstring&		wideString);

private:
	void							StartUpGdiPlus();
	void							ShutDownGdiPlus();

	int								GetEncoderClsid(
		const WCHAR*		format,
		CLSID*				pClsid);

private:
	ULONG_PTR						m_gdiplusToken;
	GdiplusStartupInput*			m_gdiplusStartupInput;

};

#endif // !defined(PICTUREHANDLER_INCLUDED_)
