function show_imgnmap2( img , smap )

%
% originally part of GBVS code by Jonathan Harel
% http://www.klab.caltech.edu/~harel/share/gbvs.php
%

smap = mat2gray( imresize(smap,[size(img,1) size(img,2)]) );
imshow(heatmap_overlay( img , smap ));