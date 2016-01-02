// GetHC.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"


int main(int argc,char *argv[])
{
	CV_Assert(argc == 3);
	CStr imgW = argv[1], salDir = argv[2];
	string imgDir, imgExt;
	vecS namesNE;
	CmFile::MkDir(salDir);
	int imgNum = CmFile::GetNamesNE(imgW, namesNE, imgDir, imgExt);

	for (int i = 0; i < imgNum; i++){
		if (CmFile::FilesExist(salDir + namesNE[i] + "_HC.png"))
			continue;

		Mat img = imread(imgDir + namesNE[i] + imgExt);
		CV_Assert(img.data != NULL);

		img.convertTo(img, CV_32F, 1.0/255);
		Mat sal = CmSaliencyRC::GetHC(img);
		imwrite(salDir + namesNE[i] + "_HC.png", sal*255);
	}
}