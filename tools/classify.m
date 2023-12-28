function experiment=classify(experiment,mixture,options)
if ~isfield(options,'proba')
    options.proba=0;
end
experiment=extract_image(experiment,options.image);
[experiment,options]=normalize_experiment(experiment,options);
if 0
    experiment.no_norm=experiment.intensities;
    experiment.intensities=log(experiment.intensities);
    n = size(experiment.intensities,1);
    s=sqrt(diag(options.normalization.covariance))';
    m=options.normalization.center;
    experiment.intensities=(experiment.intensities-ones(n,1)*m)./(ones(n,1)*s);
end
p=estep(mixture,experiment.intensities,options);
%p=p./(ones(size(p),1)*mean(p));
experiment=assign_code(experiment,p,options.proba);