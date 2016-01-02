function [R,G,B]= O2RGB(O1,O2,O3)
%opponent to RGB

%O1 = double(in(:,:,1));
%O2 = double(in(:,:,2));
%O3 = double(in(:,:,3));

R=1/sqrt(2)*O1+1/sqrt(6)*O2+1/sqrt(3)*O3;
G=-1/sqrt(2)*O1+1/sqrt(6)*O2+1/sqrt(3)*O3;
B=-2/sqrt(6)*O2+1/sqrt(3)*O3;