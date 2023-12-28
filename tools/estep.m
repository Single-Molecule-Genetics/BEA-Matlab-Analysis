function p=estep(mixture,data,options)

p=zeros(size(data,1),mixture.k);
cluster=mixture.cluster;
for i=1:length(cluster)
    p(:,i)=bcall_mahalanobis(data,cluster(i).mean,cluster(i).cov);
end
p=exp(-.5*p);


if 1
    % set to 1 the probability of cluster 1 if all coordinate are negative
    if options.satellites==0
        u=-sqrt(2)*erfinv(2*1/double(size(data,1))-1);%bonferonni
    else
        u=3;
    end
    
    idx=find((data(:,1)<u & data(:,2)<0) | (data(:,1)<0 & data(:,2)<u) | (data(:,1).^2+data(:,2).^2<u*u));
    p(idx,:)=ones(size(idx,1),1)*[1 zeros(1,size(p,2)-1)];
    
    % set to 0 the probability of cluster 2 if x coordinate is negative
    idx=find(data(:,1)<u);
    p(idx,2)=zeros(size(idx,1),1);
    
    % set to 0 the probability of cluster 3 if y coordinate is negative
    idx=find(data(:,2)<u);
    p(idx,3)=zeros(size(idx,1),1);
    
    % set to 0 the probability of cluster 4 if x|y coordinate is negative
    idx=find((data(:,1)<mixture.cluster(3).mean(1) | data(:,2)<mixture.cluster(2).mean(2)));
    p(idx,4)=zeros(size(idx,1),1);
end
p = p./max(1e-9,(sum(p,2)*ones(1,mixture.k)));

return