function [O1,O2,O3]= RGB2O(in,alfa,beta,gamma)
% convert R,G,B to E, El, Ell
R = double(in(:,:,1));
G = double(in(:,:,2));
B = double(in(:,:,3));

if (nargin<2)
    alfa=1;
    beta=1;
    gamma=1;
end

O1=(beta*R-alfa*G)/sqrt(alfa*alfa+beta*beta);
O2=(alfa*gamma*R+beta*gamma*G-(alfa^2+beta^2)*B)/(sqrt(alfa*alfa+beta*beta)*sqrt(alfa*alfa+beta*beta+gamma*gamma));
O3=(alfa*R+beta*G+gamma*B)/sqrt(alfa*alfa+beta*beta+gamma*gamma);