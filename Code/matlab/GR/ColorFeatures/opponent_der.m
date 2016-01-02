% opponent derivatives: used to compute the specular quasi-invariants (SPQI)
%
% SYNOPSIS:
%  [O1_x, O1_y, O2_x, O2_y, O3_x, O3_y] = opponent_der(input_im, sigma)
%
% INPUT :
%   input_im : color input image (NxMx3)
%	sigma    : size of the Gaussian standard deviation in computing the derivatives
% 
% OUTPUT: 
%   O1_x, O1_y, O2_x, O2_y  :  opponent derivatives in the specular INVARIANT direction.
%   O3_x, O3_y              :  opponent derivatives in the specular VARIANT direction.

% LITERATURE:
% J. van de Weijer, Th. Gevers, J-M Geusebroek
% "Edge and Corner Detection by Photometric Quasi-Invariants"
% IEEE Trans. Pattern Analysis and Machine Intelligence,
% vol. 27 (4), April 2005.

function [O1_x,O1_y,O2_x,O2_y,O3_x,O3_y] = opponent_der(input_im, sigma)

%split color channels
R=double(input_im(:,:,1));
G=double(input_im(:,:,2));
B=double(input_im(:,:,3));

% computation of spatial derivatives
Rx=gDer(R,sigma,1,0);
Ry=gDer(R,sigma,0,1);

Gx=gDer(G,sigma,1,0);
Gy=gDer(G,sigma,0,1);

Bx=gDer(B,sigma,1,0);
By=gDer(B,sigma,0,1);

% computation of derivatives in opponent color space
O1_x=(Rx-Gx)/sqrt(2);
O1_y=(Ry-Gy)/sqrt(2);
O2_x=(Rx+Gx-2*Bx)/sqrt(6);
O2_y=(Ry+Gy-2*By)/sqrt(6);
O3_x=(Rx+Gx+Bx)/sqrt(3);
O3_y=(Ry+Gy+By)/sqrt(3);