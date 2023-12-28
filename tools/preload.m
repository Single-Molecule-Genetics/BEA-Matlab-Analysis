function experiment=preload(src)
%
% data=preload(src)
% 
% load an experiement and tries to load a mat file  it exists
% otherwise create it for the next time.
%
% src is a directory containing the files to load
%

j=1;
for i=1:length(src)
    if src(i)=='\'
        dest(j)='/';
        j=j+1;
    else
        dest(j)=src(i);
        j=j+1;
    end
end
src=dest;
if (src(end)~='/')
    src=[src '/'];
end
allfile = [src 'experiment.mat'];% the name of the preloaded file
f=fopen(allfile);
if (f>0)    % if the file has been already been loaded
    %disp(['preload : loading file ' allfile])
    a=load(allfile);
    experiment=a.experiment;
    fclose(f);
    if ~strcmp(experiment.filename, src)
        disp('preload : the src directory and stored directory are different')
        disp('          Directory have been changed')
        disp(['old :' experiment.filename]);
        disp(['new :' src]);
        disp('          Updating')
        experiment.filename=src;
        save(allfile,'experiment');
    end
else     % file has never been loaded
    %experiment=load_mm_logs(src);
    experiment=load_mm_simple(src);
    save(allfile,'experiment');
end
