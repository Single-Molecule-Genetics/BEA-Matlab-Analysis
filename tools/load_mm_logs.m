function experiment=load_mm_logs(exp_path,num)
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
disp(['load_mm_logs : loading files in "' exp_path '".'])

if nargin<2
    num=[2 3 4 5];
end
n=-1;

d=dir([exp_path '/*.log' ]);
if (isempty(d))
    d=dir([exp_path '/*.LOG' ]);
end
if isempty(d)
    error('-----\n -> Empty directory %s\n-----\n',exp_path);
end
% load first the object and image numbers
% and check if they are the same for each file
for k=1:length(d)
    filename=[exp_path '/' d(k).name];
    if k==1
        name=get_first_image_name(filename);
    else
        name2=get_first_image_name(filename);
        if ~strcmp(name2,name)
            error('%s and %s do not have the image file names:\n - %s \n - %s  ',d(1).name,d(k).name,name,name2);
        end
    end
end

for k=1:length(d)
    filename=[exp_path '/' d(k).name];
    if k==1     
        [ni no] = load_mm_objects(filename,n);
    else                
        [ni2 no2] = load_mm_objects(filename,n);
        if length(ni2)~=length(ni)
            error('%s and %s do not have the same size.',d(1).name,d(k).name);
        else
            if ni2~=ni
                error('Images in %s and %s are not identical.',d(1).name,d(k).name);
            else
                if no2~=no
                    error('Objects numbers in %s and %s are not identical.',d(1).name,d(k).name);
                end
            end            
        end        
    end
end

n=length(ni);
% Load the channels
for i=1:length(d)
  filename=[exp_path '/' d(i).name];
  x=load_mm_intensities(filename,n);
  if x==0
    disp('load_mm_logs : trying lower case')
    filename=[exp_path 'w' num2str(num(i)) '.log'];
    x=load_mm_intensities(filename,n);
  end
  n=length(x);
  if (length(x)>1)
    data(:,i)=x;
  else
    disp('error in load_mm_log');
  end  
end
disp(sprintf('Size of the data set: %d x %d',size(data,1),size(data,2)));
% Put the data as a structure
experiment.filename=exp_path;
experiment.nickname=experiment_nickname(exp_path);
experiment.object=no;
experiment.image=ni;
experiment.intensities=data;
experiment.nchannels=size(experiment.intensities,2);
experiment.n=size(experiment.intensities,1);
experiment.channels=num;

return

%% Load the image number and object number from a MM log file
function [ni no]=load_mm_objects(filename,n)
if nargin<2
    n=-1;
end
f=fopen(filename,'r');
if (f>0)
  disp(['load_mm_objects : loading file "' filename '".'])
  if n<0 % if n is <0 then estimate the number of line first
    n=num_lines(filename); % to go faster in loading the file
  end
  ni=zeros(n,1);
  no=zeros(n,1);
  
  name=0;
  i=1;
  while (~ feof (f) )  & i<=n
    name = fscanf(f,'%s,',1);
    nii = find_image_number(name);
    values  = fscanf(f,'%d, %d, %d',3);
    if length(values) == 3
        ni(i) = nii;
        no(i) = values(1);
      i=i+1;
    end
    if mod(i,1000) == 0 && is_octave()
      printf('\rload_mm_objects : %d%%',i/n*100);
      fflush(stdout);
    end
  end
  fclose(f);
  if is_octave()
      printf('\r');
  end
else
  disp(['could not load file ' filename '.']);
  ni=0;
  no=0;
end
return

% find the number of lines of the file
function n=num_lines(filename)
    f=fopen(filename,'r');
    buf=0;
    n=0;
    while (~ feof (f) )    
        buf=fgetl(f);
        if ~isempty(buf); % in case it is an empty line
            n=n+1;
        end
    end
    fclose(f);
return

% decode the image number from a string
% defined by the number following the last underscore
function num=find_image_number(str) 
a=find(str=='_');
b=find(str=='"');
num=str2num(str(max(a)+1:max(b)-1));
return


function name=get_first_image_name(filename)
f=fopen(filename,'r');
if (f>0)
    name = fscanf(f,'"%s",',1);
    fclose(f);
    if length(name)>2
        name=name(1:length(name)-2);
    end
end
return


% load intensities
function x=load_mm_intensities(filename,n) 
%
      % x=xload_mm_log(filename,count) 
%
% Reads one log file and return the average intensity per objects.
% count : is the number of points to read if n<0 the all file is read
% 
f=fopen(filename,'r');
if (f>0)
  disp(['load_mm_intensities : loading file "' filename '".'])
  if n<0 % if n is <0 then estimate the number of line first
    n=num_lines(filename); % to go faster in loading the file
  end
  x=zeros(n,1);
  
  name=0;
  i=1;
  err_flag=0;
  while (~ feof (f) )  & i<=n
    name = fscanf(f,'%s,',1);
    values  = fscanf(f,'%d, %d, %f',3);
    if length(values) == 3 & values(2)~=0
      a = double(values(3))/double(values(2));
      if ~isnan(a) & ~isinf(a)
          x(i) = a;      
          i=i+1;
      else
         disp(sprintf('load_mm_intensities : nan or inf at line %d: %s %f',i,name,values))
         err_flag=err_flag+1;
      end
    else
        disp(sprintf('load_mm_intensities : zeros at line %d: %s %f',i,name,values))
        err_flag=err_flag+1;
    end
    if is_octave() && mod(i,1000) == 0
        printf('\rload_mm_intensities : %d%%',i/n*100);fflush(stdout);
    end
  end
  fclose(f);
  if is_octave()
      printf('\r');
  end
  if err_flag>0
      warning(sprintf('There was %d bad lines in the file.\n It may be corrupted or not consistent. You may check them manually at the indicated lines.\n The analysis may fail later.'),err_flag);
  end
else
  disp(['load_mm_intensities : could not load file ' filename '.']);
  x=0;
end
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
