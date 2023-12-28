function new_experiment=extract_subset(experiment,n)
% extract randomly n lines from the matrix A
  if (nargin<2)
    disp('Use by default n=1000 data points.')
    n=1000;
  end
n=min(n,size(experiment.intensities,1));
idx=ceil(size(experiment.intensities,1)*rand(1,n));
new_experiment.nickname=experiment.nickname;
new_experiment.filename=experiment.filename;
new_experiment.image=experiment.image(idx);
new_experiment.object=experiment.object(idx);
new_experiment.intensities=experiment.intensities(idx,:);
new_experiment.nchannels=size(new_experiment.intensities,2);
new_experiment.n=size(new_experiment.intensities,1);
new_experiment.channels=experiment.channels;
if exist('experiment.bases')
  new_experiment.bases=experiment.bases(idx);
end