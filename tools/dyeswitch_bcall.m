function [e,options]=dyeswitch_bcall(directory,options)
%[e,options]=dyesswitch_bcall(directory,options);
%
% options.global=true activate the computation on the all dataset otherwise
%                only the first dataset is used

close all;

if ~isstr(directory)
    disp('First argument should be a string')
end

if nargin<2
    options=[];
end

if ~isfield(options,'cg')
    options.cg='/snp*';
end

if ~isfield(options,'global')
    options.global=true;
end

if isfield(options,'imagewise_normalization')
    if options.imagewise_normalization==1
        disp('Reset options.imagewise_normalization to 0.')
        options.imagewise_normalization=0;
    end
else
    options.imagewise_normalization=0;
end

if ~isfield(options,'max_cluster_size')
    options.max_cluster_size=.5;
end

if ~isfield(options,'remove_bad_image')
    options.remove_bad_image=0;
end

if ~isfield(options,'nucleotides')
    options.nucleotides=[];
end

if ~isfield(options,'image')
    options.image=-1;
end

% Add a slash at the end
if directory(end)~='/' && directory(end)~='\'
    directory=[directory '/'];
end

if options.remove_bad_image==1
    options=extract_non_garbage_image(directory,options);
end

d=dir([directory options.cg]);
K=length(d);
% load and merge
data=[];
tag=[];
disp(sprintf('Loading %d datasets in %s ...',K,[directory options.cg]));
for i=1:K
    filenames{i}=[directory d(i).name];
    fprintf(1,'[%d] %s\n',i,filenames{i});
    e(i)=preload(filenames{i});
    if options.global
        data=[data;e(i).intensities];
        %tag=[tag; i*ones(size(e(i).intensities,1),1)];
    end
end

if options.global==true
    % make the global experiemnt structure
    disp('Calibration on merged datasets...')
    g.filename=directory;
    g.nickname=directory;
    g.channels=e(1).channels;
    g.n=size(data,1);
    g.intensities=data;
    g.object=(1:g.n)';
    g.image=ones(g.n,1);
    g.nchannels=2;
    eref=g;
else
    fprintf(1,'Calibration on 1st dataset (%s)..',e(1).filename)
    eref=e(1);
end

% analyze the data in one
options.normalization.use_precomputed=false;
[eref,mixture,options]=analyze_wash_2by2(eref,options);
options
options.normalization.use_precomputed=true;%% modif
options.normalization.center=eref.normalization.center;
options.normalization.covariance=eref.normalization.covariance;
options.imagewise_normalization=0;
% split the data
for i=1:K
    disp(['Classification of ' filenames{i}])
    newe(i)=classify(e(i),mixture,options);
    save_experiment(newe(i),mixture,options);
end

% Combining dye switches
e=combine(newe,options);
save_combined_experiment(e,options,directory);



function experiment=classify(experiment,mixture,options)
if ~isfield(options,'proba')
    options.proba=0;
end
experiment=extract_image(experiment,options.image);
[experiment,options]=normalize_experiment(experiment,options);
if 0
    experiment.no_norm=experiment.intensities;
    experiment.intensities=log(experiment.intensities);
    n = size(experiment.intensities,1);
    s=sqrt(diag(options.normalization.covariance))';
    m=options.normalization.center;
    experiment.intensities=(experiment.intensities-ones(n,1)*m)./(ones(n,1)*s);
end
p=estep(mixture,experiment.intensities,options);
%p=p./(ones(size(p),1)*mean(p));
experiment=assign_code(experiment,p,options.proba);



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
    
    h=figure;
    col='krgmbkkkk';
    for i=2:3
        s=find(experiment.code==i);
        plot(experiment.no_norm(s,1),experiment.no_norm(s,2),[col(i+1),'.'],'MarkerSize',1)
        hold on
    end
    hold off
    xlabel('channel 1');ylabel('channel 2')
    picname=[experiment.filename '/nonorm_cluster2and3.png'];
    %disp(['save_experiment : saving figure in file ' picname])
    print(h,'-dpng',picname);
    close(h);
    
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
        fprintf(1,'0 ?? : %10d <- unclassified\n',length(find(experiment.code==0)));
        cstr={'00', '10', '01', '11'};
        for c=1:4
            idx = find(experiment.code==c);
            fprintf(f,'%d %s : %10d\n',c,cstr{c},length(idx));
            fprintf(1,'%d %s : %10d\n',c,cstr{c},length(idx));
        end
        n10 = length(find(experiment.code==2));
        n01 = length(find(experiment.code==3));
        fprintf(f,'Ratio 01/10 = %f\n', n01/n10);
        fprintf(f,'Ratio (01+10)/total = %f\n',(n01+n10)/experiment.n);
        fprintf(1,'Ratio 01/10 = %f\n', n01/n10);
        fprintf(1,'Ratio (01+10)/total = %f\n',(n01+n10)/experiment.n);
        
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
        %% Save statistics dump
        fprintf(f,'\n#################DUMP PER CLASS###################\n');
        format_str='%3d,\t%4d';
        for j=1:experiment.nchannels
            format_str=[format_str ',\t%4d'];
        end
        for j=1:experiment.nchannels
            format_str=[format_str ',\t%4d'];
        end
        format_str=[format_str '\n'];
        h=hist(experiment.code,0:max(experiment.code))     ;
        for c=0:length(h)-1;
            s=code2str(c,experiment.nchannels/2);
            if isempty(strfind(s,'?')) && length(strfind(s,'0'))<experiment.nchannels
                idx=find(experiment.code==c);
                data=round([experiment.image(idx) experiment.object(idx) experiment.no_norm(idx,:) experiment.intensities(idx,:)])';
                if ~isempty(options.nucleotides)
                    fprintf(f,'[ %2d %s %s: %10d ]\n',c,s,code2seq(c,options.nucleotides),h(c+1));
                else
                    fprintf(f,'[ %2d %s : %10d ]\n',c,s,h(c+1));
                end
                fprintf(f,'im,\t obj');
                fprintf(f,'\tw%4d',1:experiment.nchannels);
                fprintf(f,'\tw%4d',1:experiment.nchannels);
                fprintf(f,'\n');
                fprintf(f,format_str,data);
                fprintf(f,'\n\n\n\n');
            end
        end
        fclose(f);
        movefile(tmpfile,[experiment.filename '/summary.txt']);
    else
        disp(['save_experiment : error while saving data in file ' tmpfile]);
    end
    
end


function e=combine(analyzedexp,options)
disp('combining')
%% combine
e=combine_experiments(analyzedexp(1),analyzedexp(2));

% converting ?? into 00
if ~isfield(options,'proba')
    options.proba=0;
end

if options.proba>0
    disp('converting ?? into 00')
        cc=0:max(e.code);
        ccstr=code2str(cc,length(e));
        ccstr(find(ccstr=='?'))='0';
        newcc=str2code(ccstr);
        for i=0:max(e.code);
            if (cc(i+1)~=newcc(i+1))
                e.code(find(e.code==i))=newcc(i+1);
            end
        end
end

h=hist(e.code,0:max(e.code));
%disp(['Counts for ' pt])
unclassified=0;
kunc=0;
for c=0:length(h)-1
    s=code2str(c,length(e));
    if isempty(strfind(s,'?'))       
        disp(sprintf('%2d %s: %7d',c,s,h(c+1)))
    else
        kunc=kunc+1;
        unclassified=unclassified+h(c+1);
    end
end
if length(h)>30
    disp('Result table too long, see summary.txt.')
end
disp(['Total unclassifed : ' num2str(unclassified)]);


function save_combined_experiment(e,options,pt)
disp('Saving global summary. Warten, Bitte!');
tmpfile=tempname;
f=fopen(tmpfile,'w');
if (f~=0)
    fprintf(f,'Globale analysis report of %s \n',pt);
    fprintf(f,'performed on %s \n',datestr(now));
    fprintf(f,'number of data points %d \n',e.n);
    fprintf(f,'number of channels =%d \n',e.nchannels);
    if isfield(e,'no_norm')
        ns=sum(e.no_norm==4095);
        for i=1:length(ns)
            if ns(i)>0
                fprintf(f,'Warning : %d points saturated in channel %d\n',ns(i),i);
            end
        end
    end
    %% save option
    fprintf(f,'\n###################OPTIONS###################\n\n');
    switch options.method
        case 0
            fprintf(f,'method ............................ EM\n');
            fprintf(f,'number of iteration ............... %d\n',options.iterations);
            fprintf(f,'probability ....................... %.3f\n',options.proba);
            %                    fprintf(f,'a priori/data tradeoff ............ %.3f\n',options.alpha);
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
%    fprintf(f,'final plotting .................... %d\n',options.endplot);
    
    %% counts
    fprintf(f,'\n###################COUNTS#########################\n\n');
%    fprintf(f,'Total unclassifed : %d\n',unclassified);    
    h=hist(e.code,0:max(e.code));
    [sh, hidx] = sort(h);
    for c=length(h):-1:1
        cs = hidx(c);
        s=code2str(cs-1,2);
        if isempty(strfind(s,'?'))
            if ~isempty(options.nucleotides);
                fprintf(f,'%2d %s %s: %10d\n',cs-1,s,code2seq(cs-1,options.nucleotides),h(cs));
            else
                fprintf(f,'%2d %s : %10d\n',cs-1,s,h(cs));
            end
        end
    end
    %% save stats
    fprintf(f,'\n###################GLOBAL STATS###################\n');
    fprintf(f,'\nmean   :');
    fprintf(f,'\t%4d',round(mean(e.no_norm,1)));
    fprintf(f,'\t-');
    fprintf(f,'\t%4d',round(mean(e.intensities,1)));
    fprintf(f,'\nmedian  :');
    fprintf(f,'\t%4d',round(median(e.no_norm,1)));
    fprintf(f,'\t-');
    fprintf(f,'\t%4d',round(median(e.intensities,1)));
    fprintf(f,'\nstd     :');
    fprintf(f,'\t%4d',round(std(e.no_norm,1)));
    fprintf(f,'\t-');
    fprintf(f,'\t%4d',round(std(e.intensities,1)));
    
    %% Save statistics per class
    fprintf(f,'\n\n##################STATS PER CLASS#################\n\n');
    for c=length(h):-1:1
        cs = hidx(c);
        s=code2str(cs-1,2);
        if isempty(strfind(s,'?'))
            idx=find(e.code==cs-1);
            data0=e.no_norm(idx,:);
            data1=e.intensities(idx,:);
            if ~isempty(options.nucleotides)
                fprintf(f,'[ %2d %s %s: %10d ]\n',cs-1,s,code2seq(cs-1,options.nucleotides),h(cs));
            else
                fprintf(f,'[ %2d %s : %10d ]\n',cs-1,s,h(cs));
            end
            fprintf(f,'    mean    :');
            fprintf(f,'\t%4d',round(mean(data0,1)));
            fprintf(f,'\t-');
            fprintf(f,'\t%4d',round(mean(data1,1)));
            fprintf(f,'\n    median  :');
            fprintf(f,'\t%4d',round(median(data0,1)));
            fprintf(f,'\t-');
            fprintf(f,'\t%4d',round(median(data1,1)));
            fprintf(f,'\n    std     :');
            fprintf(f,'\t%4d',round(std(data0,1)));
            fprintf(f,'\t-');
            fprintf(f,'\t%4d',round(std(data1,1)));
            fprintf(f,'\n\n');
        end
    end
    
    %% Save statistics dump
    fprintf(f,'\n#################DUMP PER CLASS###################\n');
    format_str='%3d,\t%4d';
    for j=1:e.nchannels
        format_str=[format_str ',\t%4d'];
    end
    for j=1:e.nchannels
        format_str=[format_str ',\t%4d'];
    end
    format_str=[format_str '\n'];
    
    for c=0:length(h)-1;
        s=code2str(c,2);
        if isempty(strfind(s,'?')) && length(strfind(s,'0'))<e.nchannels
            idx=find(e.code==c);
            data=round([e.image(idx) e.object(idx) e.no_norm(idx,:) e.intensities(idx,:)])';
            if ~isempty(options.nucleotides)
                fprintf(f,'[ %2d %s %s: %10d ]\n',c,s,code2seq(c,options.nucleotides),h(c+1));
            else
                fprintf(f,'[ %2d %s : %10d ]\n',c,s,h(c+1));
            end
            fprintf(f,'im,\t obj');
            fprintf(f,'\tw%4d',1:e.nchannels);
            fprintf(f,'\tw%4d',1:e.nchannels);
            fprintf(f,'\n');
            fprintf(f,format_str,data);
            fprintf(f,'\n\n\n\n');
        end
    end
    fclose(f);
    %% copy the tmp file to local
    disp(['Saving ' pt '/summary.txt'])
    movefile(tmpfile,[pt '/summary.txt']);
    disp('done')
else
    disp(['bcall: Could not save file ' pt 'summary.txt']);
end
