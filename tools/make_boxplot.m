function make_boxplot(experiment,norm,logit,robust,lambda)        
%
%   make_boxplot(data,norm,logit,robust)
%
%   boxplot before and after normalization
%   
%   FIXME : compatibility issue with previous versions
    
    
if is_octave()
  if isempty(findstr(path,'statistic'))    
    addpath('./statistics/')
    addpath('./statistics-1.0.8/')
  end 
  data=experiment.intensities;
  % Argument checking
  if (nargin<2)
    norm = 1;
  end
  if (nargin<3)
    logit = 1;
  end
  if (nargin<4)
    robust=0;
  end
  figure;
  % Box plot before normalization
  subplot(1,2,1)
  boxplot(data,0,'.',1,lambda);
  title('Box plot before normalization');
  set (gca, 'xtick', [1 2 3 4]) 
  set(gca,'xticklabel',{'w2' 'w3' 'w4' 'w5'});
  
  %% Pre-processing
  if (logit==1)
    disp('make_boxplot : appling log2')
    data=log2(data);
  end

  if (robust==1)
    disp('make_boxplot : using robust variance estimation')
  end
  
  if (norm==1) % my mean and variance
    disp('make_boxplot : appling normalization')
    m = median(data);
    sigma = rstd(data,robust);   
    data = data-ones(size(data,1),1)*m;
    data = data./(ones(size(data,1),1)*sigma);
  elseif norm==2  % whitening operator
    disp('make_boxplot : appling whitening')
    m=median(data);
    C = mcdcovj(data)
    [U,D,V] = svd(C);
    W = U*sqrt(inv(D))*V'; % whitening operator
    data = data-ones(size(data,1),1)*m;
    data = data*W;
  end
  
  % Box plot after normalization
  subplot(1,2,2)
  boxplot(data,0,'.',1,lambda);
  title('Box plot after normalization');
  set (gca, 'xtick', [1 2 3 4]) 
  set(gca,'xticklabel',{'w2' 'w3' 'w4' 'w5'});
  picname=[experiment.filename 'boxplot.png'];
  disp(['make_boxplot : saving figure in file ' picname])
  print('-dpng',picname);
end