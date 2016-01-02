function smap = SIM(img, window_sizes, wlev, gamma, srgb_flag)
% returns saliency map for image
%
% outputs:
%   smap: saliency map for image
%
% inputs:
%   img: input image
%   window sizes: window sizes for computing relative contrast; suggested 
%   value of [13 26]
%   wlev: # of wavelet levels
%   gamma: gamma value for gamma correction
%   srgb_flag: 0 if img is rgb; 1 if img is srgb

% convert opponent colour space of colour images:
opp_img = rgb2opponent(img, gamma, srgb_flag);

% generate saliency for each channel:
rec(:,:,1) = SIM_per_channel(opp_img(:,:,1),wlev,'colour',window_sizes);
rec(:,:,2) = SIM_per_channel(opp_img(:,:,2),wlev,'colour',window_sizes);
rec(:,:,3) = SIM_per_channel(opp_img(:,:,3),wlev,'intensity',window_sizes);

% combine channels:
s_map = sqrt(sum(rec.^2,3));

% normalise:
map_max = max(s_map(:));
map_min = min(s_map(:));
smap    = floor(255*(s_map - map_min)/(map_max - map_min));

end

function rec = SIM_per_channel(channel,wlev,mode,window_sizes)
% returns saliency map for channel
%
% outputs:
%   rec: saliency map for channel
%
% inputs:
%   channel: opponent colour channel for which saliency map will be computed
%   wlev: # of wavelet levels
%   mode: type of channel i.e. colour or intensity
%   window sizes: window sizes for computing relative contrast; suggested 
%   value of [13 26]

channel = double(channel);
[w wc]  = DWT(channel,wlev);

% for each scale:
for s = 1:wlev
    % for horizontal, vertical and diagonal orientations:
    for orientation = 1:3
           
    	% retrieve wavelet plane:
        ws = w{s,1}(:,:,orientation);

    	% calculate center-surround responses:
        Zctr = relative_contrast(ws,orientation, window_sizes);

        % return alpha values:
        alpha = generate_csf(Zctr, s, mode);
        
        % save alpha value:
        wp{s,1}(:,:,orientation) = alpha;
    end

    % set residual data to zero:
    wc{s,1} = ones(size(alpha/2,1)/2,size(alpha/2,2)/2);
end

% reconstruct the image using inverse wavelet transform:
rec = IDWT(wp,wc,size(channel,2),size(channel,1));

% normalization:
if sum(rec(:)) > 0
    rec = rec./sum(rec(:));
end

end

function zctr = relative_contrast(X,orientation,window_sizes)
% returns relative contrast for each coefficient of a wavelet plane
%
% outputs:
%   zctr: matrix of relative contrast values for each coefficient
% 
% inputs:
%   X: wavelet plane
%   window sizes: window sizes for computing relative contrast; suggested 
%   orientation: wavelet plane orientation

center_size   = window_sizes(1);
surround_size = window_sizes(2);

% horizontal orientation:
if orientation == 1
    
    % define center and surround filters:
    hc = ones(1,center_size);
    hs = [ones(1,surround_size) zeros(1,center_size) ones(1,surround_size)];
    
    % compute variance (assume mean is zero):
    var_cen = imfilter(X.^2,hc,'symmetric')/(length(find(hc==1)));
    var_sur = imfilter(X.^2,hs,'symmetric')/(length(find(hs==1)));
    
% vertical orientation:
elseif orientation == 2
    % define center and surround filters:
    hc = ones(center_size,1);
    hs = [ones(surround_size,1); zeros(center_size,1); ones(surround_size,1)];
    
    % compute variance (assume mean is zero):
    var_cen = imfilter(X.^2,hc,'symmetric')/(length(find(hc==1)));
    var_sur = imfilter(X.^2,hs,'symmetric')/(length(find(hs==1)));

% diagonal orientation:
elseif orientation == 3
    % define center and surround filters:
    hc = ceil((diag(ones(1,center_size)) + fliplr(diag(ones(1,center_size))))/4);
    hs = diag([ones(1,surround_size) zeros(1,center_size) ones(1,surround_size)]);
    hs = hs + fliplr(hs);
    
    % compute variance (assume mean is zero):
    var_cen = imfilter(X.^2,hc,'symmetric')/(length(find(hc==1)));
    var_sur = imfilter(X.^2,hs,'symmetric')/(length(find(hs==1)));
end

% compute center-surround contrast:
r    = var_cen./(var_sur+1.e-6);

% apply contrast non-linearity:
zctr = r.^2./(1+r.^2);

end
