function output_im  = BoostImage(input_im,Mboost)
% transform input_im according to Mboost matrix

R=reshape(input_im(:,:,1),1,size(input_im,1)*size(input_im,2));
G=reshape(input_im(:,:,2),1,size(input_im,1)*size(input_im,2));
B=reshape(input_im(:,:,3),1,size(input_im,1)*size(input_im,2));

output_im=Mboost*[R;G;B];
output_im=reshape(output_im',size(input_im,1),size(input_im,2),size(input_im,3));