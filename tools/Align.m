function sIm = Align(Im, x);
% Shift image Im with the coordinates in x
sIm = Im;
if (x(1)>0)                            
    sIm = padarray(sIm,[x(1),0],0, 'post');
    sIm = sIm(x(1)+1:end,:);
else if (x(1)<0)                           
    sIm = padarray(sIm,[abs(x(1)),0],0, 'pre');
    sIm = sIm(1:end-abs(x(1)),:);
    end
end

if (x(2)>0)                          
    sIm = padarray(sIm,[0 x(2)],0, 'post');
    sIm = sIm(:,x(2)+1:end);
else if (x(2)<0)                           
    sIm = padarray(sIm,[0 abs(x(2))],0, 'pre');
    sIm = sIm(:,1:end-abs(x(2)));
    end
end