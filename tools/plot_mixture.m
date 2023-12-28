function plot_mixture(mixture,experiment)

data=experiment.intensities;
if size(data,2)>2

    clf;
    k=1;
    for i=1:size(data,2)
        for j=i+1:size(data,2)
            subplot(2,3,k);
            scatter(data(:,i),data(:,j),1);
            xlabel(['w' num2str(i+1)]);
            ylabel(['w' num2str(j+1)]);
            k=k+1;
            hold on;
        end
    end
    hold off

else % 2D case
    
    if isfield(mixture.cluster(1),'cov')
        clf;
        a=min(data);
        b=max(data);
        n=100;
        x=linspace(a(1),b(1),n);
        y=linspace(a(2),b(2),n);
        im=zeros(n,n);        
        for k=1:mixture.k
            for i=1:n
                for j=1:n
                    m=mixture.cluster(k).mean;
                    C=mixture.cluster(k).cov;
                    im(i,j)=im(i,j)+exp(-.5*bcall_mahalanobis([x(j) y(i)],m,C));
                end
            end
        end
    end
    col='krgmbyy';
    k=1;
    for i=0:max(experiment.code)
        s=find(experiment.code==i);
        if ~isempty(s)
            plot(data(s,1),data(s,2),[col(i+1),'.'],'MarkerSize',1);
            legstr{k}=sprintf('%s : %d',code2str(i),length(s));
            k=k+1;
            hold on
        end
    end
    legend(legstr);
    if 0
        for i=1:mixture.k
            [u d v]=svd(mixture.cluster(i).cov);
            xi=mixture.cluster(i).mean(1);
            yi=mixture.cluster(i).mean(2);
            dxi=5*u(1,1);
            dyi=5*u(2,1);
            plot([xi xi+dxi],[yi yi+dyi]);
            hold on;
        end
    end
    hold on;
    if isfield(mixture.cluster,'cov')
        contour(x,y,im,10)
    end
    axis xy
    for k=1:mixture.k
        x=mixture.cluster(k).mean(1);
        y=mixture.cluster(k).mean(2);
        %if is_octave
        text(x,y,sprintf('%d',k));
        %else
        %    text(x,y,sprintf('%d',k),'Background','w');
        %end
    end
    axis tight
    %xlim([-10 80])
    %ylim([-10 80])
    axis square
    grid on
    box on
    hold off
    title('Normalized intensities')
    xlabel('channel 1')
    ylabel('channel 2')
    drawnow
    hold off
end


