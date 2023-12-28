function [mixture options]=init_mixture(data,options)
%
% mixture=init_mixture(data)
%
% Initislize a mixture model from the data
% the mixture has 2^channels components
% there is several cases
%  - all 0 : computed by the data covariance
%  -

if isfield(options,'satellites')
    satellites=options.satellites;
else
    satellites=1;
end
options.satellites=satellites;

if options.normalization_type==1
    lambda=3;
else
    lambda=-2*sqrt(2)*erfinv(2*1/double(size(data,1))-1);
end

if options.normalization_type==5;
    A=data(:,1);
    M=data(:,2);    
    lambda=lambda*2;
    idx1=find(abs(A)<lambda & abs(M)<lambda);
    idx2=find(           M<-lambda);
    idx3=find(           M>lambda );
    idx4=find(A>lambda & abs(M)<lambda);
    if (options.debug==1)
        figure(32)
        plot(data(idx1,1),data(idx1,2),'r.');hold on;
        plot(data(idx2,1),data(idx2,2),'g.');
        plot(data(idx3,1),data(idx3,2),'m.');
        plot(data(idx4,1),data(idx4,2),'b.');
        hold off
    end
else
    if 1
        %mva initilization
        A = (data(:,1)+data(:,2))/2; A=A(:);
        M = data(:,1)-data(:,2);     M=M(:);
        Z = (data(:,1)<lambda & data(:,2)<0) | (data(:,1)<0 & data(:,2)<lambda) | (data(:,1).^2+data(:,2).^2<lambda^2);
        s = lambda;%*rstd(M)
        v = 2*lambda;%*rstd(A);
        angle=.5;
        idx1=find(abs(M)<angle*A+s & A<v | Z==1);
        idx2=find(M>angle*A+s & Z==0);
        idx3=find(M<-angle*A-s & Z==0);
        idx4=find(abs(M)<angle*A+s & A>v & Z==0);
    else        
        t=median(data)+std(data);
        idx1=find(data(:,1)<t(1) & data(:,2)<t(2));
        idx2=find(data(:,1)>t(1) & data(:,2)<t(2));
        idx3=find(data(:,1)<t(1) & data(:,2)>t(2));
        idx4=find(data(:,1)>t(1) & data(:,2)>t(2));
    end
end

%[C,m]=rcov(data(idx1,:),options.debug,10000);
%m=median(data(idx1,:))
mixture.cluster(1).mean=[0 0];%m;
mixture.cluster(1).cov=cov(data(idx1,:));%[1 0;0 1];
mixture.cluster(1).flag=1;

thres=max(max(length(idx1)/1000,max(length(idx2),length(idx3))/50),100);
if options.debug==1
    disp(sprintf('size cluster 01 : %d = %f', length(idx2),length(idx2)/max(length(idx2),length(idx3))))
end
if (length(idx2)>thres )
    mixture.cluster(2).mean=.1*median(data(idx2,:))+.9*[max(data(:,1)) mixture.cluster(1).mean(2)];
    mixture.cluster(2).cov=cov(data(idx2,:));
    %[mixture.cluster(2).cov mixture.cluster(2).mean]=rcov(data(idx2,:),options.debug,10000);
    mixture.cluster(2).flag=1;
else
    disp('warning : few data in cluster 10')   
    mixture.cluster(2).mean=[max(data(:,1)) mixture.cluster(1).mean(2)];
    mixture.cluster(2).cov=[10 0; 0 1];
    mixture.cluster(2).flag=0;
end

if options.debug==1
    disp(sprintf('size cluster 10 : %d = %f', length(idx3),length(idx3)/max(length(idx2),length(idx3))))
end
if (length(idx3)>thres)
    mixture.cluster(3).mean=.1*median(data(idx3,:))+.9*[mixture.cluster(1).mean(1) max(data(:,2))]; 
    mixture.cluster(3).cov=cov(data(idx3,:));
    %[mixture.cluster(3).cov,mixture.cluster(3).mean]=rcov(data(idx3,:),options.debug,10000);
    mixture.cluster(3).flag=1;
else
    disp('warning : few data in cluster 01');
    mixture.cluster(3).mean=[mixture.cluster(1).mean(1) max(data(:,2))];        
    mixture.cluster(3).cov=[1 0;0 10];
    mixture.cluster(3).flag=0;
end

if options.debug==1
    disp(sprintf('size cluster 11 : %d = %f', length(idx4),length(idx4)/max(length(idx2),length(idx3))))
end
if (length(idx4)>thres)
    mixture.cluster(4).mean=median(data(idx4,:));
    mixture.cluster(4).cov=cov(data(idx4,:));
    %[mixture.cluster(4).cov,mixture.cluster(4).mean]=rcov(data(idx4,:),options.debug,10000);
    mixture.cluster(4).flag=1;
else
    disp('warning : few data in cluster 11')    
    mixture.cluster(4).mean=[mixture.cluster(2).mean(1) mixture.cluster(3).mean(2)];
    mixture.cluster(4).cov=[10 0; 0 10];
    mixture.cluster(4).flag=0;
end

% Initialize satellite cluster at 25% of the distance to from cluster 1 to
% clusters 2 and 3. The covariance is related to the cov of 5 and 6
if satellites==1    
    mixture.cluster(5).mean=.1*mixture.cluster(2).mean+.9*mixture.cluster(1).mean;
    mixture.cluster(5).cov=mixture.cluster(2).cov/sqrt(abs(det(mixture.cluster(2).cov)));
    mixture.cluster(5).flag=1;
    mixture.cluster(6).mean=.1*mixture.cluster(3).mean+.9*mixture.cluster(1).mean;
    mixture.cluster(6).cov=mixture.cluster(3).cov/sqrt(abs(det(mixture.cluster(3).cov)));
    mixture.cluster(6).flag=1;
end

mixture.k=length(mixture.cluster); % the nb of classes

if options.debug==1
    for i=1:length(mixture.cluster);
        fprintf(1,'cluster %d',i);
        disp(mixture.cluster(i).mean);
        disp(mixture.cluster(i).cov);
    end
end

return