function disp_base(experiment,id_data)
%
%  disp_base(experiment,id_data)
%
%  Print a summary and display a legend with the counts
%
data=experiment.intensities;
base=experiment.bases;

if  experiment.nchannels==4
    if nargin<2
        h=hist(encode_base(base),0:15);
        disp('id : w2 w3 w4 w5 : n')
        for i=0:15
            if(h(i+1)~=0)
                disp(sprintf('%2d : %s: %d',i,decode_base_str(i),h(i+1)))
            end
        end
        figure('Position',[20 20 300 400]);
        cmap=hsv(16);
        for i=0:15
            axis([0 4 -.5 15.5])
            plot([0 1],[15-i 15-i],'Color',cmap(i+1,:),'LineWidth',10);
            text(1.25,15-i,sprintf('%02d  :    %s  :   %d',i,decode_base_str(i),h(i+1)))
            axis off
            hold on;
        end
        hold off
        title(['Summary for experiment : ' escape_special_char(experiment.nickname)])
        picname=[experiment.filename 'summary.png'];
        disp(['disp_base : saving figure in file ' picname])
        print('-dpng',picname);
    else

        disp(['    k | im  obj |  w2   w3   w4   w5  |  w2   w3   w4   w5 | class'])
        for i=1:length(id_data)
            k=id_data(i);
            disp(sprintf('% 6d | %2d %4d | %4d %4d %4d %4d | %4d %4d %4d %4d | %2d', ...
                k,experiment.image(k),experiment.object(k),round(data(k,:)) ,base(k,:),encode_base(base(k,:)) )  );
        end

    end
else %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin<2
        h=hist(encode_base(base),0:4);
        disp('id : w w : n')
        for i=0:3
            if(h(i+1)~=0)
                disp(sprintf('%2d : %s: %d',i,decode_base_str(i),h(i+1)))
            end
        end
        figure('Position',[20 20 300 400]);
        cmap=hsv(32);
        for i=0:3
            axis([0 4 -.5 4.5])
            plot([0 1],[4-i 4-i],'Color',cmap(4*i+4,:),'LineWidth',10);
            text(1.25,4-i,sprintf('%02d  :    %s  :   %d',i,decode_base_str(i),h(i+1)))
            axis off
            hold on;
        end
        hold off
        title(['Summary for experiment : ' escape_special_char(experiment.nickname)])
        picname=[experiment.filename 'summary.png'];
        disp(['disp_base : saving figure in file ' picname])
        print('-dpng',picname);
    else

        disp(['    k | im  obj |  w   w  |   w   w | class'])
        for i=1:length(id_data)
            k=id_data(i);
            disp(sprintf('% 6d | %2d %4d | %4d %4d  | %4d %4d  | %2d', ...
                k,experiment.image(k),experiment.object(k),round(data(k,:)) ,base(k,:),encode_base(base(k,:)) )  );
        end

    end
end


