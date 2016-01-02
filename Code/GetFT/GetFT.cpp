// GetFT.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include "../MSS/PictureHandler.h"
#include "Saliency.h"


// ./Imgs/*.jpg   ./Sal/ 
int main(int argc,char *argv[])
{
	CV_Assert(argc == 3);
	string imgW = argv[1], salDir = argv[2];
	string imgDir, imgExt;
	vecS namesNE;
	CmFile::MkDir(salDir);
	int imgNum = CmFile::GetNamesNE(imgW, namesNE, imgDir, imgExt);

	for (int i = 0; i < imgNum; i++){
		if (CmFile::FilesExist(salDir + namesNE[i] + "_FT.png"))
			continue;


		vector<UINT> img(0);// or UINT* imgBuffer;
		int width(0);
		int height(0);


		PictureHandler picHand;
		picHand.GetPictureBuffer(imgDir + namesNE[i] + imgExt, img, width, height );
		int sz = width*height;

		Saliency sal;
		vector<double> salmap(0);
		sal.GetSaliencyMap(img, width, height, salmap, true);

		vector<UINT> outimg(sz);
		for( int i = 0; i < sz; i++ ){
			int val = int(salmap[i] + 0.5);
			outimg[i] = val << 16 | val << 8 | val;
		}

		picHand.SavePicture(outimg, width, height, namesNE[i], salDir, 0, "_FT");// 0 is for BMP and 1 for JPEG)

		Mat sal1u = imread(salDir + namesNE[i] + "_FT.bmp", CV_LOAD_IMAGE_GRAYSCALE);
		imwrite(salDir + namesNE[i] + "_FT.png", sal1u);
		CmFile::RmFile(salDir + namesNE[i] + "_FT.bmp");
	}
}
