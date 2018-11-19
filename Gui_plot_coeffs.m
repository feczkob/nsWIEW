function varargout = Gui_plot_coeffs(varargin)
% GUI_PLOT_COEFFS MATLAB code for Gui_plot_coeffs.fig
%      GUI_PLOT_COEFFS, by itself, creates a new GUI_PLOT_COEFFS or raises the existing
%      singleton*.
%
%      H = GUI_PLOT_COEFFS returns the handle to a new GUI_PLOT_COEFFS or the handle to
%      the existing singleton*.
%
%      GUI_PLOT_COEFFS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_PLOT_COEFFS.M with the given input arguments.
%
%      GUI_PLOT_COEFFS('Property','Value',...) creates a new GUI_PLOT_COEFFS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Gui_plot_coeffs_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Gui_plot_coeffs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Gui_plot_coeffs

% Last Modified by GUIDE v2.5 26-Sep-2018 19:09:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Gui_plot_coeffs_OpeningFcn, ...
                   'gui_OutputFcn',  @Gui_plot_coeffs_OutputFcn, ...
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


% --- Executes just before Gui_plot_coeffs is made visible.
function Gui_plot_coeffs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Gui_plot_coeffs (see VARARGIN)

% Choose default command line output for Gui_plot_coeffs
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Gui_plot_coeffs wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Gui_plot_coeffs_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load_pushbutton.
function load_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to load_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('*.*','Select file');
load([pathname filename], 'inspk', 'cluster_class');

set(handles.data_text,'String',[pathname filename]);
handles.pathname = pathname;
handles.filename = filename;
handles.inspk = inspk;
handles.cluster_class = cluster_class;
handles.no_coeff = size(inspk,2);
handles.color = 'wave_clus';
handles.markersize = 8;

dim_coeff_1 = 1;
dim_coeff_2 = 2;
str_coeff_1 = num2str(dim_coeff_1);
str_coeff_2 = num2str(dim_coeff_2);
set(handles.coeff_1_edit, 'String', str_coeff_1);
set(handles.coeff_2_edit, 'String', str_coeff_2);

cla
plot_coeff_vs_coeff(inspk, cluster_class, dim_coeff_1, dim_coeff_2, handles.color, handles.markersize)

guidata(hObject, handles);


% --- Executes on button press in coeff_1_decr_pushbutton.
function coeff_1_decr_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to coeff_1_decr_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str_coeff_1 = get(handles.coeff_1_edit, 'String');
dim_coeff_1 = str2double(str_coeff_1);

if dim_coeff_1 > 1
    dim_coeff_1_updated = dim_coeff_1 - 1;
    str_coeff_1_updated = num2str(dim_coeff_1_updated);
    set(handles.coeff_1_edit, 'String', str_coeff_1_updated);

    inspk = handles.inspk;
    cluster_class = handles.cluster_class;
    str_coeff_1 = get(handles.coeff_1_edit, 'String');
    str_coeff_2 = get(handles.coeff_2_edit, 'String');
    dim_coeff_1 = str2double(str_coeff_1);
    dim_coeff_2 = str2double(str_coeff_2);
    
    cla
    plot_coeff_vs_coeff(inspk, cluster_class, dim_coeff_1, dim_coeff_2, handles.color, handles.markersize)
end

guidata(hObject, handles);



% --- Executes on button press in coeff_1_incr_pushbutton.
function coeff_1_incr_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to coeff_1_incr_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str_coeff_1 = get(handles.coeff_1_edit, 'String');
dim_coeff_1 = str2double(str_coeff_1);

if dim_coeff_1 < handles.no_coeff
    dim_coeff_1_updated = dim_coeff_1 + 1;
    str_coeff_1_updated = num2str(dim_coeff_1_updated);
    set(handles.coeff_1_edit, 'String', str_coeff_1_updated);

    inspk = handles.inspk;
    cluster_class = handles.cluster_class;
    str_coeff_1 = get(handles.coeff_1_edit, 'String');
    str_coeff_2 = get(handles.coeff_2_edit, 'String');
    dim_coeff_1 = str2double(str_coeff_1);
    dim_coeff_2 = str2double(str_coeff_2);
    
    cla
    plot_coeff_vs_coeff(inspk, cluster_class, dim_coeff_1, dim_coeff_2, handles.color, handles.markersize)
end

guidata(hObject, handles);

% --- Executes on button press in coeff_2_decr_pushbutton.
function coeff_2_decr_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to coeff_2_decr_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str_coeff_2 = get(handles.coeff_2_edit, 'String');
dim_coeff_2 = str2double(str_coeff_2);

if dim_coeff_2 > 1
    dim_coeff_2_updated = dim_coeff_2 - 1;
    str_coeff_2_updated = num2str(dim_coeff_2_updated);
    set(handles.coeff_2_edit, 'String', str_coeff_2_updated);

    inspk = handles.inspk;
    cluster_class = handles.cluster_class;
    str_coeff_1 = get(handles.coeff_1_edit, 'String');
    str_coeff_2 = get(handles.coeff_2_edit, 'String');
    dim_coeff_1 = str2double(str_coeff_1);
    dim_coeff_2 = str2double(str_coeff_2);
    
    cla
    plot_coeff_vs_coeff(inspk, cluster_class, dim_coeff_1, dim_coeff_2, handles.color, handles.markersize)
end

guidata(hObject, handles);



% --- Executes on button press in coeff_2_incr_pushbutton.
function coeff_2_incr_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to coeff_2_incr_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
str_coeff_2 = get(handles.coeff_2_edit, 'String');
dim_coeff_2 = str2double(str_coeff_2);

if dim_coeff_2 < handles.no_coeff
    dim_coeff_2_updated = dim_coeff_2 + 1;
    str_coeff_2_updated = num2str(dim_coeff_2_updated);
    set(handles.coeff_2_edit, 'String', str_coeff_2_updated);

    inspk = handles.inspk;
    cluster_class = handles.cluster_class;
    str_coeff_1 = get(handles.coeff_1_edit, 'String');
    str_coeff_2 = get(handles.coeff_2_edit, 'String');
    dim_coeff_1 = str2double(str_coeff_1);
    dim_coeff_2 = str2double(str_coeff_2);
    
    cla
    plot_coeff_vs_coeff(inspk, cluster_class, dim_coeff_1, dim_coeff_2, handles.color, handles.markersize)
end

guidata(hObject, handles);



function coeff_2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to coeff_2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of coeff_2_edit as text
%        str2double(get(hObject,'String')) returns contents of coeff_2_edit as a double
str_coeff_2 = get(hObject, 'String');
dim_coeff_2 = str2double(str_coeff_2);

if dim_coeff_2 >= 1 && dim_coeff_2 <= handles.no_coeff
    inspk = handles.inspk;
    cluster_class = handles.cluster_class;
    str_coeff_1 = get(handles.coeff_1_edit, 'String');
    dim_coeff_1 = str2double(str_coeff_1);
    
    cla
    plot_coeff_vs_coeff(inspk, cluster_class, dim_coeff_1, dim_coeff_2, handles.color, handles.markersize)
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function coeff_2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to coeff_2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function coeff_1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to coeff_1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of coeff_1_edit as text
%        str2double(get(hObject,'String')) returns contents of coeff_1_edit as a double
str_coeff_1 = get(hObject, 'String');
dim_coeff_1 = str2double(str_coeff_1);

if dim_coeff_1 >= 1 && dim_coeff_1 <= handles.no_coeff
    inspk = handles.inspk;
    cluster_class = handles.cluster_class;
    str_coeff_2 = get(handles.coeff_2_edit, 'String');
    dim_coeff_2 = str2double(str_coeff_2);
    
    cla
    plot_coeff_vs_coeff(inspk, cluster_class, dim_coeff_1, dim_coeff_2, handles.color, handles.markersize)
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function coeff_1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to coeff_1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function plot_coeff_vs_coeff(inspk, cluster_class, dim_coeff_1, dim_coeff_2, coloring, markersize)
% Initialize:
c_wavelet_1 = inspk(:,dim_coeff_1);
c_wavelet_2 = inspk(:,dim_coeff_2);
no_cluster = cluster_class(:,1); % # of cluster

% Plot coeff_{wavelet}_i vs coeff_{wavelet}_j:
% fig_wavelet_coeff_time = figure('Name', ['C_w_' num2str(dim_coeff_1) ' vs. C_w_' num2str(dim_coeff_2)  ],...
%                                 'units','normalized','outerposition',[0 0 1 1]);
hold on 
% plot the rejected spikes with black:
scatter(c_wavelet_1(no_cluster == 0),c_wavelet_2(no_cluster == 0),markersize,[0 0 0],'filled');
switch coloring
    % plot the clustered spikes with the same color used in the wave_clus:
    case 'wave_clus'
        clus_colors = [ [0.0 0.0 1.0];
                        [1.0 0.0 0.0];
                        [0.0 0.5 0.0];
                        [0.620690 0.0 0.0];
                        [0.413793 0.0 0.758621];
                        [0.965517 0.517241 0.034483];
                        [0.448276 0.379310 0.241379];
                        [1.0 0.103448 0.724138];
                        [0.545 0.545 0.545];
                        [0.586207 0.827586 0.310345];
                        [0.965517 0.620690 0.862069];
                        [0.620690 0.758621 1.]  ]; 
        set(0,'DefaultAxesColorOrder',clus_colors);

        for i = 1:max(no_cluster)
            cluster_c_wavelet_1 = c_wavelet_1(no_cluster == i);
            cluster_c_wavelet_2 = c_wavelet_2(no_cluster == i);
            scatter(cluster_c_wavelet_1,cluster_c_wavelet_2,markersize,'filled');
        end
           
     % all clusters with grey ('blinded' scatter plot):
    case 'grey'
        color = [0.3, 0.3, 0.3];
        scatter(c_wavelet_1,c_wavelet_2,markersize,color,'filled');
end
hold off


% --- Executes on selection change in coloring_popupmenu.
function coloring_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to coloring_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns coloring_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from coloring_popupmenu
contents = cellstr(get(hObject,'String'));
handles.color = contents{get(hObject,'Value')};
    inspk = handles.inspk;
    cluster_class = handles.cluster_class;
    str_coeff_1 = get(handles.coeff_1_edit, 'String');
    str_coeff_2 = get(handles.coeff_2_edit, 'String');
    dim_coeff_1 = str2double(str_coeff_1);
    dim_coeff_2 = str2double(str_coeff_2);
    
    cla
    plot_coeff_vs_coeff(inspk, cluster_class, dim_coeff_1, dim_coeff_2, handles.color, handles.markersize)
    
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function coloring_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to coloring_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in markersize_popmenu.
function markersize_popmenu_Callback(hObject, eventdata, handles)
% hObject    handle to markersize_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns markersize_popmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from markersize_popmenu
contents = cellstr(get(hObject,'String'));
handles.markersize = str2double(contents{get(hObject,'Value')});

    inspk = handles.inspk;
    cluster_class = handles.cluster_class;
    str_coeff_1 = get(handles.coeff_1_edit, 'String');
    str_coeff_2 = get(handles.coeff_2_edit, 'String');
    dim_coeff_1 = str2double(str_coeff_1);
    dim_coeff_2 = str2double(str_coeff_2);
    
    cla
    plot_coeff_vs_coeff(inspk, cluster_class, dim_coeff_1, dim_coeff_2, handles.color, handles.markersize)
    
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function markersize_popmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to markersize_popmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
