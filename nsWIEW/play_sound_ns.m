function varargout = play_sound_ns(varargin)
% PLAY_SOUND_NS M-file for play_sound_ns.fig
%      PLAY_SOUND_NS, by itself, creates a new PLAY_SOUND_NS or raises the existing
%      singleton*.
%
%      H = PLAY_SOUND_NS returns the handle to a new PLAY_SOUND_NS or the handle to
%      the existing singleton*.
%
%      PLAY_SOUND_NS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLAY_SOUND_NS.M with the given input arguments.
%
%      PLAY_SOUND_NS('Property','Value',...) creates a new PLAY_SOUND_NS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before play_sound_ns_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to play_sound_ns_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help play_sound_ns

% Last Modified by GUIDE v2.5 30-Mar-2007 12:16:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @play_sound_ns_OpeningFcn, ...
                   'gui_OutputFcn',  @play_sound_ns_OutputFcn, ...
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


% --- Executes just before play_sound_ns is made visible.
function play_sound_ns_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to play_sound_ns (see VARARGIN)

% Choose default command line output for play_sound_ns
handles.output = hObject;

if ~isempty(varargin),
    if ishandle(varargin{1}),
        handles.phandles=guidata(varargin{1});
    end
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes play_sound_ns wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = play_sound_ns_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function ch1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ch1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function ch2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ch2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function incr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to incr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in play.
function play_Callback(hObject, eventdata, handles)
% hObject    handle to play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.arefr,'value')==1,
    handles.phandles=guidata(handles.phandles.figure1);
    guidata(hObject,handles);
end

ch1=str2num(get(handles.ch1,'string'));
ch2=str2num(get(handles.ch2,'string'));
incr=str2num(get(handles.incr,'string'));

d=handles.phandles.data;
sr=handles.phandles.srate;
if ~isempty(ch1),
    s(:,1)=d(:,ch1(1));
else
    s(:,1)=zeros(size(d(:,1)));
end
if ~isempty(ch2),
    s(:,2)=d(:,ch2(1));
else
    s(:,2)=zeros(size(d(:,1)));
end
if isempty(incr),
    incr=20;
    set(handles.incr,'string',20)
end
    
sound(s,sr*incr);




% --- Executes on button press in arefr.
function arefr_Callback(hObject, eventdata, handles)
% hObject    handle to arefr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of arefr


% --- Executes on button press in refr.
function refr_Callback(hObject, eventdata, handles)
% hObject    handle to refr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.phandles=guidata(handles.phandles.figure1);
guidata(hObject,handles);
