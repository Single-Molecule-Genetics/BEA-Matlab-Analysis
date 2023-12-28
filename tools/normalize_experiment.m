function [experiment,options]=normalize_experiment(experiment,options)
%
% experiment=normalize_experiment(experiment,logit,norm,robust)
%
% Normalize the intensities of an experiment
%
% logit : apply logarithm
% the_norm  : studentize (mean and varaince)
% robust : estimate robustly the variance
%

if nargin<2
    options.logit=1;
end

% Check arguments
if ~isfield(options,'logit')
    options.logit=1;
end
if ~isfield(options,'normalization_type')
    options.normalization_type=3;
end
if ~isfield(options,'debug')
    options.debug=0;
end

if ~isfield(options,'imagewise_normalization')
    options.imagewise_normalization=0;
end

if ~isfield(options,'normalization')
    options.normalization.done=false;    
end

if ~isfield(options.normalization,'use_precomputed')
    options.normalization.use_precomputed=false;
end

if ~isfield(experiment,'normalization')
    experiment.normalization.done=false;    
end

if experiment.normalization.done==false
    % Make a backup    
    experiment.no_norm=experiment.intensities;
    
    % Apply a log
    if options.logit==1
        experiment.intensities=log(experiment.intensities);
    end    
    
    if options.imagewise_normalization
        disp('Image wise normalization')
        for i=1:max(experiment.image)
            experiment=normalize_image(experiment,i);
        end
    end
    
    if options.normalization.use_precomputed==false
        % Normalize
        switch (options.normalization_type)
            case 1 % no normalization
                m=[0 0];
                C=[1 0;0 1];
            case 2 % standard
                m=mean(experiment.intensities);
                C=cov(experiment.intensities);
            case 3 % using robust rstd
                [s m]=rstd(experiment.intensities);
                m=median(experiment.intensities);
                C=diag(s.^2);
            case 4 % using rcov
                [C,m]=rcov(experiment.intensities,options.debug,10000);                
            case 5 % using rcov+white
                [C,m]=rcov(experiment.intensities);
                [U D V]=svd(C);
                a=pi/4;
                W = U*sqrt(inv(D))*V*[cos(a) -sin(a);sin(a) cos(a)];
                experiment.intensities = (experiment.intensities-ones(n,1)*m)*W;
        end
        %disp('Nomalization done using:'); disp([m' C]);
    else
        disp('Using precomputed normalization')
        C=options.normalization.covariance;
        m=options.normalization.center;
    end
    
    n =  size(experiment.intensities,1);
    experiment.intensities=(experiment.intensities-ones(n,1)*m)./(ones(n,1)*sqrt(diag(C))');    
    experiment.normalization.done=true;
    experiment.normalization.center=m;
    experiment.normalization.covariance=C;
end



function experiment=normalize_image(experiment,ni)
idx=find(experiment.image==ni);
n=length(idx);
if n>1
    if 1 % using rstd
        %data=experiment.intensities(idx,:);
        %c=.75*max(data)+.25*min(data);
        %data=data(data(:,1)<c(1) &  data(:,2)<c(2),:);
        %[m,s]=rstd(data);
        m=median(experiment.intensities(idx,:));
        s=std(experiment.intensities(idx,:));
        experiment.intensities(idx,:)=...
            (experiment.intensities(idx,:)-ones(n,1)*m)./(ones(n,1)*s);
    else % using rcov
        [C,m]=rcov(experiment.intensities(idx,:));
        [U D V]=svd(C);
        experiment.intensities(idx,:) = ...
            (experiment.intensities(idx,:)-ones(n,1)*m)./sqrt(D(1));
    end
end


