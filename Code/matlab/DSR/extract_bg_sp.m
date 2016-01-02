function bg_sp = extract_bg_sp(sulabel,r,c)
%% Find the superpixel label for each background templates.
r1=unique(sulabel(1,:));
rend=unique(sulabel(r,:));
c1=unique(sulabel(:,1));
cend=unique(sulabel(:,c));
bg_sp=[r1 rend c1' cend'];
bg_sp = unique(bg_sp);