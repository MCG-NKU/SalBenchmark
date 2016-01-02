function adjcMerge = AdjcProc(M,No)

adjcMerge = zeros(No,No);
[m n p] = size(M);
for i = 1:m-1
    for j = 1:n-1
        if(M(i,j)~=M(i,j+1))
            adjcMerge(M(i,j),M(i,j+1)) = 1;
            adjcMerge(M(i,j+1),M(i,j)) = 1;
        end;
        if(M(i,j)~=M(i+1,j))
            adjcMerge(M(i,j),M(i+1,j)) = 1;
            adjcMerge(M(i+1,j),M(i,j)) = 1;
        end;
        if(M(i,j)~=M(i+1,j+1))
            adjcMerge(M(i,j),M(i+1,j+1)) = 1;
            adjcMerge(M(i+1,j+1),M(i,j)) = 1;
        end;
        if(M(i+1,j)~=M(i,j+1))
            adjcMerge(M(i+1,j),M(i,j+1)) = 1;
            adjcMerge(M(i,j+1),M(i+1,j)) = 1;
        end;
    end;
end;