function [lambda1,lambda2,orient]=ColorStructureTensor2(Cxx,Cxy,Cyy)
% computes lambda1 and lambda2 of color structure tensor 
% color structure tensor = ( Rx^2+Gx^2+Bx^2           Rx Ry + Gx Gy + Bx By )
%                          ( Rx Ry + Gx Gy + Bx By    Ry^2 + Gy^2 + By^2 )

Cxy=2*Cxy;
D=sqrt((Cxx-Cyy).^2+Cxy.^2);
lambda1=Cxx+Cyy+D;
lambda2=Cxx+Cyy-D;
orient = .5*atan2(Cxy,Cxx-Cyy);