function y = EdgeMirror(x, width)
% Edge mirroring function attach the mirror edge to the input image x.
% [usage]
% y = EdgeMirror(x, width)
%
% [parameter]
% x     : input image
% width : mirroring width [x y]
%
% [history]
% Jan 20, 2005 : created by hiro

y = cat(2, x(:, width(2)+1:-1:2), x, x(: ,end-1:-1:end-width(2)));
y = cat(1, y(width(1)+1:-1:2, :), y, y(end-1:-1:end-width(1), :));