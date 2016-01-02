function [x_max,y_max,mask,num_max]=getmaxpoints(in,nPoints)
% returns the nPoints maxima of an image
%
% SYNOPSIS:
%  [x_max,y_max,mask,num_max]=getmaxpoints(in,nPoints,sigma)
%
% PARAMETERS:
%   in      : input image
%   nPoints : number maxima to return

mask=zeros(size(in));
x_max=zeros(nPoints,1);
y_max=zeros(nPoints,1);
[size_y size_x]=size(in);
ii=1;
num_max=0;

copyIn=dilation33(dilation33(in));
copyIn=copyIn.*(in==copyIn);

while(ii<=nPoints)
 [max_y ypos] =max(copyIn);
 [max_xy xpos]=max(max_y);
 x_max(ii)=xpos(1);
 y_max(ii)=ypos(xpos(1));
 
 copyIn(y_max(ii),x_max(ii))=0;
 mask(y_max(ii),x_max(ii))=1;
 
 if(sum(copyIn(:))==0) num_max=ii;ii=nPoints+1;end
 ii=ii+1;
end
if(num_max==0) num_max=nPoints;end