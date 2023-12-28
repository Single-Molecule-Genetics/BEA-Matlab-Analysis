function tab=decode_base(id,ndims)
%
%  str=decode_base(id,ndims)%
%   
%  Transform a class identifiant id (0:15) to a table
%
%  eg: decode_base_str(10,4) -> [1  0  1  0]
%
%  

% Argument checking
if nargin<2
    ndims=4;
end

% decode to binary a number stored as a string
tmp = dec2bin(id,ndims);
% convert the strings to an array
tab=zeros(size(tmp));
for j=1:size(tab,2)
    for i=1:size(tab,1)
        tab(i,j)=str2double(tmp(i,size(tab,2)-j+1));
    end
end