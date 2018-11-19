function varargout = eventeditor(varargin)
% EVENTEDITOR Application M-file for eventeditor.fig
%    FIG = EVENTEDITOR launch eventeditor GUI.
%    EVENTEDITOR('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 27-Jan-2006 15:05:57

if ~ischar(varargin{1})  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
    handles.phand=varargin{1};
	guidata(fig, handles);
    set(handles.figure1,'name','EVENTEDITOR','numbertitle','off');
    for i=1:handles.phand.chnum,
        chl{i}=num2str(i);
    end;
    set(handles.chansel,'string',chl);
    
    evnum=size(handles.phand.event,1);
    if evnum==0, 
        delete(handles.figure1), 
        return; 
    end;
    lbfill(1,handles);
    
	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
        [varargout{1:nargout}] = feval('refresh_Callback',gcbo,[0],guidata(gcbo));
		[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
	catch
		disp(lasterr);
	end

end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.



% --------------------------------------------------------------------
function varargout = lb_Callback(h, eventdata, handles, varargin)

if ~isempty(eventdata)
    v=eventdata;
else
    v=get(h,'value');
end
lbt=get(h,'listboxtop');

ts={'num', 'char', 'pos'};
al=[handles.num handles.char handles.pos];
others=find(~strcmp(ts,get(h,'tag')));
others=al(others);
set(others,'value',v,'listboxtop',lbt);

ch=get(handles.chansel,'value');
val=readvalue(handles.phand,handles.phand.event{v(1),1},ch);
set(handles.valind,'string',num2str(val));

if strcmp(get(handles.figure1,'selectiontype'),'open'),
    poslist=get(handles.pos,'string');
    if length(v)~=1, v=v(1); end;
    pos=str2num(poslist{v});
    wsize=str2num(get(handles.phand.wsize,'string'));
    begin=pos/handles.phand.srate-wsize/2;
    if begin<0, begin=0; end;
    set(handles.phand.gostep,'string',num2str(begin));
    handles.phand=nswiew('step_Callback',handles.phand.gostep,[],handles.phand);
    guidata(handles.phand.figure1,handles.phand);
    guidata(h,handles);
end;

% --------------------------------------------------------------------
function varargout = chansel_Callback(h, eventdata, handles, varargin)

v=get(handles.num,'value');
ch=get(h,'value');
val=readvalue(handles.phand,handles.phand.event{v(1),1},ch);
set(handles.valind,'string',num2str(val));

% --------------------------------------------------------------------
function varargout = blb_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.blb.

v=get(handles.num,'value');
handles.phand.binx1=v;
if isfield(handles.phand,'binx2'),
    try
    if handles.phand.event{handles.phand.binx2,1}<handles.phand.event{v,1}, 
        msgbox('The block ending must be later in time than the begining!','Warning','warn');
    end
    catch
        handles.phand.binx2=[];
        set(handles.beind,'string','');
    end
end;
set(handles.bbind,'string',num2str(v));
guidata(handles.phand.figure1,handles.phand);
guidata(h,handles);

% --------------------------------------------------------------------
function varargout = ble_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.ble.

v=get(handles.num,'value');
handles.phand.binx2=v;
if isfield(handles.phand,'binx1'),
    try
    if handles.phand.event{v,1}<handles.phand.event{handles.phand.binx1,1}, 
        msgbox('The block ending must be later in time than the begining!','Warning','warn');
    end;
    catch
        handles.phand.binx1=[];
        set(handles.bbind,'string','');
    end
end;
set(handles.beind,'string',num2str(v));
guidata(h,handles);
guidata(handles.phand.figure1,handles.phand);

% --------------------------------------------------------------------
function varargout = blc_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.ble.


handles.phand.binx1=[];
handles.phand.binx2=[];

set(handles.beind,'string','');
set(handles.beind,'string','');
guidata(handles.phand.figure1,handles.phand);
guidata(h,handles);

% --------------------------------------------------------------------
function varargout = chared_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.chared.

v=get(handles.num,'value');
str=get(h,'string');
for a=1:length(v),
    handles.phand.event{v(a),2}=str;
end
lbfill(v(1),handles);
handles.phand=nswiew('draw',handles.phand.data,handles.phand);
guidata(handles.phand.figure1,handles.phand);
guidata(h,handles);

% --------------------------------------------------------------------
function varargout = posed_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.posed.

v=get(handles.num,'value');
str=get(h,'string');

handles.phand.event{v,1}=str2num(str);
lbfill(v,handles);
handles.phand=nswiew('draw',handles.phand.data,handles.phand);
guidata(handles.phand.figure1,handles.phand);
guidata(h,handles);

% --------------------------------------------------------------------
function varargout = del_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.del.

v=get(handles.num,'value');
handles.phand.event(v,:)=[];
if strcmp(get(handles.sort_pos,'checked'),'on'),
    hm=handles.sort_pos;
else
    hm=handles.sort_label;
end;
[event, binx1, binx2]=sort_Callback(hm,[],handles);
if ~isempty(binx1),
    handles.phand.binx1=binx1;
    set(handles.bbind,'string',binx1);
end;
if ~isempty(binx2),
    handles.phand.binx2=binx2;
    set(handles.beind,'string',binx2);
end;
handles.phand.event=event;
guidata(handles.phand.figure1,handles.phand);
guidata(h,handles);

evnums=size(handles.phand.event,1);
if v>evnums, v=evnums; end;
v=v(1);
lbfill(v,handles);
hand=nswiew('draw',handles.phand.data,handles.phand);

% --------------------------------------------------------------------
function varargout = open_menu_Callback(h, eventdata, handles, varargin)

nswiew('loadevent_menu_Callback',handles.phand.figure1,[],handles.phand);
handles.phand=guidata(handles.phand.figure1);
lbfill(1,handles);

guidata(handles.phand.figure1,handles.phand);
guidata(h,handles);
set(handles.figure1,'name',['EVENTEDITOR-' handles.phand.evfilename]);

% --------------------------------------------------------------------
function varargout = save_menu_Callback(h, eventdata, handles, varargin)

nswiew('saveevent_menu_Callback',handles.phand.figure1,[],handles.phand);

% --------------------------------------------------------------------
function varargout = sort_menu_Callback(h, eventdata, handles, varargin)

[event, binx1, binx2]=sort_Callback(h,[],handles);
handles.phand.event=event;
if ~isempty(binx1),
    handles.phand.binx1=binx1;
    set(handles.bbind,'string',binx1);
end;
if ~isempty(binx2),
    handles.phand.binx2=binx2;
    set(handles.beind,'string',binx2);
end;
guidata(handles.phand.figure1,handles.phand); 
guidata(h,handles);
v=get(handles.num,'value');
lbfill(v,handles);

if strcmp(get(h,'tag'),'sort_pos'),
    set(handles.sort_pos,'checked','on');
    set(handles.sort_label,'checked','off');
else
    set(handles.sort_label,'checked','on');
    set(handles.sort_pos,'checked','off');
end;

% --------------------------------------------------------------------
function [event, varargout] = sort_Callback(h, eventdata, handles, varargin)

event=handles.phand.event;
evnum=size(event,1);
for i=1:evnum,
    evchar{i}=event{i,2};
    evpos(i)=event{i,1};
end;

if evnum==0, evchar=''; evpos=[]; end;

if strcmp(get(h,'tag'),'sort_pos'),
    [newevpos index]=sort(evpos);
    newevchar=evchar(index);
else
    [newevchar index]=sort(evchar);
    newevpos=evpos(index);
end;

for i=1:evnum,
    event{i,1}=newevpos(i);
    event{i,2}=newevchar{i};
end;
if nargout>1,
    if isfield(handles.phand,'binx1'),
        if ~isempty(handles.phand.binx1),
            varargout{1}=find(index==handles.phand.binx1);
        else
            varargout{1}=[];
        end;
    else
        varargout{1}=[];
    end;
    if isfield(handles.phand,'binx2'),
        if ~isempty(handles.phand.binx1),
            varargout{2}=find(index==handles.phand.binx2);
        else
            varargout{2}=[];
        end
    else
        varargout{2}=[];
    end;
end;

% --------------------------------------------------------------------
function event = refresh_tgb_Callback(h, eventdata, handles, varargin)

refresh_Callback(h, eventdata, handles, varargin);

% --------------------------------------------------------------------
function event = refresh_Callback(h, eventdata, handles, varargin)

v=get(handles.num,'value');
if isfield(handles,'phand'),
    handles.phand=guidata(handles.phand.figure1);
    guidata(h,handles);
    if isempty(eventdata),
        lbfill(v,handles);
    end
end;

% --------------------------------------------------------------------
function lbfill(line, handles)

event=handles.phand.event;
evnum=size(event,1);
set(handles.num,'string',num2str([1:evnum]'),'value',line,'listboxtop',line);
evchar=event(:,2);
for i=1:evnum;
    evpos{i}=num2str(event{i,1});
end;
set(handles.char,'string',evchar,'value',line,'listboxtop',line);
set(handles.pos,'string',evpos,'value',line,'listboxtop',line);

if isfield(handles.phand,'binx1')
    set(handles.bbind,'string',num2str(handles.phand.binx1));
end;
if isfield(handles.phand,'binx2')
    set(handles.beind,'string',num2str(handles.phand.binx2));
end;


% --------------------------------------------------------------------
function clear_Callback(hObject, eventdata, handles)
% hObject    handle to clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles.phand.event(:,:)=[];
guidata(handles.phand.figure1,handles.phand);
guidata(hObject,handles);

lbfill(0,handles);
hand=nswiew('draw',handles.phand.data,handles.phand);


% --- Executes on button press in del_tgb.
function del_tgb_Callback(hObject, eventdata, handles)
% hObject    handle to del_tgb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of del_tgb

del_Callback(hObject, eventdata, handles);

% --- Executes on button press in sort_tgb.
function sort_tgb_Callback(hObject, eventdata, handles)
% hObject    handle to sort_tgb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sort_tgb

lab=get(hObject,'string');
if strcmp(lab,'BY POSITION'),
    set(hObject,'string','BY LABEL');
    c=2;
else
    set(hObject,'string','BY POSITION');
    c=1;
end

switch c,
    case 1, sort_menu_Callback(handles.sort_pos,eventdata,handles);
    case 2, sort_menu_Callback(handles.sort_label,eventdata,handles);
end


% --- Executes on button press in bfly_tbg.
function bfly_tbg_Callback(hObject, eventdata, handles)
% hObject    handle to bfly_tbg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bfly_tbg

chs=str2num(get(handles.bfly_ed,'string'));
lim=str2num(get(handles.bfly_ed2,'string'));
if isempty(chs), chs=0; end;
butterfly(handles.phand.figure1,chs,0,lim);



function bfly_ed_Callback(hObject, eventdata, handles)
% hObject    handle to bfly_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bfly_ed as text
%        str2double(get(hObject,'String')) returns contents of bfly_ed as a double


% --- Executes during object creation, after setting all properties.
function bfly_ed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bfly_ed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bfly_ed2_Callback(hObject, eventdata, handles)
% hObject    handle to bfly_ed2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bfly_ed2 as text
%        str2double(get(hObject,'String')) returns contents of bfly_ed2 as a double


% --- Executes during object creation, after setting all properties.
function bfly_ed2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bfly_ed2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hd_pb.
function hd_pb_Callback(hObject, eventdata, handles)
% hObject    handle to hd_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

chs=str2num(get(handles.bfly_ed,'string'));
lim=str2num(get(handles.bfly_ed2,'string'));
v=get(handles.num,'value');
if isempty(chs) | isempty(lim),
    csdplot(handles.phand.figure1,v);
else
    csdplot(handles.phand.figure1,v,chs,lim);
end

