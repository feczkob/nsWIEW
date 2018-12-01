function varargout = filterset(varargin)
% FILTERSET Application M-file for filterset.fig
%    FIG = FILTERSET(samling rate,handles) launch filter GUI.
%    FILTERSET('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 06-Aug-2003 11:55:57

if ~ischar(varargin{1})  % LAUNCH GUI

	fig = openfig(mfilename,'new');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
    if nargin>1, handles.phand=varargin{2}; end
    handles.srate=varargin{1};
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
function varargout = lp_Callback(h, eventdata, handles, varargin)

v=get(h,'value'); 

set([handles.bp, handles.bs, handles.hp],'value',0); 
offon={'off' 'on'}; 
set(handles.frb,'enable','off'); 
set(handles.fra,'enable',offon{v+1});

plotfilt(handles)


% --------------------------------------------------------------------
function varargout = bp_Callback(h, eventdata, handles, varargin)

v=get(h,'value'); 

set([handles.lp, handles.bs, handles.hp],'value',0); 
offon={'off' 'on'}; 
set(handles.frb,'enable',offon{v+1}); 
set(handles.fra,'enable',offon{v+1});

plotfilt(handles)

% --------------------------------------------------------------------
function varargout = bs_Callback(h, eventdata, handles, varargin)

v=get(h,'value'); 

set([handles.lp, handles.bp, handles.hp],'value',0); 
offon={'off' 'on'}; 
set(handles.frb,'enable',offon{v+1}); 
set(handles.fra,'enable',offon{v+1});

plotfilt(handles)

% --------------------------------------------------------------------
function varargout = hp_Callback(h, eventdata, handles, varargin)

v=get(h,'value'); 

set([handles.lp, handles.bp, handles.bs],'value',0); 
offon={'off' 'on'}; 
set(handles.frb,'enable',offon{v+1}); 
set(handles.fra,'enable','off');

plotfilt(handles)

% --------------------------------------------------------------------
function varargout = zphs_Callback(h, eventdata, handles, varargin)

v=get(h,'value');

if v==0
    set(handles.order,'string',{'1','2','3','4','5'});
else
    set(handles.order,'string',{'2','4','6','8','10'});
end

% --------------------------------------------------------------------
function varargout = ok_Callback(h, eventdata, handles, varargin)

delete(handles.figure1);

% --------------------------------------------------------------------
function varargout = deletefcn(h, eventdata, handles, varargin)

if isfield(handles,'responseplot')
    delete(handles.responseplot);
end

[bb, aa, info]=getfilter(handles);

if isfield(handles,'phand')
    handles.phand.filterset=struct('a',aa,'b',bb,'filtfilt',get(handles.zphs,'value'),'info',info,'rect',get(handles.rect,'value'));
    guidata(handles.phand.figure1,handles.phand);
else
    global a b infos;
    a=aa; b=bb; infos=info;
    disp('b, a, infos are global');
end


% --------------------------------------------------------------------
function [b,a,info]= getfilter(handles)

vs=get([handles.lp, handles.bp, handles.bs, handles.hp,handles.zphs, handles.order, handles.type, handles.rect],'value');
frs=get([handles.frb, handles.fra],'string');

if vs{1}               % low pass
    F=str2num(frs{2})./(handles.srate/2);
    str='low';
elseif vs{2}           % band pass
    F=[str2num(frs{1}) str2num(frs{2})]./(handles.srate/2);
    str='bandpass';
elseif vs{3}          % band stop
    F=[str2num(frs{1}) str2num(frs{2})]./(handles.srate/2);
    str='stop';
elseif vs{4}            % high pass
    F=str2num(frs{1})./(handles.srate/2);
    str='high';
end

os=[1,2,3,4,5];      % order
o=os(vs{6});

if ~exist('F')
    a=[]; b=[];
    return;
elseif isempty(F)
    a=[]; b=[];
    return;
end   

zphs={ '', 'zero phase shift '};
rrrr={ '', ', rectify'};
switch vs{7}            % type
case 1                 % butter
    try [b,a]=butter(o,F,str); 
        info=['Butterworth ', num2str(o), '.order, ',zphs{vs{5}+1}, num2str(F*(handles.srate/2)), ' Hz ', str,rrrr{vs{8}+1}];
    catch a=[]; b=[]; info='not found'; return;
    end
case 2                 % finite response
    try [b,a]=fir1(o,F,str);
        info=['FIR1 ', num2str(o), '.order, ',zphs{vs{5}+1}, num2str(F*(handles.srate/2)), ' Hz ', str,rrrr{vs{8}+1}];
    catch a=[]; b=[]; info='not found'; return;
    end
case 3
    %fprintf('Itt vagyok'); % elliptic filter % should be added to the filter type options
   try     [b,a] = ellip(o,0.1,40,F,str); % the settings used by Wave_clus
       info=['Elliptic ', num2str(o), '.order, ',zphs{vs{5}+1}, num2str(F*(handles.srate/2)), ' Hz ', str,rrrr{vs{8}+1}];
   catch a=[]; b=[]; info='not found'; return;
   end
end

% --------------------------------------------------------------------
function plotfilt(handles)

[b,a]= getfilter(handles);
if ~isfield(handles,'responseplot')
    handles.responseplot=figure('numbertitle','off');
end
if ~ishandle(handles.responseplot)
    handles.responseplot=figure('numbertitle','off');
end
if isempty(a) && isempty(b)
    set(handles.responseplot,'name','Frequency and Phase response NOT DESPLAYABLE');
    guidata(handles.figure1,handles);
    return; 
else
    set(handles.responseplot,'name','Frequency and Phase response');    
    guidata(handles.figure1,handles);
end
set(0,'currentfigure',handles.responseplot);
freqz(b,a,256,handles.srate);
set(gcf,'name','Frequency and Phase response','numbertitle','off');

    







