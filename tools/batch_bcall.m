function batch_bcall(rt,options)
% script to run the base calling
% Process all the files in the directory rt

% check the options
if nargin<1
    rt='/home/jboulang/data/irene/';
end

if nargin<2
    options.iterations=5;
    options.proba=0.9;
    options.alpha=.1;
    options.satellites=1;
    options.cg='cg*';
    options.debug=0;
end

% make a list of the directory to process
pt=list_directories(rt);

% process the directories
process_list(pt,options);


% make a list of the directory to process
function pt=list_directories(rt)
d0=dir(rt);
k=1;
pt=[];
for i=3:length(d0)
    if d0(i).isdir==1
        d1=dir([rt d0(i).name]);
        for j=3:length(d1)
            t2=dir([rt d0(i).name '/' d1(j).name '/cg*']);
            if ~isempty(t2)
                pt{k}=[rt  d0(i).name '/' d1(j).name '/'];
                disp([num2str(k) ' : ' pt{k}]);                
                k=k+1;
            end
        end
    end
end

% process the directories
function process_list(pt,options)
for i=1:length(pt)
    close all
    disp(sprintf('\n *** %d/%d ***\n',i,length(pt)))
    bcall(pt{i},options);
end

