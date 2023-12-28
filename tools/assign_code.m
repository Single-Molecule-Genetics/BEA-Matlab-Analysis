function experiment=assign_code(experiment,p,proba)
% Assign a code (number between 0 and 4) to a point given the probabilities
% p to belong to a cluster.
if size(p,2)>4
    q=zeros(size(p,1),4);
    %q(:,1)=max([p(:,1)p(:,5) p(:,6)],[],2);
    q(:,1)=sum([p(:,1) p(:,5) p(:,6)],2);
    q(:,2:4)=p(:,2:4);
else
    q=p;
end
experiment.code=zeros(experiment.n,1);
[val, idx]=max(q,[],2);
subset=find(val>proba);
experiment.code(subset)=idx(subset);