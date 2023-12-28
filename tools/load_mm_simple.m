function experiment=load_mm_simple(exp_path,num)
%
%   data=load_mm_logs(exp_path)
%   Load the Data from a set of 4 files numbered w2.LOG w3.LOG
%   w4.LOG w5.LOG and located in the exp_path
%
%   the file are organized as follow:
%   "image file name",object number, area, intensity
%   the image filename contains the image number as the number after the
%   last underscore.
% 
disp(['load_mm_simple : loading files in "' exp_path '".'])

if nargin<2
    num=[2 3 4 5];
end
n=-1;

d=dir([exp_path '/*.log' ]);
if (isempty(d))
    d=dir([exp_path '/*.LOG' ]);    
end

% Remove files not in the num list


if isempty(d)
    error('-----\n -> Empty directory %s\n-----\n',exp_path);
end
% load first the object and image numbers
% and check if they are the same for each file
idel =[];
for k=1:length(d)
    filename=[exp_path '/' d(k).name];
    nr = regexp(d(k).name, '\d+', 'match');
    if isempty(nr) | ~ismember(str2num(nr{1}), num)
        idel = [idel; k ];    
    end
    
end

% eliminate logs i don't want to include
d(idel) = [];


for k=1:length(d)
    filename=[exp_path '/' d(k).name];
    if k==1     
        x = dlmread(filename);
        experiment.object=x(:,3);
        experiment.image=x(:,2);
        experiment.intensities(:,k)=x(:,5);
    else                
        x = dlmread(filename);
        experiment.intensities(:,k)=x(:,5);        
        if length(x)~=length(experiment.image)
            error('%s and %s do not have the same size.',d(1).name,d(k).name);
        else
            if x(:,2)~=experiment.image
                error('Images in %s and %s are not identical.',d(1).name,d(k).name);
            else
                if x(:,3)~=experiment.object
                    error('Objects numbers in %s and %s are not identical.',d(1).name,d(k).name);
                end
            end            
        end        
    end
end

% Put the data as a structure
experiment.filename=exp_path;
experiment.nickname=experiment_nickname(exp_path);

experiment.nchannels=size(experiment.intensities,2);
experiment.n=size(experiment.intensities,1);
experiment.channels=num;

return



function nickname=experiment_nickname(exp_path)
% extract the name of the experiment from the path
% It is supposed to be the last characters of the path
% ex: data/264_W2_W4/  -> 264_W2_W4
if isunix 
    sep='/';
else
    sep='\';
end
pos=find(exp_path==sep);
switch length(pos)
  case 0 
    nickname=exp_path;
  case 1
    nickname=exp_path(pos:length(exp_path));
  case 2
    nickname=exp_path(pos(1)+1:pos(2)-1);
  otherwise
    nickname=exp_path(pos(length(pos)-1)+1:pos(length(pos))-1);
end
