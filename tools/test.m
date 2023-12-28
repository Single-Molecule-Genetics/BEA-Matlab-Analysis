% Demo of MvA analysis of bead slides
more off;
close all;
% Set the parameters
lambda=20;         % threshold for classification
mva=1;             % uses mva normalization
logit=1;           % uses log2 transform
normalize=1;       % uses mean/variance normalization
robust=1;          % uses robust estimation of varaince

filename=load_db('/home/jboulang/data/irene/',1);   % retreive predefined dataset names
experiment=preload(filename); % load a data set

% Extract some part of the data
experiment=extract_subset(experiment,5000);
%experiment=extract_channels(experiment,[1 2]);
%experiment=extract_image(experiment,1);

experiment=normalize_experiment(experiment,logit,normalize,robust);

% Perform the MvA analysis and plotting
tic
experiment=mvaplot(experiment,mva,lambda);
%make_boxplot(experiment,lambda);
plot_base(experiment,0); % plot without MvA
disp_base(experiment);
toc
