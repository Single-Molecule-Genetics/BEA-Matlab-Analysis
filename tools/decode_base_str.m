function str=decode_base_str(id,nblanks,ndims)
%
%  str=decode_base_str(id,n)
%  str=decode_base_str(id)
%
%   
%  Transform a class identifiant id (0:15) to a string
%  and insert 'n' blanks (3 by default)
%
%  eg: decode_base_str(10,2) -> 1  0  1  0
%
%  

% Argument checking
if nargin<2
    nblanks=3; % default number of blanks
end
n=max(1,nblanks);

if nargin<3
    ndims=4;
end

% decode to binary a number
tmp = dec2bin(id,ndims);

% Add some blanks
str=blanks(nblanks*length(tmp));
for i=1:length(tmp)
    str(nblanks*i-nblanks+1)=tmp(length(tmp)-i+1);    
    if nblanks>1
        str(nblanks*i-nblanks+2:n*i)=' '; 
    end
end