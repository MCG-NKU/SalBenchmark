// Saliency.h: interface for the Saliency class.
//
//////////////////////////////////////////////////////////////////////
//===========================================================================
// This code implements the saliency method described in:
//
// R. Achanta, S. Hemami, F. Estrada and S. Süsstrunk,
// "Frequency-tuned Salient Region Detection",
// IEEE International Conference on Computer Vision and Pattern Recognition (CVPR), 2009
//===========================================================================
// Copyright (c) 2011 Radhakrishna Achanta [EPFL]
//===========================================================================

#if !defined(_SALIENCY_H_INCLUDED_)
#define _SALIENCY_H_INCLUDED_

#include <vector>
#include <cfloat>
using namespace std;

class Saliency  
{
public:
	Saliency();
	virtual ~Saliency();

public:

	void GetSaliencyMap(
		const vector<UINT>&				inputimg,//INPUT: ARGB buffer in row-major order
		const int&						width,
		const int&						height,
		vector<double>&					salmap,//OUTPUT: Floating point buffer in row-major order
		const bool&						normalizeflag = true);//false if normalization is not needed


private:

	void RGB2LAB(
		const vector<UINT>&				ubuff,
		vector<double>&					lvec,
		vector<double>&					avec,
		vector<double>&					bvec);

	void GaussianSmooth(
		const vector<double>&			inputImg,
		const int&						width,
		const int&						height,
		const vector<double>&			kernel,
		vector<double>&					smoothImg);

	//==============================================================================
	///	Normalize
	//==============================================================================
	void Normalize(
		const vector<double>&			input,
		const int&						width,
		const int&						height,
		vector<double>&					output,
		const int&						normrange = 255)
	{
		double maxval(0);
		double minval(DBL_MAX);
		{int i(0);
		for( int y = 0; y < height; y++ )
		{
			for( int x = 0; x < width; x++ )
			{
				if( maxval < input[i] ) maxval = input[i];
				if( minval > input[i] ) minval = input[i];
				i++;
			}
		}}
		double range = maxval-minval;
		if( 0 == range ) range = 1;
		int i(0);
		output.clear();
		output.resize(width*height);
		for( int y = 0; y < height; y++ )
		{
			for( int x = 0; x < width; x++ )
			{
				output[i] = ((normrange*(input[i]-minval))/range);
				i++;
			}
		}
	}

};

#endif // !defined(_SALIENCY_H_INCLUDED_)
