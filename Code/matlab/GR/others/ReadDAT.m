function B = ReadDAT(image_size,data_path)

row = image_size(1);
colomn = image_size(2);
fid = fopen(data_path,'r');
A = fread(fid, row * colomn, 'uint32')';
fclose(fid);
A = A + 1;
B = reshape(A,[colomn, row]);
B = B';
