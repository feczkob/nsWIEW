function varargout = goselect(varargin)
% GOSELECT M-file for goselect.fig
%      GOSELECT, by itself, creates a new GOSELECT or raises the existing
%      singleton*.
%
%      H = GOSELECT returns the handle to a new GOSELECT or the handle to
%      the existing singleton*.
%
%      GOSELECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GOSELECT.M with the given input arguments.
%
%      GOSELECT('Property','Value',...) creates a new GOSELECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before goselect_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to goselect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help goselect

% Last Modified by GUIDE v2.5 20-May-2007 19:33:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @goselect_OpeningFcn, ...
                   'gui_OutputFcn',  @goselect_OutputFcn, ...
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


% --- Executes just before goselect is made visible.
function goselect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to goselect (see VARARGIN)

% Choose default command line output for goselect
handles.output = hObject;

if ~isempty(varargin),
    if ishandle(varargin{1}),
        handles.phandles=guidata(varargin{1});
    end
    if ~isempty(handles.phandles.actualtransformout),
        set(handles.ereasecb,'value',1);
    else
        set(handles.ereasecb,'enable','off');
    end
end



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes goselect wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = goselect_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pb0.
function pb_Callback(hObject, eventdata, handles)
% hObject    handle to pb0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

rbs=findobj(handles.figure1,'style','radiobutton');
rb=[];
for a=1:length(rbs),
    if get(rbs(a),'value')==1,
        tag=get(rbs(a),'tag');
        rb=num2str(tag(3:end));
    end
end

data.tag=get(hObject,'tag');
data.rb=rb;
set(handles.figure1,'userdata',data);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure('menubar','none','numbertitle','off','position',[360 502 371 260]);
t=help('actualtransform');
ui=uicontrol('style','text','position',[20 20 325 221],'string',t);
set(ui,'unit','normalized')

% --- Executes on button press in rb1.
function rb_Callback(hObject, eventdata, handles)
% hObject    handle to rb1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb1

rbs=findobj(handles.figure1,'style','radiobutton');
set(rbs,'value',0);
set(hObject,'value',1);


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1




% --- Executes on button press in rb8.
function rb8_Callback(hObject, eventdata, handles)
% hObject    handle to rb8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb8


% --- Executes on button press in rb9.
function rb9_Callback(hObject, eventdata, handles)
% hObject    handle to rb9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb9


