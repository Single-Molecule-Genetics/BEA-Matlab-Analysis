function s=code2str(d,n)
%
% decode a code based on [?? 00 01 10 11] combinations
%
%

if nargin<2
    n=1;
end
d=d(:);
n=max(n,log(max(max(d),4))/log(5)); % minmal number of digit

x=mod(floor((d)*5.^(0:-1:1-n)),5);

cs(1).str='??';
cs(2).str='00';
cs(3).str='10';
cs(4).str='01';
cs(5).str='11';

for j=1:size(x,2);
   for i=1:size(x,1);
       s(i,2*j-1:2*j)=cs(x(i,j)+1).str;
   end
end


return