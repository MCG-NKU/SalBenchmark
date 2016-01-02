% color canny: computes the edges (given a photometric model) of a color image 
%
% SYNOPSIS:
%    [out]=canny(input_im, sigma)
%
% INPUT :
%   input_im      : luminance input image (NxMx3)
%	sigma        : size of the Gaussian standard deviation in computing the derivatives


% OUTPUT: 
%   out                                 :  canny edges

% LITERATURE:
% J. van de Weijer, Th. Gevers, A.W.M Smeulders
% " Robust Photometric Invariant Features from the Color Tensor"
% IEEE Trans. Image Processing,
% vol. 15 (1), January 2006.

function [out,orientation]=canny(input_im, sigma)
% color canny - computes edges in luminance image

Lx=gDer(input_im,sigma,1,0);
Ly=gDer(input_im,sigma,0,1);
gradient=sqrt(Lx.^2+Ly.^2+eps);
orientation=atan2(Ly,Lx);
mask=(orientation<=-pi/2);orientation=orientation.*double(~mask)+(orientation+pi).*double(mask);
mask=(orientation>pi/2) ;orientation=orientation.*double(~mask)+(orientation-pi).*double(mask);

out=zeros(size(input_im));

width=size(out,2);
height=size(out,1);

for jj= 2: width-1
    for ii = 2: height-1
        orient = orientation(ii+(jj-1)*height);
        grad   = gradient(ii+(jj-1)*height);
        if(grad>0)
            if(abs(orient)<=0.3927)
                dx=1; dy=0;
            end
            if( (orient<1.1781 ) & (orient>0.3927) )
                dx=1; dy=1;
            end
            if( (orient>-1.1781 ) & (orient<-0.3927) )
                dx=1; dy=-1;
            end
            if( abs(orient)>=1.1781)
                dx=0; dy=-1;
            end
		    if( ( grad >= gradient( ii+dy+(jj+dx-1)*height) ) & ( grad >= gradient( ii-dy+(jj-dx-1)*height) ))
                out(ii+jj*height)=grad;
            end
        end
    end
end            