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

if isfield(experiment,'code')
    h=figure;
    plot_mixture(mixture,experiment);
    picname=[experiment.filename '/estimation.png'];
    %disp(['save_experiment : saving figure in file ' picname])
    print(h,'-dpng',picname);
    
    h=figure;
    [bandwidth,density,X,Y]=kde2d(experiment.intensities,128,min(experiment.intensities),max(experiment.intensities));
    imagesc(X(1,:),Y(:,1),log(density+.001));axis xy
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
