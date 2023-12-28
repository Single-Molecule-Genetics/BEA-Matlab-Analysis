function CheckShifts(fname)

if ~exist('fname')
    %pt = 'E:\Leila\Images\Irene\Scan 11-02-08 J15-45 subset\'%CG'
    %pt = 'Z:\Cambridge\17-02-10\Mixes J11+8clones\1-1 Mix\New scan\'
   % [FileName,PathName,FilterIndex] = uigetfile('*.ini')

    
    [filename, pathname] = uigetfile('*.ini', 'Pick an ini-file');
    if isequal(filename,0)
        disp('User selected Cancel')
    else
        disp(['User selected', fullfile(pathname, filename)])
        fname = strcat(pathname, filename)
    end
end


%fid = fopen('Z:\Cambridge\17-02-10\Mixes J11+8clones\1-10  Mix +J11(2)\MapFile.ini');
fid = fopen(fname);
d = textscan(fid, '%s %d %d =%f ','commentStyle', 'Could','delimiter', '_', 'headerlines', 1);
col = {'k*', 'r+','co', 'bd','gv','y*','ks'};


for i = 1:length(d{1})
    if d{1}{i}== 'x'
          dd(i) = 0;
    else
          dd(i) = 1;
    end
end
aux = sortrows([ dd' d{2} d{3}  d{4} ],[1 2 3]);
shifts = [aux(1:length(dd)/2, 4)  aux(length(dd)/2+1:end, 4) aux(1:length(dd)/2, 2) aux(1:length(dd)/2, 3) ];

h = figure(1)
clf
u = unique(shifts(:,3));
for i = 1:length(u)
    id = find(shifts(:,3)==u(i));
    if length(id)>0
        plot(shifts(id,1), shifts(id,2), col{i}); hold on
    end
    
    for iid = 1:length(id)
%     if abs(shifts(iid,1))+abs (shifts(iid,2))> 100
%        %text(shifts(iid,1)+5,shifts(iid,2)+5,'a')%,'FontSize',18)
%         text(20,20,'a')%,'FontSize',18)
%     end
    end
end
legend('data 1','data 2','data 3','data 4','data 5','data 6','data 7')
saveas(h,strcat(fname, 'Shifts.jpg')) 