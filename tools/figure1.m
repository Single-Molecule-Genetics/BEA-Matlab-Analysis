% Prepare the 2nd figure for the paper
clear;

% Define here the input -------------------------------------------------
Titles={'SNP1 - C allele','SNP1 - T allele'};

% File #1 (corresponds to eidx=1)
D1=load('/home/jerome/work/data/irene/For Jerome3/SNP1/result.mat');

% File #2 (corresponds to eidx=2)
D2=load('/home/jerome/work/data/irene/For Jerome3/SNP1+2/result.mat');

% File #3 (corresponds to eidx=2)
D3=load('/home/jerome/work/data/irene/For Jerome3/SNP1+3+4/result.mat');

% Beads names
beads_str = {'C-Beads','T-beads','CA-beads','TG-beads','CTC-beads','TCT-beads'};

% index of the experiment file where to find the beads
eidx = [1 1  2 2 3 3 ]; % 1 is file D1 , 2 is D2 and 3 is D3

% code of the beads we want (see summary.txt to check matches)
%        C T CA TG CTC TCT
beads = [2 3 17 13  62  93];

NBeads=length(beads);
% range of index of beads for each plot 
% snp1C: all, snp1T:all,
idx=[1 NBeads;  % snp1C : 1-end
     1 NBeads]; % snp1T : 1-end];

% End of the input --------------------------------------------------------


e{1}=D1.e;
e{2}=D2.e;
e{3}=D3.e;
clear('D1','D2','D3');

% Colors and line styles
% Define nice colors (tango style) for each bead
Cols=[0.80, 0.00, 0.00; % C    Red
      0.80, 0.00, 0.00; % T    Red 
      0.20, 0.39, 0.64; % CA   Blue
      0.20, 0.39, 0.64; % TG   Blue
      0.45, 0.82, 0.09; % CTC  Green
      0.45, 0.82, 0.09; % TCT  Green
      0.98, 0.68, 0.24; % yellow unused
      0.98, 0.68, 0.24];% yellow ununsed
Lines = {'-', '--', '-', '--', '-', '--', '-', '--'}; % line styles
lw = 1; % line width
useloglog = 0;
use_normalized_intensities = 1;

% Extract the beads intensities we want
for i=1:length(beads)
    intensity{i}=e{eidx(i)}.intensities(e{eidx(i)}.code==beads(i),:);
    no_norm{i}=e{eidx(i)}.no_norm(e{eidx(i)}.code==beads(i),:);
end

% Print the stats
for j=1:2
    fprintf(1,'%s\n',Titles{j});
    for i=idx(j,1):idx(j,2)
          fprintf(1,'%d:\t%.2f (%.2f)\t %.2f (%.2f)\n',i, ...
            mean(intensity{i}(:,j)),std(intensity{i}(:,j)), ...
                mean(no_norm{i}(:,j)), std(no_norm{i}(:,j)));
    end
end

figure
clf
n=2^6;

% Normalized intensities
if use_normalized_intensities == 1
    x0=-10; % min
    x1=80;  % max
else    
    x0 = 100;
    x1 = 4000;
end
for j=1:2 % loop on the alleles=channels
    subplot(1,2,j)
    for i=idx(j,1):idx(j,2)
        if use_normalized_intensities == 1
            data=intensity{i}(:,j);
        else
            data=no_norm{i}(:,j);
        end
        [bandwidth,density,xmesh,cdf]=kde(data,n,x0,x1);       
        plot(xmesh,density,Lines{i},'Color',Cols(i,:),'Linewidth',lw); 
        hold on
        % plot the mean and variance (next 4 lines)
        %plot(mean(data),max(density),'+','Color',Cols(i,:))
        %LX=[mean(data)-std(data), mean(data)+std(data)];
        %LY=[max(density) max(density)];
        %plot(LX,LY,Lines{i},'Color',Cols(i,:))        
        legend(beads_str);
    end
    title(Titles{j});    
    axis tight
    hold off
end





