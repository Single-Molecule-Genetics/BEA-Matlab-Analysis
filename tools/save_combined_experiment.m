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