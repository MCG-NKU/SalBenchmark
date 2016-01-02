#include "StdAfx.h"
#include "CmIluImgs.h"

void CmIluImgs::ImgsOptions::Initial(CStr &wkDir)
{
	_w = 200, _H = 2800;
	_inDir = wkDir + "/Sal/";
	_outDir = wkDir + "/Supp/";
	_texName = wkDir + "SupFig.tex";
}

Mat CmIluImgs::Retreival(CStr wkDir, vector<vecM> &subImgs, const char* nameW[], int H, int W)
{
	bool toRow = W > H;
	vecM finImgs;
	vecD finLens;
	int TYPE_NUM = (int)subImgs.size();
	vector<vecD> subLens(TYPE_NUM);
	for (int i = 0; i < TYPE_NUM; i++) {
		LoadImgs(wkDir + nameW[i], subImgs[i], subLens[i], W, H);
		finImgs.push_back(ArrangeImgs(subImgs[i], subLens[i], W, H, toRow));
		finLens.push_back(min(W, H));
	}

	if (toRow)
		H = H * TYPE_NUM + (TYPE_NUM - 1) * space;
	else
		W = W * TYPE_NUM + (TYPE_NUM - 1) * space;
	return ArrangeImgs(finImgs, finLens, W, H, !toRow);
}


// load format(imgW, i) and add information to the back of imgs and lens
void CmIluImgs::LoadImgs(CStr &imgW, vecM &imgs, vecD &lens, int W, int H, bool iluMask)
{
	bool toRow = W > H;
	double crnt = -space;
	if (imgs.size()){ // There exist a predefined image for sketch
		lens.push_back(toRow ? H*imgs[0].cols*1./imgs[0].rows : W*imgs[0].rows*1./imgs[0].cols);
		crnt += lens[0] + space;
	}

	for (int i = 0; i < 500; i++){
		string imgN = format(_S(imgW), i), inDir, maskN;
		vecS names;
		int subN = CmFile::GetNames(imgN, names, inDir);
		if (subN == 0)
			continue;
		Mat img = imread(inDir + names[0]);
		if (img.data == NULL){
			printf("Can't load image file %-70s\n", _S(names[0]));
			continue;
		}
		if (subN > 1 && iluMask){
			Mat mask1u = imread(inDir + names[1], CV_LOAD_IMAGE_GRAYSCALE), big1u;
			dilate(mask1u, big1u, Mat(), Point(-1, -1), 5);
			bitwise_xor(mask1u, big1u, mask1u);
			img.setTo(Scalar(0, 0, 255), mask1u);
		}

		lens.push_back(toRow ? H*img.cols*1./img.rows : W*img.rows*1./img.cols);
		imgs.push_back(img);
		crnt += lens[lens.size() - 1] + space;
		if (crnt >= max(H, W))
			break;
	}
	int num = imgs.size();
	if (num && abs(crnt - max(H,W)) > abs(crnt - lens[num - 1] - space - max(H,W)))
		imgs.resize(num - 1), lens.resize(num - 1);

	printf("%s: %d\n", _S(imgW), num);
	if (crnt < max(H, W))	{
		printf("%s\n", _S(imgW + ": not enough images\n"));
	}
}

void CmIluImgs::LoadAllImgs(CStr &imgW, vecM &imgs, vecD &lens, int W, int H)
{
	bool toRow = W > H;
	double crnt = -space;
	if (imgs.size()){ // There exist a predefined image for sketch
		lens.push_back(toRow ? H*imgs[0].cols*1./imgs[0].rows : W*imgs[0].rows*1./imgs[0].cols);
		crnt += lens[0] + space;
	}

	string inDir;
	vecS names;
	int imgNum = CmFile::GetNames(imgW, names, inDir);
	for (int i = 0; i < imgNum; i++){
		Mat img = imread(inDir + names[i]);
		if (img.data == NULL){
			printf("Can't load image file %-70s\n", _S(names[i]));
			continue;
		}

		lens.push_back(toRow ? H*img.cols*1./img.rows : W*img.rows*1./img.cols);
		imgs.push_back(img);
	}
}

Mat CmIluImgs::Imgs(CStr wkDir, vector<vecM> &subImgs, const char* nameW[], int H)
{
	bool toRow = true;
	vecM finImgs;
	vecD finLens;
	int TYPE_NUM = (int)subImgs.size();
	double sumW = 0;
	vector<vecD> subLens(TYPE_NUM);
	for (int i = 0; i < TYPE_NUM; i++) {
		LoadAllImgs(wkDir + nameW[i], subImgs[i], subLens[i], INT_MAX, H);
		//subImgs[i].resize(6);
		//subLens[i].resize(6);
		sumW += sum(subLens[i]).val[0];
	}
	int W = cvRound(sumW / TYPE_NUM);

	for (int i = 0; i < TYPE_NUM; i++) {
		finImgs.push_back(ArrangeImgs(subImgs[i], subLens[i], W, H, toRow));
		finLens.push_back(min(W, H));
	}

	H = H * TYPE_NUM + (TYPE_NUM - 1) * space;
	return ArrangeImgs(finImgs, finLens, W, H, !toRow);
}

Mat CmIluImgs::ArrangeImgs(vecM &imgs, vecD &len, int W, int H, bool toRow)
{
	int imgN = (int)(imgs.size()), s = 0;
	CV_Assert(len.size() == imgN);
	double ratio, sumL = 0, err = 0;
	for (int i = 0; i < imgN; i++)
		sumL += len[i]; 

	ratio = ((toRow ? W : H) - (imgN - 1) * space) / sumL;
	Mat dstImg(H, W, CV_8UC3);
	dstImg = Scalar(255, 255, 255);
	for (int i = 0; i < imgN; i++)	{
		len[i] *= ratio;
		int l = cvRound(len[i] + err);
		Rect reg = toRow ? Rect(s, 0, l, H) : Rect(0, s, W, l);
		resize(imgs[i], dstImg(reg), reg.size());
		err = len[i] + err - l;
		s += l + space;
	}
	CV_Assert(s - space == (toRow ? dstImg.cols : dstImg.rows));
	return dstImg;
}

void CmIluImgs::Imgs(const ImgsOptions &opts, int maxImgNum)
{
	vecS names;
	CmFile::MkDir(opts._outDir);
	int imgNum = CmFile::GetNamesNE(opts._inDir + "*" + opts._exts[0], names);
	FILE *f = fopen(_S(opts._texName), "w");
	CV_Assert(f != NULL);

	//* Sort image names in order
	vector<pair<int, string>> costIdx(imgNum);
	for (int i = 0; i < imgNum; i++)
		costIdx[i] = make_pair(atoi(_S(names[i])), names[i]);
	sort(costIdx.begin(), costIdx.end());
	for (int i = 0; i < imgNum; i++)
		names[i] = costIdx[i].second;
	//*/
	imgNum = min(imgNum, maxImgNum);

	vecI heights(imgNum);
	for (int i = 0; i < imgNum; i++){
		Mat img = imread(opts._inDir + names[i] + opts._exts[0]);
		heights[i] = (img.rows * opts._w + img.cols/2) / img.cols;
	}

	vecS subNames;
	vecI subHeights;
	int height = -space;
	for (int i = 0; i < imgNum; i++) {
		height += heights[i] + space;
		subNames.push_back(names[i]);
		subHeights.push_back(heights[i]);
		if (height > opts._H){
			height = 0;
			WriteFigure(subNames, f, subHeights, opts);
			subNames.clear();
			subHeights.clear();
		}
	}
	WriteFigure(subNames, f, subHeights, opts);
	fclose(f);
	printf("%70s\r", "");
}

void CmIluImgs::WriteFigure(const vecS &names, FILE *f, const vecI &sHeights, const ImgsOptions &opts)
{
	static int idx = -1;
	printf("Output %dth big image\n", ++idx);
	{//* Produce a big figure
		Size sz(opts._w * opts._exts.size() + space * (opts._exts.size() - 1), 40 - space);
		for (size_t i = 0; i < names.size(); i++)
			sz.height += space + sHeights[i];
		Mat bImg(sz, CV_8UC3);
		memset(bImg.data, -1, bImg.step * sz.height);
		Rect reg = Rect(0, 0, opts._w, 0);
		for (size_t i = 0; i < names.size(); i++) {
			reg.x = 0;
			reg.height = sHeights[i];
			for (size_t j = 0; j < opts._exts.size(); j++) {
				Mat subImg = bImg(reg);
				Mat crntImg = imread(opts._inDir + names[i] + opts._exts[j]);
				if (crntImg.data != NULL)
					resize(crntImg, subImg, subImg.size(), INTER_AREA);
				reg.x += space + opts._w;
			}
			reg.y += space + sHeights[i];
		}
		imwrite(opts._outDir + format("%d.jpg", idx), bImg);
	}//*/

	fprintf(f, "\\begin{figure*}[t!]\n\t\\centering\n");
	fprintf(f, "\t\\begin{overpic}[width=\\textwidth]{%d.jpg} \n", idx); // \\footnotesize
	fprintf(f, "\t\\PutDes\n\t\\end{overpic}\n");  
	fprintf(f, "\t\\PutCap\n\\end{figure*}\n\\clearpage\n\n"); // \\clearpage
}

void CmIluImgs::Demo(CStr &wkDir, int height)
{
	/* Illustration of retrieval results like http://mmcheng.net/gsal/
	CStr typeN = CmFile::GetNameNE(wkDir.substr(0, wkDir.size() - 1));
	//CStr srcNames = string("Src/%d") + typeN + "_*.jpg";
	CStr srcNames = string("Src/%.3d") + ".jpg";
	const int TYPE_NUM = 3;
	vector<vecM> subImgs(TYPE_NUM);
	subImgs[1].push_back(imread(wkDir + "Sketch.jpg"));
	const char* nameW[TYPE_NUM] = {_S(srcNames), "Sort1/%.3dSr*.*", "Sort1/%.3dSHOG*.jpg"};
	Mat showRes = CmIluImgs::Retreival(wkDir, subImgs, nameW, 200, height); 
	imwrite(wkDir + typeN + ".jpg", showRes); //*/

	/* For illustration of results as demonstrated in: http://mmcheng.net/mftp/SalObj/SaliencyMapsAll.pdf
	const char* _exts[] = {".jpg", "_S0.png", "_S1DR.png", "_S2DR.png", "_AC2.png", "_G.png"};
	vecS exts = charPointers2StrVec(_exts);
	CmIllustr::ImgsOptions opts(wkDir, exts);
	CmIllustr::Imgs(opts, 200); //*/

	
	//* For illustration of customized things
	CStr dstDir = wkDir + "../";	//CmFile::MkDir(dstDir);
	const int TYPE_NUM = 2;
	vector<vecM> subImgs(TYPE_NUM);
	const char* nameW[TYPE_NUM] = {"B*_*.??g", "W*_*.??g"};
	Mat showRes = Imgs(wkDir, subImgs, nameW, 200); 
	CStr dstName = wkDir.substr(0, wkDir.size() - 1) + ".jpg";
	imwrite(dstName, showRes); //*/
}




void CheckSalMaps(CStr rootDir, vecS dbNames, vecS methodNames)
{
	ofstream file;
	file.open("text.txt", std::ofstream::out | std::ofstream::ate);

	for (int i = 0; i < dbNames.size(); i++){
		string wkDir = rootDir + dbNames[i] + "/";
		string imgNameW = wkDir + "Imgs/*.jpg";
		string salDir = wkDir + "Saliency/";
		string cutDir = wkDir + "SalCut/";
		vecS namesNE;
		int imgNum = CmFile::GetNamesNE(imgNameW, namesNE);
		printf("WkDir = %s. Checking saliency maps ... \n", _S(wkDir));
#pragma omp parallel for
		for (int f = 0; f < imgNum; f++){
			Mat img3u = imread(wkDir + "Imgs/" + namesNE[f] + ".jpg");
			for (int j = 0; j < methodNames.size(); j++)	{
				CStr salFileName = namesNE[f] + format("_%s", _S(methodNames[j]));
				Mat sal1u = imread(salDir + salFileName + ".png", CV_LOAD_IMAGE_GRAYSCALE);
				Mat scCut1u = imread(cutDir + salFileName + "_SC.png", CV_LOAD_IMAGE_GRAYSCALE);
				Mat ftCut1u = imread(cutDir + salFileName + "_FT.png", CV_LOAD_IMAGE_GRAYSCALE);
				if (sal1u.empty() || scCut1u.empty() || ftCut1u.empty()){
					printf("Can't load the saliency map: %s\n", _S(salFileName));
					file << _S(salFileName) << endl;
					continue;
				}
				if ((sal1u.size != img3u.size) || (scCut1u.size != img3u.size) || (ftCut1u.size != img3u.size)){
					printf("Image Size mismatch for %s: %dx%d vs. %dx%d\n", _S(salFileName), img3u.rows, img3u.cols, sal1u.rows, sal1u.cols);
					//resize(sal1u, sal1u, img3u.size());
					//imwrite(salDir + salFileName, sal1u);
				}
			}
		}
	}

	file.close();
}

void SalSegmentation(CStr imgNameW, CStr salDir, CStr cutDir, vecS methodName)
{
	string imgDir, imgExt;
	CmFile::MkDir(cutDir);
	vecS namesNE;
	int imgNum = CmFile::GetNamesNE(imgNameW, namesNE, imgDir, imgExt), methodNum = (int)methodName.size();
#pragma omp parallel for
	for (int i = 0; i < imgNum; i++){
		Mat img3b = imread(imgDir + namesNE[i] + ".jpg"), idx1i;
		int regNum = MeanShiftEdison(img3b, idx1i, 7, 10, 20);
		for (int m = 0; m < methodNum; m++)	{
			CStr resPathFT = cutDir + namesNE[i] + "_" + methodName[m] + "_FT.png";
			CStr resPathSC = cutDir + namesNE[i] + "_" + methodName[m] + "_SC.png";
			if (CmFile::FileExist(resPathFT) && CmFile::FileExist(resPathSC))
			{
				continue;
			}

			Mat sal1f = imread(salDir + namesNE[i] + "_" + methodName[m] + ".png", CV_LOAD_IMAGE_GRAYSCALE), salFt, ftSeg;
			if (sal1f.data == NULL && sal1f.size == img3b.size)	{
				printf("Saliency file missing %s.png\n", namesNE[i] + "_" + methodName[m]);
				continue;
			}
			sal1f.convertTo(sal1f, CV_32F, 1.0 / 255);
			Mat resFT = imread(resPathFT, CV_LOAD_IMAGE_GRAYSCALE);
			if (resFT.data == NULL || resFT.size != img3b.size){
				sal1f.copyTo(salFt);
				CmSaliencyRC::SmoothByRegion(salFt, idx1i, regNum);
				double thr = 2.0 * sum(salFt).val[0] / (salFt.rows*salFt.cols);
				compare(salFt, thr, ftSeg, CV_CMP_GE);
				imwrite(resPathFT, ftSeg);
			}


			Mat resSC = imread(resPathSC, CV_LOAD_IMAGE_GRAYSCALE);
			if (resSC.data != NULL && resSC.size == img3b.size)
				continue;

			Mat img3f;
			img3b.convertTo(img3f, CV_32FC3, 1.0 / 255);

			Mat cutMat;
			float t = 0.9f;
			int maxIt = 4;
			GaussianBlur(sal1f, sal1f, Size(9, 9), 0);
			normalize(sal1f, sal1f, 0, 1, NORM_MINMAX);
			while (cutMat.empty() && maxIt--){
				cutMat = CmSalCut::CutObjs(img3f, sal1f, 0.1f, t);
				t -= 0.2f;
			}
			if (!cutMat.empty())
				imwrite(resPathSC, cutMat);
			else{
				imwrite(resPathSC, Mat::zeros(sal1f.size(), CV_8UC1));
				printf("Image(.jpg): %s\n", _S(resPathSC));
			}
		}
	}
}

void AverageMap(CStr wkDir)
{
	CStr subName = CmFile::GetSubFolder(wkDir);

	string imgDir = wkDir + "Imgs/", salDir = wkDir + "Saliency/", cutDirFT = wkDir + "SalCut/", cutDirSC = wkDir + "SalCut/";
	CmFile::MkDir(cutDirFT);
	CmFile::MkDir(cutDirSC);
	vecS namesNE;
	int imgNum = CmFile::GetNamesNE(imgDir + "*.jpg", namesNE);
	const Size SZ(100, 100);
	Mat avgMap = Mat::zeros(SZ, CV_64F), iluMap;
	for (int i = 0; i < imgNum; i++){
		Mat gtMap = imread(imgDir + namesNE[i] + ".png", CV_LOAD_IMAGE_GRAYSCALE);
		CV_Assert(gtMap.data != NULL);
		gtMap.convertTo(gtMap, CV_64F);
		resize(gtMap, gtMap, SZ);
		avgMap += gtMap;
	}
	avgMap /= imgNum;
	normalize(avgMap, avgMap, 0, 255, NORM_MINMAX);
	avgMap.convertTo(avgMap, CV_8U);
	resize(avgMap, iluMap, Size(400, 300));
	imwrite(wkDir + "AvgMap" + subName + ".jpg", iluMap);

#pragma omp parallel for
	for (int i = 0; i < imgNum; i++){
		Mat img3b = imread(imgDir + namesNE[i] + ".jpg"), avgOut;
		resize(avgMap, avgOut, img3b.size());
		imwrite(salDir + namesNE[i] + "_AVG.png", avgOut);
	}
}