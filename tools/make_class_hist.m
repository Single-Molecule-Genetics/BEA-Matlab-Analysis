function make_class_hist(experiment,baseid)
%
% make_class_hist(experiment,baseid)
%
% Plot an histogram for data point belonging to a base baseid
%


data=experiment.intensities;
class=experiment.bases;

channel={'w2' 'w3' 'w4' 'w5'};

figure(5);
id=find(encode_base(class)==baseid);
mini=min(data(:));
maxi=max(data(:));
t=linspace(mini,maxi,100);
for i=1:size(data,2)
  subplot(size(data,2),1,i)
  x=data(id,i);
  x=x(:);
  h=hist(x,t);
  hist(x,t);hold on
  m=median(x);
  s = rstd(x,1);  
  g=exp(-.5*((t-m)/s).^2);
  g=g/sum(g)*sum(h);
  plot(t,g,'r');
  title(sprintf('%s class 1 : %s, median=%.4f, std=%.4f',channel{i},decode_base_str(baseid,1),m,s));
  xlim([mini maxi])
  hold off  
end


