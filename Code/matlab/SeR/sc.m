function I = sc(I, varargin)
%SC  Display/output truecolor images with a range of colormaps
%
% Examples:
%   sc(image)
%   sc(image, limits)
%   sc(image, map)
%   sc(image, limits, map)
%   sc(image, map, limits)
%   sc(..., col1, mask1, col2, mask2,...)
%   out = sc(...)
%   sc
%
% Generates a truecolor RGB image based on the input values in 'image' and
% any maximum and minimum limits specified, using the colormap specified.
% The image is displayed on screen if there is no output argument.
% 
% SC has these advantages over MATLAB image rendering functions:
%   - images can be displayed or output; makes combining/overlaying images
%     simple.
%   - images are rendered/output in truecolor (RGB [0,1]); no nasty
%     discretization of the input data.
%   - many special, built-in colormaps for viewing various types of data.
%   - linearly interpolates user defined linear and non-linear colormaps.
%   - no border and automatic, integer magnification (unless figure is
%     docked or maximized) for better display.
%   - multiple images can be generated for export simultaneously.
%
% For a demonstration, simply call SC without any input arguments.
%
% IN:
%   image - MxNxCxP or 3xMxNxP image array. MxN are the dimensions of the
%           image(s), C is the number of channels, and P the number of
%           images. If P > 1, images can only be exported, not displayed.
%   limits - [min max] where values in image less than min will be set to
%            min and values greater than max will be set to max.
%   map - Kx3 or Kx4 user defined colormap matrix, where the optional 4th
%         column is the relative distance between colours along the scale,
%         or a string containing the name of the colormap to use to create
%         the output image. Default: 'none', which is RGB for 3-channel
%         images, grayscale otherwise.  Conversion of multi-channel images
%         to intensity for intensity-based colormaps is done using the L2
%         norm. Most MATLAB colormaps are supported. All named colormaps
%         can be reversed by prefixing '-' to the string. This maintains
%         integrity of the colorbar. Special, non-MATLAB colormaps are:
%      'contrast' - a high contrast colormap for intensity images that
%                   maintains intensity scale when converted to grayscale,
%                   for example when printing in black & white.
%      'prob' - first channel is plotted as hue, and the other channels
%               modulate intensity. Useful for laying probabilites over
%               images.
%      'prob_jet' - first channel is plotted as jet colormap, and the other
%                   channels modulate intensity.
%      'diff' - intensity values are marked blue for > 0 and red for < 0.
%               Darker colour means larger absolute value. For multi-
%               channel images, the L2 norm of the other channels sets
%               green level. 3 channel images are converted to YUV and
%               images with more that 3 channels are projected onto the
%               principle components first.
%      'compress' - compress many channels to RGB while maximizing
%                   variance.
%      'flow' - display two channels representing a 2d Cartesian vector as
%               hue for angle and intensity for magnitude (darker colour
%               indicates a larger magnitude).
%      'phase' - first channel is intensity, second channel is phase in
%                radians. Darker colour means greater intensity, hue
%                represents phase from 0 to 2 pi.
%      'stereo' - pair of concatenated images used to generate a red/cyan
%                 anaglyph.
%      'stereo_col' - pair of concatenated RGB images used to generate a
%                     colour anaglyph.
%      'rand' - gives an index image a random colormap. Useful for viewing
%               segmentations.
%      'rgb2gray' - converts an RGB image to grayscale in the same fashion
%                   as MATLAB's rgb2gray (in the image processing toolbox).
%   col/mask pairs - Pairs of parameters for coloring specific parts of the
%                    image differently. The first (col) parameter can be
%                    a MATLAB color specifier, e.g. 'b' or [0.5 0 1], or
%                    one of the colormaps named above, or an MxNx3 RGB
%                    image. The second (mask) paramater should be an MxN
%                    logical array indicating those pixels (true) whose
%                    color should come from the specified color parameter.
%                    If there is only one col parameter, without a mask
%                    pair, then mask = any(isnan(I, 3)), i.e. the mask is
%                    assumed to indicate the location of NaNs. Note that
%                    col/mask pairs are applied in order, painting over
%                    previous pixel values.
%
% OUT:
%   out - MxNx3xP truecolour (double) RGB image array in range [0, 1]
%
% See also IMAGE, IMAGESC, IMSHOW, COLORMAP, COLORBAR.

% $Id: sc.m,v 1.81 2008/12/10 23:14:43 ojw Exp $
% Copyright: Oliver Woodford, 2007

%% Check for arguments
if nargin == 0
    % If there are no input arguments then run the demo
    if nargout > 0
        error('Output expected from no inputs!');
    end
    demo; % Run the demo
    return
end

%% Size our image(s)
[y x c n] = size(I);
I = reshape(I, y, x, c, n);

%% Check if image is given with RGB colour along the first dimension
if y == 3 && c > 3
    % Flip colour to 3rd dimension
    I = permute(I, [2 3 1 4]);
    [y x c n] = size(I);
end

%% Don't do much if I is empty
if isempty(I)
    if nargout == 0
        % Clear the current axes if we were supposed to display the image
        cla; axis off;
    else
        % Create an empty array with the correct dimensions
        I = zeros(y, x, (c~=0)*3, n);
    end
    return
end

%% Check for multiple images
% If we have a non-singleton 4th dimension we want to display the images in
% a 3x4 grid and use buttons to cycle through them
if n > 1
    if nargout > 0
        % Return transformed images in an YxXx3xN array
        A = zeros(y, x, 3, n);
        for a = 1:n
            A(:,:,:,a) = sc(I(:,:,:,a), varargin{:});
        end
        I = A;
    else
        % Removed functionality
        fprintf([' SC no longer supports the display of multiple images. The\n'...
                 ' functionality has been incorporated into an improved version\n'...
                 ' of MONTAGE, available on the MATLAB File Exchange at:\n'...
                 '    http://www.mathworks.com/matlabcentral/fileexchange/22387\n']);
        clear I;
    end
    return
end

%% Parse the input arguments coming after I (1st input)
[map limits mask] = parse_inputs(I, varargin, y, x);

%% Call the rendering function
I = reshape(double(real(I)), y*x, c); % Only work with real doubles
if ~ischar(map)
    % Table-based colormap
    reverseMap = false;
    [I limits] = interp_map(I, limits, reverseMap, map);
else
    % If map starts with a '-' sign, invert the colourmap
    reverseMap = map(1) == '-';
    map = lower(map(reverseMap+1:end));
    
    % Predefined colormap
    [I limits] = colormap_switch(I, map, limits, reverseMap, c);
end

%% Update any masked pixels
I = reshape(I, y*x, 3);
for a = 1:size(mask, 2)
    I(mask{2,a},1) = mask{1,a}(:,1);
    I(mask{2,a},2) = mask{1,a}(:,2);
    I(mask{2,a},3) = mask{1,a}(:,3);
end
I = reshape(I, [y x 3]); % Reshape to correct size


%% Only display if the output isn't used
if nargout == 0
    display_image(I, map, limits, reverseMap);
    % Don't print out the matrix if we've forgotten the ";"
    clear I
end
return

%% Colormap switch
function [I limits] = colormap_switch(I, map, limits, reverseMap, c)
% Large switch statement for all the colourmaps
switch map
%% Prism
    case 'prism'
        % Similar to the MATLAB internal prism colormap, but only works on
        % index images, assigning each index (or rounded float) to a
        % different colour
        [I limits] = index_im(I);
        % Generate prism colourmap
        map = prism(6);
        if reverseMap
            map = map(end:-1:1,:); % Reverse the map
        end
        % Lookup the colours
        I = mod(I, 6) + 1;
        I = map(I,:);
%% Rand
    case 'rand'
        % Assigns a random colour to each index
        [I limits num_vals] = index_im(I);
        % Generate random colourmap
        map = rand(num_vals, 3);
        % Lookup the colours
        I = map(I,:);
%% Diff
    case 'diff'
        % Show positive as blue and negative as red, white is 0
        switch c
            case 1
                I(:,2:3) = 0;
            case 2
                % Second channel can only have absolute value
                I(:,3) = abs(I(:,2));
            case 3
                % Diff of RGB images - convert to YUV first
                I = rgb2yuv(I);
                I(:,3) = sqrt(sum(I(:,2:end) .^ 2, 2)) ./ sqrt(2);
            otherwise
                % Use difference along principle component, and other
                % channels to modulate second channel
                I = calc_prin_comps(I);
                I(:,3) = sqrt(sum(I(:,2:end) .^ 2, 2)) ./ sqrt(c - 1);
                I(:,4:end) = [];
        end
        % Generate limits
        if isempty(limits)
            limits = [min(I(:,1)) max(I(:,1))];
        end
        limits = max(abs(limits));
        if limits
            % Scale
            if c > 1
                I(:,[1 3]) = I(:,[1 3]) / limits;
            else
                I = I / (limits * 0.5);
            end
        end
        % Colour
        M = I(:,1) > 0;
        I(:,2) = -I(:,1) .* ~M;
        I(:,1) = I(:,1) .* M;
        if reverseMap
            % Swap first two channels
            I = I(:,[2 1 3]);
        end
        %I = 1 - I * [1 0.4 1; 0.4 1 1; 1 1 0.4]; % (Green/Red)
        I = 1 - I * [1 1 0.4; 0.4 1 1; 1 0.4 1]; % (Blue/Red)
        I = min(max(reshape(I, numel(I), 1), 0), 1);
        limits = [-limits limits]; % For colourbar
%% Flow
    case 'flow'
        % Calculate amplitude and phase, and use 'phase'
        if c ~= 2
            error('''flow'' requires two channels');
        end
        A = sqrt(sum(I .^ 2, 2));
        if isempty(limits)
            limits = [min(A) max(A)*2];
        else
            limits = [0 max(abs(limits)*sqrt(2))*2];
        end
        I(:,1) = atan2(I(:,2), I(:,1));
        I(:,2) = A;
        if reverseMap
            % Invert the amplitude
            I(:,2) = -I(:,2);
            limits = -limits([2 1]);
        end
        I = phase_helper(I, limits, 2); % Last parameter tunes how saturated colors can get
        % Set NaNs (unknown flow) to 0
        I(isnan(I)) = reverseMap;
        limits = []; % This colourmap doesn't have a valid colourbar
%% Phase
    case 'phase'
        % Plot amplitude as intensity and angle as hue
        if c < 2
            error('''phase'' requires two channels');
        end
        if isempty(limits)
            limits = [min(I(:,1)) max(I(:,1))];
        end
        if reverseMap
            % Invert the phase
            I(:,2) = -I(:,2);
        end
        I = I(:,[2 1]);
        if diff(limits)
            I = phase_helper(I, limits, 1.3); % Last parameter tunes how saturated colors can get
        else
            % No intensity - just cycle hsv
            I = hsv_helper(mod(I(:,1) / (2 * pi), 1));
        end
        limits = []; % This colourmap doesn't have a valid colourbar
%% RGB2Grey
    case {'rgb2grey', 'rgb2gray'}
        % Compress RGB to greyscale
        [I limits] = rgb2grey(I, limits, reverseMap);
%% RGB2YUV
    case 'rgb2yuv'
        % Convert RGB to YUV - not for displaying or saving to disk!
        [I limits] = rgb2yuv(I);
%% YUV2RGB
    case 'yuv2rgb'
        % Convert YUV to RGB - undo conversion of rgb2yuv
        if c ~= 3
            error('''yuv2rgb'' requires a 3 channel image');
        end
        I = reshape(I, y*x, 3);
        I = I * [1 1 1; 0, -0.39465, 2.03211; 1.13983, -0.58060  0];
        I = reshape(I, y, x, 3);
        I = sc(I, limits);
        limits = []; % This colourmap doesn't have a valid colourbar
%% Prob
    case 'prob'
        % Plot first channel as grey variation of 'bled' and modulate
        % according to other channels
        if c > 1
            A = rgb2grey(I(:,2:end), [], false);
            I = I(:,1);
        else
            A = 0.5;
        end
        [I limits] = bled(I, limits, reverseMap);
        I = normalize(A + I, [-0.1 1.3]);
%% Prob_jet
    case 'prob_jet'
        % Plot first channel as 'jet' and modulate according to other
        % channels
        if c > 1
            A = rgb2grey(I(:,2:end), [], false);
            I = I(:,1);
        else
            A = 0.5;
        end
        [I limits] = jet_helper(I, limits, reverseMap);
        I = normalize(A + I, [0.2 1.8]);
%% Compress
    case 'compress'
        % Compress to RGB, maximizing variance
        % Determine and scale to limits
        I = normalize(I, limits);
        if reverseMap
            % Invert after everything
            I = 1 - I;
        end
        % Zero mean
        meanCol = mean(I, 1);
        isBsx = exist('bsxfun', 'builtin');
        if isBsx
            I = bsxfun(@minus, I, meanCol);
        else
            I = I - meanCol(ones(x*y, 1, 'uint8'),:);
        end
        % Calculate top 3 principle components
        I = calc_prin_comps(I, 3);
        % Normalize each channel independently
        if isBsx
            I = bsxfun(@minus, I, min(I, [], 1));
            I = bsxfun(@times, I, 1./max(I, [], 1));
        else
            for a = 1:3
                I(:,a) = I(:,a) - min(I(:,a));
                I(:,a) = I(:,a) / max(I(:,a));
            end
        end
        % Put components in order of human eyes' response to channels
        I = I(:,[2 1 3]);
        limits = []; % This colourmap doesn't have a valid colourbar
%% Stereo (anaglyph)
    case 'stereo'
        % Convert 2 colour images to intensity images
        % Show first channel as red and second channel as cyan
        A = rgb2grey(I(:,1:floor(end/2)), limits, false);
        I = rgb2grey(I(:,floor(end/2)+1:end), limits, false);
        if reverseMap
            I(:,2:3) = A(:,1:2); % Make first image cyan
        else
            I(:,1) = A(:,1); % Make first image red
        end
        limits = []; % This colourmap doesn't have a valid colourbar
%% Coloured anaglyph
    case 'stereo_col'
        if c ~= 6
            error('''stereo_col'' requires a 6 channel image');
        end
        I = normalize(I, limits);
        % Red channel from one image, green and blue from the other
        if reverseMap
            I(:,1) = I(:,4); % Make second image red
        else
            I(:,2:3) = I(:,5:6); % Make first image red
        end
        I = I(:,1:3);
        limits = []; % This colourmap doesn't have a valid colourbar
%% None
    case 'none'
        % No colour map - just output the image
        if c ~= 3
            [I limits] = grey(I, limits, reverseMap);
        else
            I = intensity(I(:), limits, reverseMap);
            limits = [];
        end
%% Grey
    case {'gray', 'grey'}
        % Greyscale
        [I limits] = grey(I, limits, reverseMap);
%% Jet
    case 'jet'
        % Dark blue to dark red, through green
        [I limits] = jet_helper(I, limits, reverseMap);
%% Hot
    case 'hot'
        % Black to white through red and yellow
        [I limits] = interp_map(I, limits, reverseMap, [0 0 0 3; 1 0 0 3; 1 1 0 2; 1 1 1 1]);
%% Contrast
    case 'contrast'
        % A high contrast, full-colour map that goes from black to white
        % linearly when converted to greyscale, and passes through all the
        % corners of the RGB colour cube
        [I limits] = interp_map(I, limits, reverseMap, [0 0 0 114; 0 0 1 185; 1 0 0 114; 1 0 1 174;...
                                                        0 1 0 114; 0 1 1 185; 1 1 0 114; 1 1 1 0]);
%% HSV
    case 'hsv'
        % Cycle through hues
        [I limits] = intensity(I, limits, reverseMap); % Intensity map
        I = hsv_helper(I);
%% Bone
    case 'bone'
        % Greyscale with a blue tint
        [I limits] = interp_map(I, limits, reverseMap, [0 0 0 3; 21 21 29 3; 42 50 50 2; 64 64 64 1]/64);
%% Colourcube
    case {'colorcube', 'colourcube'}
        % Psychedelic colourmap inspired by MATLAB's version
        [I limits] = intensity(I, limits, reverseMap); % Intensity map
        step = 4;
        I = I * (step * (1 - eps));
        J = I * step;
        K = floor(J);
        I = cat(3, mod(K, step)/(step-1), J - floor(K), mod(floor(I), step)/(step-1));
%% Cool
    case 'cool'
        % Cyan through to magenta
        [I limits] = intensity(I, limits, reverseMap); % Intensity map
        I = [I, 1-I, ones(size(I))];
%% Spring
    case 'spring'
        % Magenta through to yellow
        [I limits] = intensity(I, limits, reverseMap); % Intensity map
        I = [ones(size(I)), I, 1-I];
%% Summer
    case 'summer'
        % Darkish green through to pale yellow
        [I limits] = intensity(I, limits, reverseMap); % Intensity map
        I = [I, 0.5+I*0.5, 0.4*ones(size(I))];
%% Autumn
    case 'autumn'
        % Red through to yellow
        [I limits] = intensity(I, limits, reverseMap); % Intensity map
        I = [ones(size(I)), I, zeros(size(I))];
%% Winter
    case 'winter'
        % Blue through to turquoise
        [I limits] = intensity(I, limits, reverseMap); % Intensity map
        I = [zeros(size(I)), I, 1-I*0.5];
%% Copper
    case 'copper'
        % Black through to copper
        [I limits] = intensity(I, limits, reverseMap); % Intensity map
        I = [I*(1/0.8), I*0.78, I*0.5];
        I = min(max(reshape(I, numel(I), 1), 0), 1); % Truncate
%% Pink
    case 'pink'
        % Greyscale with a pink tint
        [I limits] = intensity(I, limits, reverseMap); % Intensity map
        J = I * (2 / 3);
        I = [I, I-1/3, I-2/3];
        I = reshape(max(min(I(:), 1/3), 0), [], 3);
        I = I + J(:,[1 1 1]);
        I = sqrt(I);
%% Bled
    case 'bled'
        % Black to red, through blue
        [I limits] = bled(I, limits, reverseMap);
%% Earth
    case 'earth'
        % High contrast, converts to linear scale in grey, strong
        % shades of green
        table = [0 0 0; 0 0.1104 0.0583; 0.1661 0.1540 0.0248; 0.1085 0.2848 0.1286;...
            0.2643 0.3339 0.0939; 0.2653 0.4381 0.1808; 0.3178 0.5053 0.3239;...
            0.4858 0.5380 0.3413; 0.6005 0.5748 0.4776; 0.5698 0.6803 0.6415;...
            0.5639 0.7929 0.7040; 0.6700 0.8626 0.6931; 0.8552 0.8967 0.6585;...
            1 0.9210 0.7803; 1 1 1];
        [I limits] = interp_map(I, limits, reverseMap, table);
%% Pinker
    case 'pinker'
        % High contrast, converts to linear scale in grey, strong
        % shades of pink
        table = [0 0 0; 0.0455 0.0635 0.1801; 0.2425 0.0873 0.1677;...
            0.2089 0.2092 0.2546; 0.3111 0.2841 0.2274; 0.4785 0.3137 0.2624;...
            0.5781 0.3580 0.3997; 0.5778 0.4510 0.5483; 0.5650 0.5682 0.6047;...
            0.6803 0.6375 0.5722; 0.8454 0.6725 0.5855; 0.9801 0.7032 0.7007;...
            1 0.7777 0.8915; 0.9645 0.8964 1; 1 1 1];
        [I limits] = interp_map(I, limits, reverseMap, table);
%% Pastel
    case 'pastel'
        % High contrast, converts to linear scale in grey, strong
        % pastel shades
        table = [0 0 0; 0.4709 0 0.018; 0 0.3557 0.6747; 0.8422 0.1356 0.8525;
            0.4688 0.6753 0.3057; 1 0.6893 0.0934; 0.9035 1 0; 1 1 1];
        [I limits] = interp_map(I, limits, reverseMap, table);
%% Bright
    case 'bright'
        % High contrast, converts to linear scale in grey, strong
        % saturated shades
        table = [0 0 0; 0.3071 0.0107 0.3925; 0.007 0.289 1; 1 0.0832 0.7084;
            1 0.4447 0.1001; 0.5776 0.8360 0.4458; 0.9035 1 0; 1 1 1];
        [I limits] = interp_map(I, limits, reverseMap, table);
%% Jet2
    case 'jet2'
        % Like jet, but starts in black and goes to saturated red
        [I limits] = interp_map(I, limits, reverseMap, [0 0 0; 0.5 0 0.5; 0 0 0.9; 0 1 1; 0 1 0; 1 1 0; 1 0 0]);
%% Hot2
    case 'hot2'
        % Like hot, but equally spaced
        [I limits] = intensity(I, limits, reverseMap); % Intensity map
        I = I * 3;
        I = [I, I-1, I-2];
        I = min(max(I(:), 0), 1); % Truncate
%% Bone2
    case 'bone2'
        % Like bone, but equally spaced
        [I limits] = intensity(I, limits, reverseMap); % Intensity map
        J = [I-2/3, I-1/3, I];
        J = reshape(max(min(J(:), 1/3), 0), [], 3) * (2 / 5);
        I = I * (13 / 15);
        I = J + I(:,[1 1 1]);
%% Unknown colourmap
    otherwise
        error('Colormap ''%s'' not recognised.', map);
end
return


%% Display image
function display_image(I, map, limits, reverseMap)
% Clear the axes
cla(gca, 'reset');
% Display the image - using image() is fast
hIm = image(I);
% Get handles to the figure and axes (now, as the axes may have
% changed)
hFig = gcf; hAx = gca;
% Axes invisible and equal
set(hFig, 'Units', 'pixels');
set(hAx, 'Visible', 'off', 'DataAspectRatio', [1 1 1], 'DrawMode', 'fast');
% Set data for a colorbar
if ~isempty(limits) && limits(1) ~= limits(2)
    colBar = (0:255) * ((limits(2) - limits(1)) / 255) + limits(1);
    colBar = squeeze(sc(colBar, map, limits));
    if reverseMap
        colBar = colBar(end:-1:1,:);
    end
    set(hFig, 'Colormap', colBar);
    set(hAx, 'CLim', limits);
    set(hIm, 'CDataMapping', 'scaled');
end
% Only resize image if it is alone in the figure
if numel(findobj(get(hFig, 'Children'), 'Type', 'axes')) > 1
    return
end
% Could still be the first subplot - do another check
axesPos = get(hAx, 'Position');
if isequal(axesPos, get(hFig, 'DefaultAxesPosition'))
    % Default position => not a subplot
    % Fill the window
    set(hAx, 'Units', 'normalized', 'Position', [0 0 1 1]);
    axesPos = [0 0 1 1];
end
if ~isequal(axesPos, [0 0 1 1]) || strcmp(get(hFig, 'WindowStyle'), 'docked')
    % Figure not alone, or docked. Either way, don't resize.
    return
end
% Get the size of the monitor we're on
figPosCur = get(hFig, 'Position');
MonSz = get(0, 'MonitorPositions');
MonOn = size(MonSz, 1);
if MonOn > 1
    figCenter = figPosCur(1:2) + figPosCur(3:4) / 2;
    figCenter = MonSz - repmat(figCenter, [MonOn 2]);
    MonOn = all(sign(figCenter) == repmat([-1 -1 1 1], [MonOn 1]), 2);
    MonOn(1) = MonOn(1) | ~any(MonOn);
    MonSz = MonSz(MonOn,:);
end
MonSz(3:4) = MonSz(3:4) - MonSz(1:2) + 1;
% Check if the window is maximized
% This is a hack which may only work on Windows! No matter, though.
if isequal(MonSz([1 3]), figPosCur([1 3]))
    % Leave maximized
    return
end
% Compute the size to set the window
MaxSz = MonSz(3:4) - [20 120];
ImSz = [size(I, 2) size(I, 1)];
RescaleFactor = min(MaxSz ./ ImSz);
if RescaleFactor > 1
    % Integer scale for enlarging, but don't make too big
    MaxSz = min(MaxSz, [1000 680]);
    RescaleFactor = max(floor(min(MaxSz ./ ImSz)), 1);
end
figPosNew = ceil(ImSz * RescaleFactor);
% Don't move the figure if the size isn't changing
if isequal(figPosCur(3:4), figPosNew)
    return
end
% Keep the centre of the figure stationary
figPosNew = [max(1, floor(figPosCur(1:2)+(figPosCur(3:4)-figPosNew)/2)) figPosNew];
% Ensure the figure bar is in bounds
figPosNew(1:2) = min(figPosNew(1:2), MonSz(1:2)+MonSz(3:4)-[6 101]-figPosNew(3:4));
set(hFig, 'Position', figPosNew);
return

%% Parse input variables
function [map limits mask] = parse_inputs(I, inputs, y, x)

% Check the first two arguments for the colormap and limits
ninputs = numel(inputs);
map = 'none';
limits = [];
mask = 1;
for a = 1:min(2, ninputs)
    if ischar(inputs{a}) && numel(inputs{a}) > 1
        % Name of colormap
        map = inputs{a};
    elseif isnumeric(inputs{a})
        [p q r] = size(inputs{a});
        if (p * q * r) == 2
            % Limits
            limits = double(inputs{a});
        elseif p > 1 && (q == 3 || q == 4) && r == 1
            % Table-based colormap
            map = inputs{a};
        else
            break;
        end
    else
        break;
    end
    mask = mask + 1;
end
% Check for following inputs
if mask > ninputs
    mask = cell(2, 0);
    return
end
% Following inputs must either be colour/mask pairs, or a colour for NaNs
if ninputs - mask == 0
    mask = cell(2, 1);
    mask{1} = inputs{end};
    mask{2} = ~all(isfinite(I), 3);
elseif mod(ninputs-mask, 2) == 1
    mask = reshape(inputs(mask:end), 2, []);
else
    error('Error parsing inputs');
end
% Go through pairs and generate
for a = 1:size(mask, 2)
    % Generate any masks from functions
    if isa(mask{2,a}, 'function_handle')
        mask{2,a} = mask{2,a}(I);
    end
    if ~islogical(mask{2,a})
        error('Mask is not a logical array');
    end
    if ~isequal(size(mask{2,a}), [y x])
        error('Mask does not match image size');
    end
    if ischar(mask{1,a})
        if numel(mask{1,a}) == 1
            % Generate colours from MATLAB colour strings
            mask{1,a} = double(dec2bin(strfind('kbgcrmyw', mask{1,a})-1, 3)) - double('0');
        else
            % Assume it's a colormap name
            mask{1,a} = sc(I, mask{1,a});
        end
    end
    mask{1,a} = reshape(mask{1,a}, [], 3);
    if size(mask{1,a}, 1) ~= y*x && size(mask{1,a}, 1) ~= 1
        error('Replacement color/image of unexpected dimensions');
    end
    if size(mask{1,a}, 1) ~= 1
        mask{1,a} = mask{1,a}(mask{2,a},:);
    end
end
return

%% Grey
function [I limits] = grey(I, limits, reverseMap)
% Greyscale
[I limits] = intensity(I, limits, reverseMap);
I = I(:,[1 1 1]);
return

%% RGB2grey
function [I limits] = rgb2grey(I, limits, reverseMap)
% Compress RGB to greyscale
if size(I, 2) == 3
    I = I * [0.299; 0.587; 0.114];
end
[I limits] = grey(I, limits, reverseMap);
return
        
%% RGB2YUV
function [I limits] = rgb2yuv(I)
% Convert RGB to YUV - not for displaying or saving to disk!
if size(I, 2) ~= 3
    error('rgb2yuv requires a 3 channel image');
end
I = I * [0.299, -0.14713, 0.615; 0.587, -0.28886, -0.51498; 0.114, 0.436, -0.10001];
limits = []; % This colourmap doesn't have a valid colourbar
return

%% Phase helper
function I = phase_helper(I, limits, n)
I(:,1) = mod(I(:,1)/(2*pi), 1);
I(:,2) = I(:,2) - limits(1);
I(:,2) = I(:,2) * (n / (limits(2) - limits(1)));
I(:,3) = n - I(:,2);
I(:,[2 3]) = min(max(I(:,[2 3]), 0), 1);
I = hsv2rgb(reshape(I, [], 1, 3));
return

%% Jet helper        
function [I limits] = jet_helper(I, limits, reverseMap)
% Dark blue to dark red, through green
[I limits] = intensity(I, limits, reverseMap);
I = I * 4;
I = [I-3, I-2, I-1];
I = 1.5 - abs(I);
I = reshape(min(max(I(:), 0), 1), size(I));
return

%% HSV helper
function I = hsv_helper(I)
I = I * 6;
I = abs([I-3, I-2, I-4]);
I(:,1) = I(:,1) - 1;
I(:,2:3) = 2 - I(:,2:3);
I = reshape(min(max(I(:), 0), 1), size(I));
return

%% Bled
function [I limits] = bled(I, limits, reverseMap)
% Black to red through blue
[I limits] = intensity(I, limits, reverseMap);
J = reshape(hsv_helper(I), [], 3);
if exist('bsxfun', 'builtin') 
    I = bsxfun(@times, I, J);
else
    I = J .* I(:,[1 1 1]);
end
return

%% Normalize
function [I limits] = normalize(I, limits)
if isempty(limits)
    limits = isfinite(I);
    if ~any(reshape(limits, numel(limits), 1))
        % All NaNs, Infs or -Infs
        I = double(I > 0);
        limits = [0 1];
        return
    end
    limits = [min(I(limits)) max(I(limits))];
    I = I - limits(1);
    if limits(2) ~= limits(1)
        I = I * (1 / (limits(2) - limits(1)));
    end
else
    I = I - limits(1);
    if limits(2) ~= limits(1)
        I = I * (1 / (limits(2) - limits(1)));
    end
    I = reshape(min(max(reshape(I, numel(I), 1), 0), 1), size(I));
end
return

%% Intensity maps
function [I limits] = intensity(I, limits, reverseMap)
% Squash to 1d using L2 norm
if size(I, 2) > 1
    I = sqrt(sum(I .^ 2, 2));
end
% Determine and scale to limits
[I limits] = normalize(I, limits);
if reverseMap
    % Invert after everything
    I = 1 - I;
end
return

%% Interpolate table-based map
function [I limits] = interp_map(I, limits, reverseMap, map)
% Convert to intensity
[I limits] = intensity(I, limits, reverseMap);
% Compute indices and offsets
if size(map, 2) == 4
    bins = map(1:end-1,4);
    cbins = cumsum(bins);
    bins = bins ./ cbins(end);
    cbins = cbins(1:end-1) ./ cbins(end);
    if exist('bsxfun', 'builtin')
        ind = bsxfun(@gt, I(:)', cbins(:));
    else
        ind = repmat(I(:)', [numel(cbins) 1]) > repmat(cbins(:), [1 numel(I)]);
    end
    ind = min(sum(ind), size(map, 1) - 2) + 1;
    bins = 1 ./ bins;
    cbins = [0; cbins];
    I = (I - cbins(ind)) .* bins(ind);
else
    n = size(map, 1) - 1;
    I = I(:) * n;
    ind = min(floor(I), n-1);
    I = I - ind;
    ind = ind + 1;
end
if exist('bsxfun', 'builtin')
    I = bsxfun(@times, map(ind,1:3), 1-I) + bsxfun(@times, map(ind+1,1:3), I);
else
    I = map(ind,1:3) .* repmat(1-I, [1 3]) + map(ind+1,1:3) .* repmat(I, [1 3]);
end
return

%% Index images
function [J limits num_vals] = index_im(I)
% Returns an index image
if size(I, 2) ~= 1
    error('Index maps only work on single channel images');
end
J = round(I);
rescaled = any(abs(I - J) > 0.01);
if rescaled
    % Appears not to be an index image. Rescale over 256 indices
    m = min(I);
    m = m * (1 - sign(m) * eps);
    I = I - m;
    I = I * (256 / max(I(:)));
    J = ceil(I);
    num_vals = 256;
elseif nargout > 2
    % Output the number of values
    J = J - (min(J) - 1);
    num_vals = max(J);
end
% These colourmaps don't have valid colourbars
limits = [];    
return

%% Calculate principle components
function I = calc_prin_comps(I, numComps)
if nargin < 2
    numComps = size(I, 2);
end
% Do SVD
[I S] = svd(I, 0);
% Calculate projection of data onto components
S = diag(S(1:numComps,1:numComps))';
if exist('bsxfun', 'builtin')
    I = bsxfun(@times, I(:,1:numComps), S);
else
    I = I(:,1:numComps) .* S(ones(size(I, 1), 1, 'uint8'),:);
end
return

%% Demo function to show capabilities of sc
function demo
%% Demo gray & lack of border
figure; fig = gcf; Z = peaks(256); sc(Z);
display_text([...
' Lets take a standard, MATLAB, real-valued function:\n\n    peaks(256)\n\n'...
' Calling:\n\n    figure\n    Z = peaks(256);\n    sc(Z)\n\n'...
' gives (see figure). SC automatically scales intensity to fill the\n'...
' truecolor range of [0 1].\n\n'...
' If your figure isn''t docked, then the image will have no border, and\n'...
' will be magnified by an integer factor (in this case, 2) so that the\n'...
' image is a reasonable size.']);

%% Demo colour image display 
figure(fig); clf;
load mandrill; mandrill = ind2rgb(X, map); sc(mandrill);
display_text([...
' That wasn''t so interesting. The default colormap is ''none'', which\n'...
' produces RGB images given a 3-channel input image, otherwise it produces\n'...
' a grayscale image. So calling:\n\n    load mandrill\n'...
'    mandrill = ind2rgb(X, map);\n    sc(mandrill)\n\n gives (see figure).']);

%% Demo discretization
figure(fig); clf;
subplot(121); sc(Z, 'jet'); label(Z, 'sc(Z, ''jet'')');
subplot(122); imagesc(Z); axis image off; colormap(jet(64)); % Fix the fact we change the default depth
label(Z, 'imagesc(Z); axis image off; colormap(''jet'');');
display_text([...
' However, if we want to display intensity images in color we can use any\n'...
' of the MATLAB colormaps implemented (most of them) to give truecolor\n'...
' images. For example, to use ''jet'' simply call:\n\n'...
'    sc(Z, ''jet'')\n\n'...
' The MATLAB alternative, shown on the right, is:\n\n'...
'    imagesc(Z)\n    axis equal off\n    colormap(jet)\n\n'...
' which generates noticeable discretization artifacts.']);

%% Demo intensity colourmaps
figure(fig); clf;
subplot(221); sc(Z, 'hsv'); label(Z, 'sc(Z, ''hsv'')');
subplot(222); sc(Z, 'colorcube'); label(Z, 'sc(Z, ''colorcube'')');
subplot(223); sc(Z, 'contrast'); label(Z, 'sc(Z, ''contrast'')');
subplot(224); sc(Z-round(Z), 'diff'); label(Z, 'sc(Z-round(Z), ''diff'')');
display_text([...
' There are several other intensity colormaps to choose from. Calling:\n\n'...
'    help sc\n\n'...
' will give you a list of them. Here are several others demonstrated.']);

%% Demo saturation limits & colourmap reversal
figure(fig); clf;
subplot(121); sc(Z, [0 max(Z(:))], '-hot'); label(Z, 'sc(Z, [0 max(Z(:))], ''-hot'')');
subplot(122); sc(mandrill, [-0.5 0.5]); label(mandrill, 'sc(mandrill, [-0.5 0.5])');
display_text([...
' SC can also rescale intensity, given an upper and lower bound provided\n'...
' by the user, and invert most colormaps simply by prefixing a ''-'' to the\n'...
' colormap name. For example:\n\n'...
'    sc(Z, [0 max(Z(:))], ''-hot'');\n'...
'    sc(mandrill, [-0.5 0.5]);\n\n'...
' Note that the order of the colormap and limit arguments are\n'...
' interchangable.']);

%% Demo prob
load gatlin;
gatlin = X;
figure(fig); clf; im = cat(3, abs(Z)', gatlin(1:256,end-255:end)); sc(im, 'prob');
label(im, 'sc(cat(3, prob, gatlin), ''prob'')');
display_text([...
' SC outputs the recolored data as a truecolor RGB image. This makes it\n'...
' easy to combine colormaps, either arithmetically, or by masking regions.\n'...
' For example, we could combine an image and a probability map\n'...
' arithmetically as follows:\n\n'...
'    load gatlin\n'...
'    gatlin = X(1:256,end-255:end);\n'...
'    prob = abs(Z)'';\n'...
'    im = sc(prob, ''hsv'') .* sc(prob, ''gray'') + sc(gatlin, ''rgb2gray'');\n'...
'    sc(im, [-0.1 1.3]);\n\n'...
' In fact, that particular colormap has already been implemented in SC.\n'...
' Simply call:\n\n'...
'    sc(cat(3, prob, gatlin), ''prob'');']);

%% Demo colorbar
colorbar;
display_text([...
' SC also makes possible the generation of a colorbar in the normal way, \n'...
' with all the colours and data values correct. Simply call:\n\n'...
'    colorbar\n\n'...
' The colorbar doesn''t work with all colormaps, but when it does,\n'...
' inverting the colormap (using ''-map'') maintains the integrity of the\n'...
' colorbar (i.e. it works correctly) - unlike if you invert the input data.']);

%% Demo combine by masking
figure(fig); clf;
sc(Z, [0 max(Z(:))], '-hot', sc(Z-round(Z), 'diff'), Z < 0);
display_text([...
' It''s just as easy to combine generated images by masking too. Here''s an\n'...
' example:\n\n'...
'    im = cat(4, sc(Z, [0 max(Z(:))], ''-hot''), sc(Z-round(Z), ''diff''));\n'...
'    mask = repmat(Z < 0, [1 1 3]);\n'...
'    mask = cat(4, mask, ~mask);\n'...
'    im = sum(im .* mask, 4);\n'...
'    sc(im)\n\n'...
' In fact, SC can also do this for you, by adding image/colormap and mask\n'...
' pairs to the end of the argument list, as follows:\n\n'...
'    sc(Z, [0 max(Z(:))], ''-hot'', sc(Z-round(Z), ''diff''), Z < 0);\n\n'...
' A benefit of the latter approach is that you can still display a\n'...
' colorbar for the first colormap.']);

%% Demo texture map
figure(fig); clf;
surf(Z, sc(Z, 'contrast'), 'edgecolor', 'none');
display_text([...
' Other benefits of SC outputting the image as an array are that the image\n'...
' can be saved straight to disk using imwrite() (if you have the image\n'...
' processing toolbox), or can be used to texture map a surface, thus:\n\n'...
'    tex = sc(Z, ''contrast'');\n'...
'    surf(Z, tex, ''edgecolor'', ''none'');']);

%% Demo compress
load mri;
mri = D;
close(fig); % Only way to get round loss of focus (bug?)
figure(fig); clf;
sc(squeeze(mri(:,:,:,1:6)), 'compress');
display_text([...
' For images with more than 3 channels, SC can compress these images to RGB\n'...
' while maintaining the maximum amount of variance in the data. For\n'...
' example, this 6 channel image:\n\n'...
'    load mri\n    mri = D;\n    sc(squeeze(mri(:,:,:,1:6), ''compress'')']);

%% Demo multiple images
figure(fig); clf; im = sc(mri, 'bone');
for a = 1:12
    subplot(3, 4, a);
    sc(im(:,:,:,a));
end
display_text([...
' SC can process multiple images for export when passed in as a 4d array.\n'...
' For example:\n\n'...
'    im = sc(mri, ''bone'')\n'...
'    for a = 1:12\n'...
'       subplot(3, 4, a);\n'...
'       sc(im(:,:,:,a));\n'...
'    end']);

%% Demo user defined colormap
figure(fig); clf; sc(abs(Z), rand(10, 3)); colorbar;
display_text([...
' Finally, SC can use user defined colormaps to display indexed images.\n'...
' These can be defined as a linear colormap. For example:\n\n'...
'    sc(abs(Z), rand(10, 3))\n    colorbar;\n\n'...
' Note that the colormap is automatically linearly interpolated.']);

%% Demo non-linear user defined colormap
figure(fig); clf; sc(abs(Z), [rand(10, 3) exp((1:10)/2)']); colorbar;
display_text([...
' Non-linear colormaps can also be defined by the user, by including the\n'...
' relative distance between the given colormap points on the colormap\n'...
' scale in the fourth column of the colormap matrix. For example:\n\n'...
'    sc(abs(Z), [rand(10, 3) exp((1:10)/2)''])\n    colorbar;\n\n'...
' Note that the colormap is still linearly interpolated between points.']);

clc; fprintf('End of demo.\n');
return

%% Some helper functions for the demo
function display_text(str)
clc;
fprintf([str '\n\n']);
fprintf('Press a key to go on.\n');
figure(gcf);
waitforbuttonpress;
return

function label(im, str)
text(size(im, 2)/2, size(im, 1)+12, str,...
    'Interpreter', 'none', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
return
