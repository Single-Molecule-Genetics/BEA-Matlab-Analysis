function base=encode_base(class)
%
% base=encode_base(class)
%
% encode a n-uplet into a decimal value
%
% eg: [0 1 0 1] -> 10
%

base = sum((ones(size(class,1),1)*2.^(0:size(class,2)-1)).*(class>.5),2);
