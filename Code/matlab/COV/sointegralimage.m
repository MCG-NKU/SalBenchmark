% copyright MERL, Fatih Porikli, 2005

function X = sointegralimage(I)

[n,m,d] = size(I);
X = zeros(n,m,d*d);

for i=1:d
    for j=1:d
        X(1,1,i+(j-1)*d) = I(1,1,i)*I(1,1,j);
        for y = 2 : n
            X(y,1,i+(j-1)*d) = X(y-1,1,i+(j-1)*d) + I(y,1,i)*I(y,1,j);
        end;
        for x = 2 : m
            X(1,x,i+(j-1)*d) = X(1,x-1,i+(j-1)*d) + I(1,x,i)*I(1,x,j);
        end;
    end;
end;

for i=1:d
    for j=1:d
        for y = 2 : n
            for x = 2 : m
                X(y,x,i+(j-1)*d) = X(y,x-1,i+(j-1)*d) + X(y-1,x,i+(j-1)*d) - X(y-1,x-1,i+(j-1)*d) + I(y,x,i)*I(y,x,j);
            end;
        end;
    end;
end;