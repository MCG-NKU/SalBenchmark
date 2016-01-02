// SymmetricSurroundSaliency.h: interface for the SymmetricSurroundSaliency class.
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

#pragma warning(disable:4244)

#if !defined(_SYMMETRICSURROUNDSALIENCY_H_INCLUDED_)
#define _SYMMETRICSURROUNDSALIENCY_H_INCLUDED_

#include <vector>
using namespace std;

class SymmetricSurroundSaliency  
{
public:
	SymmetricSurroundSaliency();
	virtual ~SymmetricSurroundSaliency();

public:
	void ComputeMaximumSymmetricSurroundSaliency(
		const vector<UINT>&						img,//INPUT: ARGB buffer in row-major order
		const int&								width,
		const int&								height,
		vector<double>&							salmap,//OUTPUT: Floating point buffer in row-major order
		const bool&								normflag = true);

private:

	void RGB2LAB(
		const vector<UINT>&						ubuff,
		vector<double>&							lvec,
		vector<double>&							avec,
		vector<double>&							bvec);


	void GaussianSmooth(
		const vector<double>&					inputImg,
		const int&								width,
		const int&								height,
		const vector<double>&					kernel,
		vector<double>&							smoothImg);


	//===========================================================================
	///	CreateIntegralImage
	///
	///	Any type (int, float, double) version
	//===========================================================================
	template <class T> void CreateIntegralImage(
		const vector<T>&		inputImg,
		const int&				width,
		const int&				height,
		vector< vector<T> >&	intImg)
	{
		// Initialize
		vector<T> initvec(width, 0);
		intImg.resize(height, initvec);

		int index(0);
		for( int j = 0; j < height; j++ )
		{
			T sumRow(0);
			for( int k = 0; k < width; k++ )
			{
				sumRow += inputImg[index];
				index++;

				if( 0 == j )
				{
					intImg[j][k]	= sumRow;
				}
				else
				{
					intImg[j][k]	= intImg[j-1][k] + sumRow;
				}
			}
		}
	}

	//===========================================================================
	///	GetIntegralSum
	///
	///	Any type (int, float, double) version, the more correct one. Returns a
	///	single pixle value if x1 == x2 and y1 == y2
	//===========================================================================
	template <class T> T GetIntegralSum(
		const vector< vector<T> >&		integralImage,
		const int&						x1,
		const int&						y1,
		const int&						x2,
		const int&						y2)
	{
		T sum(0);
		if( x1-1 < 0 && y1-1 < 0 )
		{
			sum =	integralImage[y2][x2];
		}
		else if( x1-1 < 0 )
		{
			sum =	integralImage[y2][x2] - integralImage[y1-1][x2];
		}
		else if( y1-1 < 0 )
		{
			sum =	integralImage[y2][x2] - integralImage[y2][x1-1];
		}
		else
		{
			sum =	integralImage[y2][x2] + integralImage[y1-1][x1-1] -
				integralImage[y1-1][x2] - integralImage[y2][x1-1];
		}

		return sum;

	}

	//===========================================================================
	///	Normalize
	//===========================================================================
	void Normalize( vector<double>& salmap, const int& width, const int& height )
	{
		double maxval(0);
		double minval(1 << 30);
		int sz = width*height;
		{for( int i = 0; i < sz; i++ )
		{
			if( maxval < salmap[i] ) maxval = salmap[i];
			if( minval > salmap[i] ) minval = salmap[i];
		}}

		int range = maxval-minval;
		_ASSERT( range > 0 );

		{for( int i = 0; i < sz; i++ )
		{
			salmap[i] = ((255.0*(salmap[i]-minval))/range);
			//----------------------------------------------------------------
			// More efficient way of multiplying by 255 is to multipy by
			// (256-1) and use shifts instead of multiplication
			//----------------------------------------------------------------
			//int val = saliencyMap[y][x] - minval;
			//saliencyMap[y][x] = ((val << 8) - val + 1)/range;
		}}
	}

};

#endif // !defined(_SYMMETRICSURROUNDSALIENCY_H_INCLUDED_)
