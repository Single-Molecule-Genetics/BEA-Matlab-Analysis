function plot_base(experiment,mva,data_id)
%
% plot_base(data,base,norm,logit,mva)
%  
% plot the data point with color coding
%

data=experiment.intensities;
base=experiment.bases;

%% Argument checking
if (size(base,2)~=4)
    error('plot_base : dimension of the input base should be N x 4');
end
if (size(data,2)~=4)
    error('plot_base : dimension of the input data should be N x 4');
end

if (nargin<2)
    mva = 1;
end
if is_octave()
    figure;
else
    fullscreen = get(0,'ScreenSize');
    figure('Position',[0 0 fullscreen(3) fullscreen(4)])
end
k=1;
cmap=hsv(16);
code=encode_base(base);
h=hist(code,(0:15));
maxi=max(data);
mini=min(data);
S=1*ones(size(data,1),1);
S(find(code==6 | code==9))=10; % put a bigger size for special
C=ones(size(data,1),3);
Centers=zeros(16,4);
for i=0:15;
    idx=find(code==i);
    if length(idx)~=0
        C(idx,:)=ones(length(idx),1)*cmap(i+1,:);
        Center(i+1,:)=median(data(idx,:));
    end
end

for i=1:size(data,2)
    for j=i+1:size(data,2)
        subplot(2,3,k);hold on
        if mva==1      
            idx=find(code>0)
            M = (data(idx,i)+data(idx,j))/2;
            A = data(idx,i)-data(idx,j);
            scatter(M,A,S(idx),C(idx));
        else
            idx=find(code>0);
            X=data(idx,i);X=X(:);
            Y=data(idx,j);Y=Y(:);
            scatter(X,Y,S(idx),C(idx,:));           
            if nargin==7
                for ii =1:length(data_id)
                    plot(data(data_id(ii),i),data(data_id(ii),j),'ko');
                    text(data(data_id(ii),i)+2,data(data_id(ii),j)+2,num2str(data_id(ii)));
                end
            end
        end
        for label=0:15;
            if (h(label+1)>0)
                text(Center(label+1,i),Center(label+1,j),sprintf('%s',decode_base_str(label,1)),'FontSize',9,'Color',cmap(label+1,:))
            end
        end 
        
        grid on; box on;
        hold off
        xlabel(sprintf('w%d',i+1))
        ylabel(sprintf('w%d',j+1))
        title(sprintf('w%d/w%d',i+1,j+1))
        k=k+1;
    end
end

if nargin==3
    disp_base(experiment,data_id)
end

picname=[experiment.filename 'cluster.png'];
disp(['plot_base : saving figure in file ' picname])
print('-dpng',picname);

if 0
figure;
for i=1:size(data,2)
    subplot(size(data,2),1,i)
    plot(data(:,i));
    xlabel('spots')
    ylabel('intensities');
    title(['w' num2str(i)])
end
end
