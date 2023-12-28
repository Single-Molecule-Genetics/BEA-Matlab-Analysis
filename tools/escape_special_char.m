function dest=escape_special_char(src)
%
% escape_special_char(src)
%
% converts '_' into '\_'
%
    
j=1;
for i=1:length(src)
    if src(i)=='_'
        dest(j:j+1)='\_';
        j=j+2;
    else
        dest(j)=src(i);
        j=j+1;
    end
end