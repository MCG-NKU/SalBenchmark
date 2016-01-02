#pragma once    
#include <math.h>
#include "image\ImageSimple.h"

inline double Fxyz(const double t)
{
    return ((t > 0.008856)? pow(t, (1.0/3.0)) : (7.787*t + 16.0/116.0));
}

inline void RgbPix2Lab(unsigned char byR, unsigned char byG, unsigned char byB, float &fL, float &fa, float &fb)
{
    // RGBtoXYZ		
    // Normalize red, green, blue values.
    double rLinear = (double)byR/255.0;
    double gLinear = (double)byG/255.0;
    double bLinear = (double)byB/255.0;

    // Convert to a sRGB form
    double r = (rLinear > 0.04045)? pow((rLinear + 0.055)/(1 + 0.055), 2.2) : (rLinear/12.92) ;
    double g = (gLinear > 0.04045)? pow((gLinear + 0.055)/(1 + 0.055), 2.2) : (gLinear/12.92) ;
    double b = (bLinear > 0.04045)? pow((bLinear + 0.055)/(1 + 0.055), 2.2) : (bLinear/12.92) ;

    // Converts
    double x = r*0.4124 + g*0.3576 + b*0.1805;
    double y = r*0.2126 + g*0.7152 + b*0.0722;
    double z = r*0.0193 + g*0.1192 + b*0.9505;

    x = (x>0.9505)? 0.9505 : ((x<0)? 0 : x);
    y = (y>1.0)? 1.0 : ((y<0)? 0 : y);
    z = (z>1.089)? 1.089 : ((z<0)? 0 : z);

    // XYZ to LAB
    double dD65_X = 0.9505;
    double dD65_Y = 1.0;
    double dD65_Z = 1.0890;

    double dL = 116.0 * Fxyz( y/dD65_Y ) - 16;
    double dA = 500.0 * ( Fxyz( x/dD65_X ) - Fxyz( y/dD65_Y) );
    double dB = 200.0 * ( Fxyz( y/dD65_Y ) - Fxyz( z/dD65_Z) );

    fL = (float) dL;
    fa = (float) dA;
    fb = (float) dB;
}

inline void Rgb2Lab(ImageSimpleUChar &rImg, ImageSimpleUChar &gImg, ImageSimpleUChar &bImg, ImageSimpleFloat &LImg, ImageSimpleFloat &AImg, ImageSimpleFloat &BImg)
{
	int w = rImg.Width();
	int h = rImg.Height();
	int pixNum = w * h;

	if (LImg.Width() != w || LImg.Height() != h)
		LImg.Create(w, h);
	if (AImg.Width() != w || AImg.Height() != h)
		AImg.Create(w, h);
	if (BImg.Width() != w || BImg.Height() != h)
		BImg.Create(w, h);

	for (int x = 0; x < pixNum; x ++)
	{
		RgbPix2Lab(rImg[x], gImg[x], bImg[x], LImg[x], AImg[x], BImg[x]);
	}
}