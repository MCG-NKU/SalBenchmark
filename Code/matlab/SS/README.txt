
Image Signature Saliency Map

=============================================================================

Description:

The code provided here allows the computation of a saliency map based on the 
Image Signature, as described in the following paper:

"Image Signature: Highlighting sparse salient regions", 
Xiaodi Hou, Jonathan Harel, and Christof Koch,
IEEE Trans. Pattern Anal. Mach. Intell. 34(1): 194-201 (2012) [1]

Authorship: 

Coding by Xiaodi Hou and Jonathan Harel, 2011
 
License: 

Code may be copied/used for any purposes as long as the use is acknowledged
and cited (namely, [1] should be cited).

=============================================================================

Code:

The main code is signatureSal.m, which allows one to compute a saliency map 
as follows:

>> salMap = signatureSal('/path/to/my/image/1.jpg');

Notes:

(1) See default_signature_param.m for available parameters. Default is best.
(2) See/run sigdemo for example output and proper usage.

=============================================================================
