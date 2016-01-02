#include <mex.h>
#include <stdio.h>
#include "SLIC.h"
#include "Rgb2Lab.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	char usageStr[] = "Usage: idxImg = SLIC_mex(image(3-Channel uint8 image), spNum(double scalar), compactness(double scalar))\n";

	//Check input
	const mxArray *pmxImg = prhs[0];
	if (nrhs != 3 || !mxIsUint8(pmxImg) || !mxIsDouble(prhs[1]) || !mxIsDouble(prhs[2]))
		mexErrMsgTxt(usageStr);

	mwSize chn = mxGetNumberOfDimensions(pmxImg);
	if (3 != chn)
		mexErrMsgTxt(usageStr);
	const mwSize *sz = mxGetDimensions(pmxImg);
	mwSize height = sz[0], width = sz[1], num_pix = height * width;
	unsigned int iPatchNum = unsigned int( mxGetScalar(prhs[1]) );
	float compactness = float( mxGetScalar(prhs[2]) );

	//Transfer matlab matrix
	ImageSimpleUChar img_r, img_g, img_b;
	img_r.Create(width, height);
	img_g.Create(width, height);
	img_b.Create(width, height);
	
	unsigned char *pImgData = (unsigned char*)mxGetData(pmxImg);
	for (int x = 0; x < width; x++)
	{
		for (int y = 0; y < height; y++)
		{
			img_r.Pixel(x,y) = pImgData[y];
			img_g.Pixel(x,y) = pImgData[y + num_pix];
			img_b.Pixel(x,y) = pImgData[y + num_pix * 2];
		}
		pImgData += height;
	}

	//Rgb --> Lab
	ImageSimpleFloat img_L, img_A, img_B;
	Rgb2Lab(img_r, img_g, img_b, img_L, img_A, img_B);

	//Do SLIC
	ImageSimpleUInt idxImg;
	idxImg.Create(width, height);
	int iSuperPixelNum = Run_SLIC_GivenPatchNum(img_L, img_A, img_B, iPatchNum, compactness, idxImg);

	//Transfer back to matlab
	plhs[0] = mxCreateDoubleMatrix(height, width, mxREAL);
	double *pdIdxImg = mxGetPr(plhs[0]);
	for (int x = 0; x < width; x++)	
	{
		for (int y = 0; y < height; y++)
		{
			unsigned int id = idxImg.Pixel(x, y);
			pdIdxImg[y] = double(id) + 1;
		}
		pdIdxImg += height;
	}

	plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
	*mxGetPr(plhs[1]) = double(iSuperPixelNum);

	return;
}