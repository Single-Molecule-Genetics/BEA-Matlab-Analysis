function new_experiment=extract_image(experiment,image)
%
% experiment=filter_by_image(experiment,image)
%
% keep experiments corresponding to a certain image number
%
% image : scalar or list of index
%
if image~=-1
    if length(image)==1
        new_experiment.nickname=experiment.nickname;
        new_experiment.filename=experiment.filename;
        idx=find(experiment.image==image);
        if isempty(idx)
            error('Image %d not found in range [%d-%d]',image,min(experiment.image),max(experiment.image));
        end
        new_experiment.image=experiment.image(idx);
        new_experiment.object=experiment.object(idx);
        new_experiment.intensities=experiment.intensities(idx,:);
        new_experiment.nchannels=size(new_experiment.intensities,2);
        new_experiment.n=size(new_experiment.image,1);
        new_experiment.channels=experiment.channels;
        if isfield(experiment,'code')
            new_experiment.code=experiment.code(idx);
        end
    else
        new_experiment.nickname=experiment.nickname;
        new_experiment.filename=experiment.filename;
        idx=[];
        for i=1:length(image)
            idx=[idx ;find(experiment.image==image(i))];
        end
        if isempty(idx)
            error('Images not found!');
        end
        new_experiment.image=experiment.image(idx);
        new_experiment.object=experiment.object(idx);
        new_experiment.intensities=experiment.intensities(idx,:);
        new_experiment.nchannels=size(new_experiment.intensities,2);
        new_experiment.n=size(new_experiment.image,1);
        new_experiment.channels=experiment.channels;
        if isfield(experiment,'code')
            new_experiment.code=experiment.code(idx);
        end
        
    end
else
    new_experiment=experiment;
end