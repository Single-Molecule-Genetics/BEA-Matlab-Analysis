function s=code2seq(d,map)
%
% s=code2seq(d,map)
% decode a code in to a nucleotid sequence defined by map
%
%

d=d(:);
n=max(1,ceil(log(max(max(d),4))/log(5))); % minmal number of digit

x=mod(floor((d)*5.^(0:-1:1-n)),5);

s=[];
for j=1:size(x,2)
    for i=1:size(x,1)
        k = x(i,j)+1; % 2x2 code
        %disp(sprintf('%d %d %s %s',j,k,cs(k).str,map(2*j-1:2*j)));
        switch k
            case 1
                s(i,j)='?';
            case 2
                s(i,j)='0';
            case 3
                if 2*j-1<=length(map)
                    s(i,j)=map(2*j-1);
                else
                    s(i,j)='x';
                end
            case 4
                if 2*j<=length(map)
                    s(i,j)=map(2*j);
                else
                    s(i,j)='x';
                end
            case 5
                s(i,j)='1';
            otherwise
                s(i,j)='x';
        end
    end
end
s=char(s);

return