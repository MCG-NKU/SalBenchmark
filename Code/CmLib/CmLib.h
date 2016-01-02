#pragma once
#pragma warning(disable: 4996)
#pragma warning(disable: 4995)
#pragma warning(disable: 4805)
#pragma warning(disable: 4267)


#include <assert.h>
#include <string>
#include <xstring>
#include <map>
#include <vector>
#include <functional>
#include <algorithm>
#include <iostream>
#include <exception>
#include <cmath>
#include <time.h>
#include <set>
#include <queue>
#include <list>
#include <limits>
#include <fstream>
#include <sstream>
#include <random>
#include <atlstr.h>
#include <atltypes.h>
#include <omp.h>
#include <strstream>
using namespace std;


#ifdef _DEBUG
#define lnkLIB(name) name "d"
#else
#define lnkLIB(name) name
#endif


#include <opencv2/opencv.hpp> 
#define CV_VERSION_ID CVAUX_STR(CV_MAJOR_VERSION) CVAUX_STR(CV_MINOR_VERSION) CVAUX_STR(CV_SUBMINOR_VERSION)
#define cvLIB(name) lnkLIB("opencv_" name CV_VERSION_ID)
#pragma comment( lib, cvLIB("core"))
#pragma comment( lib, cvLIB("imgproc"))
#pragma comment( lib, cvLIB("highgui"))

#if CV_MAJOR_VERSION == 3
#pragma comment(lib,  cvLIB("imgcodecs")) //the opencv3.0 need it
#endif

#if CV_MAJOR_VERSION == 2
#pragma comment(lib, cvLIB("contrib"))
#endif
using namespace cv;


// CmLib Basic coding help
#include "./Basic/CmDefinition.h"
#include "./Basic/CmTimer.h"
#include "./Basic/CmFile.h"
#include "./Basic/CmCv.h"

// For illustration
#include "./Illustration/CmShow.h"
//#include "./Illustration/CmIllustr.h"
#include "./Illustration/CmEvaluation.h"
#include "./Illustration/CmIllu.h"


// Other algorithms
#include "./OtherAlg/CmCurveEx.h"
#include "./OtherAlg/CmValStructVec.h"


//////Segmentation algorithms
#include "./Segmentation/PlanarCut/code/CutPlanar.h" // For Planar Cut
#include "./Segmentation/PlanarCut/code/CutGrid.h"
#include "./Segmentation/PlanarCut/code/CutShape.h"
#include "./Segmentation/Maxflow/graph.h"
#include "./Segmentation/EfficientGraphBased/segment-image.h"
#include "./Segmentation/MeanShift/msImageProcessor.h"


// Clustering algorithms
#include "./Cluster/CmAPCluster.h"
#include "./Cluster/CmColorQua.h"
#include "./Cluster/CmGMM.h"


// Saliency detection algorithms
#include "./Saliency/CmSaliencyRC.h"
#include "./Saliency/CmSaliencyGC.h"
#include "./Saliency/CmSalCut.h"

// CRFs
#include "./CRF/fastmath.h"
#include "./CRF/permutohedral.h"


#define ToDo printf("To be implemented, %d:%s\n", __LINE__, __FILE__)

extern bool dbgStop;
#define DBG_POINT if (dbgStop) printf("%d:%s\n", __LINE__, __FILE__);


