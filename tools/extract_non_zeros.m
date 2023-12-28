function new_experiment=extract_non_zeros(experiment,threshold)
val = min(experiment.intensities,[],2);
idx=find(val>threshold);
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

if new_experiment.n~=experiment.n
    disp(sprintf('Removed %d points of intensity below %d.',...
        experiment.n-new_experiment.n,threshold));
end