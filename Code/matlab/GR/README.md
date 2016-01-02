The code is for paper "Graph-regularized Saliency Detection with Convex-hull-based Center Prior" by Chuan Yang, Lihe Zhang, and Huchuan Lu
written by Chuan Yang
Email: ycscience86@gmail.com
******************************************************************************
The code is tested on Windows XP with MATLAB R2010b.
******************************************************************************
Usage:
>put the test images into file '\test'
>run 'demo.m'
******************************************************************************

We use the SLIC superpixel software to generate superpixels (http://ivrg.epfl.ch/supplementary_material/RK_SLICSuperpixels/index.html)
and some graph functions in the Graph Analysis Toolbox (http://eslab.bu.edu/software/graphanalysis/).

Thanks to J. van de Weijer, Th. Gevers, J-M Geusebroek "Boosting Color Saliency in Image Feature Detection" (PAMI06), for providing the salient points detector.

******************************************************************************
Note: the running time of the superpixel generation is computed by using the SLIC Windows GUI based executable.

