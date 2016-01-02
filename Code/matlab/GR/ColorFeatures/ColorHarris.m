% SYNOPSIS:
%  [harris_energy] = ColorHarris(in,sigma_g,sigma_a,k,method)
%
% PARAMETERS IN:
%   in      : input color image
%	sigma_g : size of the Gaussian standard deviation in computing the first-derivatives
%	sigma_a : size of the Gaussian standard deviation to define local neighborhood ( typically larger than sigma_g )
%   k       : multiplication constant from original Harris article.
%   method  : method=0 performs luminance based Harros
%           : method=1 performs multi-channel Harris.
% PARAMETERS OUT:
%   harris_energy:  the Harris corner energy funtion.
% LITERATURE:
%   J. van de Weijer, Th. Gevers and A.W.M. Smeulders, Robust
%   Photometric Invariant Features from the Color Tensor, IEEE Trans. Image Processing, vol. 15 (1), January 2006. 

function [harris_energy] = ColorHarris(in,sigma_g,sigma_a,k,method)

if(nargin<2) sigma_g=1; end
if(nargin<3) sigma_a=3; end
if(nargin<4) k=0.04; end

in=double(in);

if(method==0)   % if luminance based - compute derivatives
    Lx=gDer(sum(in,3),sigma_g,1,0);
    Ly=gDer(sum(in,3),sigma_g,0,1);
end

if(method==1)    % if color based - compute derivatives
    Lx=gDer(in(:,:,1),sigma_g,1,0);
    Ly=gDer(in(:,:,1),sigma_g,0,1);
    Lx_2=gDer(in(:,:,2),sigma_g,1,0);
    Ly_2=gDer(in(:,:,2),sigma_g,0,1);
    Lx_3=gDer(in(:,:,3),sigma_g,1,0);
    Ly_3=gDer(in(:,:,3),sigma_g,0,1);
end

Lx2=Lx.^2;
Ly2=Ly.^2;
LxLy=Lx.*Ly;

if(method==1)       % in case of color image
    Lx2=Lx2+Lx_2.^2+Lx_3.^2;
    Ly2=Ly2+Ly_2.^2+Ly_3.^2;
    LxLy=LxLy+Lx_2.*Ly_2+Lx_3.*Ly_3; 
end

% computation of the local tensor on scale sigma_a
Lx2=gDer(Lx2,sigma_a,0,0);
Ly2=gDer(Ly2,sigma_a,0,0);
LxLy=gDer(LxLy,sigma_a,0,0);

harris_energy   = Lx2.*Ly2-LxLy.^2-k*(Lx2+Ly2).^2;