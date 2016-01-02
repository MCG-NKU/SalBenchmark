// SymmetricSurroundSaliency.cpp: implementation of the SymmetricSurroundSaliency class.
//
//////////////////////////////////////////////////////////////////////
//===========================================================================
// This code implements the saliency method described in:
//
// R. Achanta and S. Süsstrunk,
// "Saliency Detection using Maximum Symmetric Surround",
// Proceedings of IEEE International Conference on Image Processing (ICIP), 2010.
//===========================================================================
//	Copyright (c) 2010 Radhakrishna Achanta [EPFL]. All rights reserved.
//===========================================================================

#include "stdafx.h"
#include "SymmetricSurroundSaliency.h"

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

SymmetricSurroundSaliency::SymmetricSurroundSaliency()
{

}

SymmetricSurroundSaliency::~SymmetricSurroundSaliency()
{

}

//===========================================================================
///	RGB2LAB
//===========================================================================
void SymmetricSurroundSaliency::RGB2LAB(
	const vector<UINT>&						ubuff,
	vector<double>&							lvec,
	vector<double>&							avec,
	vector<double>&							bvec)
{
	int sz = int(ubuff.size());
	lvec.resize(sz);
	avec.resize(sz);
	bvec.resize(sz);

	for( int j = 0; j < sz; j++ )
	{
		int sR = (ubuff[j] >> 16) & 0xFF;
		int sG = (ubuff[j] >>  8) & 0xFF;
		int sB = (ubuff[j]      ) & 0xFF;
		//------------------------
		// sRGB to XYZ conversion
		// (D65 illuminant assumption)
		//------------------------
		double R = sR/255.0;
		double G = sG/255.0;
		double B = sB/255.0;

		double r, g, b;

		if(R <= 0.04045)	r = R/12.92;
		else				r = pow((R+0.055)/1.055,2.4);
		if(G <= 0.04045)	g = G/12.92;
		else				g = pow((G+0.055)/1.055,2.4);
		if(B <= 0.04045)	b = B/12.92;
		else				b = pow((B+0.055)/1.055,2.4);

		double X = r*0.4124564 + g*0.3575761 + b*0.1804375;
		double Y = r*0.2126729 + g*0.7151522 + b*0.0721750;
		double Z = r*0.0193339 + g*0.1191920 + b*0.9503041;
		//------------------------
		// XYZ to LAB conversion
		//------------------------
		double epsilon = 0.008856;	//actual CIE standard
		double kappa   = 903.3;		//actual CIE standard

		double Xr = 0.950456;	//reference white
		double Yr = 1.0;		//reference white
		double Zr = 1.088754;	//reference white

		double xr = X/Xr;
		double yr = Y/Yr;
		double zr = Z/Zr;

		double fx, fy, fz;
		if(xr > epsilon)	fx = pow(xr, 1.0/3.0);
		else				fx = (kappa*xr + 16.0)/116.0;
		if(yr > epsilon)	fy = pow(yr, 1.0/3.0);
		else				fy = (kappa*yr + 16.0)/116.0;
		if(zr > epsilon)	fz = pow(zr, 1.0/3.0);
		else				fz = (kappa*zr + 16.0)/116.0;

		lvec[j] = 116.0*fy-16.0;
		avec[j] = 500.0*(fx-fy);
		bvec[j] = 200.0*(fy-fz);
	}
}


//==============================================================================
///	GaussianSmooth
///
///	Blur an image with a separable binomial kernel passed in.
//==============================================================================
void SymmetricSurroundSaliency::GaussianSmooth(
	const vector<double>&					inputImg,
	const int&								width,
	const int&								height,
	const vector<double>&					kernel,
	vector<double>&							smoothImg)
{
	int center = kernel.size()/2;

	int sz = width*height;
	smoothImg.clear();
	smoothImg.resize(sz);
	vector<double> tempim(sz);
	int rows = height;
	int cols = width;
	//--------------------------------------------------------------------------
	// Blur in the x direction.
	//---------------------------------------------------------------------------
	{int index(0);
	for( int r = 0; r < rows; r++ )
	{
		for( int c = 0; c < cols; c++ )
		{
			double kernelsum(0);
			double sum(0);
			for( int cc = (-center); cc <= center; cc++ )
			{
				if(((c+cc) >= 0) && ((c+cc) < cols))
				{
					sum += inputImg[r*cols+(c+cc)] * kernel[center+cc];
					kernelsum += kernel[center+cc];
				}
			}
			tempim[index] = sum/kernelsum;
			index++;
		}
	}}

	//--------------------------------------------------------------------------
	// Blur in the y direction.
	//---------------------------------------------------------------------------
	{int index = 0;
	for( int r = 0; r < rows; r++ )
	{
		for( int c = 0; c < cols; c++ )
		{
			double kernelsum(0);
			double sum(0);
			for( int rr = (-center); rr <= center; rr++ )
			{
				if(((r+rr) >= 0) && ((r+rr) < rows))
				{
					sum += tempim[(r+rr)*cols+c] * kernel[center+rr];
					kernelsum += kernel[center+rr];
				}
			}
			smoothImg[index] = sum/kernelsum;
			index++;
		}
	}}
}


//===========================================================================
///	ComputeMaximumSymmetricSurroundSaliency
//===========================================================================
void SymmetricSurroundSaliency::ComputeMaximumSymmetricSurroundSaliency(
	const vector<UINT>&						img,
	const int&								width,
	const int&								height,
	vector<double>&							salmap,
	const bool&								normflag)
{
	int sz = width*height;
	salmap.resize(sz);

	vector<double> lvec(0), avec(0), bvec(0);
	RGB2LAB(img, lvec, avec, bvec);

	vector<double> ls(sz), as(sz), bs(sz);
	vector<double> kernel(0);
	//kernel.push_back(1.0);kernel.push_back(4.0);kernel.push_back(6.0);kernel.push_back(4.0);kernel.push_back(1.0);
	kernel.push_back(1.0);kernel.push_back(2.0);kernel.push_back(1.0);
	GaussianSmooth(lvec, width, height, kernel, ls);
	GaussianSmooth(avec, width, height, kernel, as);
	GaussianSmooth(bvec, width, height, kernel, bs);

	vector< vector<double> > lint(0), aint(0), bint(0);
	CreateIntegralImage(lvec, width, height, lint );
	CreateIntegralImage(avec, width, height, aint );
	CreateIntegralImage(bvec, width, height, bint );

	int ind(0);
	for( int j = 0; j < height; j++ )
	{
		int yoff	= min(j, height-j );
		int y1		= max(j-yoff,0);
		int y2		= min(j+yoff, height-1);

		for( int k = 0; k < width; k++ )
		{
			int xoff	= min(k, width-k );
			int x1		= max(k-xoff, 0);
			int x2		= min(k+xoff, width-1);

			double area = (x2-x1+1)*(y2-y1+1);

			double lval = GetIntegralSum( lint, x1, y1, x2, y2 )/area;
			double aval = GetIntegralSum( aint, x1, y1, x2, y2 )/area;
			double bval = GetIntegralSum( bint, x1, y1, x2, y2 )/area;

			salmap[ind] =	(lval-ls[ind])*(lval-ls[ind]) +
				(aval-as[ind])*(aval-as[ind]) +
				(bval-bs[ind])*(bval-bs[ind]);//square of the euclidean distance
			//------
			ind++;
			//------
		}
	}
	//----------------------------------------------------
	// Normalize the values to lie in the interval [0,255]
	//----------------------------------------------------
	if(normflag) Normalize(salmap, width, height);
}