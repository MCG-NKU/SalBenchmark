% demo code for paper "Graph-regularized Saliency Detection with Convex-hull-based Center Prior" 
% written by chuan yang
% email: ycscience86@gmail.com

clear all;
%% paramter
deltaw=0.05; %% controal edge weight 
spnumber=200;%% superpixels number
deltap=0.2;
deltax=0.15;
deltay=0.15;
lamda=25;
%convex hull paramter
sigma_g=1.5;
sigma_a=5;
nPoints=30;
%
imgRoot='./test/';%% test image dir
outdir='./saliencymaps/';%% the output saliency map saving dir
supdir='./superpixels200/';%% the superpixels files saving dir
mkdir(supdir);
mkdir(outdir);
imnames=dir([imgRoot '*' 'jpg']);
addpath('./others/');
addpath('./ColorFeatures/');
for ii=1:length(imnames);
  
    ii
    imname=[imgRoot imnames(ii).name]; 
    input_im=imread(imname); 
    outname=[imgRoot imnames(ii).name(1:end-4) '.bmp'];
    imwrite(input_im,outname);
    input_im=im2double(input_im);
    [m,n,z] = size(input_im);
    
%% generate superpixels
    comm=['SLICSuperpixelSegmentation' ' ' outname ' ' int2str(20) ' ' int2str(spnumber) ' ' supdir];
    system(comm);    
    spname=[supdir imnames(ii).name(1:end-4)  '.dat'];
    superpixels=ReadDAT([m,n],spname);
    spnum=max(max(superpixels));   
  
%% initial saliency map
    % compute convex hull
    Mboost = BoostMatrix(input_im);
    boost_im= BoostImage(input_im,Mboost);
    [EnIm]= ColorHarris(boost_im,sigma_g,sigma_a,0.04,1);
    [x_max,y_max,corner_im2,num_max]=getmaxpoints(EnIm,nPoints);

    [x,y]=find(corner_im2>0);
    point=[x,y];
    point=point(point(:,1)>20,:);
    point=point(point(:,1)<m-20,:);
    point=point(point(:,2)>20,:);
    point=point(point(:,2)<n-20,:);
    x=point(:,1);
    y=point(:,2);
    dis=zeros(length(x),1);
    for i=1:length(x)
        dis(i)=0;
        for j=1:length(x)
            dis(i)=dis(i)+sqrt((x(i)-x(j))^2+(y(i)-y(j))^2);
        end
        dis(i)=dis(i)/length(x);
    end
    [md,mind]=sort(dis);clear dis;
    point=point(mind(1:length(x)-2),:);
    dt = DelaunayTri(point(:,2),point(:,1));
    k = convexHull(dt);
    [X,Y] = meshgrid(1:n,1:m);
    Xl=reshape(X,[m*n,1]);
    Yl=reshape(Y,[m*n,1]);
    sI=pointLocation(dt,Xl,Yl);
    mask = ~isnan(sI);    
    mask=reshape(mask,m,n); 
 
    % compute convex-hull-based center 
    STATS = regionprops(mask,'Centroid');
    center(2) = STATS(length(STATS)).Centroid(1);
    center(1)=STATS(length(STATS)).Centroid(2);
    center(1)=center(1)/m;
    center(2)=center(2)/n;
    
    % convex-hull-based center prior  
    inds=cell(spnum,1);
    input_vals=reshape(input_im, m*n, z);
    rgb_img=zeros(spnum,1,3);
    location_vals=zeros(spnum,2);
    sup_center_prior=zeros(spnum,1);
    for i=1:spnum
        inds{i}=find(superpixels==i);
        rgb_img(i,1,:)=mean(input_vals(inds{i},:),1);
        [mm,nn]=ind2sub(size(superpixels),inds{i});
        location_vals(i,1)=mean(mm/m);
        location_vals(i,2)=mean(nn/n);
        sup_center_prior(i)=exp(-((location_vals(i,1)-center(1))^2/(2*deltax)+(location_vals(i,2)-center(2))^2/(2*deltay)));
    end  
    
    % color contrast prior
    lab_img = colorspace('Lab<-', rgb_img); 
    loc_dis=dist(location_vals');
    loc_dis=exp(-loc_dis/(2*deltap)); 
    lab_vals=reshape(lab_img,spnum,3);
    lab_dis=dist(lab_vals');
    sal_lab=sum(lab_dis.*loc_dis);

    % combine contrast and convex-hull-based center
    sal_labn=sal_lab.*sup_center_prior';

%% get edges
    edges2l=[];
    adj=AdjcProc(superpixels,spnum);
    for i=1:spnum
        ind=find(adj(i,:)==1);
        ind1=ind((ind>i));
        if(~isempty(ind1))
            ed=ones(length(ind1),2);
            ed(:,2)=i*ed(:,2);
            ed(:,1)=ind1;
            edges2l=[edges2l;ed];
        end
    end

%% make affnity matrix
    weightsXl = makeweights(edges2l,lab_vals,1/(2*deltaw));
    W = adjacency(edges2l,weightsXl,spnum);
    dd = sum(W); D = sparse(1:spnum,1:spnum,dd); clear dd;
    aff =(D-W+(1/(2*lamda))*eye(spnum))\eye(spnum)*sal_labn'; 
    salmaps=zeros(m,n);
%% assign the saliency value to each pixel
    for i=1:spnum
        salmaps((superpixels==i))=aff(i);
    end
    salmaps=(salmaps-min(salmaps(:)))/(max(salmaps(:))-min(salmaps(:)));
    salmaps=salmaps*255;
    salmaps=uint8(salmaps);
    outname=[outdir imnames(ii).name(1:end-4) '_our' '.png'];   
    imwrite(salmaps,outname);
   
end
