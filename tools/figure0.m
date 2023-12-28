% Prepare the figure for the paper
clear;


% Define here the input -------------------------------------------------

%monoplex = '/home/jerome/work/data/irene/For Jerome2/SNP267/result.mat';
%multiplex = '/home/jerome/work/data/irene/For Jerome2/SNP 267 +269 (2)/result.mat';
monoplex='/home/jerome/work/data/irene/For Jerome3/SNP1/result.mat';
multiplex='/home/jerome/work/data/irene/For Jerome3/SNP1+2/result.mat';

% Title of the figures
Titles={'SNP1 - C allele','SNP1 - T allele', 'SNP2 - G allele','SNP 2 - A allele'};

% File #1 (corresponds to eidx=1) contains monoplex data
D1 = load(monoplex);

% File #2 (corresponds to eidx=2) contains multiplex data
D2 = load(multiplex);

% index of the experiment file where to find the beads
eidx = [1 1  2  2 2 2  2  2];

% code of the beads we want (see summary.txt)
%        A T CA TG C0 T0 OA 0G
beads = [2 3 17 13  7  8 16 11];

NBeads = length(beads);

% range of index for each plot 
% snp1C: all, snp1T:all, snp2G:3-end, snp2A:3-end
idx = [1 NBeads;  % snp1C : beads(1:end) = (2 3 17 13 7 8 16 11)
       1 NBeads;  % snp1T : beads(1:end) = (2 3 17 13 7 8 16 11)
       3 NBeads;  % snp2G : beads(3:end) = (    17 13 7 8 16 11)
       3 NBeads]; % snp2A : beads(3:end) = (    17 13 7 8 16 11)

% End of the input ------------------------------------------------------

e{1} = D1.e;
e{2} = D2.e;
clear('D1','D2');

% Colors and line styles
% Define nice colors (tango style)
Cols=[0.80, 0.00, 0.00;
      0.80, 0.00, 0.00; 
      0.20, 0.39, 0.64; 
      0.20, 0.39, 0.64;
      0.45, 0.82, 0.09; 
      0.45, 0.82, 0.09
      0.98, 0.68, 0.24; 
      0.98, 0.68, 0.24];
  
Lines={'-', '--', '-', '--', '-', '--', '-', '--'}; % line styles
lw=1; % line width
useloglog=0;

% Extract the beads intensities we want
for i=1:length(beads)
    intensity{i}=e{eidx(i)}.intensities(e{eidx(i)}.code==beads(i),:);
    no_norm{i}=e{eidx(i)}.no_norm(e{eidx(i)}.code==beads(i),:);
end

% Print the stats
for j=1:4
    fprintf(1,'%s\n',Titles{j});
    for i=idx(j,1):idx(j,2)
          fprintf(1,'%d:\t%.2f (%.2f)\t %.2f (%.2f)\n',i,mean(intensity{i}(:,j)),std(intensity{i}(:,j)),mean(no_norm{i}(:,j)), std(no_norm{i}(:,j)));
    end
end


figure(1);
clf
n=2^6;

%  original intensities
x0=0;    % min
x1=4500; % max
for j=1:4
    %subplot(4,2,2*(j-1)+1)
    subplot(4,1,j)
    for i=idx(j,1):idx(j,2)
        data=no_norm{i}(:,j);
        [bandwidth,density,xmesh,cdf]=kde(data,n,x0,x1);
        plot(xmesh,density,Lines{i},'Color',Cols(i,:),'Linewidth',lw); 
        hold on
        % plot the mean and variance (next 4 lines)
        plot(mean(data),max(density),'+','Color',Cols(i,:))
        LX=[mean(data)-std(data), mean(data)+std(data)];
        LY=[max(density) max(density)];
        plot(LX,LY,Lines{i},'Color',Cols(i,:))        
    end
    title(Titles{j});
    axis tight
    hold off
end

figure(2)
% Normalized intensities
x0=-10; % min
x1=80;  % max
for j=1:4 % loop on the alleles=channels
    %subplot(4,2,2*j)
    subplot(4,1,j)
    for i=idx(j,1):idx(j,2)
        data=intensity{i}(:,j);
        [bandwidth,density,xmesh,cdf]=kde(data,n,x0,x1);       
        plot(xmesh,density,Lines{i},'Color',Cols(i,:),'Linewidth',lw); 
        hold on
        % plot the mean and variance (next 4 lines)
        plot(mean(data),max(density),'+','Color',Cols(i,:))
        LX=[mean(data)-std(data), mean(data)+std(data)];
        LY=[max(density) max(density)];
        plot(LX,LY,Lines{i},'Color',Cols(i,:)) 
    end
    title(Titles{j});    
    axis tight
    hold off
end





