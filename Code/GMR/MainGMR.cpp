// GMR.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "GMRsaliency.h"

// ./Imgs/*.jpg   ./Sal/ 
int main(int argc,char *argv[])
{
	CV_Assert(argc == 3);
	CStr imgW = argv[1], salDir = argv[2];
	string imgDir, imgExt;
	vecS namesNE;
	CmFile::MkDir(salDir);
	int imgNum = CmFile::GetNamesNE(imgW, namesNE, imgDir, imgExt);

	for (int i = 0; i < imgNum; i++){
		if (CmFile::FilesExist(salDir + namesNE[i] + "_GMR.png"))
			continue;

		Mat img = imread(imgDir + namesNE[i] + imgExt);
		GMRsaliency GMRsal;
		Mat sal=GMRsal.GetSal(img);
		imwrite(salDir + namesNE[i] + "_GMR.png", sal*255);
	}
}
