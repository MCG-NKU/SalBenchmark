% The quasi-invariant derivatives can be used to suppress undesired edges
% such as shadow, shading and specular edges.

% LITERATURE:
% J. van de Weijer, Th. Gevers, J-M Geusebroek
% "Edge and Corner Detection by Photometric Quasi-Invariants"
% IEEE Trans. Pattern Analysis and Machine Intelligence,
% vol. 27 (4), April 2005.

input_im = imread('speelgoed.tif');         % test image
sigma=1;                                    % standard deviation gaussian kernel

%specular quasi invariant & variant
[O1_x, O1_y, O2_x, O2_y, O3_x, O3_y]= opponent_der(input_im, sigma);
sp_inv=sqrt(O1_x.^2+O1_y.^2+O2_x.^2+O2_y.^2+eps);
sp_var=sqrt(O3_x.^2+O3_y.^2+eps);

%shadow-shading quasi invariant & variant
[ theta_x, theta_y, phi_x, phi_y, r_x, r_y, intensityL2] = spherical_der(input_im, sigma);
ss_inv=sqrt(theta_x.^2+theta_y.^2+phi_x.^2+phi_y.^2+eps);
ss_var=sqrt(r_x.^2+r_y.^2+eps);
%specula shadow-shading quasi invariant & variant
[h_x, h_y, s_x, s_y, i_x, i_y, saturation]= HSI_der(input_im, sigma);
spss_inv=sqrt(h_x.^2+h_y.^2+eps);
spss_var=sqrt(i_x.^2+i_y.^2+s_x.^2+s_y.^2+eps);

figure(1); subplot(2,4,1);imagesc(input_im);
title('input image');axis off;
subplot(2,4,2); colormap(gray); imagesc(ss_inv);
title('shadow-shading inv.');axis off;
subplot(2,4,3); colormap(gray); imagesc(sp_inv);
title('specular inv.');axis off;
subplot(2,4,4); colormap(gray); imagesc(spss_inv);
title('shadow-shading specular inv.');axis off;

subplot(2,4,6); colormap(gray); imagesc(ss_var);
title('shadow-shading variant');axis off;
subplot(2,4,7); colormap(gray); imagesc(sp_var);
title('specular variant');axis off;
subplot(2,4,8); colormap(gray); imagesc(spss_var);
title('shadow-shading specular variant');axis off;

color_grad=color_gradient(input_im,sigma);
subplot(2,4,5); colormap(gray); imagesc(color_grad);
title('color gradient');axis off;

% note that since the transformation are ortonormal:
%   color_grad.^2=sp_inv.^2-sp_var.^2;
%   color_grad.^2=ss_inv.^2-ss_var.^2;
%   color_grad.^2=spss_inv.^2-spss_var.^2;
