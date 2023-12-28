function [C,m]=rcov(data,dflag,nmax)
%
% c=rcov(data,dflag)
%
% Compute a M-estimate of the covariance from the data
%
% dflag=debug
% nmax = use at most n data point from the all dataset
%

if nargin<2
    dflag=0;
end

if nargin==3
    data=data(ceil(rand(min(size(data,1),nmax),1)*size(data,1)),:);
end

method=1;
switch method    
    case 0

    
    m = median(data);
    C = cov(data);
    
    % .99 qunatile for chi2 of ddl 1..10
    %chi2inv_tbl=[ 6.6349    9.2103   11.3449   13.2767   15.0863   16.8119...
    %             18.4753   20.090  21.6660   23.2093];
    %lambda=chi2inv_tbl(size(data,2));
    
    lambda=chi2inv(.8,size(data,2));
    
    dold=sqrt(abs(det(C)));
    dnew=sqrt(abs(det(C)))+1;
    k=1;
    while abs(dnew-dold)>1e-9 && k<10
        dold=dnew;
        if ~isempty(find(isnan(C), 1));
            break;
        end
        d=bcall_mahalanobis(data,m,C); % compute the mahalanobis distance
        w=exp(-.5*d/lambda);     % assign some weights
        w=w./sum(w);             % we normalize the weights
        for r=1:size(data,2)     % compute the weighted covariance matrix
            for s=r:size(data,2)
                C(r,s) = ((data(:,r)-m(r))'* ((data(:,s)-m(s)).*w));
                if r~=s
                    C(s,r) = C(r,s);
                end
            end
        end
        C=1.111*C;
        dnew=sqrt(abs(det(C)));
        k=k+1;
    end
    case 1
    n=size(data,1);
    C=cov(data);
    m=median(data);
    if n>20
        if dflag==1
            [bandwidth,density,X,Y]=kde2d(data,128,min(data),max(data));
            figure(23);clf;         
            imagesc(X(1,:),Y(:,1),real(log(density+min(density(:))+.00001)));axis xy            
            hold on;
        end
        nk=50;
        m=find_mode(data);
        n=size(data,1);       
        J=zeros(1,nk);
        k=round(linspace(n/32,n,nk));
        %S(nk) = struct('C',zeros(size(data,2),size(data,2)));        
        d=bcall_mahalanobis(data,m,[1 0; 0 1]);
        [foo,is]=sort(d);        
        S(1).C=cov(data(is(1:k(1)),:));
        J(1) = log(det(S(1).C));                
        for i=2:nk;
            d=bcall_mahalanobis(data,m,S(i-1).C);
            [foo,is]=sort(d);
            S(i).C=cov(data(is(1:k(i)),:));
            J(i) = log(det(S(i).C));
            if dflag==1
                figure(23)
                ellipse_plot(m,S(i).C,'r'); drawnow
                hold on;
            end
        end
        Pen = 3*(-log(k/n)+.5*k/n);
        %Pen = k/n;
        [foo, istar0]=min(J+Pen);
        g=gradient(J);
        [foo, istar1]=max(g);
        if istar1>2
            istar1=istar1-1;
        end
        %istar=round((istar1+istar0)/2);
        istar=istar0;
        C=S(istar).C;

        if dflag==1
           figure(23)
           ellipse_plot(m,S(istar).C,'g'); drawnow
           figure(22); 
           subplot(3,1,1);
           plot(k/n,J);hold on
           plot(k/n,Pen,'g');hold off
           title('log(|det(C)|)')           
           subplot(3,1,2)
           plot(k/n,J+Pen); hold on
           plot(k(istar0)/n,J(istar0)+Pen(istar0),'r+');
           hold off           
           title('Penalized')
           subplot(3,1,3)
           plot(k/n,g);
           hold on;
           plot(k(istar1)/n,g(istar1),'r+')
           hold off
           title('Gradient')
           disp(sprintf('Covariance estimated from %.2f%% of the data',k(istar)/n*100));                      
        end
    else
        m=median(data);
        C=cov(data);
        %disp('rcov: not enough data points')
    end
    case 2
            if (size(data,1)>4000)
                data=data(ceil(size(data,1)*rand(1,4000)),:);
            end
            rew=mcdcov(data);
            C=rew.cov;
            m=rew.center;
end

% Mean shift
function mode=find_mode(data)
mstore=zeros(10,size(data,2));
C=diag(rstd(data).^2);
for i=1:50;    
    m0=data(ceil(size(data,1)*rand),:);
    mold=m0+1;
    mnew=m0;
    k=0;
    while norm(mold-mnew)/norm(mold)>1e-4 && k<500
        k=k+1;
        mold=mnew;
        d=bcall_mahalanobis(data,mold,C);
        slab=[];
        lambda=1;
        while size(slab,1)<max(size(data,1)/20,10)
            slab=data(d<lambda,:);
            lambda=lambda*2;
        end
        mnew=median(slab);
       %figure(23);hold on;
       %plot([mold(1); mnew(1)],[mold(2),mnew(2)]);
    end
    mstore(i,:)=mnew;    
end
mode=median(mstore);
        
