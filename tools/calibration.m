function options=calibration(directory,options)

close all;

if (nargin<1)
    directory = uigetdir;
end

if ~isstr(directory)
    disp('First argument should be a string')   
end

if nargin<2
    options=[];
end

if ~isfield(options,'cg')
    options.cg='/snp*';
end

if ~isfield(options,'global')
    options.global=true;
end

if isfield(options,'imagewise_normalization')
    if options.imagewise_normalization==1
        disp('Reset options.imagewise_normalization to 0.')
        options.imagewise_normalization=0;
    end
else
    options.imagewise_normalization=0;
end

if ~isfield(options,'max_cluster_size')
    options.max_cluster_size=.5;
end

if ~isfield(options,'remove_bad_image')
    options.remove_bad_image=0;
end

if ~isfield(options,'nucleotides')
    options.nucleotides=[];
end

if ~isfield(options,'image')
    options.image=-1;
end

% Add a slash at the end
if directory(end)~='/' && directory(end)~='\'
    directory=[directory '/'];
end

if options.remove_bad_image==1
    options=extract_non_garbage_image(directory,options);
end

d=dir([directory options.cg]);
K=length(d);
% load and merge
data=[];
tag=[];
disp(sprintf('Loading %d datasets in %s ...',K,[directory options.cg]));
for i=1:K
    filenames{i}=[directory d(i).name];
    fprintf(1,'[%d] %s\n',i,filenames{i});
    e(i)=preload(filenames{i});
    if options.global
        data=[data;e(i).intensities];
        %tag=[tag; i*ones(size(e(i).intensities,1),1)];
    end
end

if options.global==true
    % make the global experiemnt structure
    disp('Calibration on merged datasets...')
    g.filename=directory;
    g.nickname=directory;
    g.channels=e(1).channels;
    g.n=size(data,1);
    g.intensities=data;
    g.object=(1:g.n)';
    g.image=ones(g.n,1);
    g.nchannels=2;
    eref=g;
else
    fprintf(1,'Calibration on 1st dataset (%s)..',e(1).filename)
    eref=e(1);
end

% analyze the data in one
options.normalization.use_precomputed=false;
[eref,mixture,options]=analyze_wash_2by2(eref,options);
options.normalization.use_precomputed=true;%% modif
options.normalization.center=eref.normalization.center;
options.normalization.covariance=eref.normalization.covariance;
options.imagewise_normalization=0;
options.mixture = mixture;
