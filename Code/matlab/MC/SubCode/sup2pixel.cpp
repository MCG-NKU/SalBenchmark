#include "mex.h"
using namespace std;


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	if (nrhs!=3) mexErrMsgTxt("error :the input number error");

	 double *  pixnum = (double* )mxGetPr(prhs[0]);
	 double *  label  = (double* )mxGetPr(prhs[1]);
	 double *  sup    = (double* )mxGetPr(prhs[2]);

	int pixelN = int( pixnum[0] );
 	plhs[0] = mxCreateDoubleMatrix( pixelN, 1, mxREAL );
	double * outlabel=(double *)mxGetPr(plhs[0]);

	for ( int j = 0; j < pixelN; j++ ){

		outlabel[j] = sup[ int( label[j] ) ];

	}
}