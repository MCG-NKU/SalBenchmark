#pragma once

/************************************************************************/
/* Automatically generated benchmark latex for the huge tables			*/
/************************************************************************/

class BenchMarkLatex
{
public:
	BenchMarkLatex(const vecS &dbNames, const vecS &methodNames);
	void ProduceTable(CStr dataFileDir, CStr outTexFileDir);
//	void analysisDataset(CStr &rootDir, CStr &outStatisticDir);
	void produceSupperPixels(CStr &rootDir);

	void bestWostCases(CStr &rootDir, const vecS &dbNames, CStr &outDir);


	static double avergeFMeare(CMat &gtMask, CMat &map1u);

private:
	vecS _dbNames, _methodNames;
	int _numMethod, _numDb;
	
	vecI _subNumbers; // Number of method in each sub categories

	static vecD readVectorFromMatlabeFile(CStr &fileName, CStr &vecName);

	// Return a same int matrix, with each value is the ranking index of that value in the column.
	static Mat getRankIdx(Mat value1d, bool descendOrder = true);

	static void saveData2Csv(CMat &value1d, CStr csvFile, vecS &rowStart);

	void printMat(CMat &mat1d, CStr texFile, bool descendOrder = true);

	void printMatTransport(CMat &mat1di, CStr texFile, const char* rowDes[], bool *descendOrder);

	void copySampleWithGt(CStr sampleDir, CStr imgNameNE, CStr mName, CStr dstDir);

	void printModelRanking(CStr outName, CMat &meanF1d, CMat &maxF1d, CMat &cutAdp1d, CMat &cutSC1d, CMat &auc1d, CMat &mae1d);
};

