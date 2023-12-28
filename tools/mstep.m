function mixture=mstep(mixture,data,p)
%
% mixture=mstep(mixture,data,p)
%
% Perform the m step of the em algorithm for the estimating the mixture
% parameters.
cluster=mixture.cluster;
for i=1:length(cluster)
    newc(i)=mstep_worker(i,cluster(i),data,p);
end
Sp = sum([newc(:).p]);
for i=1:length(newc)
    newc(i).p=newc(i).p/Sp;
end
mixture.cluster=newc;

function clusteri=mstep_worker(i,clusteri,data,p)
if clusteri.flag==1
    lpi = p(:,i);
    w=lpi*ones(1,size(data,2));
    sw=sum(lpi(:));
    if (sw>0)
        clusteri.p = sw;
        clusteri.mean = sum(data.*w)./sw;        
        for r=1:size(data,2)
            for s=r:size(data,2)
                clusteri.cov(r,s) = ((data(:,r)-clusteri.mean(r))' ...
                    * ((data(:,s)-clusteri.mean(s)).*p(:,i))) ...
                    /sw;
                if r~=s
                    clusteri.cov(s,r) = clusteri.cov(r,s);
                end
            end
        end
    else
        clusteri.p=0;
    end
else
    clusteri.p=0;
end