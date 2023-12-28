function varargout = gbcall(varargin)
% GBCALL M-file for gbcall.fig
%      GBCALL, by itself, creates a new GBCALL or raises the existing
%      singleton*.
%
%      H = GBCALL returns the handle to a new GBCALL or the handle to
%      the existing singleton*.
%
%      GBCALL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GBCALL.M with the given input arguments.
%
%      GBCALL('Property','Value',...) creates a new GBCALL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gbcall_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gbcall_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gbcall

% Last Modified by GUIDE v2.5 04-Nov-2010 14:09:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gbcall_OpeningFcn, ...
                   'gui_OutputFcn',  @gbcall_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gbcall is made visible.
function gbcall_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gbcall (see VARARGIN)

% Choose default command line output for gbcall
handles.output = hObject;
handles=reset(hObject,handles);
%handles.data_directory
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gbcall wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gbcall_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
handles.directory=get(hObject,'String');
set(handles.text13,'String',sprintf('%d folders founds',count_subdirs(handles)));
set_image_slider6_range(hObject, eventdata, handles);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.directory=get(hObject,'String');
%set(handles.text13,'String',sprintf('%d folders founds',count_subdirs(handles)));
guidata(hObject,handles)


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.directory=uigetdir(handles.data_directory,'Enter data file');
set(handles.edit1,'String',handles.directory);
set(handles.text13,'String',sprintf('%d folders founds',count_subdirs(handles)));
set_image_slider6_range(hObject, eventdata, handles);
guidata(hObject,handles)

function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
handles.options.cg=get(hObject,'String');
set(handles.text13,'String',sprintf('%d folders founds',count_subdirs(handles)));
set_image_slider6_range(hObject, eventdata, handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.options.cg=get(hObject,'String');
guidata(hObject,handles)

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.options.proba=round(get(hObject,'Value')*100)/100;
set(handles.edit3,'String',handles.options.proba);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Value',0);
set(hObject,'Min',0);
set(hObject,'Max',1);
guidata(hObject,handles)


function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
handles.options.proba=max(min(str2double(get(hObject,'String')),1),0);
set(handles.slider1,'Value',handles.options.proba);
set(handles.edit3,'String',num2str(handles.options.proba));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',0);


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.options.iterations=round(get(hObject,'Value'));
set(handles.edit4,'String',handles.options.iterations);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Value',5);
set(hObject,'Min',0);
set(hObject,'Max',20);
guidata(hObject,handles)

function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
handles.options.iterations=max(min(str2double(get(hObject,'String')),20),0);
set(handles.slider2,'Value',handles.options.iterations);
set(handles.edit4,'String',num2str(handles.options.iterations));
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',5);


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.options.max_cluster_size=round(10*get(hObject,'Value'))/10;
set(handles.edit7,'String',handles.options.max_cluster_size);
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
slider_step(1) = .1/(5);
slider_step(2) = .1/(5);
set(hObject,'Min',0,'Max',5,'sliderstep',slider_step);
guidata(hObject,handles)


function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double
handles.options.max_cluster_size=max(min(str2double(get(hObject,'String')),20),0);
set(handles.edit7,'String',num2str(handles.options.max_cluster_size));
set(handles.slider3,'Value',handles.options.max_cluster_size);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
handles.options.satellites=get(hObject,'Value');
guidata(hObject,handles)

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
handles.options.debug=get(hObject,'Value');
guidata(hObject,handles)

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
handles.options.endplot=get(hObject,'Value');
guidata(hObject,handles)

% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.options.pfiltcat=get(hObject,'Value');
set(handles.edit8,'String',handles.options.pfiltcat);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'Min',0);
set(hObject,'Max',1);
set(hObject,'Value',handles.options.pfiltcat);
guidata(hObject,handles)

function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double
handles.options.pfiltcat=max(min(str2double(get(hObject,'String')),1),0);
set(handles.slider4,'Value',handles.options.pfiltcat);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
handles.options.pfiltcat=max(min(str2double(get(hObject,'String')),1),0);
guidata(hObject,handles)

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
n2x2=count_subdirs(handles);
if n2x2>0
    d=dir([handles.directory '/' handles.options.cg]);
    h=fopen([handles.directory '/' d(1).name '/experiment.mat']);
    if h>0
        fclose(h);
        e=preload([handles.directory '/' d(1).name]);
        if handles.options.image<0
            n=e.n;
        else
            n=size(find(e.image==handles.options.image),1);
        end
        if n>0            
            disp(sprintf('Data size 2x%dx%d',n2x2,n));
            bcall(handles.directory,handles.options);
        else
            disp(sprintf('Image %d image not found.',handles.options.image));
            set(handles.text15,'foregroundcolor','r');
        end
    else % cannot perform a precheck of the data if they have not been preloaded
        bcall(handles.directory,handles.options);
    end
else
    disp('No subdirectory found.')
end
guidata(hObject,handles)


function n2x2=count_subdirs(handles)
n2x2=length(dir([handles.directory '/' handles.options.cg]));
%disp([num2str(n2x2) ' folders founds.'])



function handles=reset(hObject,handles)
hf=fopen('bcallrc.mat');
if (hf~=-1)
    disp('Loading default options from bcallrc.mat');
    a=load('bcallrc.mat');
    handles.options=[];
    handles.options=a.options;
    handles.data_directory=a.data_directory;
    guidata(hObject,handles);
    set(handles.edit10,'String',handles.data_directory);
    set(handles.slider1,'Value',handles.options.proba);
    set(handles.edit3,'String',handles.options.proba);
    set(handles.slider2,'Value',handles.options.iterations);
    set(handles.edit4,'String',handles.options.iterations);
    set(handles.slider3,'Value',handles.options.max_cluster_size);
    set(handles.edit7,'String',handles.options.max_cluster_size);
    set(handles.slider4,'Value',handles.options.pfiltcat);
    set(handles.edit8,'String',handles.options.pfiltcat);
    set(handles.checkbox1,'Value',handles.options.satellites);
    set(handles.checkbox2,'Value',handles.options.debug);
    set(handles.checkbox3,'Value',handles.options.endplot);
    set(handles.checkbox4,'Value',handles.options.close);
    set(handles.checkbox5,'value',handles.options.remove_bad_image);
    set(handles.checkbox6,'value',handles.options.imagewise_normalization);
    set(handles.popupmenu2,'value',handles.options.normalization_type);
    set(handles.edit11,'String','all');
    set(handles.edit12,'String',handles.options.nucleotides);
    fclose(hf);
    disp(['Default data directory changed to ' handles.data_directory]);
else    
    disp('Configuration file bcallrc.mat file not found. Create a new one.');
    options.cg='/CG*';
    options.proba=0;
    options.iterations=5;
    options.max_cluster_size=2;
    options.pfiltcat=.1;
    options.satellites=1;
    options.debug=0;
    options.endplot=0;
    options.close=1;
    options.image=-1;
    options.nucleotides=[];
    options.remove_bad_image=1;
    options.imagewise_normalization=1;
    options.normalization_type=4;
    data_directory='./';
    handles.options=options;
    handles.data_directory=data_directory;
    guidata(hObject,handles);
    save_bcallrc(hObject,handles);
    handles=reset(hObject,handles);
    guidata(hObject,handles);
end


function save_bcallrc(hObject,handles)
data_directory=handles.data_directory;
options=handles.options;
save('bcallrc.mat','data_directory','options');


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=reset(hObject,handles);
guidata(hObject,handles);

function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double
handles.data_directory=get(hObject,'String');
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.data_directory=uigetdir('*','Enter data file');
disp(['Data directory changed to ' handles.data_directory]);
set(handles.edit10,'String',handles.data_directory);
guidata(hObject,handles)

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_bcallrc(hObject,handles)


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
handles.options.close=get(hObject,'Value');
guidata(hObject,handles)


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.options.image=round(get(hObject,'value'));
if handles.options.image<0
    set(handles.edit11,'String','all');
else
    set(handles.edit11,'String',num2str(handles.options.image));
end
set(handles.text15,'foregroundcolor','k')
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
guidata(hObject,handles)

function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double
s=get(hObject,'String');
val = min(str2double(s),get(handles.slider6,'Max'));
if strcmp(s,'all')==1 || val<0
    set(handles.slider6,'value',-1);
    handles.options.image=-1;
    set(handles.edit11,'String','all');
else
    set(handles.slider6,'value',val)
    handles.options.image=val;
    set(handles.edit11,'String',num2str(handles.options.image));
end

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function n=count_images(handles)
d=dir([handles.directory '/' handles.options.cg]);
n2x2=length(d);
n=-1;
if n2x2>0
    h=fopen([handles.directory '/' d(1).name '/experiment.mat']);
    if h>0
        fclose(h);
        e=preload([handles.directory '/' d(1).name]);
        n=max(e.image);
        disp(sprintf('%d image founds',n));
    else
        disp('Cache not found: Cannot select images if the MM files have not');
        disp('been loaded once before. Please run the analysis a first time to');
        disp('convert the files.');
        n=-1;
    end
end

function set_image_slider6_range(hObject, eventdata, handles)
n=count_images(handles);
slider_step(1) = 1/(n+2);
slider_step(2) = 1/(n+2);
set(handles.slider6,'Min',-1,'Max',n,'sliderstep',slider_step);
guidata(hObject,handles);



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double

handles.options.nucleotides=get(hObject,'String');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5
handles.options.remove_bad_image=get(hObject,'Value');
guidata(hObject,handles)


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6
handles.options.imagewise_normalization=get(hObject,'Value');
guidata(hObject,handles)


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
%contents = cellstr(get(hObject,'String'));
handles.options.normalization_type=get(hObject,'Value');
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
