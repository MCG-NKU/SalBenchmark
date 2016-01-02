#include "mex.h"
#include "matrix.h"
#include <cfloat>
#include <cmath>
#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <algorithm>
using namespace std;

// SLIC.h: interface for the SLIC class.
//===========================================================================
// This code implements the superpixel method described in:
//
// Radhakrishna Achanta, Appu Shaji, Kevin Smith, Aurelien Lucchi, Pascal Fua, and Sabine Susstrunk,
// "SLIC Superpixels",
// EPFL Technical Report no. 149300, June 2010.
//===========================================================================
//	Copyright (c) 2012 Radhakrishna Achanta [EPFL]. All rights reserved.
//===========================================================================
//////////////////////////////////////////////////////////////////////

#if !defined(_SLIC_H_INCLUDED_)
#define _SLIC_H_INCLUDED_

class SLIC  
{
public:
	SLIC();
	virtual ~SLIC();
	//============================================================================
	// sRGB to CIELAB conversion for 2-D images
	//=========================================================================
	void DoRGBtoLABConversionSup(
        vector <double> &           r1,
		vector <double> &           g1,
		vector <double> &           b1,
		double*&					lvec,
		double*&					avec,
		double*&					bvec,
		const int &                 numSup);
	//======================================================================
	//mean rgb in each superpixel
	//=======================================================================
	void SLIC::DoMeanSup( double *  &                    m_rr,
	                      double *  &                    m_gg,
                  	      double *  &                    m_bb,
	                      int &                          numlabels,
	                      int &                          NumPixel ,
	                      double *&                      outlabel,
	                      vector <double> &                meanSupl,
					      vector <double> &                meanSupa,
					      vector <double> &                meanSupb);
	//============================================================================
	// Superpixel segmentation for a given step size (superpixel size ~= step*step)
	//============================================================================
        void DoSuperpixelSegmentation_ForGivenSuperpixelSize(
          double *   &          r,
		  double *   &          g,
		  double *   &          b,
	      const int					width,
	      const int					height,
		vector <int> &		    	klabels,
		int&						numlabels,
        const int&					superpixelsize,
        const double&               compactness,
		double *&                   outlabel,
		const int&                   sz);
	//============================================================================
	// Superpixel segmentation for a given number of superpixels
	//============================================================================
        void DoSuperpixelSegmentation_ForGivenNumberOfSuperpixels(
        double *    &              r,
		double *    &              g,
		double *    &              b,
		const int					width,
		const int					height,
		//vector <int> &						klabels,
		int&						numlabels,
       const int&					K,         //required number of superpixels
       const double&                compactness,
	   double *&                    outlabel,
	   const int&                   NumPixel);

private:
	//============================================================================
	// The main SLIC algorithm for generating superpixels
	//============================================================================
	void PerformSuperpixelSLIC(
		vector<double>&				kseedsl,
		vector<double>&				kseedsa,
		vector<double>&				kseedsb,
		vector<double>&				kseedsx,
		vector<double>&				kseedsy,
		vector <int> &			    klabels,
		const int&					STEP,
        const vector<double>&		edgemag,
		const double&				m ,
		const int &                 sz,
		const int &                 numk);
	
	//============================================================================
	// Pick seeds for superpixels when step size of superpixels is given.
	//============================================================================
	void GetLABXYSeeds_ForGivenStepSize(
		vector<double>&				kseedsl,
		vector<double>&				kseedsa,
		vector<double>&				kseedsb,
		vector<double>&				kseedsx,
		vector<double>&				kseedsy,
		const int&					STEP,
		const bool&					perturbseeds,
		const vector<double>&		edgemag,
		int &                       numk);
	
	//============================================================================
	// Move the superpixel seeds to low gradient positions to avoid putting seeds
	// at region boundaries.
	//============================================================================
	void PerturbSeeds(
		vector<double>&				kseedsl,
		vector<double>&				kseedsa,
		vector<double>&				kseedsb,
		vector<double>&				kseedsx,
		vector<double>&				kseedsy,
		const vector<double>&		edges);
	//============================================================================
	// Detect color edges, to help PerturbSeeds()
	//============================================================================
	void DetectLabEdges(
		const double*				lvec,
		const double*				avec,
		const double*				bvec,
		const int&					width,
		const int&					height,
		vector<double>&				edges,
		const int &                 sz);
	//============================================================================
	// sRGB to XYZ conversion; helper for RGB2LAB()
	//============================================================================
	void RGB2XYZ(
		const double &					sR,
		const double &					sG,
		const double &					sB,
		double&						X,
		double&						Y,
		double&						Z);
	//============================================================================
	// sRGB to CIELAB conversion (uses RGB2XYZ function)
	//============================================================================
	void RGB2LAB(
		const double &					sR,
		const double &					sG,
		const double &					sB,
		double&						lval,
		double&						aval,
		double&						bval);
	//============================================================================
	// sRGB to CIELAB conversion for 2-D images
	//============================================================================
	void DoRGBtoLABConversion(
         double *  &           r1,
		 double *  &           g1,
		 double *  &           b1,
		double*&					lvec,
		double*&					avec,
		double*&					bvec,
		const int &                 sz);
	//===============================================================================
	//  convert mean rgb of superpixel to lab
	//=================================================================================
	void RGB2XYZSup(
		const double &					sR,
		const double &					sG,
		const double &					sB,
		double&						X,
		double&						Y,
		double&						Z);
	//============================================================================
	// sRGB to CIELAB conversion (uses RGB2XYZ function)
	void RGB2LABSup(
		const  double &					sR,
		const double &					sG,
		const double &					sB,
		double&						lval,
		double&						aval,
		double&						bval);
	
	//============================================================================
	// Post-processing of SLIC segmentation, to avoid stray labels.
	//============================================================================
	void EnforceLabelConnectivity(
		vector <int>&				labels,
		const int					width,
		const int					height,
		double *&					outlabelout,      //input labels that need to be corrected to remove stray labels
		int&						numlabels,        //the number of labels changes in the end if segments are removed
		const int&					K,                //the number of superpixels desired by the user
		const int&                  sz);
	

private:
	int										m_width;
	int										m_height;
	int										m_depth;

	double*									m_lvec;
	double*									m_avec;
	double*									m_bvec;

	double**								m_lvecvec;
	double**								m_avecvec;
	double**								m_bvecvec;
};

#endif // !defined(_SLIC_H_INCLUDED_)

// SLIC.cpp: implementation of the SLIC class.
//
// Copyright (C) Radhakrishna Achanta 2012
// All rights reserved
// Email: firstname.lastname@epfl.ch
//////////////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

SLIC::SLIC()
{
	m_lvec = NULL;
	m_avec = NULL;
	m_bvec = NULL;

	m_lvecvec = NULL;
	m_avecvec = NULL;
	m_bvecvec = NULL;
}

SLIC::~SLIC()
{
	if(m_lvec) delete [] m_lvec;
	if(m_avec) delete [] m_avec;
	if(m_bvec) delete [] m_bvec;


	if(m_lvecvec)
	{
		for( int d = 0; d < m_depth; d++ ) delete [] m_lvecvec[d];
		delete [] m_lvecvec;
	}
	if(m_avecvec)
	{
		for( int d = 0; d < m_depth; d++ ) delete [] m_avecvec[d];
		delete [] m_avecvec;
	}
	if(m_bvecvec)
	{
		for( int d = 0; d < m_depth; d++ ) delete [] m_bvecvec[d];
		delete [] m_bvecvec;
	}
}

//==============================================================================
///	RGB2XYZ
///
/// sRGB (D65 illuninant assumption) to XYZ conversion
//==============================================================================
void SLIC::RGB2XYZ(
	const double &		sR,
	const double &		sG,
	const double &		sB,
	double&			X,
	double&			Y,
	double&			Z)
{
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

	
	X = r*0.4339563 + g*0.3762153 + b*0.1898430;
	Y = r*0.2126729 + g*0.7151522 + b*0.0721750;
	Z = r*0.0177578 + g*0.1094756 + b*0.8728363;
}

//===========================================================================
///	RGB2LAB
//===========================================================================
void SLIC::RGB2LAB(const double& sR, const double & sG, const double & sB, double& lval, double& aval, double& bval)
{
	//------------------------
	// sRGB to XYZ conversion
	//------------------------
	double X, Y, Z;
	RGB2XYZ(sR, sG, sB, X, Y, Z);

	//------------------------
	// XYZ to LAB conversion
	//------------------------
	double epsilon = 0.008856;	//actual CIE standard
//	double kappa   = 903.3;		//actual CIE standard

	double fx, fy, fz;
	if( X > epsilon)	fx = pow(X, 1.0/3.0);
	else				fx = 7.787069 * X + 0.137931; //(kappa*X + 16.0)/116.0;
	if( Y > epsilon)	fy = pow(Y, 1.0/3.0);
	else				fy = 7.787069 * Y + 0.137931; //(kappa*Y + 16.0)/116.0;
	if( Z > epsilon)	fz = pow(Z, 1.0/3.0);
	else				fz = 7.787069 * Z + 0.137931; //(kappa*Z + 16.0)/116.0;

	lval = 116.0*fy-16.0;
	aval = 500.0*(fx-fy);
	bval = 200.0*(fy-fz);
}

//===========================================================================
///	DoRGBtoLABConversion
///
///	For whole image: overlaoded floating point version
//===========================================================================
void SLIC::DoRGBtoLABConversion(
          double*  &          r1,
	      double*  &          g1,
		  double*  &          b1,
	double*&					lvec,
	double*&					avec,
	double*&					bvec,
	const int &                 sz)
{
	lvec = new double[sz];
	avec = new double[sz];
	bvec = new double[sz];

	for( int j = 0; j < sz; j++ )
	{
		double r = r1[j];
		double g = g1[j];
		double b = b1[j];

		RGB2LAB( r, g, b, lvec[j], avec[j], bvec[j] );
	}
}

//////////////// convert mean rgb of superpixel to lab
void SLIC::RGB2XYZSup(
	const double &		sR,
	const double &		sG,
	const double &		sB,
	double&			X,
	double&			Y,
	double&			Z)
{
	double r, g, b;
	r = pow( ( sR + 0.099 )/1.099, 2.222 );
	g = pow( ( sG + 0.099 )/1.099, 2.222 );
	b = pow( ( sB + 0.099 )/1.099, 2.222 );

	if ( r < 0.018 )
		r = sR / 4.5138;

	if ( g < 0.018 )
		g = sG / 4.5138;

	if ( b < 0.018 )
		b = sB / 4.5138;

	X = r*0.4339563 + g*0.3762153 + b*0.1898430;
	Y = r*0.2126729 + g*0.7151522 + b*0.0721750;
	Z = r*0.0177578 + g*0.1094756 + b*0.8728363;
}

//===========================================================================
///	RGB2LAB
//===========================================================================
void SLIC::RGB2LABSup(const double& sR, const double & sG, const double & sB, double& lval, double& aval, double& bval)
{
	//------------------------
	// sRGB to XYZ conversion
	//------------------------
	double X, Y, Z;
	RGB2XYZSup(sR, sG, sB, X, Y, Z);

	//------------------------
	// XYZ to LAB conversion
	//------------------------
	double epsilon = 0.008856;	//actual CIE standard

	double fx, fy, fz;
	if( X > epsilon)	fx = pow(X, 1.0/3.0);
	else				fx = 7.787069 * X + 0.137931; //(kappa*X + 16.0)/116.0;
	if( Y > epsilon)	fy = pow(Y, 1.0/3.0);
	else				fy = 7.787069 * Y + 0.137931; //(kappa*Y + 16.0)/116.0;
	if( Z > epsilon)	fz = pow(Z, 1.0/3.0);
	else				fz = 7.787069 * Z + 0.137931; //(kappa*Z + 16.0)/116.0;

	lval = 116.0*fy-16.0;
	aval = 500.0*(fx-fy);
	bval = 200.0*(fy-fz);
}

//===========================================================================
///	DoRGBtoLABConversion
///
///	For whole image: overlaoded floating point version
//===========================================================================
void SLIC::DoRGBtoLABConversionSup(
          vector <double>  &          r1,
	      vector <double>  &          g1,
		  vector <double>  &          b1,
	double*&					lvec,
	double*&					avec,
	double*&					bvec,
	const int &                 numSup)
{
	
	/*lvec = new double[sz];
	avec = new double[sz];
	bvec = new double[sz];*/

	for( int j = 0; j < numSup; j++ )
	{
		double r = r1[j];
		double g = g1[j];
		double b = b1[j];

		RGB2LABSup( r, g, b, lvec[j], avec[j], bvec[j] );
	}
}

//==============================================================================
///	DetectLabEdges
//==============================================================================
void SLIC::DetectLabEdges(
	const double*				lvec,
	const double*				avec,
	const double*				bvec,
	const int&					width,
	const int&					height,
	vector<double>&				edges,
	const int &                  sz)
{
	
	edges.resize(sz,0);
	for( int j = 1; j < height-1; j++ )
	{
		for( int k = 1; k < width-1; k++ )
		{
			int i = j*width+k;

			double dx = (lvec[i-1]-lvec[i+1])*(lvec[i-1]-lvec[i+1]) +
						(avec[i-1]-avec[i+1])*(avec[i-1]-avec[i+1]) +
						(bvec[i-1]-bvec[i+1])*(bvec[i-1]-bvec[i+1]);

			double dy = (lvec[i-width]-lvec[i+width])*(lvec[i-width]-lvec[i+width]) +
						(avec[i-width]-avec[i+width])*(avec[i-width]-avec[i+width]) +
						(bvec[i-width]-bvec[i+width])*(bvec[i-width]-bvec[i+width]);

			//edges[i] = fabs(dx) + fabs(dy);
			edges[i] = dx*dx + dy*dy;
		}
	}
}

//===========================================================================
///	PerturbSeeds
//===========================================================================
void SLIC::PerturbSeeds(
	vector<double>&				kseedsl,
	vector<double>&				kseedsa,
	vector<double>&				kseedsb,
	vector<double>&				kseedsx,
	vector<double>&				kseedsy,
    const vector<double>&       edges)
{
	const int dx8[8] = {-1, -1,  0,  1, 1, 1, 0, -1};
	const int dy8[8] = { 0, -1, -1, -1, 0, 1, 1,  1};
	
	int numseeds = kseedsl.size();

	for( int n = 0; n < numseeds; n++ )
	{
		int ox = kseedsx[n]; //original x
		int oy = kseedsy[n]; //original y
		int oind = oy*m_width + ox;

		int storeind = oind;
		for( int i = 0; i < 8; i++ )
		{
			int nx = ox+dx8[i];//new x
			int ny = oy+dy8[i];//new y

			if( nx >= 0 && nx < m_width && ny >= 0 && ny < m_height)
			{
				int nind = ny*m_width + nx;
				if( edges[nind] < edges[storeind])
				{
					storeind = nind;
				}
			}
		}
		if(storeind != oind)
		{
			kseedsx[n] = storeind%m_width;
			kseedsy[n] = storeind/m_width;
			kseedsl[n] = m_lvec[storeind];
			kseedsa[n] = m_avec[storeind];
			kseedsb[n] = m_bvec[storeind];
		}
	}
}


//===========================================================================
///	GetLABXYSeeds_ForGivenStepSize
///
/// The k seed values are taken as uniform spatial pixel samples.
//===========================================================================
void SLIC::GetLABXYSeeds_ForGivenStepSize(
	vector<double>&				kseedsl,
	vector<double>&				kseedsa,
	vector<double>&				kseedsb,
	vector<double>&				kseedsx,
	vector<double>&				kseedsy,
    const int&					STEP,
    const bool&					perturbseeds,
    const vector<double>&       edgemag,
	int &                       numk)
{
    const bool hexgrid = false;
	int numseeds(0);
	int n(0);

	//int xstrips = m_width/STEP;
	//int ystrips = m_height/STEP;
	int xstrips = (0.5+double(m_width)/double(STEP));
	int ystrips = (0.5+double(m_height)/double(STEP));

    int xerr = m_width  - STEP*xstrips;if(xerr < 0){xstrips--;xerr = m_width - STEP*xstrips;}
    int yerr = m_height - STEP*ystrips;if(yerr < 0){ystrips--;yerr = m_height- STEP*ystrips;}

	double xerrperstrip = double(xerr)/double(xstrips);
	double yerrperstrip = double(yerr)/double(ystrips);

	int xoff = STEP/2;
	int yoff = STEP/2;
	//-------------------------
	numseeds = xstrips*ystrips;
	//-------------------------
	kseedsl.resize(numseeds);
	kseedsa.resize(numseeds);
	kseedsb.resize(numseeds);
	kseedsx.resize(numseeds);
	kseedsy.resize(numseeds);

	for( int y = 0; y < ystrips; y++ )
	{
		int ye = y*yerrperstrip;
		for( int x = 0; x < xstrips; x++ )
		{
			int xe = x*xerrperstrip;
            int seedx = (x*STEP+xoff+xe);
            if(hexgrid){ seedx = x*STEP+(xoff<<(y&0x1))+xe; seedx = min(m_width-1,seedx); }//for hex grid sampling
            int seedy = (y*STEP+yoff+ye);
            int i = seedy*m_width + seedx;
			
			kseedsl[n] = m_lvec[i];
			kseedsa[n] = m_avec[i];
			kseedsb[n] = m_bvec[i];
            kseedsx[n] = seedx;
            kseedsy[n] = seedy;
			n++;
		}
	}
	numk = n;
	if(perturbseeds)
	{
		PerturbSeeds(kseedsl, kseedsa, kseedsb, kseedsx, kseedsy, edgemag);
	}
}

//===========================================================================
///	PerformSuperpixelSLIC
///
///	Performs k mean segmentation. It is fast because it looks locally, not
/// over the entire image.
//===========================================================================
void SLIC::PerformSuperpixelSLIC(
	vector<double>&				kseedsl,
	vector<double>&				kseedsa,
	vector<double>&				kseedsb,
	vector<double>&				kseedsx,
	vector<double>&				kseedsy,
    vector <int> &		    	klabels,
    const int&				    STEP,
    const vector<double>&       edgemag,
    const double&				M,
	const int &                 sz,
	const int &                 numk)
{
	
	//const int numk = kseedsl.size();
	//----------------
	int offset = STEP;
        //if(STEP < 8) offset = STEP*1.5;//to prevent a crash due to a very small step size
	//----------------
	
	vector<double> clustersize(numk, 0);
	vector<double> inv(numk, 0);//to store 1/clustersize[k] values

	vector<double> sigmal(numk, 0);
	vector<double> sigmaa(numk, 0);
	vector<double> sigmab(numk, 0);
	vector<double> sigmax(numk, 0);
	vector<double> sigmay(numk, 0);
	vector<double> distvec(sz, DBL_MAX);

	double invwt = 1.0/((STEP/M)*(STEP/M));

	int x1, y1, x2, y2;
	double l, a, b;
	double dist;
	double distxy;
	for( int itr = 0; itr < 10; itr++ )
	{
		distvec.assign(sz, DBL_MAX);
		for( int n = 0; n < numk; n++ )
		{
                        y1 = max(0.0,			kseedsy[n]-offset);
                        y2 = min((double)m_height,	kseedsy[n]+offset);
                        x1 = max(0.0,			kseedsx[n]-offset);
                        x2 = min((double)m_width,	kseedsx[n]+offset);


			for( int y = y1; y < y2; y++ )
			{
				for( int x = x1; x < x2; x++ )
				{
					int i = y*m_width + x;

					l = m_lvec[i];
					a = m_avec[i];
					b = m_bvec[i];

					dist =			(l - kseedsl[n])*(l - kseedsl[n]) +
									(a - kseedsa[n])*(a - kseedsa[n]) +
									(b - kseedsb[n])*(b - kseedsb[n]);

					distxy =		(x - kseedsx[n])*(x - kseedsx[n]) +
									(y - kseedsy[n])*(y - kseedsy[n]);
					
					//------------------------------------------------------------------------
					dist += distxy*invwt;//dist = sqrt(dist) + sqrt(distxy*invwt);//this is more exact
					//------------------------------------------------------------------------
					if( dist < distvec[i] )
					{
						distvec[i] = dist;
						klabels[i]  = n;
					}
				}
			}
		}
		//-----------------------------------------------------------------
		// Recalculate the centroid and store in the seed values
		//-----------------------------------------------------------------
		//instead of reassigning memory on each iteration, just reset.
	
		sigmal.assign(numk, 0);
		sigmaa.assign(numk, 0);
		sigmab.assign(numk, 0);
		sigmax.assign(numk, 0);
		sigmay.assign(numk, 0);
		clustersize.assign(numk, 0);
		//------------------------------------
		//edgesum.assign(numk, 0);
		//------------------------------------

		{int ind(0);
		for( int r = 0; r < m_height; r++ )
		{
			for( int c = 0; c < m_width; c++ )
			{
				sigmal[klabels[ind]] += m_lvec[ind];
				sigmaa[klabels[ind]] += m_avec[ind];
				sigmab[klabels[ind]] += m_bvec[ind];
				sigmax[klabels[ind]] += c;
				sigmay[klabels[ind]] += r;
				//------------------------------------
				//edgesum[klabels[ind]] += edgemag[ind];
				//------------------------------------
				clustersize[klabels[ind]] += 1.0;
				ind++;
			}
		}}

		{for( int k = 0; k < numk; k++ )
		{
			if( clustersize[k] <= 0 ) clustersize[k] = 1;
			inv[k] = 1.0/clustersize[k];//computing inverse now to multiply, than divide later
		}}
		
		{for( int k = 0; k < numk; k++ )
		{
			kseedsl[k] = sigmal[k]*inv[k];
			kseedsa[k] = sigmaa[k]*inv[k];
			kseedsb[k] = sigmab[k]*inv[k];
			kseedsx[k] = sigmax[k]*inv[k];
			kseedsy[k] = sigmay[k]*inv[k];
			//------------------------------------
			//edgesum[k] *= inv[k];
			//------------------------------------
		}}
	}
}

//===========================================================================
///	EnforceLabelConnectivity
///
///		1. finding an adjacent label for each new component at the start
///		2. if a certain component is too small, assigning the previously found
///		    adjacent label to this component, and not incrementing the label.
//===========================================================================
void SLIC::EnforceLabelConnectivity(
	vector <int> &				labels,       //input labels that need to be corrected to remove stray labels
	const int					width,
	const int					height,
	double *&					outlabelout,  //new labels
	int&						numlabels,    //the number of labels changes in the end if segments are removed
	const int&					K,            //the number of superpixels desired by the user
	const int &                 sz)
{
//	const int dx8[8] = {-1, -1,  0,  1, 1, 1, 0, -1};
//	const int dy8[8] = { 0, -1, -1, -1, 0, 1, 1,  1};

	const int dx4[4] = {-1,  0,  1,  0};
	const int dy4[4] = { 0, -1,  0,  1};

	
	const int SUPSZ = sz/K;
	//nlabels.resize(sz, -1);
	for( int i = 0; i < sz; i++ ) outlabelout[i] = -1;
	int label(0);
	int* xvec = new int[sz];
	int* yvec = new int[sz];
	int oindex(0);
	int adjlabel(0);//adjacent label
	for( int j = 0; j < height; j++ )
	{
		for( int k = 0; k < width; k++ )
		{
			if( 0 > outlabelout[oindex] )
			{
				outlabelout[oindex] = label;
				//--------------------
				// Start a new segment
				//--------------------
				xvec[0] = k;
				yvec[0] = j;
				//-------------------------------------------------------
				// Quickly find an adjacent label for use later if needed
				//-------------------------------------------------------
				{for( int n = 0; n < 4; n++ )
				{
					int x = xvec[0] + dx4[n];
					int y = yvec[0] + dy4[n];
					if( (x >= 0 && x < width) && (y >= 0 && y < height) )
					{
						int nindex = y*width + x;
						if(outlabelout[nindex] >= 0) adjlabel = outlabelout[nindex];
					}
				}}

				int count(1);
				for( int c = 0; c < count; c++ )
				{
					for( int n = 0; n < 4; n++ )
					{
						int x = xvec[c] + dx4[n];
						int y = yvec[c] + dy4[n];

						if( (x >= 0 && x < width) && (y >= 0 && y < height) )
						{
							int nindex = y*width + x;

							if( 0 > outlabelout[nindex] && labels[oindex] == labels[nindex] )
							{
								xvec[count] = x;
								yvec[count] = y;
								outlabelout[nindex] = label;
								count++;
							}
						}

					}
				}
				//-------------------------------------------------------
				// If segment size is less then a limit, assign an
				// adjacent label found before, and decrement label count.
				//-------------------------------------------------------
				if(count <= SUPSZ >> 2)
				{
					for( int c = 0; c < count; c++ )
					{
						int ind = yvec[c]*width+xvec[c];
						outlabelout[ind] = adjlabel;
					}
					label--;
				}
				label++;
			}
			oindex++;
		}
	}
	numlabels= label;

	if(xvec) delete [] xvec;
	if(yvec) delete [] yvec;
}



//===========================================================================
///	DoSuperpixelSegmentation_ForGivenSuperpixelSize
///
/// The input parameter ubuff conains RGB values in a 32-bit unsigned integers
/// as follows:
///
/// [1 1 1 1 1 1 1 1]  [1 1 1 1 1 1 1 1]  [1 1 1 1 1 1 1 1]  [1 1 1 1 1 1 1 1]
///
///        Nothing              R                 G                  B
///
/// The RGB values are accessed from (and packed into) the unsigned integers
/// using bitwise operators as can be seen in the function DoRGBtoLABConversion().
///
/// compactness value depends on the input pixels values. For instance, if
/// the input is greyscale with values ranging from 0-100, then a compactness
/// value of 20.0 would give good results. A greater value will make the
/// superpixels more compact while a smaller value would make them more uneven.
///
/// The labels can be saved if needed using SaveSuperpixelLabels()
//===========================================================================
void SLIC::DoSuperpixelSegmentation_ForGivenSuperpixelSize(
        double *   &          r,
		double *   &          g,
		double *   &          b,
	const int					width,
	const int					height,
	vector <int> &				klabels,
	int&						numlabels,
    const int&					superpixelsize,
    const double&               compactness,
	double *&                   outlabel,
	const int&                  sz)
{
    //------------------------------------------------
    const int STEP = sqrt(double(superpixelsize))+0.5;
    //------------------------------------------------
	vector<double> kseedsl(0);
	vector<double> kseedsa(0);
	vector<double> kseedsb(0);
	vector<double> kseedsx(0);
	vector<double> kseedsy(0);

	//--------------------------------------------------
	m_width  = width;
	m_height = height;

	//LAB, the default option
    
        DoRGBtoLABConversion(r,g,b, m_lvec, m_avec, m_bvec, sz);
   
	//--------------------------------------------------
    bool perturbseeds(false);//perturb seeds is not absolutely necessary, one can set this flag to false
	vector<double> edgemag(0);
	if(perturbseeds) DetectLabEdges(m_lvec, m_avec, m_bvec, m_width, m_height, edgemag, sz);
	int numk(0);
	GetLABXYSeeds_ForGivenStepSize(kseedsl, kseedsa, kseedsb, kseedsx, kseedsy, STEP, perturbseeds, edgemag, numk);

	PerformSuperpixelSLIC(kseedsl, kseedsa, kseedsb, kseedsx, kseedsy, klabels, STEP, edgemag, compactness, sz, numk);
	//numlabels = kseedsl.size();
	//numlabels = numk;
	//int* nlabels = new int[sz];
	//vector <int> nlabels (sz,-1);
	EnforceLabelConnectivity(klabels, m_width, m_height, outlabel, numlabels, double(sz)/double(STEP*STEP), sz);
	//{for(int i = 0; i < sz; i++ ) outlabel[i] = nlabels[i];}
	//if(nlabels) delete [] nlabels;
}

//===========================================================================
///	DoSuperpixelSegmentation_ForGivenNumberOfSuperpixels
///
/// The input parameter ubuff conains RGB values in a 32-bit unsigned integers
/// as follows:
///
/// [1 1 1 1 1 1 1 1]  [1 1 1 1 1 1 1 1]  [1 1 1 1 1 1 1 1]  [1 1 1 1 1 1 1 1]
///
///        Nothing              R                 G                  B
///
/// The RGB values are accessed from (and packed into) the unsigned integers
/// using bitwise operators as can be seen in the function DoRGBtoLABConversion().
///
/// compactness value depends on the input pixels values. For instance, if
/// the input is greyscale with values ranging from 0-100, then a compactness
/// value of 20.0 would give good results. A greater value will make the
/// superpixels more compact while a smaller value would make them more uneven.
///
/// The labels can be saved if needed using SaveSuperpixelLabels()
//===========================================================================
void SLIC::DoSuperpixelSegmentation_ForGivenNumberOfSuperpixels(
         double *  &           r,
		 double *  &           g,
		 double *  &           b,
	const int					width,
	const int					height,
	//vector <int> &			klabels,
	int&						numlabels,
	const int&					 K,
	const double&                compactness,
	double *&                    outlabel,
	const int&                   NumPixel )
{
	vector <int> klabels( NumPixel, -1 );

    const int superpixelsize = 0.5 + double(NumPixel)/double(K);
    DoSuperpixelSegmentation_ForGivenSuperpixelSize(r,g,b,width,height,klabels,numlabels,superpixelsize,compactness,outlabel,NumPixel);
}

void SLIC::DoMeanSup(   double *  &                    m_rr,
	                    double *  &                    m_gg,
                  	    double *  &                    m_bb,
	                    int &                           numlabels,
	                    int &                           NumPixel,
	                   double *&                       outlabel,
	                   vector <double> &                       meanSupl,
					   vector <double> &                       meanSupa,
					   vector <double> &                       meanSupb )
{ 
	vector <int> num( numlabels );
	
	for ( int j = 0; j< NumPixel; j++ ){

		int kk = int(outlabel[j]);
		meanSupl[ kk ] +=   m_rr[j];
		num[ kk ] +=   1;

		meanSupa[ kk ] +=   m_gg[j];		

		meanSupb[ kk ] +=   m_bb[j];		
	}

	for ( int j = 0; j< numlabels; j++ ) {

		int numj = num[ j ];
		meanSupl[ j ] /=  numj;
		meanSupa[ j ] /=  numj;
		meanSupb[ j ] /=  numj;		
	}	
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	if (nrhs!=4) mexErrMsgTxt("error :the input number error");

	 double * rr= (double* )mxGetPr(prhs[0]);
	 double * gg= (double*)mxGetPr(prhs[1]);
	 double * bb= (double*)mxGetPr(prhs[2]);
	 double *imgattr=(double *)mxGetPr(prhs[3]);

	double height=imgattr[0];
	double width=imgattr[1];
	double k=imgattr[2];
	double m=imgattr[3];
	int NumPixel = imgattr[4];
	
	int numlabels(0);

	plhs[0] = mxCreateDoubleMatrix( NumPixel, 1, mxREAL);
	double * outlabel=(double *)mxGetPr(plhs[0]);

	SLIC slic;
	slic.DoSuperpixelSegmentation_ForGivenNumberOfSuperpixels( rr, gg, bb, width, height, numlabels, k, m, outlabel, NumPixel );

	plhs[1] = mxCreateDoubleMatrix( numlabels, 1, mxREAL);
	double * Supll = (double *)mxGetPr(plhs[1]);

	plhs[2] = mxCreateDoubleMatrix( numlabels, 1, mxREAL);
	double * Supaa = (double *)mxGetPr(plhs[2]);

	plhs[3] = mxCreateDoubleMatrix( numlabels, 1, mxREAL);
	double * Supbb = (double *)mxGetPr(plhs[3]);

	plhs[4] = mxCreateDoubleMatrix( 1, 1, mxREAL );
	double * numSuperpixel = (double *)mxGetPr(plhs[4]);
	numSuperpixel[0] = numlabels;

    vector <double> meanSuprr( numlabels );
	vector <double> meanSupgg( numlabels );
	vector <double> meanSupbb( numlabels );

	slic.DoMeanSup( rr, gg, bb, numlabels, NumPixel , outlabel, meanSuprr, meanSupgg, meanSupbb );	
	
	slic.DoRGBtoLABConversionSup(meanSuprr, meanSupgg, meanSupbb, Supll, Supaa, Supbb, numlabels); 
	
}