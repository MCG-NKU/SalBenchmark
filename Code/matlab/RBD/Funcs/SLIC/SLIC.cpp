typedef unsigned int UINT;

#include "SLIC.h"
const int MAXITER = 10;

inline double max(double a, double b) {return a > b ? a : b;}
inline double min(double a, double b) {return a < b ? a : b;}

void PerformLabXYKMeans(
	vector<double> &kseedsl,
	vector<double> &kseedsa,
	vector<double> &kseedsb,
	vector<double> &kseedsx,
	vector<double> &kseedsy,
	ImageSimpleFloat &LImg, ImageSimpleFloat &AImg, ImageSimpleFloat &BImg,
	const int iPatchSize,
	const double spatialFactor,
	ImageSimpleUInt &idxImg)
{
	UINT uiWidth = LImg.Width();
	UINT uiHeight = LImg.Height();

	const double searchRange = iPatchSize;
	const size_t seedNum = kseedsl.size();

	vector<double> clustersize(seedNum, 0);

	vector<double> centroidl(seedNum, 0);
	vector<double> centroida(seedNum, 0);
	vector<double> centroidb(seedNum, 0);
	vector<double> centroidx(seedNum, 0);
	vector<double> centroidy(seedNum, 0);

	ImageSimpleDouble minDistImage(uiWidth, uiHeight);
	minDistImage.FillPixels(DBL_MAX);

	ImageSimpleUInt lastIdxImg(uiWidth, uiHeight);
	lastIdxImg.FillPixels(0);

	bool converged = false;
	int iter = 0;
	const UINT pixNum = uiWidth * uiHeight;
	while(!converged && iter < MAXITER)
	{
		int x1, y1, x2, y2;
		double l, a, b;
		double distCol;
		double distxy;
		double dist;

		minDistImage.FillPixels(DBL_MAX);

		for( size_t n = 0; n < seedNum; n++ )
		{
			y1 = (int)max(0.0,			kseedsy[n]-searchRange);
			y2 = (int)min((double)uiHeight,	kseedsy[n]+searchRange);
			x1 = (int)max(0.0,			kseedsx[n]-searchRange);
			x2 = (int)min((double)uiWidth,	kseedsx[n]+searchRange);

			for( int y = y1; y < y2; y++ )
			{
				for( int x = x1; x < x2; x++ )
				{
					l = LImg.Pixel(x,y);
					a = AImg.Pixel(x,y);
					b = BImg.Pixel(x,y);

					distCol = (l - kseedsl[n])*(l - kseedsl[n]) +
						(a - kseedsa[n])*(a - kseedsa[n]) +
						(b - kseedsb[n])*(b - kseedsb[n]);

					distxy = (x - kseedsx[n])*(x - kseedsx[n]) +
						(y - kseedsy[n])*(y - kseedsy[n]);

					dist = (distCol) + (distxy * spatialFactor);//sqrt(distCol) + sqrt(distxy * spatialFactor);
					if( dist < minDistImage.Pixel(x,y) )
					{
						minDistImage.Pixel(x,y) = dist;
						idxImg.Pixel(x,y)  = ImageSimpleUInt::PixelType(n);
					}
				}
			}
		}

		// Recalculate the centroid and store in the seed values
		centroidl.assign(seedNum, 0);
		centroida.assign(seedNum, 0);
		centroidb.assign(seedNum, 0);
		centroidx.assign(seedNum, 0);
		centroidy.assign(seedNum, 0);
		clustersize.assign(seedNum, 0);

		for (UINT y = 0; y < uiHeight; y ++)
		{
			for (UINT x = 0; x < uiWidth; x ++)
			{
				ImageSimpleUInt::PixelType idx = idxImg.Pixel(x,y);
				centroidl[idx] += LImg.Pixel(x,y);
				centroida[idx] += AImg.Pixel(x,y);
				centroidb[idx] += BImg.Pixel(x,y);
				centroidx[idx] += x;
				centroidy[idx] += y;
				clustersize[idx] += 1.0;
			}
		}

		for( UINT k = 0; k < seedNum; k++ )
		{
			assert(clustersize[k] > 0);

			double inv = 1.0 / clustersize[k];
			kseedsl[k] = centroidl[k] * inv;
			kseedsa[k] = centroida[k] * inv;
			kseedsb[k] = centroidb[k] * inv;
			kseedsx[k] = centroidx[k] * inv;
			kseedsy[k] = centroidy[k] * inv;
		}

		//Judge convergence
		converged = true;
		for (UINT x = 0; x < pixNum; x ++)
		{
			if (lastIdxImg[x] != idxImg[x])
			{
				converged = false;
				break;
			}
		}

		lastIdxImg = idxImg;

		iter ++;
	}
}

int EnforceLabelConnectivity( ImageSimpleUInt &idxImg, const int iPatchSize )
{
	//	const int dx8[8] = {-1, -1,  0,  1, 1, 1, 0, -1};
	//	const int dy8[8] = { 0, -1, -1, -1, 0, 1, 1,  1};
	UINT uiWidth = idxImg.Width();
	UINT uiHeight = idxImg.Height();

	const int dx4[4] = {-1,  0,  1,  0};
	const int dy4[4] = { 0, -1,  0,  1};

	const int pixNum = uiWidth* uiHeight;
	const int AreaThresh = iPatchSize * iPatchSize / 4;

	ImageSimpleInt newIdxImg(uiWidth, uiHeight);
	newIdxImg.FillPixels(-1);

	int label = 0;
	int adjlabel = 0;
	int* xvec = new int[pixNum];			//this is actually a queue
	int* yvec = new int[pixNum];

	for( UINT q = 0; q < uiHeight; q++ )
	{
		for( UINT p = 0; p < uiWidth; p++ )
		{
			if( newIdxImg.Pixel(p,q) < 0 )	//"< 0 " means unprocessed
			{
				newIdxImg.Pixel(p,q) = label;

				//Add current pixel to the queue
				xvec[0] = p;
				yvec[0] = q;

				//Adjacent label for current region, this may be used for region merging
				for( int n = 0; n < 4; n++ )
				{
					int x = xvec[0] + dx4[n];
					int y = yvec[0] + dy4[n];
					if( (x >= 0 && x < (int)uiWidth) && (y >= 0 && y < (int)uiHeight) )
					{
						//Note, adjacent label for the first(top-left corner) patch is unset, so it's initial value 0.
						if(newIdxImg.Pixel(x,y) >= 0)
							adjlabel = newIdxImg.Pixel(x,y);
					}
				}

				int count = 1;
				for( int c = 0; c < count; c++ )	//count will be updated, so xvec and yvec are queues
				{
					for( int n = 0; n < 4; n++ )
					{
						int x = xvec[c] + dx4[n];
						int y = yvec[c] + dy4[n];

						if( (x >= 0 && x < (int)uiWidth) && (y >= 0 && y < (int)uiHeight) )
						{
							if( newIdxImg.Pixel(x,y) < 0 && idxImg.Pixel(x,y) == idxImg.Pixel(p,q) )
							{
								xvec[count] = x;
								yvec[count] = y;
								newIdxImg.Pixel(x,y) = label;
								count++;
							}
						}

					}
				}

				// If segment size is less then a limit, assign an adjacent label found before, and decrement label count.
				if(count <= AreaThresh)
				{
					for( int c = 0; c < count; c++ )
					{
						newIdxImg.Pixel(xvec[c], yvec[c]) = adjlabel;
					}
					label--;
				}
				label++;
			}
		}
	}

	//Transfer newIdxImg to idxImg
	for (UINT y = 0; y < uiHeight; y ++)
	{
		for (UINT x = 0; x < uiWidth; x ++)
		{
			assert(newIdxImg.Pixel(x, y) >= 0);
			idxImg.Pixel(x, y) = newIdxImg.Pixel(x, y);
		}
	}


	delete [] xvec;
	delete [] yvec;

	return label;
}

int Run_SLIC_GivenPatchNum(ImageSimpleFloat &LImg, ImageSimpleFloat &AImg, ImageSimpleFloat &BImg, unsigned int iPatchNum, float compactness, ImageSimpleUInt &idxImg)
{
	UINT uiWidth = LImg.Width();
	UINT uiHeight = LImg.Height();
	UINT STEP = UINT(sqrt(float(uiWidth * uiHeight) / iPatchNum) + 0.5f);

	return Run_SLIC_GivenPatchSize(LImg, AImg, BImg, STEP, compactness, idxImg);
}

int Run_SLIC_GivenPatchSize(ImageSimpleFloat &LImg, ImageSimpleFloat &AImg, ImageSimpleFloat &BImg, unsigned int uiPatchSize, float compactness, ImageSimpleUInt &idxImg)
{
	const UINT MINSPSIZE = 3;
	UINT uiWidth = LImg.Width(), uiHeight = LImg.Height();

	uiPatchSize = max(uiPatchSize, MINSPSIZE);
		
	assert(uiPatchSize <= min(uiWidth, uiHeight));

	if (idxImg.Width() != uiWidth || idxImg.Height() != uiHeight)
	{
		idxImg.Create(uiWidth, uiHeight);
	}
		
	// initialize seeds
	const UINT seedNum_x = UINT(uiWidth / uiPatchSize);
	const UINT seedNum_y = UINT(uiHeight / uiPatchSize);
	const UINT seedNum = seedNum_x * seedNum_y;
	vector<double> kseedsx(seedNum), kseedsy(seedNum), kseedsl(seedNum), kseedsa(seedNum), kseedsb(seedNum);

	float step_x = float(uiWidth) / seedNum_x;
	float step_y = float(uiHeight) / seedNum_y;

	assert(step_x >= MINSPSIZE && step_y >= MINSPSIZE);

	
	int n = 0;
	for (UINT y = 0; y < seedNum_y; y ++)
	{
		for (UINT x = 0; x < seedNum_x; x ++)
		{
			kseedsx[n] = step_x * (x + 0.5) + 0.5;
			kseedsy[n] = step_y * (y + 0.5) + 0.5;
			UINT sx = (UINT)kseedsx[n];
			UINT sy = (UINT)kseedsy[n];
			kseedsl[n] = LImg.Pixel(sx, sy);
			kseedsa[n] = AImg.Pixel(sx, sy);
			kseedsb[n] = BImg.Pixel(sx, sy);
			n++;
		}
	}	

	const double spatialFactor = 1.0 / ( (uiPatchSize/compactness) * (uiPatchSize/compactness) );
	PerformLabXYKMeans(kseedsl, kseedsa, kseedsb, kseedsx, kseedsy, LImg, AImg, BImg, uiPatchSize, spatialFactor, idxImg);

	//Assign small patches to its neighbor patch
	return EnforceLabelConnectivity(idxImg, uiPatchSize);
}