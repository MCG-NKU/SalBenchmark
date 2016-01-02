
The source code implements the saliency detection algorithm described in the published work [1]. 
This code is the preliminary version. We appreciate any comments/suggestions. 
Questions regarding the code can be directed to Xiaohui Li at lxh1988924@gmail.com.

*********************************************************************************************************************************************************************************

Before you use the code, please make sure that mex files are correctly compiled. 
Some functions like mexLasso.m need the libararies in the SPAMS toolbox:
http://www.di.ens.fr/willow/SPAMS/downloads.html

*********************************************************************************************************************************************************************************

The code runs on Windows XP with MATLAB R2009b.

To get a quick overview:
1. Add your test image in the current directory.
2. Edit the image name 'imName' in demo.m.
3. Run demo.m.

You can also set/change the parameters in demo.m if necessary.

After running demo.m, you can obtain seven saliency maps of different phases as presented in [1] and the final integrated saliency map is named as '****_DSR.bmp'.

*********************************************************************************************************************************************************************************

Note: 
1. We observe that some images on the MSRA dataset are surrounded with artificial frames, which will invalidate the used boundary templates. Therefore, we run a pre-processing to remove such obvious frames. If necessary, you can refer to deletebd.m for more details.
2. We utilize the SLIC execution file 'SLICSuperpixelSegmentation.exe' of the published work [2] ( http://ivrg.epfl.ch/research/superpixels ). Make sure the input image be .bmp file to execute 'SLICSuperpixelSegmentation.exe'.

*********************************************************************************************************************************************************************************

References:
[1] Xiaohui Li, Huchuan Lu, Ming-Hsuan Yang, Lihe Zhang and Xiang Ruan. Saliency Detection Via Dense and Sparse Reconstruction. International Conference on Computer Vision (ICCV), 2013.
[2] R. Achanta, A. Shaji, K. Smith, A. Lucchi, P. Fua, and S. Susstrunk. Slic superpixels. Technical Report, EPFL, 2010.
