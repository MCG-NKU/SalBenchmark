The source code implements the saliency computation algorithm described in published work:
R. Margolin, L. Zelnik-Manor and A. Tal. "What Makes a Patch Distinct" in CVPR 2013
This code is provided for research purposes only.
In case of a problem or a question, please contact margolin@tx.technion.ac.il.


Files:
demo.m - demo batch run
calcSaliency. - Compute saliency for a single file or iteratively for files in a directory
PCA_Saliency.m - Configures and calls the PCA_Saliency_Core.p function.
PCA_Saliency_Core.p - Actual implementation of the above mentioned algorithm.


External Files:
IM2COLSTEP - Taken from SmallBox: http://small-project.eu
vl_slic - Taken from VLFeat open source library: http://www.vlfeat.org/index.html