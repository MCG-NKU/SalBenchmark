% color canny: computes the edges (given a photometric model) of a color image 
%
% SYNOPSIS:
%    [out]=color_canny(input_im, sigma1, sigma2, method)
%
% INPUT :
%   input_im      : color input image (NxMx3)
%	sigma1        : size of the Gaussian standard deviation in computing the derivatives
%	sigma2        : size of the Gaussian averaging of the color tensor
%   method        : the color canny is computed based on: 
%                                           0 - color gradient
%                                           1 - shadow-shading quasi-invariant
%                                           2 - specular quasi-invariant
%                                           3 - specular-shadow-shading quasi-invariant
% OUTPUT: 
%   out                                 :  canny edges

% LITERATURE:
% J. van de Weijer, Th. Gevers, A.W.M Smeulders
% " Robust Photometric Invariant Features from the Color Tensor"
% IEEE Trans. Image Processing,
% vol. 15 (1), January 2006.

function [out]=color_canny(input_im, sigma1, sigma2, method)
% color canny - copmutes edges in a color image

if nargin<4 method=0; end
if(method==0)
    [lambda1,lambda2,orientation,anisotropy]=ColorStructureTensor(input_im, sigma1, sigma2);
end

if(method==1)
    % quasi-invariants
    [theta_x, theta_y,f_phi_x,f_phi_y] = spherical_der(input_im, sigma1);
    Lxy=theta_x.*theta_y+f_phi_x.*f_phi_y;
    Lxx=theta_x.*theta_x+f_phi_x.*f_phi_x;
    Lyy=theta_y.*theta_y+f_phi_y.*f_phi_y;
    Lxx =gDer(Lxx,sigma2,0,0);
    Lxy =gDer(Lxy,sigma2,0,0);
    Lyy =gDer(Lyy,sigma2,0,0);
    [lambda1,lambda2,orientation]=ColorStructureTensor2(Lxx,Lxy,Lyy);
end

if(method==2)
    % specular-invariants
    [O1_x, O1_y, O2_x, O2_y] = opponent_der(input_im, sigma1);
    Lxy=(O1_x.*O1_y+O2_x.*O2_y);
    Lxx=(O1_x.*O1_x+O2_x.*O2_x);
    Lyy=(O1_y.*O1_y+O2_y.*O2_y);
    Lxx= gDer(Lxx,sigma2,0,0);
    Lxy= gDer(Lxy,sigma2,0,0);
    Lyy= gDer(Lyy,sigma2,0,0);
    [lambda1,lambda2,orientation]=ColorStructureTensor2(Lxx,Lxy,Lyy);
end

if(method==3)
    % specular-shadow-shading invariant
    [h_x, h_y] = HSI_der(input_im, sigma1);
    Lxy=h_x.*h_y;
    Lxx=h_x.*h_x;
    Lyy=h_y.*h_y;
    Lxx= gDer(Lxx,sigma2,0,0);
    Lxy= gDer(Lxy,sigma2,0,0);
    Lyy= gDer(Lyy,sigma2,0,0);
    [lambda1,lambda2,orientation]=ColorStructureTensor2(Lxx,Lxy,Lyy);
end

lambda1=sqrt(lambda1+eps);
out=zeros(size(input_im(:,:,1)));

width=size(out,2);
height=size(out,1);

for jj= 2: width-1
    for ii = 2: height-1
        orient = orientation(ii+(jj-1)*height);
        grad   = lambda1(ii+(jj-1)*height);
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
		    if( ( grad >= lambda1( ii+dy+(jj+dx-1)*height) ) & ( grad >= lambda1( ii-dy+(jj-dx-1)*height) ))
                out(ii+jj*height)=grad;
            end
        end
    end
end            