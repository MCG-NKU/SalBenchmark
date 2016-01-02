#pragma once

/************************************************************************/
/* This is a faster version of the saliency detection method in our ICCV*/
/* paper:
/* [1] Efficient Salient Region Detection with Soft Image Abstraction.	*/
/*	 M.M. Cheng, J. Warrell, W.Y. Lin, S. Zheng, V. Vineet, N. Crook.	*/
/*	 IEEE ICCV, 2013.													*/
/************************************************************************/

class CmSaliencyGU
{
public:
	CmSaliencyGU(CMat &img3f, CStr &outName);

	void HistgramGMMs();
	void MergeGMMs();
	Mat GetSaliencyCues();

	static int Demo(CStr &wkDir); // C:/Data/SaliencyFT/

private: // Data values
	CmGMM _gmm;
	Mat _img3f;
	CStr _nameNE;
	static const int DEFAULT_GMM_NUM;

	// L0: pixel layer, each Mat variable has the same size as image
	Mat _HistBinIdx1i; // The histogram bin index of each pixel, associating L0 and L1
	vector<Mat> _PixelSalCi1f; // Pixel saliency of component i, type CV_32FC1 (denoted 1f)

	// L1: histogram layer, each Mat variable has the same size as histogram
	vector<Mat> _HistBinSalCi1f; // Histogram bin saliency of component i

	// L2: GMM layer, each vector has the size of GMM numbers
	int _NUM;
	vector<Vec3f> _gmmClrs; // Colors of GMM components
	vecD _gmmW; // Weight of each GMM component
	PointSetd _gmmMeanPos;
	vecI _ClusteredIdx; // Bridge between L2 and L3
	vecD _csd; // color spatial distribution
	vecD _gu; // global contrast
	vecD _fSal; // Final saliency

	// L3: clustered layer
	int _NUM_Merged;
	vector<Mat> _pciM1f; // Probability of GMM components, after merged

private: 
	void ViewValues(vecD &vals, CStr &ext);
	Mat GetSalFromGMMs(vecD &val, bool normlize = true);
	void GetCSD(vecD &csd, vecD &cD);
	void GetGU(vecD& gc, vecD &d, double sigmaDist, double dominate = 30);
	void ReScale(vecD& salVals, double minRatio = 0.01);

	// Return the spatial variance. Pixel locations are normalized to [0, 1]
	static double SpatialVar(CMat& map1f, double &cD = dummyD);
};