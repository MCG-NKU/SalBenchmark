#ifndef _GMRSALIENCY_H
#define _GMRSALIENCY_H

#include <opencv2\core\core.hpp>
#include <opencv2\highgui\highgui.hpp>
#include <opencv2\imgproc\imgproc.hpp>
#include <iostream>
#include <vector>
#include <algorithm>
#include <limits>
#include "SLIC.h"

using namespace cv;

class GMRsaliency
{
public:
	GMRsaliency();
	~GMRsaliency();

	//Get saliency map of an input image
	Mat GetSal(Mat &img);

private://parameters
	int spcount;//superpxiels number
	double compactness;//superpixels compactness
	float alpha;//balance the fittness and smoothness
	float delta;//contral the edge weight
	int spcounta;//actual superpixel number

private:
	//Get the superpixels of the image
	Mat GetSup(const Mat &img);	

	//Get the adjacent matrix
	Mat GetAdjLoop(const Mat &supLab);

	//Get the affinity matrix of edges 
	Mat GetWeight(const Mat &img,const Mat &supLab,const Mat &adj);

	//Get the optimal affinity matrix learned by minifold ranking (e.q. 3 in paper)
	Mat GetOptAff(const Mat &W);

	//Get the indicator vector based on boundary prior
	Mat GetBdQuery(const Mat &supLab,int type);

	//Remove the obvious frame of the image
	Mat RemoveFrame(const Mat &img,int *wcut);

};

#endif