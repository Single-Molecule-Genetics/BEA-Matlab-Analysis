% Test the mixture model approach
% Works only in 2D (the plotting..)

%clear; 
close all;
tic

%experiment=preload('/home/jboulang/data/irene/14-04-10 Multiplex/snp267/'); % load a data set
experiment=preload('/home/jboulang/data/irene/14-04-10 Multiplex/SNP 267 +754 (3)/cg1/');

% Extract some part of the data
%experiment=extract_subset(experiment,100000); % extract randomly 1000 points
%experiment=extract_channels(experiment,[1 2]); % extract some channel [ch1 ch2 ...]
%experiment=extract_image(experiment,7); % extract data corresponding to an image
%experiment=extract_non_zeros(experiment,200); % remove data correspondong to 0000


% processing
experiment=normalize_experiment(experiment); % we normalize the experiement
[experiment mixture p]=estimate_mixture_parameters(experiment); % estimate mixture components
print_experiment(experiment);
save_experiment(experiment,mixture);
toc

