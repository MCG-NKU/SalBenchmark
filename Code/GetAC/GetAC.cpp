// GetAC.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

// ./Imgs/*.jpg   ./Sal/ 
int main(int argc,char *argv[])
{
	CV_Assert(argc == 3);
	CStr imgW = argv[1], salDir = argv[2];
	CStr tmpDir = salDir + "Tmp/";
	string imgDir, imgExt;
	vecS namesNE;
	CmFile::MkDir(salDir);
	CmFile::MkDir(tmpDir);
	int imgNum = CmFile::GetNamesNE(imgW, namesNE, imgDir, imgExt);

	for (int i = 0; i < imgNum; i++){
		if (CmFile::FilesExist(salDir + namesNE[i] + "_AC.png"))
			continue;

		Mat img = imread(imgDir + namesNE[i] + imgExt);
		imwrite(tmpDir + namesNE[i] + ".bmp", img);
		CStr param = format("\"%s\" \"%s\"", _S(tmpDir + namesNE[i] + ".bmp"), _S(salDir));
		CmFile::RunProgram("..\\Executable\\AC\\ACPerImg.exe", param, true);

		CStr tmpSalFileName = salDir + namesNE[i] + "_saliency.bmp";
		Mat sal = imread(tmpSalFileName, CV_LOAD_IMAGE_GRAYSCALE);
		imwrite(salDir + namesNE[i] + "_AC.png", sal);
		CmFile::RmFile(tmpSalFileName);
	}
	CmFile::RmFolder(tmpDir);
}
