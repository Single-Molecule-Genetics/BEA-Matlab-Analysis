function experiment=mvaplot(experiment,norm,logit,mva,robust,lambda)
%%
%%   mvaplot(data,norm,logit,mva)
%%
%%   Plot a normalize MvA plot
%%   Defined by plot((log(A)+log(B)/2),log(A)-log(B))
%%   where A and B are normalized by mean and variance
%%   if norm==1 normalize
%%   if logit==1 take the log andplot MvA otherwise plot intensities
%%
%%

%% do box plot before and after

%% Argument checking
if (nargin<2)
    norm = 1;
end
if (nargin<3)
    logit = 1;
end
if (nargin<4)
    mva = 1;
end
if (nargin<5)
    robust=0;
end
if (nargin<6)
    lambda=3;
end

data=experiment.intensities;

%% Pre-processing
if (logit==1)
    disp('mvaplot : applying log2')
    data=log2(data);
end

if (norm==1) % my mean and variance
    disp('mvaplot : appling normalization')
    m = median(data);
    data = data-ones(size(data,1),1)*m;
    sigma = rstd(data,robust);
    data = data./(ones(size(data,1),1)*sigma);
    experiment.sigma=sigma;
elseif norm==2  % whitening operator
    disp('mvaplot : appling whitening')
    m=median(data);
    C = mcdcovj(data)
    [U,D,V] = svd(C);
    W = U*sqrt(inv(D))*V'; % whitening operator
    data = data-ones(size(data,1),1)*m;
    data = data*W;
end

%% Compute base 
disp('mvaplot : computing bases')
base=zeros(size(data));
if mva==1
    for i=1:size(data,2)
        for j=i+1:size(data,2)
            A = (data(:,i)+data(:,j))/2;
            M = data(:,j)-data(:,i);
            s = lambda*rstd(M,robust);
            v = lambda*rstd(A,robust);          
            base(find(M<-s),i) = 1;
            base(find(M>s),j) = 1;
            base(find(M<s & M>-s & A>v),i) = 1;
            base(find(M<s & M>-s & A>v),j) = 1;
        end
    end
else
    for i=1:size(data,2)
        x=data(:,i);
        sx = lambda*rstd(x,robust);
        base(find(x>sx),i)=1;
    end
end
if is_octave()
    figure;
else
    fullscreen = get(0,'ScreenSize');
    figure('Position',[0 0 fullscreen(3) fullscreen(4)])
end
subplot(3,1,2);
%% plotting
disp('mvaplot : plotting')
clf;
k=1;
for i=1:size(data,2)
    for j=i+1:size(data,2)
        subplot(2,3,k);hold on
        if mva==1
            A = (data(:,i)+data(:,j))/2; M=M(:);
            M = data(:,i)-data(:,j);     A=A(:);
            s = lambda*rstd(M,robust);
            v = lambda*rstd(A,robust);
            idx=find(abs(M)<s);
            plot(A(idx),M(idx),'.','MarkerSize',1); hold on
            idx=find(abs(M)>s);
            if (length(idx)>0)
                plot(A(idx),M(idx),'r.','MarkerSize',1);
            end
            idx=find(M<s & M>-s & A>v);
	    if (length(idx)>0)
                plot(A(idx),M(idx),'g.','MarkerSize',1);
            end
            line([min(M) max(M)],[s s],'Color','g');
            line([min(M) max(M)],[-s -s],'Color','g');	  
            hold off	  
            xlabel(sprintf('(log(w%d)+log(w%d))/2',i+1,j+1))
            ylabel(sprintf('log(w%d)-log(w%d)',i+1,j+1))
            %axis([-8 8 -8 8])
        else
            x=data(:,i);x=x(:);
            y=data(:,j);y=y(:);	    
            plot(x,y,'.');     
        end
	grid on; box on;
        hold off
        xlabel(sprintf('w%d',i+1))
        ylabel(sprintf('w%d',j+1))
        title(sprintf('w%d/w%d',i+1,j+1))
        k=k+1;
    end
end


picname=[experiment.filename 'mvaplot.png'];
disp(['mvaplot : saving figure in file ' picname])
print('-dpng',picname);

experiment.bases=base;