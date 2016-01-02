function LARK = ComputeLARK(varargin)

% Compute LARK descriptors

% [RETURNS]
% LARK   : LARK descriptors
%
% [PARAMETERS]
% img   : Input image
% wsize : LARK window size
% alpha : Sensitivity parameter
% h     : smoothing paramter

% [HISTORY]
% Apr 25, 2011 : created by Hae Jong

img = varargin{1};
wsize = varargin{2};
alpha = varargin{3};
h = varargin{4};

[M,N] = size(img);
win = (wsize-1)/2;
[zx,zy]=gradient(img);

K = fspecial('disk', win);
K = K ./ K(win+1, win+1);
len = sum(K(:));
zx = EdgeMirror(zx,[win,win]);
zy = EdgeMirror(zy,[win,win]);

% Covariance matrices computation
df = 1;
for i = 1 : df : M
    for j = 1 : df : N
        gx = zx(i:i+wsize-1, j:j+wsize-1).* K;
        gy = zy(i:i+wsize-1, j:j+wsize-1).* K;
        G = [gx(:), gy(:)];
        len = sum(K(:));
        [u s v] = svd(G,'econ');
        S(1) = (s(1,1) + 1) / (s(2,2) + 1);
        S(2) = (s(2,2) + 1) / (s(1,1) + 1);
        tmp = (S(1) * v(:,1) * v(:,1).' + S(2) * v(:,2) * v(:,2).')  * ((s(1,1) * s(2,2) + 0.0000001) / len)^alpha;
        C11(i,j) = tmp(1,1);
        C12(i,j) = tmp(1,2);
        C22(i,j) = tmp(2,2);
    end
end

C11 = C11(1:df:end,1:df:end);
C12 = C12(1:df:end,1:df:end);
C22 = C22(1:df:end,1:df:end);

C11 = imresize(C11,[M N]);
C12 = imresize(C12,[M N]);
C22 = imresize(C22,[M N]);


[x2,x1] = meshgrid(-win:win,-win:win);
C11 = EdgeMirror(C11,[win,win]);
C12 = EdgeMirror(C12,[win,win]);
C22 = EdgeMirror(C22,[win,win]);
x12 = 2*x1.*x2;
x11 = x1.^2;
x22 = x2.^2;

x1x1 = reshape(repmat(reshape(x11,[1 wsize^2]),M*N,1),[M,N,wsize wsize]);
x1x2 = reshape(repmat(reshape(x12,[1 wsize^2]),M*N,1),[M,N,wsize wsize]);
x2x2 = reshape(repmat(reshape(x22,[1 wsize^2]),M*N,1),[M,N,wsize wsize]);

% Geodesic distance computation between a center and surrounding pixels
LARK = zeros(M,N,wsize,wsize);
for i = 1:wsize
    for j = 1:wsize
        temp = C11(i:i+M-1,j:j+N-1).*x1x1(:,:,i,j)+ C12(i:i+M-1,j:j+N-1).*x1x2(:,:,i,j)+ C22(i:i+M-1,j:j+N-1).*x2x2(:,:,i,j);
        LARK(:,:,i,j) = temp;
    end
end
% Convert geodesic distance to self-similarity
 LARK = exp(-LARK*0.5/h^2);
 LARK = reshape(LARK,[M N wsize^2]);

