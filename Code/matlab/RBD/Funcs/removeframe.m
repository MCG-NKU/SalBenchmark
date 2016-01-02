function [noFrameImg, frameRecord] = removeframe(input_im, edgeMethod)
% Remove image frames

% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

if size(input_im, 3) == 3
    grayImg=rgb2gray(input_im);
else
    grayImg = input_im;
end
[height, width] = size(grayImg);

threshold=0.6;
MAXWIDTH = 30;  % we assume that the frame is not wider than 30 pixels
edgemap = edge(grayImg, edgeMethod);
haveFrame = false;
frameWidth = zeros(4, 1);

% TOP
edgeDensity = mean( edgemap(1:MAXWIDTH, :), 2); % average density per row
% find the largest row index with large enough edge density
top_row_idx = find(edgeDensity > threshold, 1, 'last');
if ~isempty(top_row_idx)
    frameWidth(1) = top_row_idx;
    haveFrame = true;
end

% BOTTOM
edgeDensity = mean( edgemap(end - MAXWIDTH + 1:end, :), 2);
bottom_row_idx = find(edgeDensity > threshold, 1, 'first');
if ~isempty(bottom_row_idx)
    frameWidth(2) = MAXWIDTH - bottom_row_idx + 1;
    haveFrame = true;
end

%LEFT
edgeDensity = mean( edgemap(:, 1:MAXWIDTH, :), 1);
left_col_idx = find(edgeDensity > threshold, 1, 'last');
if ~isempty(left_col_idx)
    frameWidth(3) = left_col_idx; 
    haveFrame = true;
end

% RIGHT
edgeDensity = mean( edgemap(:, end - MAXWIDTH + 1:end), 1);
right_col_idx = find(edgeDensity > threshold, 1, 'first');
if ~isempty(right_col_idx)
    frameWidth(4) = MAXWIDTH - right_col_idx + 1;
    haveFrame = true;
end

frameRecord = [height,width,1,height,1,width];
if haveFrame
    frameWidth(frameWidth == 0) = max(frameWidth);
    
    frameRecord(3) = frameWidth(1) + 1;
    frameRecord(4) = height - frameWidth(2);
    frameRecord(5) = frameWidth(3) + 1;
    frameRecord(6) = width - frameWidth(4);
end

noFrameImg = input_im(frameRecord(3):frameRecord(4), frameRecord(5):frameRecord(6), :);