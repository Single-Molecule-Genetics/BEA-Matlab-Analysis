function new_experiment=extract_channels(experiment,list)
%
% experiment=extract_channels(experiment,list)
%
% Extract a set of channels from an experiment
%
% list : list of channels index as a vector 
%
% eg: extract_channels(experiment,[1 2]) to keep w2 and w3
%

new_experiment.nickname=experiment.nickname;
new_experiment.filename=experiment.filename;
new_experiment.image=experiment.image;
new_experiment.object=experiment.object;
new_experiment.intensities=experiment.intensities(:,list);
new_experiment.nchannels=size(new_experiment.intensities,2);
new_experiment.n=experiment.n;
new_experiment.channels=experiment.channels(list);
if exist('experiment.bases')
  new_experiment.bases=experiment.bases(:,list);
end
