function map = mynorm(map,param)

if ( param.subtractMin )
  map = mat2gray(map);
else
  map = map / max(map(:));
end