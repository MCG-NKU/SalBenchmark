% copyright MERL, Fatih Porikli, 2005

function [C, M] = iicov(fiimageSource, fsiimageSource, tp1, tp2)

[n,m,fdim] = size(fiimageSource);

s = double((tp2(1)-max(1,tp1(1)-1))*(tp2(2)-max(1,tp1(2)-1)));

SO = zeros(fdim);
T = zeros(fdim);
SO = reshape(fsiimageSource(tp2(1), tp2(2), :), fdim, fdim);
T = reshape(fsiimageSource(max(1,tp1(1)-1), max(1,tp1(2)-1), :), fdim, fdim);
SO = SO+T;
T = reshape(fsiimageSource(tp2(1), max(1,tp1(2)-1), :), fdim, fdim);
SO = SO-T;
T = reshape(fsiimageSource(max(1,tp1(1)-1), tp2(2), :), fdim, fdim);
SO = SO-T;

fi = zeros(fdim,1);
t = zeros(fdim,1);
fi(:) = fiimageSource(tp2(1), tp2(2), :);
t(:) = fiimageSource(max(1,tp1(1)-1), max(1,tp1(2)-1), :);
fi = fi+t;
t(:) = fiimageSource(tp2(1), max(1,tp1(2)-1), :);
fi = fi-t;
t(:) = fiimageSource(max(1,tp1(1)-1), tp2(2), :);
fi = fi-t;
C = (SO - ((fi*fi')/s)) / s;
M = fi'/s;