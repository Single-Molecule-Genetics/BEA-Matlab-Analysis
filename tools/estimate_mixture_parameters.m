function [experiment mixture p options]=estimate_mixture_parameters(experiment,options)
%
% experiment mixture p options]=estimate_mixture_parameters(experiment, options)
%
% Estimate the parameter of the mixture using an EM algorithm
% and several additional contraints.
%
% experiment : experiment data with a field intensities
% options    : structure containing following fields
%             options.proba : float [0 1] proba threshold of belonging to a class
%             options.iterations : integer number of iterations
%             options.debug : integer 0/1 show itermediate steps
%             options.alpha : float tradeoff initialization/estimation
%             options.satellites : uses additional 2 clusters
%             options.max_cluster_size : maximum cluster size
%

options.method=0;

if isfield(options,'proba')
    proba=min(1,max(0,options.proba));
else
    proba=0;
    
end
options.proba=proba;

if isfield(options,'iterations')
    n=max(0,options.iterations);
else
    n=5;
end
options.iterations=n;

if isfield(options,'debug')
    debug=options.debug;
else
    debug=0;
end
options.debug=debug;

if isfield(options,'alpha')
    alpha=options.alpha;
else
    alpha=0;
end
options.alpha=alpha;

if isfield(options,'max_cluster_size')
    options.max_cluster_size=max(options.max_cluster_size,0);
else
    options.max_cluster_size=1;
end

if ~isfield(options,'beta')
  options.beta=.1;
end

if ~isfield(options,'imagewise_normalization')
    options.imagewise_normalization=0;
end
if ~isfield(options,'normalization_type')
    options.normalization_type=3;
end

if debug>0
    disp('Estimate the parameters of the mixture')
end
data=experiment.intensities;
[mixture options]=init_mixture(data,options);
mixture=force(mixture,mixture,data,options);
p=estep(mixture,data,options);
experiment=assign_code(experiment,p,proba);
for i=1:mixture.k
    mixture.cluster(i).n=length(find(experiment.code==i));
end
if debug>0
    figure(11)
    plot_mixture(mixture,experiment);
end
m0=mixture;
err=1;
mi=0;
while (err>.01) & (mi<n)
    mi=mi+1;
    p0=p;
    %fprintf(1,'\riteration: % d, evolution:%.2f',mi,err);   
    mixture=mstep(mixture,data,p);
    mixture=force(mixture,m0,data,options);
    p=estep(mixture,data,options);
    experiment=assign_code(experiment,p,proba);
    for k=1:mixture.k
        mixture.cluster(k).n=length(find(experiment.code==k));
    end
    if debug>0
        figure(11)
        plot_mixture(mixture,experiment);
    end
    err=max(abs(p0(:)-p(:)));
end
fprintf(1,'number of iterations: %d\n',mi);
if debug>0
    close(11);
end
%experiment.p=p;
return








