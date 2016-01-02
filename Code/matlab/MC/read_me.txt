MATLAB code of Saliency detection via absorb Markov chain of ICCV 2013.

Bowen Jiang, Lihe Zhang, Huchuan Lu, Ming-Hsuan Yang and Chuan Yang
Saliency detection via absorb Markov chain 
Proc. IEEE International Conference on Computer Vision (ICCV), 2013
written by Bowen Jiang
Email: dogbowenjiang@gmail.com
Date: 02/10/2013
========================================================================
The code is run on MATLAB R2010b on Windows XP.

Run 'Saliency_Absorb_MC.m'.
======================================================================== 
 Saliency_Absorb_MC.m:   the main function

 SLIC.mex:    the mex file of the SLIC algorithm

 find_connect_superpixel_DoubleIn_Opposite.m:  obtain the neighbour relationship of the super-pixels

 Find_Edge_Superpixels.m:  obtain the indication of edge super-pixels

 normalize.m:  normalize the range of the input vector to [0, 1]
===========================================================================
Reference: 
We utilized the SLIC code of the following public implementations:
   R. Achanta, A. Shaji, K. Smith, A. Lucchi, P. Fua, and S. Susstrunk.  Slic superpixels. Technical Report, EPFL, 2010.
   ( http://ivrg.epfl.ch/research/superpixels ).
Some graph functions in the Graph Analysis are from the Toolbox ( http://eslab.bu.edu/software/graphanalysis/ ).
