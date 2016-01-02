function [l] = RGB2l(f,sigma)

l=0.299*double(f(:,:,1))+0.587*double(f(:,:,1))+0.114*double(f(:,:,3));
