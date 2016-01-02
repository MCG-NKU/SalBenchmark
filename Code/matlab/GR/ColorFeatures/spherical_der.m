% spherical derivatives: used to compute the shadow-shading quasi-invariants (SSQI)
%
% SYNOPSIS:
%   [ theta_x, theta_y, phi_x, phi_y, r_x, r_y, intensityL2] = spherical_der(input_im, sigma)
%
% INPUT :
%   input_im     : color input image (NxMx3)
%	sigma        : size of the Gaussian standard deviation in computing the derivatives
% 
% OUTPUT: 
%   theta_x, theta_y, phi_x, phi_y      :  spherical derivatives in the shadow-shading INVARIANT direction.
%                                          (note that the Jacobian is taken into account theta_x = r*sin(phi)*THETA_x
%                                           and phi_x = r* PHI_x, where THETA_x and PHI_x are the true spatial 
%                                           derivatives of THETA and PHI)                                               
%   r_x, r_y                            :  spherical derivatives in the shadow-shading VARIANT direction.

% LITERATURE:
% J. van de Weijer, Th. Gevers, J-M Geusebroek
% "Edge and Corner Detection by Photometric Quasi-Invariants"
% IEEE Trans. Pattern Analysis and Machine Intelligence,
% vol. 27 (4), April 2005.

function [ theta_x, theta_y, phi_x, phi_y, r_x, r_y, intensityL2] = spherical_der(input_im, sigma)

%split color channels
R=double(input_im(:,:,1));
G=double(input_im(:,:,2));
B=double(input_im(:,:,3));

% computation of spatial derivatives
Rx=gDer(R,sigma,1,0);
Ry=gDer(R,sigma,0,1);
R =gDer(R,sigma,0,0);

Gx=gDer(G,sigma,1,0);
Gy=gDer(G,sigma,0,1);
G =gDer(G,sigma,0,0);

Bx=gDer(B,sigma,1,0);
By=gDer(B,sigma,0,1);
B =gDer(B,sigma,0,0);

intensityL2 = sqrt(R.*R+G.*G+B.*B+eps);
I2 = sqrt(R.*R+G.*G+eps);

theta_x=(R.*Gx-G.*Rx)./I2;
phi_x=(G.*(B.*Gx-G.*Bx)+R.*(B.*Rx-R.*Bx))./(intensityL2.*I2);
r_x=(R.*Rx+G.*Gx+B.*Bx)./intensityL2;

theta_y=(R.*Gy-G.*Ry)./I2;
phi_y=(G.*(B.*Gy-G.*By)+R.*(B.*Ry-R.*By))./(intensityL2.*I2);
r_y=(R.*Ry+G.*Gy+B.*By)./intensityL2;
