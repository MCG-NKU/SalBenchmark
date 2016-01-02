function out=fill_border(in,bw)

hh=size(in,1);
ww=size(in,2);
dd=size(in,3);

if(dd==1)
	out=zeros(hh+bw*2,ww+bw*2);
	
	out(1:bw,1:bw)=ones(bw,bw).*in(1,1);
	out(bw+hh+1:2*bw+hh,1:bw)=ones(bw,bw).*in(hh,1);
	out(1:bw,bw+1+ww:2*bw+ww)=ones(bw,bw).*in(1,ww);
	out(bw+hh+1:2*bw+hh,bw+1+ww:2*bw+ww)=ones(bw,bw).*in(hh,ww);
	out( bw+1:bw+hh,bw+1:bw+ww )= in;
	out(1:bw,bw+1:bw+ww)=ones(bw,1)*in(1,:);
	out(bw+hh+1:2*bw+hh,bw+1:bw+ww)=ones(bw,1)*in(hh,:);
	out(bw+1:bw+hh,1:bw)=in(:,1)*ones(1,bw);
	out(bw+1:bw+hh,bw+ww+1:2*bw+ww)=in(:,ww)*ones(1,bw);
else
  	out=zeros(hh+bw*2,ww+bw*2,dd);
    for(ii=1:dd)
    	out(1:bw,1:bw,ii)=ones(bw,bw).*in(1,1,ii);
		out(bw+hh+1:2*bw+hh,1:bw,ii)=ones(bw,bw).*in(hh,1,ii);
		out(1:bw,bw+1+ww:2*bw+ww,ii)=ones(bw,bw).*in(1,ww,ii);
		out(bw+hh+1:2*bw+hh,bw+1+ww:2*bw+ww,ii)=ones(bw,bw).*in(hh,ww,ii);
		out( bw+1:bw+hh,bw+1:bw+ww,ii )= in(:,:,ii);
		out(1:bw,bw+1:bw+ww,ii)=ones(bw,1)*in(1,:,ii);
		out(bw+hh+1:2*bw+hh,bw+1:bw+ww,ii)=ones(bw,1)*in(hh,:,ii);
		out(bw+1:bw+hh,1:bw,ii)=in(:,1,ii)*ones(1,bw);
		out(bw+1:bw+hh,bw+ww+1:2*bw+ww,ii)=in(:,ww,ii)*ones(1,bw);
    end
end