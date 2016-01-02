% SYNOPSIS:
%   [star, circle] = star_sym_color(a,sigma_g,sigma_a,center_flag)
%
% PARAMETERS IN:
%   a           : input color image
%	sigma_g     : size of the Gaussian standard deviation in computing the first-derivatives
%	sigma_a     : size of the Gaussian standard deviation to define local neighborhood ( typically larger than sigma_g )
%   center_flag : where to add the derivative energy in the center is undefined ( but you want star+circle to be total energy )
%                 center_flag allows to decide to which pixel to add the centerpoint energy
%                 0: centerpoint is added to circle energy, 1: centerpoint is added to star energy  
% PARAMETERS OUT:
%   star          :  star energy funtion.
%   circle        :  circle energy funtion.

% LITERATURE:
%  original article which introduced the filter for luminance
%   J. Bigun
%   Pattern recognition in images by symmetry and coordinate
%   transformation.
%   Computer Vision and Image Understanding, 68(3): 290-307, 1997
%
%   color implementation:
%   J. van de Weijer, Th. Gevers and A.W.M. Smeulders, Robust
%   Photometric Invariant Features from the Color Tensor, IEEE Trans. Image
%   Processing, vol. 15 (1), January 2006. 

function [star, circle] = star_sym_color(a,sigma_g,sigma_a,center_flag)


if(nargin<4)
    center_flag=1;
end

R=double(a(:,:,1));
G=double(a(:,:,2));
B=double(a(:,:,3));

%Initialize the filter
break_of_sigma = 3.;
filtersize = break_of_sigma*sigma_g;

% compute the Gaussian and first Gaussian derivatives at scale sigma_g
[y x] = ndgrid(-filtersize:filtersize,-filtersize:filtersize);
Gg    = 1/(2 * pi * sigma_g^2)* exp((x.^2 + y.^2)/(-2 * sigma_g * sigma_g) );
Gg_x  = 1/(sigma_g^2)* x .* Gg;
Gg_y  = 1/(sigma_g^2)* y .* Gg;

% Compute the (moment generating) filters at scale sigma_a
filtersize = round(break_of_sigma*sigma_a);
[y x] = ndgrid(-filtersize:filtersize,-filtersize:filtersize);
Ga    = 1/(2 * pi * sigma_a^2) * exp((x.^2 + y.^2)/(-2 * sigma_a * sigma_a));
%Ga(filtersize+1,filtersize+1)=0;

div=x.*x+y.*y;
div(filtersize+1,filtersize+1)=1;

Ga_xx = x.*x./div.* Ga;
Ga_xy = 2*x.*y./div .* Ga;
Ga_yy = y.*y./div .* Ga;

if(center_flag)
    Ga_xx(filtersize+1,filtersize+1)=0;
    Ga_xy(filtersize+1,filtersize+1)=0;
    Ga_yy(filtersize+1,filtersize+1)=0;
else
    Ga_xx(filtersize+1,filtersize+1)=Ga(filtersize+1,filtersize+1);
    Ga_xy(filtersize+1,filtersize+1)=Ga(filtersize+1,filtersize+1);
    Ga_yy(filtersize+1,filtersize+1)=Ga(filtersize+1,filtersize+1);
end
% Orientation Estimation
Fx  = filter2(Gg_x,R);
Fy  = filter2(Gg_y,R);
Fxx = Fx .* Fx;
Fxy = Fx .* Fy;
Fyy = Fy .* Fy;

out1=filter2(Ga_xx,Fyy)-filter2(Ga_xy,Fxy)+filter2(Ga_yy,Fxx);
out2=filter2(Ga,Fxx+Fyy);

Fx  = filter2(Gg_x,G);
Fy  = filter2(Gg_y,G);
Fxx = Fx .* Fx;
Fxy = Fx .* Fy;
Fyy = Fy .* Fy;

out1=out1+filter2(Ga_xx,Fyy)-filter2(Ga_xy,Fxy)+filter2(Ga_yy,Fxx);
out2=out2+filter2(Ga,Fxx+Fyy);

Fx  = filter2(Gg_x,B);
Fy  = filter2(Gg_y,B);
Fxx = Fx .* Fx;
Fxy = Fx .* Fy;
Fyy = Fy .* Fy;

out1=out1+filter2(Ga_xx,Fyy)-filter2(Ga_xy,Fxy)+filter2(Ga_yy,Fxx);
out2=out2+filter2(Ga,Fxx+Fyy);

star=out1;
circle=filter2(Ga,out2)-star;