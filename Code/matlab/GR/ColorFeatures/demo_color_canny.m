% The quasi-invariant derivatives can be used to suppress undesired edges
% such as shadow, shading and specular edges.

% LITERATURE:
% J. van de Weijer, Th. Gevers, A.W.M Smeulders
% " Robust Photometric Invariant Features from the Color Tensor"
% IEEE Trans. Image Processing,
% vol. 15 (1), January 2006.


% example of photometric invariant edge detection
% fig 1: input image
% fig 2: all edges
% fig 3: no shadow and shading edges
% fig 4: no specular edges (highlights)
% fig 5: no shadow-shading and specular edges (only material edges)

input_im = imread('speelgoed.tif');         % test image
sigma1=1;                                   % standard deviation gaussian derivative kernel
sigma2=3;                                   % standard deviation gaussian averaging kernel
edgeT=3;                                    % threshold on which edges to display

[out0]=color_canny(input_im, sigma1, sigma2, 0);
[out1]=color_canny(input_im, sigma1, sigma2, 1);
[out2]=color_canny(input_im, sigma1, sigma2, 2);
[out3]=color_canny(input_im, sigma1, sigma2, 3);


figure(1); imagesc(input_im);
title('input image');axis off;
figure(2); colormap(gray); imagesc(out0>edgeT);
title('color gradient');axis off;
figure(3); colormap(gray); imagesc(out1>edgeT);
title('shadow-shading inv.');axis off;
figure(4); colormap(gray); imagesc(out2>edgeT);
title('specular inv.');axis off;
figure(5); colormap(gray); imagesc(out3>edgeT);
title('shadow-shading specular inv.');axis off;


% example of isoluminance : edges are lost in the transformation to luminance
% fig 11: input image
% fig 12: luminance canny (not all edges of the flower are detected)
% fig 13: color canny 
input_im=imread('flower.jpg');
sigma1=2;
sigma2=2;

flower1=color_canny(input_im, sigma1,sigma2, 0);
flower2=canny(RGB2luminance(input_im), sigma1);
figure(11);
imagesc(input_im);title('input image');axis off;
figure(12); 
colormap(gray); imagesc(flower2 > 5);
title('luminance canny');axis off;
figure(13); 
colormap(gray); imagesc(flower1 > 5);
title('color canny');axis off;
