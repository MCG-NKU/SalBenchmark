function [lambda1,lambda2,orient,anisotropy]=ColorStructureTensor(in, sigma, sigma2)
% computes lambda1 and lambda2 of the structure tensor of a color image,
% and computes the local orientation

% structure tensor = ( Rx^2+Gx^2+Bx^2           Rx Ry + Gx Gy + Bx By )
%                    ( Rx Ry + Gx Gy + Bx By    Ry^2 + Gy^2 + By^2 )
% orientation = .5 * arctan ( 2 *  (Rx Ry + Gx Gy + Bx By) /
%                                            (Rx^2+Gx^2+Bx^2)-(Ry^2+Gy^2+By^2) )
% anisotropy is a confidence measure of the orientation

R=double(in(:,:,1));
G=double(in(:,:,2));
B=double(in(:,:,3));

Rx=gDer(R,sigma,1,0);
Ry=gDer(R,sigma,0,1);
R =gDer(R,sigma,0,0);

Gx=gDer(G,sigma,1,0);
Gy=gDer(G,sigma,0,1);
G =gDer(G,sigma,0,0);

Bx=gDer(B,sigma,1,0);
By=gDer(B,sigma,0,1);
B =gDer(B,sigma,0,0);

Cxy=2*(Rx.*Ry+Gx.*Gy+Bx.*By);
Cxx=Rx.*Rx+Gx.*Gx+Bx.*Bx;
Cyy=Ry.*Ry+Gy.*Gy+By.*By;

Cxx =gDer(Cxx,sigma2,0,0);
Cxy =gDer(Cxy,sigma2,0,0);
Cyy =gDer(Cyy,sigma2,0,0);

D=sqrt((Cxx-Cyy).^2+Cxy.^2+eps);
lambda1=Cxx+Cyy+D;
lambda2=Cxx+Cyy-D;
orient = .5*atan2(Cxy,Cxx-Cyy);
anisotropy=D./(Cxx+Cyy);