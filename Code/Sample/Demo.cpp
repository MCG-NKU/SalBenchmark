// Sample.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include "BenchMarkLatex.h"
#include "CmIluImgs.h"


int _tmain(int argc, _TCHAR* argv[])
{
	string rootDir = "../../Data/";

//  Set cpu thread numbers.
//	CmFile::SegOmpThrdNum(0.8); 

// "AC", "FT", "GC", "HC", "RC", "GMR", "GU", "MSS"  is exe.
// "PCA", "SWD" is Matlab Code, you can run them in  "./Code/matlab/RunAll.m"
	const char* _methodNames[] = {
		"FT", "GC", "HC", "RC", "GMR", "GU", "MSS", "PCA", "SWD"
	};
//	const char* _exeNames[] = { "AC", "FT", "GC", "HC", "RC", "GMR", "GU", "MSS" }; 
//	"AC", be caution with AC, which might results in many pop up windows , 
//	if you want to try, you can put it into _exeNames[].
	const char* _exeNames[] = { "FT", "GC", "HC", "RC", "GMR", "GU", "MSS" };
	const char* _dbNames[] = { "DataSet1", "DataSet2" }; 

	vecS dbNames = charPointers2StrVec(_dbNames);
	vecS exeNames = charPointers2StrVec(_exeNames);
	vecS methodNames = charPointers2StrVec(_methodNames);

	//Set label name.
	string strLabel = format("\n\n\nbar([FMeasureMaskFT; FMeasureMaskSC]');\ngrid on;\naxis([0 %d 0 1]);\nmethodLabels = {'%s'", methodNames.size() + 1, _S(methodNames[0]));
	for (int i = 1; i < methodNames.size(); i++)
		strLabel += format(", '%s'", _S(methodNames[i]));
	strLabel += format("};\nlegend('CutFT', 'CutSC');\nxticklabel_rotate([1:%d],90, methodLabels,'interpreter','none');\ntitle('FMeasure');\n\n", methodNames.size());

	for (int i = 0; i < dbNames.size(); i++){
		string wkDir = rootDir + dbNames[i] + "/";
		string imgNameW = wkDir + "/Imgs/*.jpg", gtImgW = wkDir + "/Imgs/*.png";
		string resultFileName = wkDir + dbNames[i] + "PrRocAuc.m";
		string salDir = wkDir + "/Saliency/", cutDir = wkDir + "SalCut/";
		if (!CmFile::FolderExist(salDir)){
			CmFile::MkDir(salDir);	
			CmFile::MkDir(cutDir);
		}
		printf("Processing dataset: %s\n", _S(dbNames[i]));
		vecS namesNE;
		int imgNum = CmFile::GetNamesNE(imgNameW, namesNE);
		for (int j = 0; j < exeNames.size(); j++)	{
			CmTimer tm("Timer " + exeNames[j]);
			tm.Start();
			CStr exeName = "..\\Executable\\" + exeNames[j] + "/Get" + exeNames[j] + ".exe";
			CmFile::RunProgram(exeName, getExeParameters(exeNames[j], wkDir), true, false);
			tm.Stop();
			printf("Speed %s: %g seconds = %g fps\n", _S(exeNames[j]), tm.TimeInSeconds() / imgNum, imgNum / tm.TimeInSeconds());
		}
		//Produce Saliency Cut Map.
		SalSegmentation(imgNameW, salDir, cutDir, methodNames);
		printf("Evaluating saliency maps in ./Saliency/\n");
		AverageMap(wkDir);
		CmEvaluation::Evaluate(gtImgW, salDir, resultFileName, methodNames);
		CmFile::AppendStr(resultFileName, "\n\n\nfigure(5);\n");
		CmEvaluation::EvalueMask(gtImgW, cutDir, methodNames, resultFileName, 0.3, true, "FT");
		CmEvaluation::EvalueMask(gtImgW, cutDir, methodNames, resultFileName, 0.3, true, "SC");
		CmFile::AppendStr(resultFileName, strLabel);
		CmEvaluation::MeanAbsoluteError(wkDir + "Imgs/", salDir, methodNames, true);
	}

	BenchMarkLatex bmLatex(dbNames, methodNames);
	CStr outStatisticDir = "../../Results/";
	bmLatex.ProduceTable(rootDir, outStatisticDir); 
	return 0;
} 

