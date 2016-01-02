function bdIds = GetBndPatchIds(idxImg, thickness)
% Get super-pixels on image boundary
% idxImg is an integer image, values in [1..spNum]
% thickness means boundary band width

% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

if nargin < 2
    thickness = 8;
end

bdIds=unique([
    unique( idxImg(1:thickness,:) );
    unique( idxImg(end-thickness+1:end,:) );
    unique( idxImg(:,1:thickness) );
    unique( idxImg(:,end-thickness+1:end) )
    ]);