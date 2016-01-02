function [out]=color_gradient(in, sigma)
% computes the gradient of a color image

R=double(in(:,:,1));
G=double(in(:,:,2));
B=double(in(:,:,3));

Rx=gDer(R,sigma,1,0);
Ry=gDer(R,sigma,0,1);

Gx=gDer(G,sigma,1,0);
Gy=gDer(G,sigma,0,1);

Bx=gDer(B,sigma,1,0);
By=gDer(B,sigma,0,1);

out=sqrt(Rx.*Rx+Ry.*Ry+Gx.*Gx+Gy.*Gy+Bx.*Bx+By.*By+eps);