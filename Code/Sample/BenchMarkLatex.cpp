#include "stdafx.h"
#include "BenchMarkLatex.h"
#include "CmIluImgs.h"

BenchMarkLatex::BenchMarkLatex(const vecS &dbNames, const vecS &methodNames)
	: _dbNames(dbNames)
	, _methodNames(methodNames)
{
	_numDb = dbNames.size();	
	_numMethod = methodNames.size();
}

double BenchMarkLatex::avergeFMeare(CMat &gtMask, CMat &map1u)
{
	int count = 0;
	double fMeasure = 0;
	for (int i = 0; i <= 255; i += 5) {// Jump threshold for speed
		Mat mapMask;
		compare(map1u, i, mapMask, CMP_GE);
		fMeasure += CmEvaluation::FMeasure(mapMask, gtMask);
		count ++;
	}
	return fMeasure / count;
}

void BenchMarkLatex::bestWostCases(CStr &rootDir, const vecS &dbNames, CStr &outDirRoot)
{
	const int NUM_M = 2;
	const char* methodNames[NUM_M] = {"DRFI", "MC"};
	for (int d = 0; d < dbNames.size(); d++){
		CStr inDir = rootDir + dbNames[d] + "/";
		vecS namesNE;
		CmValStructVec<double, string> scoreNames[NUM_M];
		int imgNum = CmFile::GetNamesNE(inDir + "Imgs/*.png", namesNE);
		for (int m = 0; m < NUM_M; m++)	
			scoreNames[m].reserve(imgNum);

#pragma omp parallel for
		for (int i = 0; i < imgNum; i++){ // For each image
			Mat gtMap = imread(inDir + "Imgs/" + namesNE[i] + ".png", CV_LOAD_IMAGE_GRAYSCALE);
			for (int m = 0; m < NUM_M; m++)	{ // For each method
				Mat salMap = imread(inDir + "Saliency/" + namesNE[i] + "_" + methodNames[m] + ".png", CV_LOAD_IMAGE_GRAYSCALE), dif1f;
				normalize(salMap, salMap, 0, 255, CV_MINMAX);
				double score = avergeFMeare(salMap, gtMap);  
				scoreNames[m].pushBack(score, namesNE[i]);
			}
		}
		
		for (int m = 0; m < NUM_M; m++)	{
			CStr outDir = outDirRoot + dbNames[d] + "_" + methodNames[m] + "/";
			CmFile::MkDir(outDir);
			CmFile::CleanFolder(outDir);
			scoreNames[m].sort(true); // Worst first
			for (int i = 0; i < 3; i++) {//
				copySampleWithGt(inDir, scoreNames[m][i], methodNames[m], outDir + format("B%d_", i));
				int idx = imgNum - 1 - i;
				copySampleWithGt(inDir, scoreNames[m][idx], methodNames[m], outDir + format("W%d_", i));
			}

			CmIluImgs::Demo(outDir);
		}
	}
}

void SetBorder2Zero(Mat &mat, int bW, int bH)
{
	mat.rowRange(0, bH).setTo(0);
	mat.rowRange(mat.rows - bH, mat.rows).setTo(0);
	mat.colRange(0, bW).setTo(0);
	mat.colRange(mat.cols - bW, mat.cols).setTo(0);
}


void BenchMarkLatex::copySampleWithGt(CStr sampleDir, CStr imgNameNE, CStr mName, CStr dstDir)
{
	if (imgNameNE == "yokohm060409_dyjsn266")
		int a = 0;

	Mat gt = CmFile::LoadMask(sampleDir + "Imgs/" + imgNameNE + ".png"), largerGt;
	Mat img = imread(sampleDir + "Imgs/" + imgNameNE + ".jpg"); // C:\WkDir\Saliency\SED2\Saliency\00000155_DRFI.png
	Mat sal = imread(sampleDir + "Saliency/" + imgNameNE + "_" + mName + ".png", CV_LOAD_IMAGE_GRAYSCALE);
	SetBorder2Zero(gt, 5, 5);
	dilate(gt, largerGt, Mat(), Point(-1, -1), 5);
	bitwise_xor(gt, largerGt, largerGt);
	img.setTo(Scalar(0, 0, 255), largerGt);
	imwrite(dstDir + imgNameNE + ".jpg", img);
	imwrite(dstDir + imgNameNE + ".png", sal);
}


void BenchMarkLatex::ProduceTable(CStr dataFileDir, CStr outDir)
{
	CmFile::MkDir(outDir);
	Mat mae1d(_numMethod, _numDb, CV_64F), auc1d(_numMethod, _numDb, CV_64F);
	Mat meanF1d(_numMethod, _numDb, CV_64F), maxF1d(_numMethod, _numDb, CV_64F);
	Mat cutAdp1d(_numMethod, _numDb, CV_64F), cutSC1d(_numMethod, _numDb, CV_64F);

	for (int i = 0; i < _numDb; i++){
		CStr inName = _dbNames[i] + "PrRocAuc.m", outDataF = outDir + inName;
		CmFile::Copy2Dir(dataFileDir + _dbNames[i] + "/" + inName, outDir);
		CV_Assert(CmFile::FilesExist(outDataF));
		
		Mat(readVectorFromMatlabeFile(outDataF, "MAE")).copyTo(mae1d.col(i)); // MAE
		Mat(readVectorFromMatlabeFile(outDataF, "AUC")).copyTo(auc1d.col(i)); // AUC
		Mat(readVectorFromMatlabeFile(outDataF, "MeanFMeasure")).copyTo(meanF1d.col(i)); // MeanFMeasure
		Mat(readVectorFromMatlabeFile(outDataF, "MaxFMeasure")).copyTo(maxF1d.col(i)); // MaxFMeasure
		Mat(readVectorFromMatlabeFile(outDataF, "FMeasureMaskFT")).copyTo(cutAdp1d.col(i)); // Adaptive threshold
		Mat(readVectorFromMatlabeFile(outDataF, "FMeasureMaskSC")).copyTo(cutSC1d.col(i)); // Saliency Cut
	}
	printMat(mae1d, outDir + "MAE.tex", false);
	printMat(auc1d, outDir + "AUC.tex", true);
	printMat(meanF1d, outDir + "MeanF.tex", true);
	printMat(maxF1d, outDir + "MaxF.tex", true);
	printMat(cutAdp1d, outDir + "CutAdp.tex", false);
	printMat(cutSC1d, outDir + "SalCut.tex", true);


		Mat chals[3] = {maxF1d, cutAdp1d, cutSC1d};
	 	Mat mergedTabel3d;
	 	merge(chals, 3, mergedTabel3d);
	 	printMat(mergedTabel3d, outDir + "FixAdpSc.tex", true);
	 	saveData2Csv(mergedTabel3d, outDir + "FixAdpSc.csv", _methodNames);
	 
	 	chals[0] = auc1d; chals[1] = mae1d;
	 	Mat mergedTabel2d;
	 	merge(chals, 2, mergedTabel2d);
	 	saveData2Csv(mergedTabel2d, outDir + "AucMae.csv", _methodNames);//
	 
	 
	 	// Print table for a specific dataset
	 	const int NUM_ROW = 3; // Number of rows in the table
	 	Mat dataArray[NUM_ROW] = { maxF1d, auc1d, mae1d }; //, meanF1d, cutAdp1d, cutSC1d};
	 	const char* rowDes[NUM_ROW] = {"Max", "AUC", "MAE"}; //, "Mean", "AdpT", "SCut"};
	 	bool decentOrder[NUM_ROW] = { true, true, false };
		for (int i = 0; i < _numDb; i++){
			Mat dbTable(_numMethod, NUM_ROW, CV_64F);
			for (int j = 0; j < NUM_ROW; j++)
				dataArray[j].col(i).copyTo(dbTable.col(j));
			printMatTransport(dbTable.t(), outDir + "MaxAdpScT" + _dbNames[i] + ".tex", rowDes, decentOrder);
		}
	 	
	 	printModelRanking(outDir + "MaxFRnk", meanF1d, maxF1d, cutAdp1d, cutSC1d, auc1d, mae1d);


	CmFile::Copy2Dir("xticklabel_rotate.m", outDir);
	CmFile::Copy2Dir("Results.tex", outDir);
}

void BenchMarkLatex::printModelRanking(CStr outName, CMat &meanF1d, CMat &maxF1d, CMat &cutAdp1d, CMat &cutSC1d, CMat &auc1d, CMat &mae1d)
{
	CV_Assert(meanF1d.size == cutAdp1d.size && cutAdp1d.size == cutSC1d.size);
	CV_Assert(meanF1d.size() == Size(_numDb, _numMethod));
	Mat RnkMean1i = getRankIdx(meanF1d), RnkAdp1i = getRankIdx(cutAdp1d), RnkSc1i = getRankIdx(cutSC1d);
	Mat RnkMax1i = getRankIdx(maxF1d), RnkAuc1i = getRankIdx(auc1d), RnkMae1i = getRankIdx(mae1d, false);
	const int NUM_ROW = 5; // Number of rows in the table
	const char* rowDes[NUM_ROW] = { "Max", "AUC", "MAE", "AdpT", "SCut" };
	bool decentOrder[NUM_ROW];
	memset(decentOrder, 0, sizeof(bool) * NUM_ROW);
	Mat dbTable = Mat::zeros(NUM_ROW, _numMethod, CV_64F);

	for (int m = 0; m < _numMethod; m++){
		for (int d = 0; d < _numDb; d++) {
			dbTable.at<double>(0, m) += RnkMax1i.at<int>(m, d) + 1;
			dbTable.at<double>(1, m) += RnkAuc1i.at<int>(m, d) + 1;
			dbTable.at<double>(2, m) += RnkMae1i.at<int>(m, d) + 1;
			dbTable.at<double>(3, m) += RnkAdp1i.at<int>(m, d) + 1;
			dbTable.at<double>(4, m) += RnkSc1i.at<int>(m, d) + 1;			
		}
	}
	printMatTransport(dbTable, outName + "D.tex", rowDes, decentOrder);

	Mat rnkDb = getRankIdx(dbTable.t(), false).t() + 1;
	printMatTransport(rnkDb, outName + ".tex", rowDes, decentOrder);
}

void BenchMarkLatex::produceSupperPixels(CStr &rootDir)
{
	for (int d = 0; d < _numDb; d++){
		string imgDir = rootDir + _dbNames[d] + "/Imgs/";
		printf("Processing %s\n", _S(imgDir));
		vecS namesNE;
		int imgNum = CmFile::GetNamesNE(imgDir + "*.jpg", namesNE);
#pragma omp parallel for
		for (int i = 0; i < imgNum; i++) {
			if (CmFile::FileExist(imgDir + namesNE[i] + "_Seg.png"))
				continue;
			Mat img3u = imread(imgDir + namesNE[i] + ".jpg"), img3f, idx1i, color3u;
			img3u.convertTo(img3f, CV_32F, 1.0 / 255);
			cvtColor(img3f, img3f, CV_BGR2Lab);
			SegmentImage(img3f, idx1i, 0.8, 50, 100);
			CmIllu::label2Rgb<int>(idx1i, color3u);
			imwrite(imgDir + namesNE[i] + "_Seg.png", color3u);			
		}
	}

}

int intMatMax(CMat idx1i)
{
	int maxV = -INT_MAX;
	for (int r = 0; r < idx1i.rows; r++){
		const int *idx = idx1i.ptr<int>(r);
		for (int c = 0; c < idx1i.cols; c++)
			maxV = max(idx[c], maxV);
	}
	return maxV;
}

//void BenchMarkLatex::analysisDataset(CStr &rootDir, CStr &outStatisticDir)
//{
//	static const int CN = 7; // Color Number 
//	static const char* c[CN * 3] = { "'k'", "'b'", "'g'", "'r'", "'c'", "'m'", "'y'", "'--k'", "'--b'", "'--g'", "'--r'", "'--c'", "'--m'", "'--y'", "':k'", "':b'", "':g'", "':r'", "':c'", "':m'", "':y'" };
//
//	CmFile::MkDir(outStatisticDir);
//	string outName = outStatisticDir + "DbStatistics.m", legendStr = "legend(";
//	CmFile::WriteNullFile(outName);
//	const double regNumberLogScale = 0.2;
//	CmFile::AppendStr(outName, "clear;\nclose all;\nclc;\nfigure(1);\nhold on; \nSmoothD = 3;%% 3: smoothing, 2 not smoothing");
//	CmFile::AppendStr(outName, format("\nRegNumLogScale = %g;\n", regNumberLogScale));
//	const double halfDialog = 1.0 / (0.5 * sqrt(2.0));
//	//produceSupperPixels(rootDir);
//		
//	for (int d = 0; d < _numDb; d++){
//		string imgDir = rootDir + _dbNames[d] + "/Imgs/";
//		printf("Processing %s\n", _S(imgDir));
//		vecS namesNE;
//		int imgNum = CmFile::GetNamesNE(imgDir + "*.jpg", namesNE);
//
//
//		// Segment images in imgDir
//#pragma omp parallel for
//		for (int i = 0; i < imgNum; i++){
// 			if (CmFile::FileExist(imgDir + namesNE[i] + "_Seg.png"))
// 				continue;
//			Mat srcImg = imread(imgDir + namesNE[i] + ".jpg"), seg1i, seg3u, src3f;
//			srcImg.convertTo(src3f, CV_32FC3);
//			SegmentImage(src3f, seg1i, 0.5, 200, 50);
//			CmIllu::label2Rgb<int>(seg1i, seg3u);
//			imwrite(imgDir + namesNE[i] + "_Seg.png", seg3u);
//		}
//
//		vecD centerDistImg(imgNum);
//		vecD objSizeImg(imgNum); // -1 if ground truth is empty
//		vecD regNumImgAll(imgNum), regNumImgSal(imgNum), regNumImgBack(imgNum);
//
//#pragma omp parallel for
//		for (int i = 0; i < imgNum; i++) {
//			//*
//			Mat gtObj1u = CmFile::LoadMask(imgDir + namesNE[i] + ".png");
//			Mat gtMap = CmCv::GetNZRegionsLS(gtObj1u, 0); // Most salient object
//			Point2d centroid;
//			int count = 0;
//			for (int r = 0; r < gtMap.rows; r++) {
//				const byte* val = gtMap.ptr<byte>(r);
//				for (int c = 0; c < gtMap.cols; c++)
//					if (val[c])
//						centroid += Point2d(c, r), count++;
//			}
//			centroid /= (count*1.0) + EPS;
//			centroid.x /= gtMap.cols;
//			centroid.y /= gtMap.rows;
//			centerDistImg[i] = pntDist(centroid, Point2d(0.5, 0.5)) * halfDialog; // Over half image dialog
//			objSizeImg[i] = sum(gtMap).val[0] / (255.0 * gtMap.rows * gtMap.cols);
//			objSizeImg[i] = objSizeImg[i] == 1.0 ? 0.99999 : objSizeImg[i];//*/
//
//			Mat seg3u = imread(imgDir + namesNE[i] + "_Seg.png");
//			Mat gtMap1u = imread(imgDir + namesNE[i] + ".png", CV_LOAD_IMAGE_GRAYSCALE);
//			Mat_<int> seg1i;
//			CmIllu::rgb2Label<int>(seg3u, seg1i);
//			int regNum = intMatMax(seg1i) + 1;
//			regNumImgAll[i] = regNum;
//			vecD regSalPixels(regNum), regAllPixels(regNum);
//			CV_Assert(seg1i.size == gtMap1u.size);
//			for (int r = 0; r < seg1i.rows; r++) { 
//				const int *idx = seg1i.ptr<int>(r);
//				const byte *gt = gtMap1u.ptr<byte>(r);
//				for (int c = 0; c < seg1i.cols; c++) {
//					regAllPixels[idx[c]]++;
//					if (gt[c] > 128)
//						regSalPixels[idx[c]]++;
//				}
//			}
//			for (int r = 0; r < regNum; r++)
//				regNumImgSal[i] += regSalPixels[r] / regAllPixels[r];
//			double backVal = regNumImgAll[i] - regNumImgSal[i];
//
//			regNumImgAll[i] = max(log10(regNumImgAll[i]), 0.);
//			regNumImgSal[i] = max(log10(regNumImgSal[i]), 0.);
//			regNumImgBack[i] = max(log10(backVal), 0.);
//			//printf("All = %g, sal = %g\n", regNumImgAll[i], regNumImgSal[i]);
//			//CmShow::Label(seg1i, "Segmentation", regNum);
//			//imshow("Salient object", gtMap);
//			//waitKey(0);
//		}
//
//		// Skip ground truth with all zeros
//		int nImgNum = 0;
//		for (int i = 0; i < imgNum; i++){
//			centerDistImg[nImgNum] = centerDistImg[i];
//			objSizeImg[nImgNum] = objSizeImg[i];
//			regNumImgAll[nImgNum] = regNumImgAll[i];
//			regNumImgSal[nImgNum] = regNumImgSal[i];
//			regNumImgBack[nImgNum] = regNumImgBack[i];
//
//			if (objSizeImg[i] > 0)
//				nImgNum++;
//		}
//		imgNum = nImgNum;
//		centerDistImg.resize(imgNum);
//		objSizeImg.resize(imgNum);
//		regNumImgAll.resize(imgNum);
//		regNumImgSal.resize(imgNum);
//		regNumImgBack.resize(imgNum);
//
//		const int SAMPLE_NUM = imgNum > 500 ? 20 : 10;
//		vecD centerDistHist(SAMPLE_NUM);
//		vecD objSizeHist(SAMPLE_NUM);
//		vecD regNumAllHist(SAMPLE_NUM);
//		vecD regNumSalHist(SAMPLE_NUM);
//		vecD regNumBackhist(SAMPLE_NUM);
//		for (int i = 0; i < imgNum; i++){
//
//	//		cout << namesNE[i] << endl;
//			centerDistHist[int(centerDistImg[i] * SAMPLE_NUM)] += 1.0 / imgNum;     
//			objSizeHist[int(objSizeImg[i] * SAMPLE_NUM)] += 1.0 / imgNum;
//			
//			int regNumHistIdx = int(regNumImgAll[i] * SAMPLE_NUM * regNumberLogScale);
//			if (regNumHistIdx >= SAMPLE_NUM)
//				printf("RegionNumber log: %g, idx = %d, i = %d\n", regNumImgAll[i], regNumHistIdx, i);
//			regNumAllHist[regNumHistIdx] += 1.0 / imgNum;
//			regNumSalHist[int(regNumImgSal[i] * SAMPLE_NUM * regNumberLogScale)] += 1.0 / imgNum;
//			regNumBackhist[int(regNumImgBack[i] * SAMPLE_NUM * regNumberLogScale)] += 1.0 / imgNum;
//		}
//
//		FILE *f = fopen(_S(outName), "a");
//		fprintf(f, _S(format("\n\n%%%%%%%% %s\nxValues = %g:%g:1; \nHistBinNum = %d;\n\n", _S(_dbNames[d]), 0.5 / SAMPLE_NUM, 1.0 / SAMPLE_NUM, SAMPLE_NUM)));
//		CmEvaluation::PrintVector(f, centerDistImg, "CenterDistImg" + _dbNames[d]);
//		CmEvaluation::PrintVector(f, objSizeImg, "ObjSizeImg" + _dbNames[d]);
//		CmEvaluation::PrintVector(f, centerDistHist, "CenterDistHist" + _dbNames[d]);
//		CmEvaluation::PrintVector(f, objSizeHist, "ObjSizeHist" + _dbNames[d]);
//		CStr centerDistStr = format("CDistPnts%s", _dbNames[d]);
//		CStr ObjSizeStr = format("ObjSizePnts%s", _dbNames[d]);
//		fprintf(f, "%s = [xValues; CenterDistHist%s];\n", _S(centerDistStr), _S(_dbNames[d]));
//		fprintf(f, "%s = [xValues; ObjSizeHist%s];\n", _S(ObjSizeStr), _S(_dbNames[d]));
//		fprintf(f, "%s = spcrv(%s, SmoothD);\nplot(%s(1, :), %s(2, :)*HistBinNum/10, %s, 'linewidth', 2);\n\n%%log10(regNums)\n", _S(centerDistStr), _S(centerDistStr), _S(centerDistStr), _S(centerDistStr), c[d%CN]);
//		if (d)
//			legendStr += ", ";
//		legendStr += format("'%s'", _S(_dbNames[d]));
//
//		CmEvaluation::PrintVector(f, regNumImgAll, "RegNumImgAll" + _dbNames[d]);
//		CmEvaluation::PrintVector(f, regNumImgSal, "RegNumImgSal" + _dbNames[d]);
//		CmEvaluation::PrintVector(f, regNumAllHist, "regNumAllHist" + _dbNames[d]);
//		CmEvaluation::PrintVector(f, regNumSalHist, "regNumSalHist" + _dbNames[d]);
//		CmEvaluation::PrintVector(f, regNumBackhist, "regNumBackhist" + _dbNames[d]);
//		fprintf(f, _S(format("RegNumPntsAll%s = [xValues/RegNumLogScale; regNumAllHist%s];\n", _S(_dbNames[d]), _S(_dbNames[d]))));
//		fprintf(f, _S(format("RegNumPntsSal%s = [xValues/RegNumLogScale; regNumSalHist%s];\n", _S(_dbNames[d]), _S(_dbNames[d]))));
//		fprintf(f, _S(format("RegNumPntsBack%s = [xValues/RegNumLogScale; regNumBackhist%s];\n", _S(_dbNames[d]), _S(_dbNames[d]))));
//		fclose(f);
//	}
//
//	FILE *f = fopen(_S(outName), "a");
//	fprintf(f, _S(legendStr + ");\n\nhold off;\ngrid on;\n\n%%%% Object size plot\nfigure(2)\nhold on;\n"));
//	for (int d = 0; d < _numDb; d++)
//		fprintf(f, "ObjSizePnts%s = spcrv(ObjSizePnts%s, SmoothD);\nplot(ObjSizePnts%s(1, :), ObjSizePnts%s(2, :), %s, 'linewidth', 2);\n", _S(_dbNames[d]), _S(_dbNames[d]), _S(_dbNames[d]), _S(_dbNames[d]), c[d%CN]);
//	
//	fprintf(f, _S(legendStr + ");\n\nhold off;\ngrid on;\n\n%%%% Region number plot\nfigure(3)\n"));
//	legendStr = "legend(";
//	for (int d = 0; d < _numDb; d++){
//		fprintf(f, "RegNumPntsAll%s = spcrv(RegNumPntsAll%s, SmoothD);\nsemilogx(10.^RegNumPntsAll%s(1, :), RegNumPntsAll%s(2, :), %s, 'linewidth', 2);\n", _S(_dbNames[d]), _S(_dbNames[d]), _S(_dbNames[d]), _S(_dbNames[d]), c[d%CN]);
//		if (d)
//			legendStr += ", ";
//		else
//			fprintf(f, "hold on;\n");
//		legendStr += format("'%sAll', '%sSal', '%sBack'", _S(_dbNames[d]), _S(_dbNames[d]), _S(_dbNames[d]));
//		fprintf(f, "RegNumPntsSal%s = spcrv(RegNumPntsSal%s, SmoothD);\nsemilogx(10.^RegNumPntsSal%s(1, :), RegNumPntsSal%s(2, :), %s, 'linewidth', 2);\n", _S(_dbNames[d]), _S(_dbNames[d]), _S(_dbNames[d]), _S(_dbNames[d]), c[d%CN + CN]);
//		fprintf(f, "RegNumPntsBack%s = spcrv(RegNumPntsBack%s, SmoothD);\nsemilogx(10.^RegNumPntsBack%s(1, :), RegNumPntsBack%s(2, :), %s, 'linewidth', 2);\n", _S(_dbNames[d]), _S(_dbNames[d]), _S(_dbNames[d]), _S(_dbNames[d]), c[d%CN + 2*CN]);
//	}
//	
//	fprintf(f, _S(legendStr + ");\nhold off;\nxlim([1, 10^4]);\ngrid on;"));	
//	fclose(f);
//}

void BenchMarkLatex::saveData2Csv(CMat &_value1d, CStr csvFile, vecS &rowStart)
{
	Mat value1d = _value1d.reshape(1);
	FILE *f = fopen(_S(csvFile), "w");
	CV_Assert(f != NULL && value1d.type() == CV_64FC1);
	for (int r = 0; r < value1d.rows; r++)	{
		const double *v = value1d.ptr<double>(r);
		fprintf(f, "\n%s", _S(rowStart[r]));
		for (int c = 0; c < value1d.cols; c++)	
			fprintf(f, ", %5.3f", v[c]);
	}
	fclose(f);
}

Mat BenchMarkLatex::getRankIdx(Mat value1d, bool descendOrder /* = true */)
{
	Mat idx1i(value1d.size(), CV_32S);
	for (int c = 0; c < value1d.cols; c++){
		Mat colVal;
		value1d.col(c).copyTo(colVal);
		vecD vec = colVal;
		vecI idx;
		GetRankingIdx<double>(colVal, idx, descendOrder);
		Mat(idx).copyTo(idx1i.col(c));
	}
	//cout<<value1d<<endl<<idx1i<<endl;
	return idx1i;
}


void BenchMarkLatex::printMat(CMat &_mat1d, CStr texFile, bool descendOrder)
{
	FILE* f = fopen(_S(texFile), "w");
	if (f == NULL){
		printf("Can't open file %s\n", _S(texFile));
		return;
	}
	CV_Assert(_mat1d.rows == _numMethod);

	Mat mat1d = _mat1d.reshape(1);
	int dataWidth = mat1d.cols;
	string strAlign = "|l||";
	for (int i = 0; i < _mat1d.cols; i++){
		for (int c = 0; c < _mat1d.channels(); c++)
			strAlign += "c";
		strAlign += "|";
	}
	fprintf(f, "\\begin{tabular}{%s} \\hline\n\t\\tabTitle \\\\", _S(strAlign));
	const char* rankCommand[3] = {"\\first", "\\second", "\\third"};
	Mat rnk1i = getRankIdx(mat1d, descendOrder);
	for (int i = 0; i < _numMethod; i++){
		if (find(_subNumbers.begin(), _subNumbers.end(), i) != _subNumbers.end())
			fprintf(f, "\t\\hline \\hline\n");
		fprintf(f, "\t\\textbf{%-5s ", _S(_methodNames[i] + "}"));
		for (int j = 0; j < dataWidth; j++){
			int idx = rnk1i.at<int>(i, j);
			if (idx < 3)
				fprintf(f, "& %s{%5.3f} ", rankCommand[idx], mat1d.at<double>(i, j));
			else
				fprintf(f, "& %5.3f ", mat1d.at<double>(i, j));
		}
		fprintf(f, "\\\\\n");
	}
	fprintf(f, "\\hline\n\\end{tabular}\n");

	fclose(f);
}

void BenchMarkLatex::printMatTransport(CMat &mat1di, CStr texFile, const char* rowDes[], bool *descendOrder)
{
	FILE* f = fopen(_S(texFile), "w");
	if (f == NULL){
		printf("Can't open file %s\n", _S(texFile));
		return;
	}
	CV_Assert(mat1di.cols == _numMethod);
	const int MAX_COL = min(20, _numMethod);
	const int NUM_BLOCK = (_numMethod + MAX_COL - 1) / MAX_COL;
	string strAlign = "|l||";
	for (int i = 0; i < MAX_COL; i++)
		strAlign += "c|";	
	const char* rankCommand[3] = {"\\first", "\\second", "\\third"};

	Mat mat1d = mat1di.t();
	mat1d.convertTo(mat1d, CV_64F);
	Mat rnk1i = getRankIdx(mat1d, true).t();
	Mat rnkInv = getRankIdx(mat1d, false).t(); 
	for (int i = 0; i < mat1di.rows; i++)
		if (!descendOrder[i])	
			rnkInv.row(i).copyTo(rnk1i.row(i)); // Revert ordering for row i
	for (int b = 0; b < NUM_BLOCK; b++){
		fprintf(f, "\\begin{tabular}{%s} \\hline\n\tMethod ", _S(strAlign));
		for (int i = 0; i < MAX_COL; i++){
			int colIdx = i + b * MAX_COL;
			fprintf(f, "& %4s", colIdx < _numMethod ?  _S(_methodNames[colIdx]) : "");
		}
		fprintf(f, "\\\\\\hline\n");
		for (int i = 0; i < mat1di.rows; i++){
			fprintf(f, "\t%-5s ", rowDes[i]);
			for (int j = 0; j < MAX_COL; j++){
				int colIdx = j + b * MAX_COL;
				if (colIdx >= _numMethod){
					fprintf(f, "&      ");
					continue;
				}
				int idx = rnk1i.at<int>(i, colIdx);
				if (mat1di.type() == CV_32S){
					if (idx < 3)
						fprintf(f, "& %s{%d} ", rankCommand[idx], mat1di.at<int>(i, colIdx));
					else
						fprintf(f, "& %d ", mat1di.at<int>(i, colIdx));
				}
				else{// CV_64F
					if (idx < 3)
						fprintf(f, "& %s{%5.3f} ", rankCommand[idx], mat1di.at<double>(i, colIdx));
					else
						fprintf(f, "& %5.3f ", mat1di.at<double>(i, colIdx));
				}
			}
			fprintf(f, "\\\\\n");
		}
		fprintf(f, "\\hline\n\\end{tabular}\n");
	}
	fclose(f);
}

vecD BenchMarkLatex::readVectorFromMatlabeFile(CStr &fileName, CStr &vecName)
{
	ifstream fin(fileName);
	CV_Assert(fin.is_open());
	string lineStr, token = vecName + " = [";
	while (getline(fin, lineStr))
		if (strncmp(_S(lineStr), _S(token), token.size() - 1) == 0)
			break;

	CV_Assert_(lineStr.size(), ("Can't load vector '%s' from: %s\n", _S(vecName), _S(fileName)));
	lineStr = lineStr.substr(token.size());
	istringstream sIn(lineStr);
	vecD scores;
	double s;
	while (sIn>>s)
		scores.push_back(s);
	return scores;
}