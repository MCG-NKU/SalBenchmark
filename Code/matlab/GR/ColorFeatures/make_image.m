function im=make_image(R,G,B)

im=zeros(size(R,1),size(R,2),3);
im(:,:,1)=R;
im(:,:,2)=G;
im(:,:,3)=B;