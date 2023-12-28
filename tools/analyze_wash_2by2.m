function [experiment, mixture,options]=analyze_wash_2by2(experiment,options)
%
% experiment=analyze_wash_2by2(experiment,options)
%
% Analyze a wash composed on 2 channels
%
% filename : path to the folder containing w2.log and w3.log
%
% see estimate_mixture_parameters
%


if nargin<2
    options=[];
end

if ~isfield(options,'method')
    options.method=0;
end

if isfield(options,'debug')
    debug=options.debug;
else
    debug=0;
end
options.debug=debug;


% remove counts in summary < nfiltcat
if ~isfield(options,'pfiltcat')
    options.pfiltcat=.05; % y default take class with more than 1 percent of the data
end

%disp(['>> ' e.filename])

%experiment=preload(filename);

% Extract some part of the data
experiment=extract_channels(experiment,[1 2]); % extract some channel [ch1 ch2 ...]
if isfield(options,'image')
    if options.image>0
        experiment=extract_image(experiment,options.image); % extract data corresponding to an image
    else
        options.image=-1; % means all images will be processed
    end
end

% For safety we remove zeros :
experiment=extract_non_zeros(experiment,1); % remove data corresponding to 0000


if experiment.n==0 || size(experiment.intensities,1)==0
    error('Not enough data points. Wrong image selected?')
end


% processing
if ~isfield(options,'imagewise_normalization')
   options.imagewise_normalization=1;
end
    
experiment=normalize_experiment(experiment,options);

switch options.method
    case 0 
        [experiment mixture p options]=estimate_mixture_parameters(experiment,options); % estimate mixture components
    case 1
        [experiment mixture options] = apply_mean_shift(experiment,options);
    otherwise
        disp('Unknown method in options.method');
        return;
end
% display and saving
print_experiment(experiment);
save_experiment(experiment,mixture,options);
mva_compare(experiment);


function print_experiment(experiment)
if isfield(experiment,'no_norm')
    if isfield(experiment,'no_norm')
        if max(experiment.no_norm(:))>4096
            satval = 65535;
            %disp(sprintf('Image were (probably) coded on 16bit'));
        else
            %disp(sprintf('Image were (probably) coded on 12bit'));
            satval = 4095;
        end
        ns=sum(experiment.no_norm==satval);
        if ns(1)>0
            disp(sprintf('Warning : %d points saturated in channel 1',ns(1)));
        end
        if ns(2)>0
            disp(sprintf('Warning : %d points saturated in channel 2',ns(2)));
        end
    end
end
disp('counts:');
disp(sprintf('0 ?? : %d <- unclassified',length(find(experiment.code==0))));
disp(sprintf('1 00 : %d',length(find(experiment.code==1))));
disp(sprintf('2 10 : %d',length(find(experiment.code==2))));
disp(sprintf('3 01 : %d',length(find(experiment.code==3))));
disp(sprintf('4 11 : %d',length(find(experiment.code==4))));
r=length(find(experiment.code==3))/length(find(experiment.code==2));
disp(sprintf('ratio 3/2 : %.2f',r));

return


function mva_compare(experiment)
data=experiment.intensities;
A = (data(:,1)+data(:,2))/2; A=A(:);
M = data(:,1)-data(:,2);     M=M(:);
lambda=-sqrt(2)*erfinv(2*1/double(size(data,1))-1);
Z = (data(:,1)<lambda & data(:,2)<0) | (data(:,1)<0 & data(:,2)<lambda) | (data(:,1).^2+data(:,2).^2<lambda^2);
s = lambda;%*rstd(M,1);
v = lambda*2;%rstd(A,1);
idx1=find(abs(M)<.5*A+s & A<v | Z==1);
idx2=find(M>.5*A+s & Z==0);
idx3=find(M<-.5*A-s & Z==0);
idx4=find(abs(M)<.5*A+s & A>v & Z==0);

hf=figure;
plot(data(idx1,1),data(idx1,2),'r.','MarkerSize',1); hold on
plot(data(idx2,1),data(idx2,2),'g.','MarkerSize',1);
plot(data(idx3,1),data(idx3,2),'m.','MarkerSize',1);
plot(data(idx4,1),data(idx4,2),'b.','MarkerSize',1);
legend(['00 : ' num2str(length(idx1))],['10 : ' num2str(length(idx2))],['01 : ' num2str(length(idx3))],['11 : ' num2str(length(idx4))] )
%xlabel('A=(log(X)+log(Y))/2');ylabel('M=log(X/Y)')
xlabel('channel 1');ylabel('channel 2')
grid on
axis square
title('MvAplot with normalized intensities')
hold off
picname=[experiment.filename '/mva.png'];
print(hf,'-dpng',picname);
close(hf)
return

function save_experiment(experiment,mixture,options)
% save all the data from an experiment

% before normalization
if isfield(experiment,'no_norm')
    figure(20)
    col='krgmbkkkk';
    for i=0:max(experiment.code)
        s=find(experiment.code==i);
        plot(experiment.no_norm(s,1),experiment.no_norm(s,2),[col(i+1),'.'],'MarkerSize',1)
        hold on
    end
    hold off
    xlabel('channel 1');ylabel('channel 2')
    picname=[experiment.filename '/nonorm.png'];
    %disp(['save_experiment : saving figure in file ' picname])
    print(20,'-dpng',picname);


    % histograms of the channels
    figure(20)
    subplot(2,1,1)
    [h,x]=hist(experiment.no_norm(:,1),50);
    plot(x,log(h+1),'--')
    hold on
    for i=1:4
        idx=find(experiment.code==i);
        h=hist(experiment.no_norm(idx,1),x);
        plot(x,log(h+1),col(i+1))
    end
    hold off
    ylabel('log frequency');xlabel('intensity');title('channel 1')
    axis tight
    subplot(2,1,2)
    [h,x]=hist(experiment.no_norm(:,2),50);
    plot(x,log(h+1),'--')
    hold on
    for i=1:4
        idx=find(experiment.code==i);
        h=hist(experiment.no_norm(idx,2),x);
        plot(x,log(h+1),col(i+1))
    end
    hold off
    ylabel('log frequency');xlabel('intensity');title('channel 2')
    axis tight
    picname=[experiment.filename 'hist.png'];
    %disp(['save_experiment : saving figure in file ' picname])
    print(20,'-dpng',picname);
    close(20)
end

    % Check images
    h=figure;
    hist(experiment.image,(min(experiment.image):max(experiment.image)));        
    title('Number of beads per image')
    picname=[experiment.filename '/check_image.png'];
    print(h,'-dpng',picname);
    close(h)


if isfield(experiment,'code')
    h=figure;
    plot_mixture(mixture,experiment);
    picname=[experiment.filename '/estimation.png'];
    %disp(['save_experiment : saving figure in file ' picname])
    print(h,'-dpng',picname);    
       
    h=figure;
    [bandwidth,density,X,Y]=kde2d(experiment.intensities,128,min(experiment.intensities),max(experiment.intensities));
    imagesc(X(1,:),Y(:,1),abs(log(max(0,density+.001))));axis xy
    title('Density')
    picname=[experiment.filename '/kde.png'];
    print(h,'-dpng',picname);
    close(h)
   
    f=0;    
    tmpfile=tempname;
    f=fopen(tmpfile,'w');    
    if (f~=0)
        %disp(['save_experiment : saving data in file ' file]);

        fprintf(f,'2 by 2 analyzis of %s \n',experiment.filename);
        fprintf(f,'performed on %s \n',datestr(now));
        fprintf(f,'number of data points %d \n',experiment.n);
        if isfield(experiment,'no_norm')
            if max(experiment.no_norm(:))>4096
                satval = 65535;
                fprintf(f,'Image were (probably) coded on 16bit\n');
            else
                fprintf(f,'Image were (probably) coded on 12bit\n');
                satval = 4095;
            end
            ns=sum(experiment.no_norm==satval);
            if ns(1)>0
                fprintf(f,'Warning : %d points saturated in channel 1\n',ns(1));
            end
            if ns(2)>0
                fprintf(f,'Warning : %d points saturated in channel 2\n',ns(2));
            end
        end
        fprintf(f,'\n#######################OPTIONS########################\n\n');
        switch options.method
            case 0
                fprintf(f,'method ............................ EM\n');
                fprintf(f,'number of iteration ............... %d\n',options.iterations);
                fprintf(f,'probability ....................... %.3f\n',options.proba);
                fprintf(f,'a priori/data tradeoff ............ %.3f\n',options.alpha);
                fprintf(f,'satellites ........................ %d\n',options.satellites);
                fprintf(f,'max cluster size .................. %.3f\n',options.max_cluster_size);
                fprintf(f,'normalization ..................... %.3f\n',options.normalization_type);
            case 1
                fprintf(f,'method ............................ Mean Shift\n');
                fprintf(f,'bandwidth ......................... %.3f\n',options.bandwidth);
        end
        if isfield(options,'image')
            if length(options.image)==1
                if options.image>=0
                    fprintf(f,'image ............................. %d\n',options.image);
                else
                    fprintf(f,'image ............................. all\n');
                end
            else
                fprintf(f,'image ............................. ');
                for i=1:length(options.image)
                    fprintf(f,'%d ',options.image(i));
                end
                fprintf(f,'\n');
            end
        else
            fprintf(f,'image ............................. all\n');
        end
        if isfield(options,'removed')
            fprintf(f,'removed ........................... ');
            for i=1:length(options.removed)
                fprintf(f,'%d ',options.removed(i));
            end
            fprintf(f,'\n');
        end
        fprintf(f,'min %% of objects in categories .... %.3f %%\n',options.pfiltcat);

        fprintf(f,'max cluster size : %.3f\n',options.max_cluster_size);
        fprintf(f,'\n###################COUNTS#############################\n\n');
        fprintf(f,'0 ?? : %10d <- unclassified\n',length(find(experiment.code==0)));        
        cstr={'00', '10', '01', '11'};
        for c=1:4
            idx = find(experiment.code==c);
            fprintf(f,'%d %s : %10d\n',c,cstr{c},length(idx));
        end
        n10 = length(find(experiment.code==2));
        n01 = length(find(experiment.code==3));        
        fprintf(f,'Ratio 01/10 = %f\n', n01/n10);
        fprintf(f,'Ratio (01+10)/total = %f\n',(n01+n10)/experiment.n);
        
        fprintf(f,'\n###################STATS##############################\n');        
        for c=1:4
            idx = find(experiment.code==c);
            fprintf(f,'[ %d %s        : %10d ]\n',c,cstr{c},length(idx));
            data = experiment.no_norm(idx,:);
            fprintf(f,'    mean      :');
            fprintf(f,'\t%4d',round(mean(data,1)));
            fprintf(f,'\n    median    :');
            fprintf(f,'\t%4d',round(median(data,1)));
            fprintf(f,'\n    std       :');
            fprintf(f,'\t%4d',round(std(data,1)));            
            fprintf(f,'\n\n');
        end
        
        fprintf(f,'\n#################DUMP#################################\n');
        format_str='%3d,\t%4d';
        for j=1:4
            format_str=[format_str ',\t%4d'];
        end
        format_str=[format_str '\n'];
        for i=2:3
            idx=find(experiment.code==i);
            fprintf(f,'[ %d %s        : %10d ]\n',i,cstr{i},length(idx));
            fprintf(f,'im,\tobj,\tw2,\tw3,\t[w2,tw3]<-normalized\n');
            idx=find(experiment.code==i);
            data=round([experiment.image(idx) experiment.object(idx) experiment.no_norm(idx,:) experiment.intensities(idx,:)])';
            fprintf(f,format_str,data);
            fprintf(f,'\n\n');
        end
        fclose(f);
        movefile(tmpfile,[experiment.filename '/summary.txt']);
    else
        disp(['save_experiment : error while saving data in file ' tmpfile]);
    end  

end
