% hue-saturation-intensity derivatives: used to compute the specular shadow-shading quasi-invariants (SP-SSQI)
%
% SYNOPSIS:
%   [[h_x, h_y, s_x, s_y, i_x, i_y, saturation] = HSI_der( input_im, sigma)
%
% INPUT :
%   input_im        : color input image (NxMx3)
%	sigma           : size of the Gaussian standard deviation in computing the derivatives
% 
% OUTPUT: 
%   h_x, h_y                     :  derivatives in the speclar-shadow-shading INVARIANT direction.
%                                   (note that h_x= saturation * hue_x)
%   s_x, s_y, i_x, i_y           :  spherical derivatives in the specular-shadow-shading VARIANT directions.

% LITERATURE:
% J. van de Weijer, Th. Gevers, J-M Geusebroek
% "Edge and Corner Detection by Photometric Quasi-Invariants"
% IEEE Trans. Pattern Analysis and Machine Intelligence,
% vol. 27 (4), April 2005.

function [h_x, h_y, s_x, s_y, i_x, i_y, saturation] = HSI_der(input_im, sigma)
% computes the hue saturation and intensity derivatives

R=double(input_im(:,:,1));
G=double(input_im(:,:,2));
B=double(input_im(:,:,3));

Rx=gDer(R,sigma,1,0);
Ry=gDer(R,sigma,0,1);
R =gDer(R,sigma,0,0);

Gx=gDer(G,sigma,1,0);
Gy=gDer(G,sigma,0,1);
G =gDer(G,sigma,0,0);

Bx=gDer(B,sigma,1,0);
By=gDer(B,sigma,0,1);
B =gDer(B,sigma,0,0);

%hsi derivatives- hue saturation intensity
saturation=sqrt(2*(R.*R+G.*G+B.*B-R.*G-R.*B-G.*B+eps));
h_x=(R.*(Bx-Gx)+G.*(Rx-Bx)+B.*(Gx-Rx))./saturation;
s_x=(R.*(2*Rx-Gx-Bx)+G.*(2*Gx-Rx-Bx)+B.*(2*Bx-Rx-Gx))./(sqrt(3)*saturation);
i_x=1/sqrt(3)*(Rx+Gx+Bx);

h_y=(R.*(By-Gy)+G.*(Ry-By)+B.*(Gy-Ry))./saturation;
s_y=(R.*(2*Ry-Gy-By)+G.*(2*Gy-Ry-By)+B.*(2*By-Ry-Gy))./(sqrt(3)*saturation);
i_y=1/sqrt(3)*(Ry+Gy+By);

saturation=saturation/sqrt(3);