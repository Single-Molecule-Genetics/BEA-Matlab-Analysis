function code=str2code(str)
% Converts a string to a code
%
% See code2str

cs(1).str='??';
cs(2).str='00';
cs(3).str='10';
cs(4).str='01';
cs(5).str='11';

code=zeros(size(str,1),1);
for j=1:size(str,1)
    for i=1:size(str,2)/2
        for k=1:length(cs)
            if str(j,2*i-1:2*i)==cs(k).str
                c=k-1;
                break;
            end
        end
        code(j)=code(j)+c*5^(i-1);
    end
end