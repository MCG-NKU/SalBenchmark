// Saliency.cpp: implementation of the Saliency class.
//
//////////////////////////////////////////////////////////////////////
//===========================================================================
// This code implements the saliency method described in:
//
// R. Achanta, S. Hemami, F. Estrada and S. Süsstrunk,
// "Frequency-tuned Salient Region Detection",
// IEEE International Conference on Computer Vision and Pattern Recognition (CVPR), 2009
//===========================================================================
//	Copyright (c) 2011 Radhakrishna Achanta [EPFL] 
//===========================================================================

#include "stdafx.h"
#include "Saliency.h"


//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

Saliency::Saliency()
{

}

Saliency::~Saliency()
{

}


//===========================================================================
///	RGB2LAB
///
/// This is the re-written version of the sRGB to CIELAB conversion
//===========================================================================
void Saliency::RGB2LAB(
	const vector<UINT>&				ubuff,
	vector<double>&					lvec,
	vector<double>&					avec,
	vector<double>&					bvec)
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
void Saliency::GaussianSmooth(
	const vector<double>&			inputImg,
	const int&						width,
	const int&						height,
	const vector<double>&			kernel,
	vector<double>&					smoothImg)
{
	int center = int(kernel.size())/2;

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
///	GetSaliencyMap
///
/// Outputs a saliency map with a value assigned per pixel. The values are
/// normalized in the interval [0,255] if normflag is set true (default value).
//===========================================================================
void Saliency::GetSaliencyMap(
	const vector<UINT>&				inputimg,
	const int&						width,
	const int&						height,
	vector<double>&					salmap,
	const bool&						normflag) 
{
	int sz = width*height;
	salmap.clear();
	salmap.resize(sz);

	vector<double> lvec(0), avec(0), bvec(0);
	RGB2LAB(inputimg, lvec, avec, bvec);
	//--------------------------
	// Obtain Lab average values
	//--------------------------
	double avgl(0), avga(0), avgb(0);
	{for( int i = 0; i < sz; i++ )
	{
		avgl += lvec[i];
		avga += avec[i];
		avgb += bvec[i];
	}}
	avgl /= sz;
	avga /= sz;
	avgb /= sz;

	vector<double> slvec(0), savec(0), sbvec(0);

	//----------------------------------------------------
	// The kernel can be [1 2 1] or [1 4 6 4 1] as needed.
	// The code below show usage of [1 2 1] kernel.
	//----------------------------------------------------
	vector<double> kernel(0);
	kernel.push_back(1.0);
	kernel.push_back(2.0);
	kernel.push_back(1.0);

	GaussianSmooth(lvec, width, height, kernel, slvec);
	GaussianSmooth(avec, width, height, kernel, savec);
	GaussianSmooth(bvec, width, height, kernel, sbvec);

	{for( int i = 0; i < sz; i++ )
	{
		salmap[i] = (slvec[i]-avgl)*(slvec[i]-avgl) +
					(savec[i]-avga)*(savec[i]-avga) +
					(sbvec[i]-avgb)*(sbvec[i]-avgb);
	}}

	if( true == normflag )
	{
		vector<double> normalized(0);
		Normalize(salmap, width, height, normalized);
		swap(salmap, normalized);
	}
}