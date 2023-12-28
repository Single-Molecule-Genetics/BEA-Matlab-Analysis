    function [e options]=bcall(pt,options)
    %
    % [experiment options]=bcall(pt,pat,options)
    %
    % perform a 2 by 2 base calling on a directory pt
    %
    % options is a structure containing options  :
    %  options.cg='/cg*' : pattern of the sub-directories
    %  options.proba : float [0 1] proba threshold of belonging to a class
    %  options.iterations : integer number of iterations
    %  options.debug : integer 0/1 show itermediate steps
    %  options.alpha : float tradeoff initialization/estimation
    %  options.satellites : uses additional 2 clusters
    %  options.max_cluster_size : maximum cluster size
    %  options.endplot : final plotting
    %  options.pfiltcat : remove classes with less than pfiltcat of the calls
    %  options.image : keep one image
    %
    % returns two structures : experiements and options
    %   experiments structure contains:
    %        nickname: a short name
    %        filename: full name
    %           image: image numbers
    %          object: object numbers
    %     intensities: normalized intensities
    %       nchannels: number of channels
    %               n: total number of objects
    %        channels: code of the channels
    %         no_norm: non normalized intensities
    %            code: code of the class

    %addpath('../LIBRA');
%% check options
    if nargin<1
        disp('bcall : a directory name is needed. Type "help bcall" for more informations.');
        return;        
    end

    % if no options create an empty matrix
    if nargin<2
        options=[];
    end

    if isempty(options)
        hf=fopen('bcallrc.mat');
        if (hf~=-1)
            disp('Loading default options from file bcallrc.mat');
            a=load('bcallrc.mat');
            options=a.options;
            fclose(hf);
        else % keep this sync with reset in gbcall
            options.cg='/CG*';
            options.proba=0;
            options.iterations=5;
            options.max_cluster_size=0;
            options.pfiltcat=.01;
            options.satellites=0;
            options.debug=0;
            options.endplot=0;
            options.close=1;
            options.image=-1;
            options.remove_bad_image=0;
            options.imagewise_normalization=1;
            options.normalization_type=4;
            options.nucleotides=[];
            data_directory='./';    
            save('bcallrc.mat','data_directory','options');
        end
    end

    % Set the pattern for the CG directories
    if ~isfield(options,'cg')
        options.cg='/cg*';
    end

    % if 1 will perform a final plotting (long)
    if ~isfield(options,'endplot')
        options.endplot=0;
    end

    % remove counts in summary < nfiltcat
    if ~isfield(options,'pfiltcat')
        options.pfiltcat=.1; % y default take class with more than 1 percent of the data
    end

    % Select a method
    if ~isfield(options,'method')
        options.method=0;
    end

    % close the window before starting
    if ~isfield(options,'close')
        options.close=1;
    end

    if ~isfield(options,'nucleotides')
        options.nucleotides=[];
    end

    if ~isfield(options,'remove_bad_image')
        options.remove_bad_image=1;
    end
    
    if ~isfield(options,'imagewise_normalization')
        options.imagewise_normalization=1;
    end

    % Add a slash at the end
    if pt(end)~='/' && pt(end)~='\'
        pt=[pt '/'];
    end

    d=dir([pt options.cg]);
    n2x2=length(d);

    if n2x2>0
%% initialization
        tic

        % close figures
        if options.close==1
            ll = get(0,'children');
            for i=1:length(ll)
                if strcmp(get(ll(i),'name'),'gbcall')==0
                    close(ll(i));
                else
                end
            end
        end

        disp(['Analysing ' pt])
        disp([ num2str(n2x2) ' subfolder.'])
        disp('Using following options:')
        disp(options)

        if options.remove_bad_image==1
            options=extract_non_garbage_image(pt,options);
        end


        %% Preload everything    
        data=[];
        h=figure;        
        colors={'r','g','b','y','b','k','r','g','b','y','b','k'};
        for i=1:length(d)
            filenames{i}=[pt d(i).name];
            a(i)=preload(filenames{i});
            data=[data;a(i).intensities];
            plot(log(a(i).intensities(:,1)),log(a(i).intensities(:,2)),'.','MarkerSize',1,'Color',colors{i});hold on
        end
        hold off
        if 0 % Prenormalize     
            disp('Global Normalization')
            data=log(data);
            switch (options.normalization_type)
                case 3
                    [s,m]=rstd(data);
                    C=diag(s);
                case 4
                    [C,m]=rcov(data,options.debug,10000);
            end
            options.covariance=C;
            options.center=m;
            hold on;ellipse_plot(m,C,'m');hold off
        end
        print(h,'-dpng',[pt 'global.png']);
        close(h);
        %% make the analysis 2by2
        for i=1:length(d);
            [analyzedexp(i),mixture,options]=analyze_wash_2by2(a(i),options);
            %=combine_experiments(e,analyze_wash_2by2(e(i),options));
        end
        %% combine
        e=analyzedexp(1);
        for i=2:length(d);
            e=combine_experiments(e,analyzedexp(i));
        end
        % converting ?? into 00
        if options.proba>0
            disp('converting ?? into 00')
            if 1 %% faster version which find ? and converts possible codes
                cc=0:max(e.code);
                ccstr=code2str(cc,length(d));                
                ccstr(find(ccstr=='?'))='0';
                newcc=str2code(ccstr);
                for i=0:max(e.code);
                    if (cc(i+1)~=newcc(i+1))
                        e.code(find(e.code==i))=newcc(i+1);
                    end
                end                
            else %% this is too slow..
                code2str(e.code,2);
                toto = code2str(e.code,lenght(d));
                disp('converting ?? into 00 b')
                toto(find(toto=='??'))='00';
                disp('converting ?? into 00 c')
                e.code=str2code(toto);
                disp('converting ?? into 00 d')
            end
            % end of the convertion
        end
                
        h=hist(e.code,0:max(e.code));
        disp(['Counts for ' pt])
        unclassified=0;
        kunc=0;
        for c=0:length(h)-1
            s=code2str(c,length(d));
            if isempty(strfind(s,'?')) 
                if h(c+1)>options.pfiltcat*e.n/100 && length(h)<30
                    disp(sprintf('%2d %s: %7d',c,s,h(c+1)))
                end
            else
                kunc=kunc+1;
                unclassified=unclassified+h(c+1);
            end
        end
        if length(h)>30
            disp('Result table too long, see summary.txt.')
        end
        disp(['Total unclassifed : ' num2str(unclassified)]);
%% Save the experiement file
        save([pt '/result.mat'],'e');

%% make the global plot
        if options.endplot==1
            %%%%%%
            disp('Preparing final plot.')
            figure(4);
            if ~is_octave()
                fullscreen = get(0,'ScreenSize');
                set(gcf,'Position',[0 0 fullscreen(3) fullscreen(4)])
            end
            clf;
            cmap=jet(length(h)+1);
            %imax=max(e.intensities(:));
            for c=0:length(h)-1;
                s=code2str(c,length(d));
                if isempty(strfind(s,'?'))  && length(strfind(s,'0'))<e.nchannels 
                    data=e.intensities(find(e.code==c),:);
                    k=1;
                    for i=1:e.nchannels
                        for j=i+1:e.nchannels
                            subplot(n2x2,2*n2x2-1,k);hold on

                            plot(data(:,i),data(:,j),'.','MarkerSize',4,'Color',cmap(c+1,:));

                            hold on
                            axis tight
                            box on
                            %%%%%%
                            %axis([-5 imax -5 imax])
                            %%%%%%
                            grid on
                            xlabel(num2str(i));
                            ylabel(num2str(j))
                            k=k+1;
                        end
                    end

                end
            end
            hold off
            picname=[pt '/global.png'];
            %%%%%%
            %disp(['saving figure in file ' picname])
            %%%%%%
            print(4,'-dpng',picname);

            % make the legend
            if is_octave()
                hf=figure;
            else
                fullscreen = get(0,'ScreenSize');
                hf=figure('Position',[0 0 fullscreen(3) fullscreen(4)]);
            end
            k=0;
            for c=0:length(h)-1;
                s=code2str(c,length(d));
                if isempty(strfind(s,'?')) && h(c+1)>options.pfiltcat*e.n/100
                    y=length(h)-kunc-k;
                    %plot([0 1],[y y],'Color',cmap(c+1,:),'Linewidth',10);hold on
                    text(1.1,y,sprintf('%3d %s : %d',c,s,h(c+1)));
                    k=k+1;
                end
            end
            hold off
            axis off
            axis([0 5 0 length(h)-kunc+.5])
            picname=[pt '/legend.png'];
            %disp(['saving figure in file ' picname])
            print(hf,'-dpng',picname);
        end

%% Save into a file a global summary
        disp('Saving global summary. Warten, Bitte!');
        tmpfile=tempname;
        f=fopen(tmpfile,'w');
        if (f~=0)
            fprintf(f,'Globale analysis report of %s \n',pt);
            fprintf(f,'performed on %s \n',datestr(now));
            fprintf(f,'number of data points %d \n',e.n);
            fprintf(f,'number of channels 2x%d=%d \n',n2x2,e.nchannels);
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
            fprintf(f,'final plotting .................... %d\n',options.endplot);
            
%% counts
            fprintf(f,'\n###################COUNTS#########################\n\n');
            fprintf(f,'Total unclassifed : %d\n',unclassified);
            [sh, hidx] = sort(h);
            for c=length(h):-1:1
                cs = hidx(c);
                s=code2str(cs-1,length(d));
                if isempty(strfind(s,'?')) &&  h(cs)>options.pfiltcat*e.n/100;
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
                s=code2str(cs-1,length(d));
                if isempty(strfind(s,'?'))  && h(cs)>options.pfiltcat*e.n/100.0
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
                s=code2str(c,length(d));
                if isempty(strfind(s,'?')) && length(strfind(s,'0'))<e.nchannels && h(c+1)>options.pfiltcat*e.n/100.0
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
            movefile(tmpfile,[pt '/summary.txt']);
        else
            disp(['bcall: Could not save file ' pt 'summary.txt']);
        end
        toc
        disp('Done.')
    else
        disp(['bcall: Unable to find any directory matching the pattern ' options.cg]);
    end
    
    global bcall_options
    bcall_options=options;

    
