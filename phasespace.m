function varargout = phasespace(varargin)
% PHASESPACE Application M-file for phasespace.fig
%    FIG = PHASESPACE (data, ivoker figure handle (optional)) launch the GUI.
%    PHASESPACE('callback_name', ...) invoke the named callback.
%
% Daniel Fabó 2003

% Last Modified by GUIDE v2.0 15-Jun-2003 14:07:11

if ~ischar(varargin{1})  % LAUNCH GUI
    
	fig = openfig('phasespace.fig','reuse');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
    handles.data=varargin{1};
    if nargin>1,
        handles.phand=varargin{2};
    end;
    handles.point=0;
    
    set(handles.figure1,'handlevisibility','on');
    der=str2num(get(handles.dered,'string'));
    
    plot(handles.data(1:end-der+1),handles.data(der:end));
    
	guidata(fig, handles);
    
	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
	catch
		disp(lasterr);
	end

end


% --------------------------------------------------------------------
function varargout = bdownfcn(h, eventdata, handles, varargin)

switch handles.point,
case 0,
    point=get(handles.axes1,'currentpoint');
    p1=[point(1,1) point(1,2)];
    handles.p1=p1;
    handles.point=1;
    hold on;
    handles.line=plot(p1(1),p1(2),'g');
    guidata(h,handles);
case 1,
    point=get(handles.axes1,'currentpoint');
    p2=[point(1,1) point(1,2)];
    handles.p2=p2;
    set(handles.ok,'enable','on'); set(handles.cancel,'enable','on');
    handles.point=2;
    guidata(h,handles);
end;

% --------------------------------------------------------------------
function varargout = bmotionfcn(h, eventdata, handles, varargin)

point=get(handles.axes1,'currentpoint');
xlim=get(handles.axes1,'xlim'); ylim=get(handles.axes1,'ylim');
if point(1,1)>min(xlim) & point(1,1)<max(xlim) & point(1,2)>min(ylim) & point(1,2)<max(ylim),
    set(handles.figure1,'pointer','fullcrosshair');
    if handles.point==1,
        delete(handles.line);
        p1=handles.p1; p2=point(1,1:2);
        hold on;
        handles.line=plot([p1(1) p2(1)],[p1(2) p2(2)],'g');
        guidata(h,handles);
    end;
else
    set(handles.figure1,'pointer','arrow');
end;

% --------------------------------------------------------------------
function varargout = dered_Callback(h, eventdata, handles, varargin)

set(handles.figure1,'currentaxes',handles.axes1);
der=str2num(get(handles.dered,'string'));
hold off;
plot(handles.data(1:end-der+1),handles.data(der:end)); 

% --------------------------------------------------------------------
function varargout = ok_Callback(h, eventdata, handles, varargin)


p1=handles.p1;
p2=handles.p2;
der=str2num(get(handles.dered,'string'));
for i=1:length(handles.data)-der+1;
    d(i)=lindist(p1,p2,[handles.data(i) handles.data(i+der-1)]);
end;

f=figure('name','Select the treshold for minimums: SHIFT + LEFT MOUSE button',...
        'numbertitle','off',...
        'pointer','fullcrosshair',...
        'windowbuttondownfcn',...
        'if strcmp(get(gcbo,''selectiontype''),''extend''); set(gcbo,''userdata'',get(gca,''currentpoint'')); end;');
plot(d);  
title('Distance from the specified line');
waitfor(f,'userdata');
point=get(f,'userdata');
delete(f);

lim=[point(1,2) max(d)];
% dm=sqrt(2)*max(diff(handles.data))
% lim=[2*dm max(d)]; 
[maxes dmin]=amplfind(d,lim);

if isfield(handles,'phand');
    nswiew('php_menu_Callback',handles.phand.php,dmin,handles.phand);
else
    global dmins;
    dmins=dmin;
    disp('dmins is global');
end;

set(handles.figure1,'currentaxes',handles.axes1, ...
                    'userdata','done',...
                    'windowbuttondownfcn','');
set(handles.ok,'enable','off'); set(handles.cancel,'enable','off');
der=str2num(get(handles.dered,'string'));
plot(handles.data(1:end-der+1),handles.data(der:end),'.k');
delete(handles.figure1);

% --------------------------------------------------------------------
function varargout = cancel_Callback(h, eventdata, handles, varargin)

delete(handles.line);
handles.point=0;
set(handles.ok,'enable','off'); set(handles.cancel,'enable','off');
guidata(h,handles);
        
