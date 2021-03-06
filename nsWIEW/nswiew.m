function varargout = nswiew(varargin)
% NSWIEW Application M-file for nswiew.fig
%    FIG = NSWIEW launch nswiew GUI.
%    NSWIEW('callback_name', ...) invoke the named callback.
%
% Daniel Fab� 2003

% Last Modified by GUIDE v2.5 05-Dec-2018 14:24:06

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'new');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);
    
    set(handles.inport_menu,'Accelerator','i');
    set(handles.pglayout_menu,'Accelerator','p');
    set(handles.evedit_menu,'Accelerator','e');
    set(handles.figure1,'deletefcn','nswiew(''saveevent_menu_Callback'',gcbo,[],guidata(gcbo))');
    f=fopen('blank.cnt','r');
    handles.blank=fread(f,'int8');
    fclose(f);
    guidata(fig, handles);
    

	if (nargout > 0)
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
function varargout = step_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.plus.

if isempty(handles.data)
    return;
end
if isempty(eventdata), eventdata=''; end

so=str2num(get(handles.short_step,'string'));
lg=str2num(get(handles.long_step,'string'));
wd=str2num(get(handles.wsize,'string')); %str2double ?

tag=get(h,'tag');
v=strfind(tag,'_');
if ~isempty(v), tag=tag(1:v-1); end
switch tag
case 'fwend'
    begin=fix(handles.maxsec*1000)/1000-wd;
case 'rewend'
    begin=0;
case 'fwlong'
    begin=handles.inx1+lg; 
    if strcmp(eventdata,'kb')
        begin=handles.inx1+wd; 
%         begin=handles.inx1+2; 
    end
case 'fwshort'
    begin=handles.inx1+so;
case 'rewlong'
    begin=handles.inx1-lg;
    if strcmp(eventdata,'kb')
        begin=handles.inx1-wd; 
%         begin=handles.inx1-2; 
    end
case 'rewshort'
    begin=handles.inx1-so;
case 'gostep'
    gs=get(handles.gostep,'string');
    if gs<0, return; end
    begin=str2num(gs);
    set(handles.gostep,'string',[]);
end

set(handles.wsize,'string',wd);  
handles=inport(begin,wd,handles); 
handles=draw(handles.data,handles);
if nargout>0
    varargout{1}=handles;
end
guidata(h,handles);    

% --------------------------------------------------------------------
function varargout = mark_check_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.plus.

set(handles.figure1,'windowbuttonupfcn','nswiew(''putmark'',gcbo,[],guidata(gcbo))');
handles.eventcharacter={};
answer=inputdlg('The symbol:','Give the mark symbol (Or "pointed")',1,{'1'});
if ~isempty(answer)
    handles.eventcharacter=answer{1};
else
    return;
end

set(handles.figure1,'windowbuttondownfcn','');
w=['mark ' answer{1}];
st=get(handles.evselind,'string');
if ischar(st), st={st}; end
le=length(st);
st{le+1}=w;
set(handles.evselind,'string',st,'value',le+1);
guidata(h,handles);

% --------------------------------------------------------------------
function varargout = box_check_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.plus.

prompt  = {'1: peak; 2: extreme; 3: derivate','Smooth [point times]','Channel','Eventcharacter'};
title   = 'Give the parameters';
lines= 1;
def     = {'2','5 0','',''};
answer  = inputdlg(prompt,title,lines,def);
param.type=str2num(answer{1});
param.smooth=str2num(answer{2});
param.ch=str2num(answer{3});
param.ec=answer{4};
if any(param.type==[1 2 3]) 
    prompt  = {'1: min; 2: max'};
    title   = 'Give the parameters';
    lines= 1;
    def     = {'1'};
    answer  = inputdlg(prompt,title,lines,def);
    param.ptype=str2num(answer{1});
end
mima={'mi','ma'};
if isempty(param.ec), param.ec=[num2str(param.ch) mima{param.ptype}]; end

set(handles.figure1,'windowbuttonupfcn','');
set(handles.figure1,'windowbuttondownfcn','nswiew(''boxdraw'',gcbo,[],guidata(gcbo))');
set(h,'userdata',param);

w=['box ' param.ec ' ' num2str(param.ch) ' '];

if param.ptype==1, w=[w 'min '];
elseif param.ptype==2, w=[w 'max '];
end
if  param.type==1, w=[w 'peak '];
elseif  param.type==2, w=[w 'extreme '];
elseif  param.type==3, w=[w 'derivate '];    
end
w=[w num2str(param.smooth(1)) ' ' num2str(param.smooth(2))];

st=get(handles.evselind,'string');
if ischar(st), st={st}; end
le=length(st);
st{le+1}=w;
set(handles.evselind,'string',st,'value',le+1);


% --------------------------------------------------------------------
function varargout = block_check_Callback(h, eventdata, handles, varargin)

set(handles.sel_pop,'enable','off');
set(handles.evselind,'enable','off');
set(handles.sel_do,'string','C');

handles.eventcharacter={};
answer=inputdlg('The symbol:','Give the mark symbol (Only 1 character)',1,{'b'});
if ~isempty(answer)
    handles.eventcharacter=answer{1}(1);
else
    return;
end

set(handles.figure1,'windowbuttonupfcn','nswiew(''putblock'',gcbo,[],guidata(gcbo))');
set(handles.figure1,'windowbuttondownfcn','');
guidata(h,handles);

% --------------------------------------------------------------------
function varargout = C_check_Callback(h, eventdata, handles, varargin)

set(handles.figure1,'windowbuttonupfcn','');
set(handles.figure1,'windowbuttondownfcn','');
set(handles.evselind,'string',{'no event-selection set'},'value',1);

set(handles.sel_pop,'enable','on');
set(handles.sel_do,'string','DO');
set(handles.evselind,'enable','on');


function  varargout = WaveletBox_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.plus.

prompt  = {'Channel'};
title   = 'Give the parameters';
lines= 1;
def     = {'2'};
answer  = inputdlg(prompt,title,lines,def);
% param.type=str2num(answer{1});
% param.smooth=str2num(answer{2});
param.ch=str2num(answer{1});
param.frb=60; 
param.fra=500;
param.nf=50;
%%%%%%
set(handles.figure1,'windowbuttonupfcn','');
set(handles.figure1,'windowbuttondownfcn','nswiew(''wavelet_boxdraw'',gcbo,[],guidata(gcbo))');
set(h,'userdata',param);

function varargout = wavelet_boxdraw(h, eventdata, handles, varargin) 
st=get(handles.figure1,'selectiontype');
if strcmp(st,'alt')
    handles=step_Callback(handles.fwlong,'kb',handles);
    guidata(h,handles);
    return;
end

set(handles.figure1,'handlevisibility','on');
point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);             % calculate locations
offset = abs(point1-point2);         % and dimensions
if offset==0, return; end
x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
% hold on,
% plot(x,y);
set(handles.figure1,'handlevisibility','off');

param=get(handles.sel_do,'userdata');                                                         % peak detect
ylims=get(handles.ax,'ylim');
if handles.time(1)<p1(1) && p1(1)<handles.time(end) &&ylims(1)<p1(2) && p1(2)<ylims(2),   % check the area in the figure 
    xx1=find(handles.time<p1(1), 1, 'last' );
    xx2=find(handles.time<p1(1)+offset(1), 1, 'last' );
    
%     plot(handles.time(xx1:xx2), handles.data(xx1:xx2, param.ch))  ;
    handles2=handles;
    handles2.data=handles.data(xx1:xx2,:);
    handles2.time=handles.time(xx1:xx2);
    handles=wavelet_Callback_DO2(h,param,handles2);

%     guidata(h,handles);
end


% --------------------------------------------------------------------
function varargout = evselind_Callback(h, eventdata, handles, varargin)

v=get(h,'value');
st=get(h,'string');
if ischar(st)
    w=wordsc(st);
else
    w=wordsc(st{v});
end
switch w{1}
case 'box'
    param.ec=w{2};
    param.ch=str2num(w{3});
    if strcmp(w{4},'min'), param.ptype=1;
    elseif strcmp(w{4},'max'), param.ptype=2;
    end
    if strcmp(w{5},'peak'), param.type=1;
    elseif strcmp(w{5},'extreme'), param.type=2;
    elseif strcmp(w{5},'derivate'), param.type=3;
    end
    param.smooth=[str2num(w{6}) str2num(w{7})];
    
    set(handles.figure1,'windowbuttonupfcn','');
    set(handles.figure1,'windowbuttondownfcn','nswiew(''boxdraw'',gcbo,[],guidata(gcbo))');
    set(handles.sel_do,'userdata',param);
case 'mark'
    handles.eventcharacter=w{2};
    
    set(handles.figure1,'windowbuttonupfcn','nswiew(''putmark'',gcbo,[],guidata(gcbo))');
    set(handles.figure1,'windowbuttondownfcn','');
case 'no'
    set(handles.figure1,'windowbuttonupfcn','');
    set(handles.figure1,'windowbuttondownfcn','nswiew(''windowbuttondownfcn_Callback'',gcbo,[],guidata(gcbo))');
end
guidata(h,handles);

% --------------------------------------------------------------------
function varargout = keypressfcn_Callback(h, eventdata, handles, varargin)

char=get(h,'currentcharacter');
if isempty(char)
    return;
end

switch double(char)
case 28, handles=nswiew('step_Callback',handles.rewlong,['kb'],handles); 
case 29, handles=nswiew('step_Callback',handles.fwlong,['kb'],handles);
case 43, handles=nswiew('plus_Callback',handles.plus,[],handles);
case 45, handles=nswiew('plus_Callback',handles.minus,[],handles);
case 110, set(handles.wsize,'string',get(handles.n_ed,'string')); handles=nswiew('wsize_Callback',handles.wsize,[],handles);
case 107, set(handles.wsize,'string',get(handles.k_ed,'string')); handles=nswiew('wsize_Callback',handles.wsize,[],handles);
case {49    50    51    52    53    54    55    56    57}, 
    np=length(handles.page); dch=double(char);
    if dch-48<=np
        handles.apage=dch-48;
        handles=draw(handles.data,handles);
    end
case {97    98    99    100    101    102    103    104    105}, 
    np=length(handles.page); dch=double(char);
    if dch-87<=np
        handles.apage=dch-87;
        handles=draw(handles.data,handles);
    end
case 30, np=length(handles.page);
         if handles.apage<np
             handles.apage=handles.apage+1; 
             handles=draw(handles.data,handles);
         end
case 31, if handles.apage>1
             handles.apage=handles.apage-1; 
             handles=draw(handles.data,handles);    
        end
         
end
guidata(h,handles);

% --------------------------------------------------------------------
function varargout = windowbuttonmotionfcn_Callback(h, eventdata, handles, varargin)

if ~isfield(handles,'data') || isfield(handles,'figure2')
    return;
end
% set(handles.figure1,'handlevisibility','on');

point=get(handles.ax,'currentpoint');
[ach, value, inside]=mouseloc(point,handles);

if inside
    
    if ~strcmp(get(handles.figure1,'pointer'),'fullcrosshair')
        set(handles.figure1,'pointer','crosshair'); %'fullcrosshair' volt
    end
    set(handles.chind,'string',num2str(ach));
    set(handles.ampind,'string',num2str(round(value*100)/100));
    
    % ch value
%     chx=9;
%     [achx valuex insidex]=mouseloc(point,handles,chx);
%     set(handles.ampind,'string',num2str(round(valuex*100)/100));
    
    abstime=fix(point(1,1)*1000)/1000;
    lenh=fix(length(handles.time)/2);
    absmtime=fix(handles.time(lenh)*1000)/1000;
    if isfield(handles,'absmtime')
        if ~isempty(handles.absmtime)
            absmtime=handles.absmtime;
        end
    end
    reltime=1000*(abstime-absmtime);
    set(handles.tind,'string',num2str(reltime));
    evs=[]; n=10;
    for i=1:size(handles.event,1)
        evs(i)=fix(handles.event{i,1}/n)*n;
    end
    x=fix(point(1,1)*handles.srate/n)*n;
    if ~isempty(evs)
        e=find(evs==x);
        set(handles.evind,'string',num2str(e));
    end
    
%     Phase_plotter
%
%     set(0,'currentfigure',5);
%     p5=get(5,'userdata');
%     xw=round((point(1,1)-handles.time(1))*handles.srate);
%     if ishandle(p5),
%         delete(p5);
%     end;
%     if xw+12<length(handles.data),
%         p5=plot(handles.data(xw,1),handles.data(xw+12,1),'.r');
%     end
%     set(5,'userdata',p5);
    
else
    set(handles.figure1,'pointer','arrow');
end
% set(handles.figure1,'handlevisibility','off');

% --------------------------------------------------------------------
function varargout = putmark(h, eventdata, handles, varargin)

if ~isfield(handles,'data') || (strcmp(get(handles.figure1,'selectiontype'),'alt') && isempty(eventdata))
    return;
end

set(handles.figure1,'handlevisibility','on');
x='';
set(0,'currentfigure',handles.figure1);
set(handles.figure1,'currentaxes',handles.ax);

if isempty(eventdata)                          % if the point is set by mouse click
    point=get(handles.ax,'currentpoint');
    ylims=get(handles.ax,'ylim');
    if handles.time(1)<point(1,1) && point(1,1)<handles.time(end) && ylims(1)<point(1,2) && point(1,2)<ylims(2)
        x=round((point(1,1))*handles.srate);
        t=text(point(1,1),-8.5,[''' ', handles.eventcharacter],'color','red');
        if get(handles.eventpoint_menu,'userdata'),
            evp=str2num(get(handles.eventpoint_menu,'userdata'));
            if isempty(evp)
                evp=handles.page{handles.apage}(1);
            end
            maxi=length(handles.page{handles.apage});
            i=find(handles.page{handles.apage}==evp);
            if ~isempty(i)
                hold on;
                xx=max(find(handles.time<point(1,1)));
                plot(handles.time(xx),handles.data(xx,evp)*handles.amp+(maxi-i)*10,'.r');
                hold off;
            end
        end
    end
    
else                                                % if this is a call for a known point
    xx=fix(eventdata{1}-handles.inxp+1); tt=eventdata{1}/handles.srate;
    if handles.time(1)<tt && tt<handles.time(end)
        t=text(tt,-8.5,[''' ', eventdata{2}],'color','red');
        if get(handles.eventpoint_menu,'userdata')
            evp=get(handles.eventpoint_menu,'userdata');
            if strcmp(evp,'self')
                evp=sscanf(eventdata{2},'%f');
            else
                evp=str2num(evp);
            end
            if ~isempty(evp)
                maxi=length(handles.page{handles.apage});
                i=find(handles.page{handles.apage}==evp);
                if ~isempty(i)
                    hold on;
                    plot(handles.time(xx),handles.data(xx,evp)*handles.amp+(maxi-i)*10,'.r');
                    hold off;
                end
            end
        end
        hold off;
    end
    need=1;                                 % if needed store the event (if exist it is not stored just drawn)
    if nargin>3
        if varargin{1}=='exist'
            need=0;
        end
    end
    if need
        x=fix(eventdata{1});
        handles.eventcharacter=eventdata{2};
    end
end

if isfield(handles,'eventcharacter')
    if strcmp(handles.eventcharacter,'pointed')
        eventcharacter=get(handles.chind,'string');
    else
        eventcharacter=handles.eventcharacter;
    end
end

if ~isempty(x)
    if isempty(handles.event)
        handles.event={x, eventcharacter};
    else
        handles.event(end+1,1:2)={x, eventcharacter};
    end
end
guidata(h,handles);
set(handles.figure1,'handlevisibility','off');
if nargout==1
    varargout{1}=handles;
end

% --------------------------------------------------------------------
function varargout = boxdraw(h, eventdata, handles, varargin)

st=get(handles.figure1,'selectiontype');
if strcmp(st,'alt')
    handles=step_Callback(handles.fwlong,'kb',handles);
    guidata(h,handles);
    return;
end

set(handles.figure1,'handlevisibility','on');
point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);             % calculate locations
offset = abs(point1-point2);         % and dimensions
if offset==0, return; end
x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
% hold on,
% plot(x,y);
set(handles.figure1,'handlevisibility','off');

param=get(handles.sel_do,'userdata');                                                         % peak detect
ylims=get(handles.ax,'ylim');
if handles.time(1)<p1(1) && p1(1)<handles.time(end) && ylims(1)<p1(2) && p1(2)<ylims(2)   % check the area in the figure 
    xx1=find(handles.time<p1(1), 1, 'last' );
    xx2=find(handles.time<p1(1)+offset(1), 1, 'last' );
    dat=smooth2(handles.data(xx1+1:xx2,param.ch),param.smooth(1),param.smooth(2));
    
    p=[];
    switch param.type
    
    case 1
        [ch, value, inside]=mouseloc(point1,handles,param.ch);
    
        if isempty(value), return; end;
    
        if param.ptype==1
            [maxs, mins]=amplfind(dat,[value,max(dat)]);
            p=mins;
        else
            [maxs, mins]=amplfind(dat,[min(dat),value]);
            p=maxs;
        end
    case 2
        if param.ptype==1
            [pe, p]=min(dat);
        else
            [pe, p]=max(dat);
        end
    case 3
        [ch, value, inside]=mouseloc(point1,handles,param.ch);
        if isempty(value), return; end
        
        dd=diff(dat);
        if param.ptype==1
            [pe, p]=min(dd);
        else
            [pe, p]=max(dd);
        end
        
%         difs=dif./abs(dif);
%         p=[];                     % detect multiple peaks
%         for j=2:length(difs);
%             if difs(j-1)~=difs(j), p=[p j]; end;
%         end;
%         m=mean(difs(1:fix(length(difs)/2)))
%         if m<0, [pe ph]=min(dat); 
%         else [pe ph]=max(dat); 
%         end;

    case 4             % Inporting Pattern
        param=get(handles.pattern_menu,'userdata');
        ylims=get(handles.ax,'ylim');
        if handles.time(1)<p1(1) && p1(1)<handles.time(end) && ylims(1)<p1(2) & p1(2)<ylims(2)   % check the area in the figure 
            xx1=max(find(handles.time<p1(1)));
            xx2=max(find(handles.time<p1(1)+offset(1)));
            param.pat=smooth2(handles.data(xx1+1:xx2,param.ch),param.smooth(1),param.smooth(2));
            param.pat=(param.pat-min(param.pat))/range(param.pat);
        end
        set(handles.pattern_menu,'userdata',param);
        set(handles.figure1,'windowbuttonupfcn','');
        set(handles.figure1,'windowbuttondownfcn','');
        return
    end
    mima={'mi','ma'};
    if isempty(param.ec), param.ec=[num2str(param.ch) mima{param.ptype}]; end
    for i=1:length(p)
        handles=putmark(h,{p(i)+xx1+handles.inxp-1 param.ec},handles);
    end

    guidata(h,handles);
end


% --------------------------------------------------------------------
function varargout = putblock(h, eventdata, handles, varargin)

if ~isfield(handles,'blocking')
    handles.blocking=0;
end

handles=putmark(handles.figure1,[],handles);
evnums=size(handles.event,1);

if handles.blocking
    handles.binx2=evnums;
    if handles.event{handles.binx2,1}<handles.event{handles.binx1,1},
        handles.binx2=handles.binx1;
        handles.binx1=evnums;
    end
    C_check_Callback(h,[],handles);
else
    handles.binx1=evnums;    
end

handles.blocking=abs(handles.blocking-1);
guidata(h,handles);

% --------------------------------------------------------------------
function varargout = wsize_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.wsize.

lengt=str2num(get(h,'string'));
begin=handles.inx1;
handles=inport(begin,lengt,handles);

handles=draw(handles.data,handles);
guidata(h,handles);

if nargout>0
    varargout{1}=handles;
end
    
% --------------------------------------------------------------------
function varargout = plus_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.plus.

apl=str2num(get(handles.apl,'string'));
switch get(h,'tag')
case 'plus', handles.amp=handles.amp+apl;
case 'minus', if handles.amp-apl>0; handles.amp=handles.amp-apl; end
end
set(handles.ap,'string',num2str(handles.amp));
handles=draw(handles.data,handles);
if nargout>0
    varargout{1}=handles;
end
guidata(h,handles);

% --------------------------------------------------------------------
function varargout = pglayout_menu_Callback(h, eventdata, handles, varargin)

if ~isfield(handles,'page')
    return;
end

prompt=['Existing pages:', newline]; %char(10) volt a newline helyén
sz = strings(size(cell2mat(handles.page)));
for i=1:size(cell2mat(handles.page), 2)
        sz(i) = [num2str(i), ' '];
end
prompt = [prompt,  sz{1:end}];
%{
prompt=['Existing pages:' newline]; %char(10) volt a newline helyén
for i=1:length(handles.page)
    prompt=[prompt, num2str(i), ': ', num2str(handles.page{i}), newline]; %itt is
end
%}
answer=inputdlg(prompt,'Give a new page layout',1,{''});

if ~isempty(answer)
    if strcmp(answer{1},'reset')
        if handles.apage~=1
            handles.apage=2;
            handles.page(2)=handles.page(handles.apage);
            handles.page(3:end)=[];
        else
            handles.page(2:end)=[];
        end
        handles=draw(handles.data,handles);
    elseif ~isempty(str2num(answer{1}))
        handles.page{end+1}=str2num(answer{1});
    end
end
guidata(h,handles);

% --------------------------------------------------------------------
function varargout = evedit_menu_Callback(h, eventdata, handles, varargin)

e=eventeditor(handles);
handles.eventeditor=e;
if ~ishandle(e), return; end
if isfield(handles,'evfilename')
    set(e,'name',['EVENTEDITOR-' handles.evfilename]);
end
set(e,'pointer','arrow');
guidata(h,handles);

% --------------------------------------------------------------------
function varargout = inport_menu_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.inport_menu

ty={'*.cnt', 'Neuroscan cnt file *.cnt'; ...
    '*.avg', 'Neuroscan avg file *.avg'; ...
    '*.edf', 'European data format file *.edf'; ...
    '*.ns*', 'Neural *.nsX'; ...
    '*.asc','ASC file *.asc';...
    '*.mat','NSWIEW data file *.mat'; ...    
    '*avg.mat;*psth.mat','NSWIEW AVG file *_avg.mat, *_psth.mat';...
    '*fft.mat','NSWIEW FFT file *_fft.mat'; ...
    '*.wdq','Windaqui eeg *.wdq'; ...
    '*.prn','Brainqiuck ASCII eeg *.prn'; ...
    '*.trc','Brainqiuck eeg *.trc'; ...
    '*.txt','Generic header file *.txt'; ...
    '*.vhdr','BrainVision header file *.vhdr'
                        };
as=[1:size(ty,1)];
if isfield(handles,'findex')
    as(1)=handles.findex;
    as(handles.findex)=1;
else
    handles.findex=1;
end
for a=1:size(ty,1)
    typsel(a,:)=ty(as(a),:);
end

% if isempty(eventdata),
%     [fname, path, findex]=uigetfile(typsel,'Select the data file');
% else
%     fname=eventdata{1};
%     path=eventdata{2};
%     findex=1;
% end
if isempty(varargin)==1
    [fname, path, findex]=uigetfile(typsel,'Select the data file');
else
    fname=varargin{1}{2}; % inputban a varargin helyen megadni a file teljes eleresi utvonalat,igy:  { strcat(folderName,  '\'), fnametrc{F} }
    path=varargin{1}{1};
    findex=1;
end

if findex==1 || findex==0
    handles.findex;
elseif findex==handles.findex
    handles.findex=1;
else
    handles.findex=findex;
end
if fname==0
    guidata(h,handles);
    return;
end

f=fopen([path fname]);
cd(path);
handles.fname=fname; handles.path=path; handles.file=[path fname];
handles.apage=1;
handles.montage=[];
handles.chnames={};
if isfield(handles,'binx1')
    handles=rmfield(handles,'binx1');
end
if isfield(handles,'binx2')
    handles=rmfield(handles,'binx2');
end
handles.event={};
if ~isfield(handles,'task')
    handles.task={};
end
handles.smoothen=0;
set(handles.figure1,'name',['NSWIEW-' fname]);
poi=strfind(fname,'.');
if ~isempty(poi)
    handles.type=fname(poi(end)+1:end);
else
    string={'cnt' 'wdq' 'avg' 'mat'};
    [s, ok]=listdlg('PromptString','Select the type',...
                'SelectionMode','single',...
                'ListString',string);
    if ok
        handles.type=string(s);
    else
        return;
    end
end
if strfind(upper(handles.type), 'NS')==1
    handles.type='NS';
end
set(handles.figure1,'paperpositionmode','auto')

switch upper(handles.type)
case 'CNT'
    % to determine:
    %             handles.srate
    %             handles.chnum
    %             handles.databyte
    %             handles.maxbyte
    %             handles.maxsec
    %             handles.orig.chnames{a}
    %             handles.minbyte
    % 
    %             handles.inx1=0;
    %             handles.amp=0.05;
    %             lengt=10;
    %             handles.page={[1:handles.chnum]};
    
    handles.databyte=2;    
    fseek(f,376,-1);
    handles.srate=fread(f,1,'int16');
    fseek(f,370,-1);
    handles.chnum=fread(f,1,'int16');
    fseek(f,225, -1);
    filedate=fread(f,10,'uint8');
    indxd=find(char(filedate')=='/');  % year                                  % month                                         % day 
    if isempty(indxd)==0
        handles.fileDate=[str2double(char(filedate(1:indxd(1)-1)'))+2000 str2double(char(filedate(indxd(1)+1:indxd(2)-1)')) str2double(char(filedate(indxd(2)+1:end)'))];
    end
    fseek(f,235, -1);
    filetime=fread(f,12,'uint8');
    indxt=find( char(filetime')==':');
    if isempty(indxt)==0
        handles.fileTime=[str2double(char(filetime(1:indxt(1)-1)')) str2double(char(filetime(indxt(1)+1:indxt(2)-1)')) str2double(char(filetime(indxt(2)+1:end)'))];
    end
    handles.page={[1:handles.chnum]};
    lengt=str2num(get(handles.wsize,'string'));
    if handles.srate>10000
%         set(handles.apl,'string',num2str(0.01));
%         lengt=1;
        if ~isfield(handles,'amp')
            handles.amp=0.02;
        end
        lengt=str2num(get(handles.wsize,'string'));
    else
%         lengt=10;
        if ~isfield(handles,'amp')
            handles.amp=0.001;
        end
    end
    
    fseek(f,886,-1);
%     maxbyte=fix(fread(f,1,'int32'));
    fileinfo=dir(handles.fname);
    filesize=fileinfo.bytes;
    bytepersec=handles.srate* handles.databyte*handles.chnum;
    
    minbyte=900+75*handles.chnum;
    maxbyte=filesize-minbyte;
    handles.maxsec=maxbyte/bytepersec;
    
    fseek(f,0,-1);
    handles.header=fread(f,minbyte,'int8');
    handles.maxbyte=maxbyte;
    handles.minbyte=minbyte;
    
    for n = 1:handles.chnum
        fseek(f,900+75*(n-1),'bof');
        str=fread(f,10,'char');
        space=find(str==32);
        das=find(str==45);
        str=char(str);
        
        if isempty(space)
            space=10;
        else
            space=space-1;
        end
        handles.chnames{n}=str(1:space(1))';
        
        if ~isempty(das)
            c1=str(1:das(1)-1)';
            c2=str(das(1)+1:space(1))';
            handles.orig.chnames{n,1}=c1;
            handles.orig.chnames{n,1}=c2;
        else
            c1=str(1:space(1))';
            c2='REF';
            handles.orig.chnames{n,1}=c1;
            handles.orig.chnames{n,2}=c2;
        end
    end
    handles.orig.chnum=handles.chnum;
    
    handles.inx1=0;
    handles.maxsec=(handles.maxbyte-handles.minbyte)/(handles.chnum*handles.databyte*handles.srate);
    
    objs=findobj(handles.figure1,'type','uimenu');
    set(objs,'enable','on');
    set(handles.cntmv,'enable','on');
    handles.event={};    
case 'NS'
    handles.databyte=2;    
    fseek(f,24,-1);
    periodus=fread(f,1,'uint32');
    handles.srate=1/periodus*30000;
    handles.chnum=fread(f,1,'uint32');
    for a=1:handles.chnum
        handles.orig.chnames{a}=fread(f,1,'uint32');
    end
    
    minbyte=32+4*handles.chnum;
    handles.minbyte=minbyte;
    fseek(f,0,-1);
    handles.header=fread(f,minbyte,'int8');
    fseek(f,0,1);
    handles.maxbyte=ftell(f);
    handles.maxsec=(handles.maxbyte-handles.minbyte)/(handles.chnum*handles.databyte*handles.srate);
    
    handles.inx1=0;
    handles.amp=0.05;
    lengt=10;
    handles.page={[1:handles.chnum]};
case 'EDF'
    
%     header=readedf_ns([path fname]);
%     handles.srate=header.samplerate(1);
%     handles.chnum=header.channels;
%     handles.orig.chnames=header.channelname;
%     handles.maxbyte=header.maxbyte;
%     handles.databyte=2;
%     handles.minbyte=header.length;
%     handles.maxsec=handles.maxbyte/handles.srate;

    hdr=sopen([handles.path handles.fname],'r',0,'OVERFLOWDETECTION:OFF');
    handles.srate=hdr.SampleRate;
    handles.chnum=hdr.NS;
    handles.databyte=2; % ????????????????????????????????
    handles.maxbyte=hdr.NRec*hdr.Dur*hdr.SampleRate*2;
    handles.maxsec=hdr.NRec*hdr.Dur;
    handles.NRec=hdr.NRec; % number of block in the whole data
    handles.Dur=hdr.Dur;   % length of 1 block in seconds
    handles.orig.chnames=hdr.Label;
    for a=1:size(hdr.Label,1)
        handles.orig.chnames{a,2}='REF';
    end
    handles.orig.chnum=hdr.NS;
    handles.minbyte=0;

    handles.inx1=0;
    handles.amp=0.01;
    set(handles.apl,'string',num2str(0.01));
    lengt=10;
    handles.page={[1:handles.chnum]};
    handles.montage=[]; 
    param.info='';
    handles=task_add(handles.change_montage,{'inport','task_montage'},handles,param);
    
    ButtonName = questdlg('Import the whole data?', ...
                         'Question', ...
                         'Yes', 'No', 'Yes');
    switch ButtonName
      case 'Yes'
       outeeg=pop_biosig([handles.path handles.fname]);
       handles.wholedata=outeeg.data';
       disp('The whole data is in the memory');
    end
%     [hdr]=read_edf([path fname]);
%     handles.edfheader=hdr;
%     handles.srate=hdr.Fs;
%     handles.chnum=hdr.nChans;
%     handles.databyte=2; % ????????????????????????????????
%     handles.maxbyte=hdr.nSamples*hdr.nTrials*2;
%     handles.maxsec=hdr.nSamples*hdr.nTrials/hdr.Fs;
%     handles.NRec=hdr.nTrials; % number of block in the whole data
%     handles.Dur=hdr.nSamples*1/hdr.Fs;   % length of 1 block in seconds
%     handles.orig.chnames=hdr.label;
%     for a=1:size(hdr.label,1),
%         handles.orig.chnames{a,2}='REF';
%     end
%     handles.orig.chnum=hdr.nChans;
%     handles.minbyte=0;
% 
%     handles.inx1=0;
%     handles.amp=0.01;
%     set(handles.apl,'string',num2str(0.01));
%     lengt=10;
%     handles.page={[1:handles.chnum]};
%     handles.montage=[]; 
%     param.info='';
%     handles=task_add(handles.change_montage,{'inport','task_montage'},handles,param);
%     
%     ButtonName = questdlg('Import the whole data?', ...
%                          'Question', ...
%                          'Yes', 'No', 'Yes');
%     switch ButtonName,
%       case 'Yes',
%        outeeg=pop_biosig([handles.path handles.fname]);
%        handles.wholedata=outeeg.data';
%        disp('The whole data is in the memory');
%     end
case 'VHDR'
    [handles,lengt]=vhdr_inport_menu(handles,f);
case 'TXT'
    [handles,lengt]=txt_inport_menu(handles,f);

case 'AVG'
    [handles.wholedata, handles.variance, chan_names, pnts, rate, xmin, xmax, nsweeps]=loadavg_dani(handles.file);
    handles.wholedata=handles.wholedata';
    handles.srate=rate;
    handles.chnum=size(handles.wholedata,2);
    handles.nsweeps=nsweeps;
    
%     set(handles.figure1,'position',[0.0047 0.8594 0.0898 0.00001]);
    handles.databyte=4;
    
%     fseek(f,376,-1);
%     handles.srate=fread(f,1,'int16');
%     fseek(f,370,-1);
%     handles.chnum=fread(f,1,'int16');
    handles.page={[1:handles.chnum]};
    if handles.srate>10000
        set(handles.apl,'string',num2str(0.1));
        handles.amp=0.1;
    else
        handles.amp=0.0005;
    end
    
    fseek(f,886,-1);
    maxbyte=fread(f,1,'int32');
    minbyte=900+75*handles.chnum;
    handles.maxbyte=maxbyte;
    handles.minbyte=minbyte;
    fseek(f,864,-1);
%     handles.nsamples=fread(f,1,'int32');
    handles.nsamples=0.1;
    fseek(f,0,-1);
    handles.header=fread(f,minbyte,'int8');    
    handles.inx1=0;
    handles.maxsec=pnts/handles.srate;
    lengt=handles.maxsec;
%     lengt=(maxbyte-minbyte)/(handles.chnum*handles.databyte*handles.srate);
%     handles.maxsec=(handles.maxbyte-handles.minbyte)/(handles.chnum*handles.databyte*handles.srate);
   
case 'WDQ'
    handles.databyte=2;
    fseek(f,0,-1);
    a=fread(f,1,'int16');
    chnum=mod(a,32);
    handles.chnum=chnum;
    handles.page={[1:handles.chnum]};
    sr=fread(f,1,'int8');
    srate=mod(sr,256);
    handles.srate=srate;
    
    fseek(f,0,1);
    handles.maxbyte=ftell(f);
    handles.minbyte=1156;
    fseek(f,0,-1);
    handles.header=fread(f,handles.minbyte,'int8');
    set(handles.apl,'string',num2str(0.00005));
    handles.amp=0.0005;
    fseek(f,0,-1);
    handles.header=fread(f,handles.minbyte,'int8');
    handles.inx1=0;
    lengt=10;
    maxsec=(handles.maxbyte-handles.minbyte)/(handles.chnum*handles.databyte*handles.srate);
    handles.maxsec=maxsec;
    set([handles.php,handles.linder,handles.down_sampl_menu,handles.variance_menu,handles.skewness_menu],'enable','off');
        
case 'MAT'
    fclose(f);
    if strcmpi(fname(poi(end)-3:poi(end)-1),'AVG') %strcmp volt strcmpi helyett
        handles.type2='avg';
%         set(handles.figure1,'position',[0.0047 0.8594 0.0898 0.00001]);
    elseif strcmpi(fname(poi(end)-4:poi(end)-1),'PSTH') %itt is
        handles.type2='psth';   
    elseif strcmpi(fname(poi(end)-3:poi(end)-1),'FFT') %és itt is
        handles.type2='fft'; 
    else
        handles.type2='';
    end
    d=load([path fname]);
    if isfield(d,'handles')
        handles=d.handles;
    else
        field=fieldnames(d);
        s=struct('type','.','subs',field{1});
        d1=subsref(d,s);
        if isstruct(d1)
            d=d1;
            field=fieldnames(d);
            s=struct('type','.','subs',field{1});
        end
        handles.wholedata=subsref(d,s);
        handles.wholedata=shiftdim(handles.wholedata);
        handles.chnum=size(handles.wholedata,2);
        lengt=10;
        if isfield(d,'evnum')
            handles.nsweeps=d.evnum;
        end
        if isfield(d,'ev')
            handles.avgevent=d.ev;
        end
        if isfield(d,'event')
            handles.avgevent=d.event;
        end
        handles.page={[1:handles.chnum]};
        if strcmp(handles.type2,'fft')
            handles.srate=1;
            handles.f=d.f;
            lengt=size(handles.wholedata,1);
        elseif isfield(d,'srate')
            handles.srate=d.srate;
        else
            answer  = inputdlg('The sampling rate?','Give the parameters',1,{'2000'});
            handles.srate=str2num(answer{1});
        end
        handles.maxbyte=size(handles.wholedata,1);
        handles.databyte=1;
        handles.minbyte=0;
        handles.inx1=0;
        handles.amp=0.05;
        set(handles.apl,'string',num2str(0.01));
        handles.maxsec=handles.maxbyte/handles.srate;
    end
    if isfield(handles,'orig')
        lrange=handles.orig.logic_max-handles.orig.logic_min+1;
        prange=handles.orig.physic_max-handles.orig.physic_min;
        handles.wholedata=(handles.wholedata-handles.orig.logic_gnd)/lrange*prange;
    end
case 'PRN'
    fclose(f);
    answer  = inputdlg({'The sampling rate?','The channel number?'},'Give the parameters',1,{'128','1'});
    handles.srate=str2num(answer{1});
    handles.chnum=str2num(answer{2});
    st='%f '; string='';
    for i=1:handles.chnum
        string=[string st];
    end
    string=string(1:end-1);
    d=textscan([path fname],string,'headerlines',6); %textread volt textscan helyett
    handles.wholedata=d;
    handles.srate=str2num(answer{1});
    handles.maxbyte=size(handles.wholedata,1);
    handles.databyte=1;
    handles.minbyte=0;
    handles.inx1=0;
    handles.amp=0.05;
    set(handles.apl,'string',num2str(0.01));
    lengt=10;
    handles.maxsec=handles.maxbyte/handles.srate;
    set([handles.unit_menu,handles.php,handles.linder,handles.down_sampl_menu,handles.variance_menu,handles.skewness_menu],'enable','off');
case 'TRC'
    [handles,lengt]=trc_inport_menu(handles,f);
    disp('');
case 'ASC'
    d=load([path fname]);
    handles.wholedata=d;
    handles.chnum=size(handles.wholedata,2);
    handles.page={[1:handles.chnum]};
    handles.srate=[];
    
    av=strfind(fname,'_'); %findstr volt
    if ~isempty(av)
        name=fname(1:av(1)-1);
        names=dir(path);
        found=0;
        for a1=1:length(names)
            if ~names(a1).isdir
                if strcmp(names(a1).name(end-2:end),'had')
                    if strfind(names(a1).name,fname(1:end-4))
                        found=a1; break;
                    elseif strfind(names(a1).name,name)
                        found=a1; break;
                    end
                end
            end
        end
        
        fi=fopen([path names(found).name]);
        ok=0; a1=0;
        while ~ok && found
            l=fgetl(fi);
            if ~ischar(l), break; end
            if ~isempty(handles.srate) && isempty(str2num(l)) && ~isempty(l)
                a1=a1+1;
                handles.chnames{a1}=words(l);
            end
            if length(l)==79
                srp=strfind(l,'Sampling rate');
                handles.srate=str2num(l(srp+13:end));
            end
            if a1==2, ok=1; end
        end
    end
    
    if isempty(handles.srate)
        answer  = inputdlg('The sampling rate?','Give the parameters',1,{'256'});
        handles.srate=str2num(answer{1});
        handles.chnames='';
    end
    
    handles.maxbyte=size(handles.wholedata,1);
    handles.databyte=1;
    handles.minbyte=0;
    handles.inx1=0;
    handles.amp=0.05;
    set(handles.apl,'string',num2str(0.01));
    lengt=10;
    handles.maxsec=handles.maxbyte/handles.srate;
end

if isfield(handles,'chnum')
    for i=1:handles.chnum
        S(1).type='.';S(2).type='.';
        S(1).subs='chdata';S(2).subs=['ch' num2str(1)];
        handles=subsasgn(handles,S,struct);
    end
end
if lengt>handles.maxsec
    lengt=handles.maxsec;
end
set(handles.ap,'string',num2str(handles.amp));
set(handles.flength,'string',num2str(handles.maxsec));
set(handles.wsize,'string',num2str(lengt));

%%%% EVALUATE INPORT, and DRAW %%%%%%%%
handles.checked = 'off'; %en irtam ide

handles=inport(handles.inx1,lengt,handles); 
handles=draw(handles.data,handles);
if nargout>0
    varargout{1}=handles;
%     guidata(h,handles);
else
    guidata(h,handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function varargout=inport(begin,lengt,handles)

% inport subfunction
% needs the begin and length in seconds

beginpoint=fix(begin*handles.srate);

begin=fix(begin*1000)/1000;
lengt=fix(lengt*1000)/1000;

if begin+lengt>handles.maxsec || begin<0
    set(handles.wsize,'string',length(handles.data)/handles.srate);
    if nargout==1
        varargout{1}=handles;
    end
    return;
end

inlengt=lengt; inbegin=begin;
ok=0;
t=handles.type;

if isfield(handles,'wholedata')
    begin=fix(begin*handles.srate);
    lengt=fix(lengt*handles.srate);
    if begin==0, begin=1; lengt=lengt-1; end

    handles.data=handles.wholedata(begin:begin+lengt,:);
    handles.inx1=inbegin;
    handles.inxp=beginpoint;
    ok=1;
    t='DONT OPEN ANY MORE';
end

switch upper(t)
case {'CNT','WDQ','TXT','NS'}
    if isfield(handles,'orig')
        chnum=handles.orig.chnum;
    else
        chnum=handles.chnum;
    end
    begin=round(handles.minbyte+beginpoint*chnum*handles.databyte);
    lengt=lengt*chnum*handles.srate;
    
    file=fopen(handles.file);
    fseek(file,begin,'bof');
    if ~isempty(ferror(file))
        fclose(file);
        errordlg(['IO error: ' ferror(file)]);
        if nargout==1
            varargout{1}=handles;
        end
        return;
    end
    data=fread(file,lengt,'int16');

    if chnum>1
        n=size(data,1);
        nchn=fix(n/chnum);
        data(nchn*chnum+1:end)=[];
        data=reshape(data,chnum,nchn)';
    end
    
    %Calculate mikroV values
    if isfield(handles,'orig')
        if isfield(handles.orig,'logic_max')
            lrange=handles.orig.logic_max-handles.orig.logic_min+1;
            prange=handles.orig.physic_max-handles.orig.physic_min;
            data=(data-handles.orig.logic_gnd)/lrange*prange;
        end
    end
    
    fclose(file);
    handles.data=data;
    handles.inx1=inbegin;
    handles.inxp=beginpoint;
    ok=1;
case {'EDF'}
    ending=begin+lengt;  % ending of the data in secs
    % converting sec to blocks
    begin=begin/handles.Dur;
    ending=ending/handles.Dur;
    begin=fix(begin*1000)/1000;
    ending=fix(ending*1000)/1000;
    
    outeeg=pop_biosig([handles.path handles.fname],'blockrange',[begin ending]);
    %[outdata]=read_edf([handles.path handles.fname],handles.edfheader, inbegin, ending, 2:handles.chnum);
    handles.data=outeeg.data';
    %handles.data=outdata;
    handles.inx1=inbegin;
    handles.inxp=beginpoint;
    ok=1;
    
case {'TRC'}
    begin=round(handles.minbyte+beginpoint*handles.orig.chnum*handles.databyte);
    lengt=lengt*handles.orig.chnum*handles.srate;
    
    file=fopen(handles.file);
    fseek(file,begin,'bof');
    if ~isempty(ferror(file))
        fclose(file);
        errordlg(['IO error: ' ferror(file)]);
        if nargout==1
            varargout{1}=handles;
        end
        return;
    end
    switch  handles.databyte
        case 1
        data=fread(file,lengt,'uint8');
        case 2
        data=fread(file,lengt,'uint16');
        case 4
        data=fread(file,lengt,'uint32');
    end
    if handles.orig.chnum>1
        n=size(data,1);
        nchn=fix(n/handles.orig.chnum);
        data(nchn*handles.orig.chnum+1:end)=[];
        data=reshape(data,handles.orig.chnum,nchn)';
    end
    fclose(file);
    
    %Calculate mikroV values
    if handles.trcty>1
        for a=1:handles.orig.chnum
            lrange=handles.orig.logic_max(a)-handles.orig.logic_min(a)+1;
            prange=handles.orig.physic_max(a)-handles.orig.physic_min(a);
            origdata(:,a)=(data(:,a)-handles.orig.logic_gnd(a))/lrange*prange;
        end
    else
        for a=1:handles.orig.chnum
            mcs=handles.orig.mcs(a)/handles.mcs_factor;
            origdata(:,a)=(data(:,a)-128)/256*mcs;
        end
    end
    handles.origdata=origdata;
    
    handles.inx1=inbegin;
    handles.inxp=beginpoint;
    ok=1;
case 'VHDR'
    begin=round(handles.minbyte+beginpoint*handles.orig.chnum*handles.databyte);
    lengt=lengt*handles.orig.chnum*handles.srate;
    
    file=fopen(handles.file);
    fseek(file,begin,'bof');
    if ~isempty(ferror(file))
        fclose(file);
        errordlg(['IO error: ' ferror(file)]);
        if nargout==1
            varargout{1}=handles;
        end
        return;
    end
    data=fread(file,lengt,'int16');
    
    if handles.orig.chnum>1
        n=size(data,1);
        nchn=fix(n/handles.orig.chnum);
        data(nchn*handles.orig.chnum+1:end)=[];
        data=reshape(data,handles.orig.chnum,nchn)';
    end
    fclose(file);
    
    %Calculate mikroV values
    for a=1:handles.orig.chnum
        lrange=handles.orig.logic_max(a)-handles.orig.logic_min(a)+1;
        prange=handles.orig.physic_max(a)-handles.orig.physic_min(a);
        origdata(:,a)=(data(:,a)-handles.orig.logic_gnd(a))/lrange*prange;
    end
    
    handles.origdata=origdata;
    
    handles.inx1=inbegin;
    handles.inxp=beginpoint;
    ok=1;        
case 'AVG'
    if isfield(handles,'wholedata')
        begin=fix(begin*handles.srate);
        lengt=fix(lengt*handles.srate);
        if begin==0, begin=1; lengt=lengt-1; end
    
        handles.data=handles.wholedata(begin:begin+lengt,:);
        handles.inx1=inbegin;
        handles.inxp=beginpoint;
        ok=1;
    else
        [signal, variance, chan_names, pnts, rate, xmin, xmax]=loadavg_dani(handles.file);
        handles.data=signal';
    
    
%     file=fopen(handles.file);
%     fseek(file,handles.minbyte,-1);
%     nsamples=((handles.maxbyte-handles.minbyte)/handles.chnum-5)/4;
%     if mod(nsamples,1) & mod(handles.nsamples,1),
%         answer  = inputdlg('The number of samples?','Give the parameters',1,{'2001'});
%         handles.nsamples=str2num(answer{1});
%     elseif ~mod(nsamples,1) & mod(handles.nsamples,1),
%         handles.nsamples=nsamples;
%     end
%     for i=1:handles.chnum,
%         fseek(file,5,0);
%         data(:,i)=fread(file,handles.nsamples,'float32');
%     end;
%     fclose(file);
%     handles.data=data;

        handles.inx1=0;
        ok=1;
    end
case {'MAT','PRN','ASC'}
    begin=fix(begin*handles.srate);
    lengt=fix(lengt*handles.srate);
    if begin==0, begin=1; lengt=lengt-1; end
    
    handles.data=handles.wholedata(begin:begin+lengt,:);
    handles.inx1=inbegin;
    handles.inxp=beginpoint;
    ok=1;
end

if ok
    for a=1:size(handles.task,1)
        if strcmp(handles.task{a,1},'inport')
            handles=feval(handles.task{a,2},handles,a);
        end
    end
end

% fclose('all');

if nargout==1
    varargout{1}=handles;
end

% --------------------------------------------------------------------
function handles = task_filter(handles,tasknumber)

filterset=handles.taskparam{tasknumber};
data=handles.data;

data=double(data);

if filterset.filtfilt
    handles.data=filtfilt(filterset.b,filterset.a,data);
else
    handles.data=filter(filterset.b,filterset.a,data);
end
if filterset.rect
    handles.data=abs(handles.data);
end

% --------------------------------------------------------------------
function handles = task_linder(handles,tasknumber)

handles.data=handles.data*handles.taskparam{tasknumber}.matrix;


% --------------------------------------------------------------------
function handles = task_montage(handles,varargin)

% For calculate a montage NSWIEW needs the stored data in handles.origdata

if isempty(handles.montage)
    handles=montage_alap_Callback(handles);
end

handles.chnum=size(handles.montage,1);
if ~isfield(handles,'origdata')
    origdata=handles.data;  
else
    origdata=handles.origdata;
end
handles.data=[];
handles.chnames={};
for a=1:handles.chnum
    if handles.montage(a,2)==1000
        if handles.montage(a,1)==0
            handles.data(:,a)=zeros(size(origdata(:,1)));
        else
            handles.data(:,a)=origdata(:,handles.montage(a,1));
        end
        c2toknum=double(handles.c2{a}~=32); %find(double(handles.c2{a}~=32)) volt
        handles.chnames{a}=[handles.c1{a}, '-', handles.c2{a}(c2toknum)]; %c2toknum
    elseif handles.montage(a,2)==1001
        if ~isfield(handles,'avgchannels')
            answer=inputdlg('AVG channels','Give the AVG channels',1,{''});
            handles.avgchannels=str2num(answer{1});
            handles.avgdata=mean(origdata(:,handles.avgchannels)')';
        end
        handles.avgdata=mean(origdata(:,handles.avgchannels)')';
        avgdata=handles.avgdata;
        handles.data(:,a)=origdata(:,handles.montage(a,1))-avgdata;
        handles.chnames{a}=[handles.c1{a}, '-', handles.c2{a}];
    else
        if any(handles.montage(a,:)==0)
            handles.data(:,a)=zeros(size(origdata(:,1)));
        else
            handles.data(:,a)=origdata(:,handles.montage(a,1))-origdata(:,handles.montage(a,2));
        end
        handles.chnames{a}=[handles.c1{a}, '-', handles.c2{a}];
    end
end
% cellfun('size',handles.chnames,2)
% size(handles.chnames)
% disp(handles.chnames);

% --------------------------------------------------------------------
function handles = task_fourier(handles,tasknumber)

newfig=0;
if ~isfield(handles,'fourierfig')
    newfig=1;
elseif ~ishandle(handles.fourierfig)
    newfig=1;
end

if newfig
    handles.fourierfig=fourierfig(handles.figure1);
    set(handles.figure1,'position',[0.0023    0.0371    0.8234    0.9160]); 
    ylim={};
    fr=handles.taskparam{tasknumber}.fr;
else
    set(0,'currentfigure',handles.fourierfig);
    axes=findobj(gcf,'type','axes');
    ylim=get(axes,'ylim');
    if ~iscell(ylim)
        a{1}=ylim;
        ylim=a;
    end
    lim=findobj(handles.fourierfig,'tag','lim');
    fr=str2num(get(lim,'String'));
end

% fourierfig('update',handles.fourierfig,handles.taskparam{tasknumber},guidata(handles.fourierfig));

ch=handles.taskparam{tasknumber}.ch;
pt=handles.taskparam{tasknumber}.pt;


%%%%%%
[fc, f]=fourier_bas_power_hann(handles.data(:,ch),pt,handles.srate);
% [fc f]=fourier_bas(handles.data(:,ch),pt,handles.srate);
sfc=size(fc,1);
df=mean(diff(f));
n=length(ch);
%%%%%%%

mb=findobj(handles.fourierfig,'style','togglebutton');
meas=get(mb,'value');

if ~meas && isfield(handles,'fourierint')
    handles=rmfield(handles,'fourierint');
elseif meas && ~isfield(handles,'fourierint')
    handles.fourierint=zeros(1,n);
    handles.fouriermaxe=zeros(1,n);
    handles.fouriermaxh=zeros(1,n);
    handles.fourierfc=zeros(1,sfc,n);
    handles.fourierf=zeros(1,sfc,n);    
end
if meas
    flim=handles.fourierlim;
    int=find(f>flim(1) & f<flim(2));
end

% disp('1')


if isempty(ylim)
    for a=1:n
        ylim{a}=[mean(mean(fc))*40 0];
    end
end

% %%%
for a=1:n
    axes(a)=subplot(n,1,a);
    fc(:,a)=smooth2(fc(:,a),5);
    bar(f,fc(:,a));
    set(gca,'xlim',fr, ...
            'ylim',[ylim{a}], ...
            'xtick',[fr(1):diff(fr)/5:fr(2)]);
    title(num2str(ch(a)));
    if meas
        handles.fourierint(end,a)=sum(fc(int,a))*df;
        [maxe, maxh]=max(fc(int,a));
        handles.fouriermaxe(end,a)=maxe;
        [maxe, maxh]=max(smooth2(fc(int,a),3));
        handles.fouriermaxh(end,a)=f(maxh+int(1)-1);
        handles.fourierfc(end,:,a)=fc(:,a);
        handles.fourierf(end,:,a)=f;
    end
end
% disp('2')

if meas
    handles.fourierint(end+1,:)=zeros(1,n);
    handles.fouriermaxe(end+1,:)=zeros(1,n);
    handles.fouriermaxh(end+1,:)=zeros(1,n);
    handles.fourierfc(end+1,:,:)=zeros(1,sfc,n);
    handles.fourierf(end+1,:,:)=zeros(1,sfc,n);    
end
% disp('3')
guidata(handles.figure1,handles);


% --------------------------------------------------------------------
function varargout = peak_menu_Callback(h, eventdata, handles, varargin)

if strcmp(get(h,'checked'),'on')
    handles.tresholding=0; %hadles.tresholding volt itt
    set(h,'checked','off');
    set(handles.figure1,'name',handles.fignam,'windowbuttonupfcn','');
    return;
end    

err=0;
if ~isfield(handles,'binx1') && ~isfield(handles,'binx2')
    err=1;
    errordlg('There is no block specified!');
    return;
else
    try
        handles.event{handles.binx1,1};
        handles.event{handles.binx2,1};
    catch
        handles.binx1=[]; handles.binx2=[];
        guidata(h,handles);
        error('The block is invalid!');
    end
end

ButtonName=questdlg('Which type of selection do you prefer?', ...
                       'Select the type', ...
                       'Amplitude','Distribution','Cancel','Amplitude'); 
if strcmp(ButtonName,'Cancel')
    return;
elseif strcmp(ButtonName,'Distribution')
    prompt  = {'p','1: Only the peaks, 2: Every data points','Smooth [point times]','Minimum distance','Channel'};
    title   = 'Give the parameters';
    lines= 1;
    def     = {'0.01','1','5 0','',''};
    answer  = inputdlg(prompt,title,lines,def);
    if isempty(answer), return; end
    p=str2num(answer{1});
    ty=str2num(answer{2});
    smoot=str2num(answer{3});
    mindist=str2num(answer{4});
    ch=str2num(answer{5});
    
    b=handles.event{handles.binx1,1};
    e=handles.event{handles.binx2,1};
    ep=readvalue(handles,[b e],ch(1));
    ep=smooth2(ep,smoot(1),smoot(2));
    if ty==2
        [maxs, mins]=distfind(ep,p/2);
    else
        ep=ep-mean(ep);
        [maxs, mins]=amplfind(ep,[0 0]);
        vmaxs=ep(maxs);
        vmins=ep(mins);
        [pmaxs, xoutmax]=histcum(vmaxs,30,1);
        [pmins, xoutmin]=histcum(vmins,30,1);
        maxlim=xoutmax(max(find(pmaxs<1-p/2)));
        minlim=xoutmin(max(find(pmins<p/2)));
        maxs=maxs(find(vmaxs>=maxlim));
        mins=mins(find(vmins<=minlim));
    end
    
    if ~isempty(mindist)
        maxs=exclude_dist(maxs,mindist,ep,'max');
        mins=exclude_dist(mins,mindist,ep,'min');
    end
   
    event={};
    for i=1:size(handles.event,1)
        c=sscanf(handles.event{i,2},'%f');
        if c~=ch
            event{end+1,1}=handles.event{i,1};
            event{end,2}=handles.event{i,2};
        end
    end
    handles.event=event;
    
    disp('Event number:');
    disp([length(maxs) length(mins)]);
    maxs=fix(maxs); mins=fix(mins);
    for a=1:length(maxs)
        handles=putmark(h,{b+maxs(a)-1 [num2str(ch) 'a']},handles);
    end
    
    for a=1:length(mins)
        handles=putmark(h,{b+mins(a)-1 [num2str(ch) 'b']},handles);
    end
    handles=draw(handles.data,handles);
    guidata(h,handles);
    set_treshold_plot(handles,ch);
    return;
end
             
set(h,'checked','on');

prompt  = {'1: min; 2: max','Smooth [point times]','Minimum distance','Channel'};
title   = 'Give the parameters';
lines= 1;
def     = {'1','5 0','',''};
answer  = inputdlg(prompt,title,lines,def);
param.mima=str2num(answer{1});
param.smooth=str2num(answer{2});
param.dist=str2num(answer{3});
param.ch=str2num(answer{4});
set(h,'userdata',param);
    
handles.fignam=get(handles.figure1,'name');
set(handles.figure1,'name','Press SHIFT and LEFT MOUSE BUTTON to set the treshold',...
                        'windowbuttonupfcn','nswiew(''set_treshold'',gcbo,[],guidata(gcbo))');                 
guidata(h,handles);
    
% --------------------------------------------------------------------
function varargout = set_treshold(h, eventdata, handles, varargin)

% Block begin reset not implemented

st=get(handles.figure1,'selectiontype');
param=get(handles.peak_menu,'userdata');

switch st
    case 'alt'
        prompt  = {'Value'};
        tit   = 'Give the parameter';
        lines= 1;
        def     = {''};
        answer  = inputdlg(prompt,tit,lines,def);
        value=num2str(answer{1});
    case 'extend'
        point=get(handles.ax,'currentpoint');
        [ch, value, inside]=mouseloc(point,handles,param.ch); 
    otherwise return; 
end
  
if isempty(value), return; end

S(1).type='.';S(2).type='.';S(3).type='.';
S(1).subs='chdata';S(2).subs=['ch' num2str(param.ch)];S(3).subs='treshold';
handles=subsasgn(handles,S,value);
begin=handles.event{handles.binx1,1}./handles.srate;
lengt=handles.event{handles.binx2,1}./handles.srate-begin;
[beg, len, fbeg, fend]=fragment(handles,begin,lengt,handles.srate,0.1);

event={};
for i=1:size(handles.event,1)
    ch=sscanf(handles.event{i,2},'%f');
    if isempty(ch)
        ch=0;
    end
    if ch~=param.ch || isempty(ch)
        event{end+1,1}=handles.event{i,1};
        event{end,2}=handles.event{i,2};
    end
end
handles.event=event;
eventnum=0;
AMpl=[];
for i=1:length(beg)
    hand=inport(beg(i),len(i),handles); 
    data=hand.data;
    data=smooth2(data(:,param.ch),param.smooth(1),param.smooth(2));
   
    if param.mima==1
        [maxs, mins]=amplfind(data,[value,max(data)]);
        p=mins; c='b';
    else
        [maxs, mins]=amplfind(data,[min(data),value]);
        p=maxs; c='a';
    end
    p=p(p>fbeg(i) & p<fend(i)); %p = p(find(p>fbeg(i) & p<fend(i))) volt
    ampl=hand.data(p);
    AMpl=[AMpl; ampl];
    if ~isempty(param.dist)
        mima={'min','max'};
        p=exclude_dist(p,param.dist,data,mima{param.mima});
    end
    
    eventnum=eventnum+length(p);
    p=fix(p);
    for i=1:length(p)
        handles=putmark(h,{hand.inxp+p(i)-1 [num2str(param.ch) c]},handles);
    end
end
save('ampl_dat2', 'AMpl')
disp('Event number:')
disp(eventnum)
handles=draw(handles.data,handles);
guidata(h,handles);
set_treshold_plot(handles,param.ch);

% --------------------------------------------------------------------
function set_treshold_plot(handles,ch)

ev=[]; eva=[]; evb=[];  
for i=1:size(handles.event,1)
    c=sscanf(handles.event{i,2},'%f');
    if c==ch
        if handles.event{i,2}(end)=='a'
            eva(end+1,1)=handles.event{i,1};
        elseif handles.event{i,2}(end)=='b'
            evb(end+1,1)=handles.event{i,1};
        else
            ev(end+1,1)=handles.event{i,1};
        end
    end
end
ev=shiftdim(sort(ev)); eva=shiftdim(sort(eva)); evb=shiftdim(sort(evb)); 
dev=diff(ev); deva=diff(eva); devb=diff(evb); 
a={}; tit={};
if ~isempty(ev), a{end+1}=dev; tit{end+1}='Other event''s distribution'; end
if ~isempty(eva), a{end+1}=deva; tit{end+1}='Upper event''s distribution'; end
if ~isempty(evb), a{end+1}=devb; tit{end+1}='Lower event''s distribution'; end

% f1=findobj('name','histogram');
% f2=findobj('name','return plot');
% delete([f1 f2]); 
for a1=1:length(a)
    f1=figure('name',['histogram ch:' num2str(ch)],'numbertitle','off');
    f2=figure('name',['return plot ch:' num2str(ch)],'numbertitle','off');
    set(0,'currentfigure',f1);
    hist(a{a1},200);
    title(tit{a1});
    set(0,'currentfigure',f2);
    plot(a{a1}(1:end-1),a{a1}(2:end),'.b','markersize',6);
    title(tit{a1});
end

% --------------------------------------------------------------------
function varargout = down_sampl_menu_Callback(h, eventdata, handles, varargin)

if upper(handles.type)~='CNT'
    errordlg('This routine is implemented only for CNT file!');
    return;
end

prompt  = {'Downsampl by ..'};
title   = 'Give the parameter';
lines= 1;
def     = {''};
answer  = inputdlg(prompt,title,lines,def);
rate=str2num(answer{1});

cd(handles.path);
type=['.' handles.type];
[file,path] = uiputfile(['*' type],'Give the file name');
poi=strfind(file,'.'); %findstr volt
if ~isempty(poi), file=file(1:poi(1)-1); end
file=[file type];
ft=fopen([path file],'w');
fwrite(ft,handles.header,'int8');
fseek(ft,376,-1);
newsrate=fix(handles.srate/rate);
fwrite(ft,newsrate,'int16');
fseek(ft,0,1);

begin=0; lengt=handles.maxbyte/(handles.srate*handles.chnum*handles.databyte);
if lengt>20
    prompt  = {'Do fragment?','Length in seconds'};
    title   = 'The selected length is too long';
    lines= 1;
    def     = {'yes','20'};
    answer  = inputdlg(prompt,title,lines,def);
    if upper(answer{1})=='YES'
        frlengt=str2num(answer{2});
    else
        frlengt=lengt;
    end
else
    frlengt=lengt;
end
beg=begin;
for i=1:fix(lengt/frlengt)
    disp(num2str(i))
    hand=inport(beg,frlengt,handles);
   
    for j=1:handles.chnum
        data(:,j)=hand.data(1:rate:end,j);
    end
    
    fwrite(ft,data','int16');
end
maxbyte=ftell(ft)-handles.minbyte;
fseek(ft,886,-1);
fwrite(ft,maxbyte,'int32');
fclose(ft);
msgbox('Ready');

% --------------------------------------------------------------------
function varargout = filter_menu_Callback(h, eventdata, handles, varargin)

if strcmp((handles.checked), 'on') || strcmp(get(h, 'checked'), 'on') %en irtam
%if strcmp(get(h,'checked'),'on')
    prompt  = {'1: Erase all the filters; 2: Add new filter.'};
    button=questdlg('Select', ...
                'Quest', ...
                ['Add new filter.'],...
                ['Erase all the filters.'],...
                ['Add new filter.']);
    if strcmp(button,'Erase all the filters.')
    	answer={'1'};
    elseif strcmp(button,'Add new filter.')
        answer={'2'};
    else
        return;
    end
else
    answer={'2'};
end
    
if strcmp(answer{1},'1')
    handles=task_menu_turn_off(h,'task_filter',handles);
    return;
end
button=questdlg('Apply the filter ...', ...
                'Select', ...
                ['only on the display.'],...
                ['on the entire/blocked data.'],...
                ['only on the display.']);
if strcmp(button,'only on the display.')
	answer={'1'};
elseif strcmp(button,'on the entire/blocked data.')
	answer={'2'};
else
    return;
end

%%%%%%%%%%%%%% SETTING UP THE FILTER
filtset=filterset(handles.srate,handles);
waitfor(filtset);
handles=guidata(handles.figure1);


if ~isfield(handles,'filterset')
    errordlg('Error in specifying a filter');
    return; 
end

if strcmp(answer{1},'1')
    handles=task_menu_add(h,{'inport','task_filter'},handles,handles.filterset);
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a=handles.filterset.a;
b=handles.filterset.b;

%%%%%%%%%%%%%% SETTING UP THE DATA
if ~strcmpi(handles.type,'CNT') && ~strcmpi(handles.type,'WDQ') %strcmp volt
    errordlg('This routine is implemented only for CNT or WDQ file!');
    return;
end

if ~isfield(handles,'binx1') || ~isfield(handles,'binx2')
    begin=0;
    lengt=handles.maxsec;
else
    begin=handles.event{handles.binx1,1}./handles.srate;
    lengt=handles.event{handles.binx2,1}./handles.srate-begin;
end
if lengt>10
    bb=[0:10:lengt]';
    bb(end)=[];
    bl=ones(size(bb))*10;
    bl(end)=mod(lengt,10)+10;
else
    bb=begin;
    bl=lengt;
end

% [b a]=butter(4,5/1000,'high'); handles.filter.filtfilt=1;
len = bl*handles.srate;   % length of input
b = b(:).'; a = a(:).'; nb = length(b); na = length(a); nfilt = max(nb,na);
nfact = 3*(nfilt-1);  % length of edge transients

if any(len<=nfact)   % input data too short!
    errordlg('Data must have length more than 3 times filter order.');
    return;
end

% set up filter's initial conditions to remove dc offset problems at the 
% beginning and end of the sequence
    if nb < nfilt, b(nfilt)=0; end   % zero-pad if necessary
    if na < nfilt, a(nfilt)=0; end
% use sparse matrix to solve system of linear equations for initial conditions
% zi are the steady-state states of the filter b(z)/a(z) in the state-space 
% implementation of the 'filter' command.
    rows = [1:nfilt-1  2:nfilt-1  1:nfilt-2];
    cols = [ones(1,nfilt-1) 2:nfilt-1  2:nfilt-1];
    da = [1+a(2) a(3:nfilt) ones(1,nfilt-2)  -ones(1,nfilt-2)];
    sp = sparse(rows,cols,da);
    zi = sp \ ( b(2:nfilt).' - a(2:nfilt).'*b(1) );

zi1=zi;

%%%%%%%%%%%%%% SETTING UP THE FILE

type=['.' handles.type];
[fn,path] = uiputfile(['*' type],'Give the file name');
poi=strfind(fn,'.'); %findstr volt
if ~isempty(poi), fn=fn(1:poi(1)-1); end
fn=[fn type];
fw=fopen([path fn],'w');
fwrite(fw,handles.header,'int8');
if upper(handles.type)~= 'WDQ' 
    fseek(fw,886,-1);
    maxbyte=handles.minbyte+lengt*handles.srate*handles.chnum*handles.databyte;
    fwrite(fw,maxbyte,'int32');
end
fseek(fw,0,1);

if handles.filterset.filtfilt
    ff=fw;
    fw=fopen('filter.tns','w');
    fwrite(fw,handles.header,'int8');
    fwrite(ff,handles.header,'int8');
end

%%%%%%%%%%%%%% PROCEED

indi('0 %');
for i=1:length(bb)
    indi([num2str(round((bb(i)-bb(1))/lengt*100)) ' %']);
    hand=inport(bb(i),bl(i),handles);
    data=hand.data;
    
    [fdata, zf]=filter(b,a,data,zi);
    zi=zf;
    
    switch upper(handles.type)
    case {'CNT','WDQ'}
        fwrite(fw,fdata','int16');
        fwrite(ff,zeros(size(fdata')),'int16');
    case 'AVG'
        fwrite(fw,fdata','float32');
    end
end
fclose(fw);

if handles.filter.filtfilt
    ft=fopen('filter.tns');
    zi=zi1;
    for i=length(bb):-1:1
        indi([num2str(round((bb(i)-bb(1))/lengt*100)) ' %']);
        beg=bb(i); len=bl(i);
        beg=round(beg*1000)/1000;
        len=round(len*1000)/1000;
        
        beg=round(handles.minbyte+beg*handles.chnum*handles.srate*handles.databyte);
        len=len*handles.chnum*handles.srate;
        fseek(ft,beg,'bof');
        data=fread(ft,len,'int16');
        n=size(data,1);
        nchn=fix(n/handles.chnum);
        data(nchn*handles.chnum+1:end)=[];
        data=reshape(data,handles.chnum,nchn)';
        data=flip(data,1); %flipdim volt
        
        [fdata, zf]=filter(b,a,data,zi);
        zi=zf;
        
        fdata=flip(fdata,1); %flipdim volt
        
        switch upper(handles.type)
        case {'CNT','WDQ'}
            fseek(ff,beg,-1);
            fwrite(ff,fdata','int16');
        case 'AVG'
            fwrite(ff,fdata','float32');
        end
    end
    fclose(ff);
    fclose(ft);
end
indi('del');


% --------------------------------------------------------------------
function varargout = linder_menu_Callback(h, eventdata, handles, varargin)

if strcmp(get(h,'checked'),'on')
    
    button=questdlg('Select ...', ...
                       'Quest', ...
                       ['Add new linear derivation.'],...
                       ['Erase all the linear derivations.'],...
                       ['Add new linear derivation.']);
    if strcmp(button,'Add new linear derivation.')
        answer={'2'};
    elseif strcmp(button,'Erase all the linear derivations.')
        answer={'1'};
    else
        return;
    end
else
    answer={'2'};
end

if strcmp(answer{1},'1')
    handles=task_menu_turn_off(h,'task_linder',handles);
    return;
end

button=questdlg('Apply the derivation ...', ...
                'Select', ...
                ['only on the display.'],...
                ['on the entire/blocked data.'],...
                ['only on the display.']);
if strcmp(button,'only on the display.')
	answer={'1'};
elseif strcmp(button,'on the entire/blocked data.')
	answer={'2'};
else
    return;
end


%%%%%%%%%%%%%% SETTING UP THE LDR

[fn,path] = uigetfile({'*.ldr','LDR file WITHOUT HEADER *.ldr'},'Give the ldr file WITHOUT HEADER');
m=load([path fn]);
m=m';

%%%%%%%%%%%%%%%%%%%%%%

if strcmp(answer{1},'1')
    param=struct('matrix',m,'info',['file: ',fn]);
    handles=task_menu_add(h,{'inport','task_linder'},handles,param);
    return;
end
    
    
%%%%%%%%%%%%%% SETTING UP THE DATA
if ~strcmpi(handles.type,'CNT') && ~strcmpi(handles.type,'WDQ') %strcmp és & volt
    errordlg('This routine is implemented only for CNT or WDQ file!');
    return;
end

if ~isfield(handles,'binx1') || ~isfield(handles,'binx2') %| volt
    begin=0;
    lengt=handles.maxsec;
else
    begin=handles.event{handles.binx1,1}./handles.srate;
    lengt=handles.event{handles.binx2,1}./handles.srate-begin;
end

% [bb bl fb fe]=fragment(begin,lengt,handles.srate,0);

if lengt>10
    bb=[0:10:lengt]';
    bb(end)=[];
    bl=ones(size(bb))*10;
    bl(end)=mod(lengt,10)+10;
else
    bb=begin;
    bl=lengt;
end


%%%%%%%%%%%%%% SETTING UP THE FILE

type=['.' handles.type];
[fn,path] = uiputfile(['*' type],'Give the file name');
poi=strfind(fn,'.'); %findstr volt
if ~isempty(poi), fn=fn(1:poi(1)-1); end
fn=[fn type];
fw=fopen([path fn],'w');
fwrite(fw,handles.header,'int8');
if upper(handles.type)~= 'WDQ' %még mindig rossz vmi (vagy ilyennek kell lennie?)
    fseek(fw,886,-1);
    maxbyte=handles.minbyte+lengt*handles.srate*handles.chnum*handles.databyte;
    fwrite(fw,maxbyte,'int32');
end
fseek(fw,-1,'eof');

%%%%%%%%%%%%%% PROCEED

indi('0 %');

for i=1:length(bb)
    indi([num2str(round((bb(i)-bb(1))/lengt*100)) ' %']);
    hand=inport(bb(i),bl(i),handles);
    data=hand.data;
    
    ldata=data*m;
    
    switch upper(handles.type)
    case {'CNT','WDQ'}
        fwrite(fw,ldata','int16');
    case 'AVG'
        fwrite(fw,ldata','float32');
    end
end
fclose(fw);

indi('del');


% --------------------------------------------------------------------
function varargout = smooth_menu_Callback(h, eventdata, handles, varargin)

if strcmp(get(h,'checked'),'on')
    set(h,'checked','off');
    t={};
    for i=1:size(handles.task,1)
        if ~strfind(handles.task{i,2},'task_smooth') %findstr volt
            t{end+1,1}=handles.task{i,1};
            t{end,2}=handles.task{i,2};
        end
    end
    handles.task=t;
    guidata(h,handles);
    return;
end

prompt  = {'Smooth [point times]',' 1: only the display; 2: the entire data'};
title   = 'Give the parameters';
lines= 1;
def     = {'5 1','1'};
answer  = inputdlg(prompt,title,lines,def);

param=str2num(answer{1});
param2=answer{2};

switch param2
case '2'
    type=['.' handles.type];
    [file,path] = uiputfile(['*' type],'Give the file name');
    if ~strcmp(file(end-3:end),type)
        file=[file type];
    end
    ft=fopen([path file],'w');
    fwrite(ft,handles.header,'int8');
    if upper(handles.type)~='WDQ'
        fseek(ft,886,-1);
        maxbyte=handles.maxsec*handles.srate*handles.chnum*handles.databyte;
        fwrite(ft,maxbyte,'int32');
    end
    fseek(ft,0,1);
    
    [beg, len, fbeg, fend]=fragment(0,handles.maxsec,handles.srate,'yes',20);
    for i=1:length(beg)
        indi([num2str(round((beg(i)-beg(1))/handles.maxsec*100)) ' %']);
        hand=inport(beg(i),len(i),handles);
        pdat=hand.data;
        for j=1:handles.chnum
            pdat(:,j)=smooth2(pdat(:,j),param(1),param(2));
        end
        dat=pdat(fbeg(i):fend(i),:);
        switch upper(handles.type)
        case {'CNT','WDQ'}
            fwrite(ft,dat','int16');
        case 'AVG'
            fwrite(ft,dat','float32');
        end
    end
    indi('del');
    fclose(ft);
case '1'
    set(h,'checked','on','userdata',param);
    handles.task(end+1,1)={'inport'};
    handles.task(end,2)={'task_smooth_in'};
    handles=task_smooth_in(handles);
    handles.task(end+1,1)={'draw'};
    handles.task(end,2)={'task_smooth_dr'};
    handles=draw(handles.data,handles);
    guidata(h,handles);
end;

% --------------------------------------------------------------------
function varargout = saveevent_menu_Callback(h, eventdata, handles, varargin)

if isempty(handles.event)
    return
end

string={'Ev2' 'Mat'};
ButtonName=questdlg('Which file type do you prefer?', ...
                       'Select the type', ...
                       'Ev2','Mat','Cancel','Ev2');    
            
if ~strcmp(ButtonName,'Cancel')
    if strcmp(ButtonName,'Mat')
        [fn, pa]=uiputfile('*_nswev.mat','Give the file name');
        poi=strfind(fn,'.'); %findstr volt
        if ~ isempty(poi), fn=fn(1:poi(1)-1); end
        if ~any(strfind(fn,'_nswev')), fn=[fn '_nswev']; end %itt is
        events=handles.event;
        save([pa fn],'events');    
    elseif strcmp(ButtonName,'Ev2')
        ev2writer(handles);
    end
end

% --------------------------------------------------------------------
function varargout = save_longevent_menu_Callback(h, eventdata, handles, varargin)

if isempty(handles.event)
    return
end

for i=1:size(handles.event,1)
    evpos(i,1)=handles.event{i,1};
end
longevent(evpos,handles.maxsec*handles.srate,'asc');

% --------------------------------------------------------------------
function varargout = loadevent_menu_Callback(h, eventdata, handles, varargin)
  
if ~isempty(handles.event)
    ButtonName=questdlg('Do you want to save the present events?', ...
                       'Select', ...
                       'Yes','No','Keep them','Yes');  
    if strcmpi(ButtonName,'YES') %strcmp volt
        saveevent_menu_Callback(h,[],handles);
    elseif isempty(ButtonName)
        return;
    end
    if ~strcmpi(ButtonName,'KEEP THEM')
        handles.event={};
    end
end

[fname, path]=uigetfile({'*.ev2', 'EV2 file; *.ev2'; ...
                '*nswev.mat', 'Eventfile saved by NSWIEW; *nswev.mat'}, 'Select the event file');

if strcmp(fname(end-2:end),'mat')
    eventvar=load([path fname]);
    if isfield(eventvar,'events')
        handles.event=[handles.event; eventvar.events];
    end
    if isfield(eventvar,'events_')
        handles.event=[handles.event; eventvar.events_];
    end
    
elseif strcmp(fname(end-2:end),'ev2')
    events_=load([path fname]);
    for i=1:size(events_,1)
        handles.event(end+1,1)={events_(i,6)};
        handles.event(end,2)={num2str(events_(i,2))};
        if strcmp(handles.event{end,2},'100')
            handles.event{end,2}='a';
        end    
    end
end

handles.evfilename=fname;
handles=draw(handles.data,handles);
guidata(h,handles);
disp(' ')
cd(path);

% --------------------------------------------------------------------
function varargout = pointdraw_menu_Callback(h, eventdata, handles, varargin)

offon={'off' 'on'};
c=strcmp(get(h,'checked'),'on');
set(h,'checked',offon{abs(c-1)+1});
handles=draw(handles.data,handles);
guidata(h,handles);

% --------------------------------------------------------------------
function varargout = eventpoint_menu_Callback(h, eventdata, handles, varargin)

ud=get(h,'userdata');
if isempty(ud)
    answer=inputdlg('On which channel do you want to indicate?','Give the parameter',1,{'self'});
    set(h,'userdata',answer{1},'checked','on');
    handles=draw(handles.data,handles);
else
    set(h,'userdata','','checked','off');
    handles=draw(handles.data,handles);
end
guidata(h,handles);

% --------------------------------------------------------------------
function varargout = variance_menu_Callback(h, eventdata, handles, varargin)

t1=round(handles.time(1)*100)/100; te=round(handles.time(end)*100)/100;
per=strfind(handles.path,'\'); %findstr volt
exp=handles.path(per(1)+1:per(2)-1);

[bm, am]=butter(8,[500/handles.srate*2 5000/handles.srate*2]); %[500/handles.srate*2 0.9999] 1024-es sr-n�l hogy is van ez???
chs=handles.page{handles.apage};
ep=filtfilt(bm,am,handles.data(:,chs));

rmsep=ep.*ep;
rmsep=mean(rmsep);
rmsep=sqrt(rmsep);

o=1;
try
    load('basevar');
catch
    o=0;
end
    

if exist('basevar')~=1 
    basevar=mean(var(ep));
end

%%%%%%%%%%%%%%%%%% RMS plot

figure
plot(rmsep,chs);
title([exp, ': ', handles.fname(1:end-4) ': ' num2str(t1) '-' num2str(te) 's RMS']);
set(gca,'ylim',[chs(1) chs(end)], ...
        'ytick',[chs(1):chs(end)], ...
        'ydir','reverse',...
        'xlim',[0 25]);
        ... 'xlim',[0 max(rmsep)]);

%%%%%%%%%%%%%%%%%% Variance plot
%
% figure
% bar(var(ep)./basevar);
% hold on
% plot([0 handles.chnum],[1 1],'k');
% plot([0 handles.chnum],[2 2],'r');
% set(gca,'xtick',[0:handles.chnum]);
% set(gcf,'numbertitle','off',...
%         'name',[num2str(t1) '-' num2str(te) ' ' handles.fname(1:end-4) ' Variance']);
% title([handles.fname(1:end-4) ': ' num2str(t1) '-' num2str(te) 's Variance / Basevariance']);

% --------------------------------------------------------------------
function varargout = skewness_menu_Callback(h, eventdata, handles, varargin)

t1=round(handles.time(1)*100)/100; te=round(handles.time(end)*100)/100;
figure
bar(skewness(handles.data));
set(gca,'xtick',[0:handles.chnum]);
set(gcf,'numbertitle','off',...
        'name',[num2str(t1) '-' num2str(te) ' ' handles.fname(1:end-4) ' Skewness']);
title([handles.fname(1:end-4) ': ' num2str(t1) '-' num2str(te) 's Skewness']);


% --------------------------------------------------------------------
function varargout = fourier_menu_Callback(h, eventdata, handles, varargin)

if strcmp(get(h,'checked'),'on')
    handles=task_menu_turn_off(h,'task_fourier',handles);
    close(handles.fourierfig)
    return;
end

prompt  = {'Which channel do you want to analyse?','Number of FFT point','Display it for every step: 1'};
title   = 'The whole window data will be analysed! Give the parameters!';
lines= 1;
def     = {'1 2 3','1024','1'};
answer  = inputdlg(prompt,title,lines,def);
ch=str2num(answer{1});
pt=str2num(answer{2});
fr=[0,70];
keep=str2num(answer{3});

if keep
    param=struct('ch',ch,'pt',pt,'fr',fr,'info',[num2str(pt),' point FFT']);
    handles=task_menu_add(h,{'draw','task_fourier'},handles,param);
    guidata(h,handles);                     
else
    [fc, f]=fourier_bas(handles.data(:,ch),pt,handles.srate);
    figure
    bar(f,fc)
end

% --------------------------------------------------------------------
function varargout = php_menu_Callback(h, eventdata, handles, varargin)

if isempty(eventdata)
    answer=inputdlg('Which channel do you want to analyse?','Give the parameter',1,{'22'});
    ch=str2num(answer{1});
    set(h,'userdata',ch);
    ph=phasespace(handles.data(:,ch),handles);
else
    dmin=eventdata;
    ch=get(h,'userdata');
    for i=1:length(dmin)
%         if handles.data(dmin(i),ch)>-500, 
            putmark(handles.figure1,{handles.time(dmin(i))*handles.srate 'p'},handles);
%         end;
    end
end
    

% --------------------------------------------------------------------
function handles=task_smooth_in(handles,trn)

handles.smoothen=0;
if ~handles.smoothen
    param=get(handles.smooth_menu,'userdata');
    chs=handles.page{handles.apage};
    for i=1:length(chs)
            handles.data(:,chs(i))=smooth2(handles.data(:,chs(i)),param(1),param(2));
    end
    handles.smoothen=1;
end


% --------------------------------------------------------------------
function handles=task_smooth_dr(handles,trn)

% if ~handles.smoothen,
%     param=get(handles.smooth_menu,'userdata');
%     chs=handles.page{handles.apage};
%     for i=1:length(chs),
%             handles.data(:,chs(i))=smooth2(handles.data(:,chs(i)),param(1),param(2));
%     end;
%     handles.smoothen=1;
% end;

% --------------------------------------------------------------------
function handles=draw(data,handles)

if strcmpi(handles.type,'ART') %strcmp(upper ... volt
    if ~isfield(handles,'amp')
        handles.amp=0.01;
    end
    set(handles.figure1,'paperpositionmode','auto')
    handles.inx1=0;
    handles.page={[1:size(data,2)]};
    handles.apage=1;
    handles.event={};
    if ~isfield(handles,'task')
        handles.task={};
    end
    handles.data=data;
end

time=[0:size(data,1)-1]./handles.srate+handles.inx1;
t0=time(1); t1=time(end);
handles.time=time;

for a=1:size(handles.task,1)
    if strcmp(handles.task{a,1},'draw')
        handles=feval(handles.task{a,2},handles,a);
    end
end
data=handles.data;

if strcmpi(handles.type,'ART')
    maxi=size(data,2);
    for a=1:maxi
        d(:,a)=data(:,a)*handles.amp+(maxi-a)*10;
    end
    data=d;
    handles.p=plot(time,data,'color','black','parent',handles.ax);
    
    set(handles.ax,'ylim',[-10 maxi*10], ...
               'ytick',[1:10:maxi*10], ...
               'yticklabel',[handles.page{handles.apage}(end:-1:1)], ...
               'xlim',[t0 t1], ...
               'xtick',[t0:(t1-t0)/10:t1], ...
               'xticklabel',round([t0:(t1-t0)/10:t1].*100)./100);
    
    guidata(handles.figure1,handles);
    return;
end


t=upper(handles.type);
if strcmp(t,'MAT')
    if strcmp(handles.type2,'avg'), t='AVG'; end
    if strcmp(handles.type2,'psth'), t='PSTH'; end
    if strcmp(handles.type2,'fft'), t='FFT'; end
end
        
switch t
case 'AVG'
    handles.figure2=figure('color','k',...
                           'units','normalized',...
                           'position',[0 0 1 0.933594], ...
                           ... 'numbertitle','off',...
                           'name',handles.fname, ...
                           'keypressfcn','nswiew(''avgamp'',gcbo,[],guidata(gcbo))',...
                           'windowbuttondownfcn', ...
                              ['h=guidata(gcbo);', ...
                               'guidata(h.figure1,h);', ...
                               'set(h.figure1,''name'',[''NSWIEW-'',h.fname])']);
    set(handles.figure1,'name','NSWIEW-AVG');    
    chs=handles.page{handles.apage};
    chn=length(chs);
    ylim=[min(min(handles.data(:,chs))) max(max(handles.data(:,chs)))];
    for i=1:chn
        a=fix(sqrt(chn)); b=ceil(chn/a);
        handles.axes(i)=subplot(a,b,i);
        handles.p(i)=plot(time,data(:,chs(i)),'g');
        set(handles.axes(i),'color','k','xcolor','w','ycolor','w',...
                          'buttondownfcn','nswiew(''singlewindow'',gcbo,[],guidata(gcbo))', ...
                          'userdata',i,...
                          'xlim',[min(time) max(time)],...
                          'ylim',ylim);
        title(num2str(chs(i)),'verticalalignment','bottom','color','w');     
    end
    handles.sw=[];
    guidata(handles.figure2,handles);
case 'FFT'
    time=handles.f(1:str2num(get(handles.wsize,'string')));
    handles.time=time;
    handles.figure2=figure('color','k',...
                           'units','normalized',...
                           'position',[0 0 1 0.933594], ...
                           ... 'numbertitle','off',...
                           'name',handles.fname, ...
                           'keypressfcn','nswiew(''avgamp'',gcbo,[],guidata(gcbo))',...
                           'windowbuttondownfcn', ...
                              ['h=guidata(gcbo);', ...
                               'guidata(h.figure1,h);', ...
                               'set(h.figure1,''name'',[''NSWIEW-'',h.fname])']);
    set(handles.figure1,'name','NSWIEW-FFT');    
    chs=handles.page{handles.apage};
    chn=length(chs);
    ylim=[min(min(handles.data(:,chs))) max(max(handles.data(:,chs)))];
    for i=1:chn
        a=fix(sqrt(chn)); b=ceil(chn/a);
        handles.axes(i)=subplot(a,b,i);
%         handles.p(i)=plot(time,data(:,chs(i)),'g');
        handles.p(i)=bar(time,data(:,chs(i)),'facecolor','g','edgecolor','none');
        set(handles.axes(i),'color','k','xcolor','w','ycolor','w',...
                          'buttondownfcn','nswiew(''singlewindow'',gcbo,[],guidata(gcbo))', ...
                          'userdata',i,...
                          'xlim',[min(time) max(time)],...
                          'ylim',ylim);
        title(num2str(chs(i)),'verticalalignment','bottom','color','w');     
    end
    handles.sw=[];
    guidata(handles.figure2,handles);    
case 'PSTH'
    handles.figure2=figure('color','k',...
                           'units','normalized',...
                           'position',[0 0 1 0.933594], ...
                           'numbertitle','off',...
                           'name',handles.fname, ...
                           'keypressfcn','nswiew(''avgamp'',gcbo,[],guidata(gcbo))',...
                           'windowbuttondownfcn','h=guidata(gcbo);guidata(h.figure1,h);');
    set(handles.figure1,'name','NSWIEW-PSTH');                       
    ylim=[min(min(handles.data)) max(max(handles.data))];
    for i=1:handles.chnum
        a=fix(sqrt(handles.chnum)); b=ceil(handles.chnum/a);
        handles.axes(i)=subplot(a,b,i);
        bar(time,data(:,i),'g');
        set(handles.axes(i),'color','k','xcolor','w','ycolor','w',...
                          'buttondownfcn','nswiew(''singlewindow'',gcbo,[],guidata(gcbo))', ...
                          'userdata',i,...
                          'xlim',[min(time) max(time)],...
                          'ylim',ylim);
        title(num2str(i),'verticalalignment','bottom','color','w');     
    end
    handles.sw=[];
    guidata(handles.figure2,handles);    
    otherwise % {'CNT','WDQ','MAT','PRN','ASC','TRC','TXT','VHDR','EDF','NS'},
    maxi=length(handles.page{handles.apage});
    for i=1:maxi
        d(:,i)=data(:,handles.page{handles.apage}(i))*handles.amp+(maxi-i)*10;
    end
    data=d;
    handles.p=plot(time,data,'color','black','parent',handles.ax);

% PLOT SPIKES ALREADY DETECTED
    if isfield(handles, 'SUAs_cluster_class')
        spk_current = handles.SUAs_cluster_class(...
                            handles.time(1)*handles.srate < handles.SUAs_cluster_class(:,2) & ...
                            handles.SUAs_cluster_class(:,2) < handles.time(end)*handles.srate,:);
        spk_inframe = [spk_current(:,1), spk_current(:,2:4) - handles.time(1)*handles.srate];
        clus_colors = [ [0.2 0.2 0.2];
                        [0.0 0.0 1.0];
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
                        [0.620690 0.758621 1.]
                        [0.5 0.5 0.5];
                        [0.5 0.5 0.5];
                        [0.5 0.5 0.5];
                        [0.5 0.5 0.5];
                        [0.5 0.5 0.5];
                        [0.5 0.5 0.5];
                        [0.5 0.5 0.5];];
         for i=1:size(spk_inframe,1)
            set(handles.figure1,'handlevisibility','on');
            hold on;
            % disp(i);
            ind_start = spk_inframe(i,2);
            ind_end = min(spk_inframe(i,4),(handles.time(end) - handles.time(1))*handles.srate);
            clus_color_actual = clus_colors(spk_inframe(i,1)+1,:);
            plot(time(ind_start:ind_end), data(ind_start:ind_end,:),...
                 'color',clus_color_actual, 'LineWidth', 2,...
                 'parent',handles.ax); 
            hold off;
            set(handles.figure1,'handlevisibility','off');
             %set(handles.p(no_plots + i),'parent',handles.ax)
         end
    end

% PLOT THRESHOLD USED FOR SPIKE-DETECTION
%     handles.thr(1).t_dp_thr = t_dp_thr; 
%     handles.thr(1).thr_step = thr_step;
%     handles.thr(1).type = par.detection;
%     handles.thr(1).ch_id = ch_id;
%     handles.thr(1).filename=fname;
%     handles.thr(1).path=path;
    if isfield(handles, 'thr')
        ch_id = handles.thr(1).ch_id;
        ind_before = find(handles.thr(1).t_dp_thr <= handles.time(1)*handles.srate, 1, 'last');
        ind_after = find(handles.time(end)*handles.srate <= handles.thr(1).t_dp_thr, 1, 'first');      
        t_dp_thr_current = handles.thr(1).t_dp_thr(ind_before:ind_after);
        t_dp_thr_current(1) = handles.time(1)*handles.srate;
        t_dp_thr_current(end) = handles.time(end)*handles.srate;
        t_dp_thr_inframe = t_dp_thr_current - handles.time(1)*handles.srate; 
        thr_step_current = handles.thr(1).thr_step(ind_before:ind_after,:);
        
        for i=1:maxi
            thr_step_inframe_pos(:,i)= thr_step_current(:,handles.page{handles.apage}(i))*handles.amp+(maxi-i)*10;
            thr_step_inframe_neg(:,i)= - thr_step_current(:,handles.page{handles.apage}(i))*handles.amp+(maxi-i)*10;
        end
        
        set(handles.figure1,'handlevisibility','on');
        hold on;
        switch handles.thr(1).type
            case 'pos'
                plot(t_dp_thr_inframe, thr_step_inframe_pos,'b-','parent',handles.ax);
            case 'neg'
                plot(t_dp_thr_inframe, thr_step_inframe_neg,'b-','parent',handles.ax);
            case 'both'
                plot(t_dp_thr_inframe, thr_step_inframe_pos,'b-','parent',handles.ax);
                plot(t_dp_thr_inframe, thr_step_inframe_neg,'b-','parent',handles.ax);
        end
        hold off;
        set(handles.figure1,'handlevisibility','off');
    end
    
    
    if strcmp(get(handles.pointdraw_menu,'checked'),'on') 
        set(handles.figure1,'handlevisibility','on');
        hold on; handles.p=plot(time,data,'.b','parent',handles.ax); hold off;
        set(handles.figure1,'handlevisibility','off');
    end
    
    set(handles.ax,'ylim',[-10 maxi*10], ...
               'ytick',[1:10:maxi*10], ...
               'yticklabel',[handles.page{handles.apage}(end:-1:1)], ...
               'xlim',[t0 t1], ...
               'xtick',[t0:(t1-t0)/10:t1], ...
               'xticklabel',round([t0:(t1-t0)/10:t1].*100)./100);
           
    if ~isempty(handles.chnames)
%         handles.chnames;
%         disp(handles.chnames);
%         cellfun('size',handles.chnames,2)
        set(handles.ax,'yticklabel',handles.chnames(handles.page{handles.apage}(end:-1:1)));
%         gg=get(handles.ax,'yticklabel');
%         cellfun('size',gg,2)
    end
    
    le=size(handles.event,1);
    b=zeros(1,le); 
    for i=1:le
        b(i)=handles.event{i,1};
    end
    inc=find(handles.time(1)*handles.srate<b & b<handles.time(end)*handles.srate);
    for i=1:length(inc)
        putmark(handles.figure1,{b(inc(i)) handles.event{inc(i),2}},handles,'exist');
    end
    drawnow
end

% --------------------------------------------------------------------
function [ch, value, inside, varargout]=mouseloc(point,handles,varargin)

% [aktual channel, value of data there, inside or nor, x-window(optional)]=mouseloc(point,handles,channel(optional))

maxi=length(handles.page{handles.apage});
ylims=get(handles.ax,'ylim');
inside=0; ch=[]; value=[]; 
if nargout>3, varargout{1}=[]; end
if handles.time(1)<point(1,1) && point(1,1)<handles.time(end) && ylims(1)<point(1,2) && point(1,2)<ylims(2) %& volt
    inside=1;
    if nargin==2
        ch=maxi-round(point(1,2)/10);
        if ch<1, ch=1; end
        if ch>maxi, ch=maxi; end
        ch=handles.page{handles.apage}(ch);
        xw=round((point(1,1)-handles.time(1))*handles.srate);
        value=handles.data(xw,ch);
        if nargout>3, varargout{1}=xw; end
    else
        ch=varargin{1};
        i=find(handles.page{handles.apage}==ch);
        if isempty(i)
            errordlg(['The selected ' num2str(ch) '.th channel is not on the screen']);
            return;
        end       
        value=(point(1,2)-(maxi-i)*10)/handles.amp;
        xw=round((point(1,1)-handles.time(1))*handles.srate);
        if nargout>3, varargout{1}=xw; end
    end
end

% --------------------------------------------------------------------
function [b, l, fb, fe]=fragment(h, begin,lengt,sr,overlap,varargin)

% gives the fragment parameters if the lengt is bigger that 10, else makes 1 fragment (the whole)
% begin lengt in seconds, sr is the sampling rate
% if overlap: between 0 and 0.5 the fraction of fragment length overlapping
%             the cut is in the middle of overlapping for output variables
% varargin{1} is the fragment-length in seconds default is 10
% Outputs:
%     b: begining of fragments in seconds at the original data
%     l: length of fragments in seconds
%     fb: final begining of the fragments w/o overlaping in data points
%     fe: final ending of the fragments w/o overlaping in data points

if nargin>5, fsec=varargin{1};
else fsec=10;
end

if isempty(overlap)
    overlap=0;
end

if overlap>0.5 || overlap<0
    return;
end

if lengt>10 && fsec<lengt    
    fn=fix(lengt/(fsec*(1-overlap)));
    if lengt-(fn*fsec*(1-overlap))<fsec*1/4
        fn=fn-1; 
    end
    b=[begin:fsec*(1-overlap):begin+(fn-1)*fsec*(1-overlap)]';
    l=ones(fn-1,1)*fsec; l(end+1)=lengt-(fn-1)*fsec*(1-overlap);
    fb=ones(fn,1)+(fsec*(overlap/2)*sr); fb(1)=1;
    fe=ones(fn,1)*fsec*(1-overlap/2)*sr; fe(end)=l(end)*sr;
else
    b=begin;
    l=lengt;
    fb=1;
    fe=lengt*sr;
end

overhalf_sec=fsec*(overlap/2);
if isfield(h,'artefact')             % Artefact detection: Artefacts are stored in handles.artefact (n) : (n+1)
    disp('2722')
    if mod(length(h.artefact),2)==0
        for art=1:2:length(h.artefact)
            fragends=b+l;
            artbegsec=h.artefact(art)/sr;
            artendsec=h.artefact(art+1)/sr;
            begfrag=find(b<=artbegsec & artbegsec<fragends);
            midfrag=find(artbegsec<b & fragends<artendsec);
            endfrag=find(b<artendsec & artendsec<=fragends);
           
            if length(begfrag)>1 || length(endfrag)>1
                split=0;
            elseif begfrag==endfrag
                split=1;
            else
                split=0;
            end
            
            begfrag=begfrag(1);
            endfrag=endfrag(end);
            
            l_begfrag=artbegsec-b(begfrag);
            fe_begfrag=l_begfrag*sr;
            b_endfrag=artendsec;
            fb_endfrag=1;
            l_endfrag=l(endfrag)-(artendsec-b(endfrag));
            if l_endfrag<=overhalf_sec
                fe_endfrag=l_endfrag*sr;
            else
                fe_endfrag=(l_endfrag-overhalf_sec)*sr;
            end
            
            if ~split
                l(begfrag)=l_begfrag;
                fe(begfrag)=fe_begfrag;
                
                b(endfrag)=b_endfrag;
                fb(endfrag)=fb_endfrag;
                l(endfrag)=l_endfrag;
                fe(endfrag)=fe_endfrag;
            else
                b= [b(1:begfrag);artendsec;b(begfrag+1:end)];
                fb=[fb(1:begfrag);1;fb(begfrag+1:end)];
                l= [l(1:begfrag-1);l_begfrag;l_endfrag;l(begfrag+1:end)];
                fe=[fe(1:begfrag-1);fe_begfrag;fe_endfrag;fe(begfrag+1:end)];
            end
             
            b(midfrag)=[];
            l(midfrag)=[];
            fb(midfrag)=[];
            fe(midfrag)=[];
        end
    end
end
short=find(l<=overhalf_sec | l<0.2);
b(short)=[];
l(short)=[];
fb(short)=[];
fe(short)=[];

fb=fix(fb);
fe=fix(fe);

% --------------------------------------------------------------------
function varargout=singlewindow(h, eventdata, handles, varargin)

swn=length(handles.sw);
pos=get(h,'position');
if pos(2)+pos(4)>0.9, pos(2)=0.8-pos(4); end
i=get(h,'userdata');
f=figure;
handles.sw(swn+1)=f;
set(f,'units','normalized',...
                        'color','k',...
                        'keypressfcn','nswiew(''avgamp'',gcbo,[],guidata(gcbo))',...
                        'position',pos,...
                        'numbertitle','off',...
                        'name',num2str(i));     
barr=0;                    
if isfield(handles,'type2')
    if strcmp(handles.type2,'fft')
        barr=1;
    end
end
if barr
    handles.swp(swn+1)=bar(handles.time,handles.data(:,i),'facecolor','g','edgecolor','none');
else
    handles.swp(swn+1)=plot(handles.time,handles.data(:,i),'g');
end
set(gca,'color','k','xcolor','w','ycolor','w',...
        'userdata',i, ...
        'xlim',[min(handles.time) max(handles.time)],...
        'ylim',get(h,'ylim'));
swh=struct('axes',gca,'chnum',1);
guidata(f,swh);
guidata(h,handles);    
guidata(handles.figure2,handles);

% --------------------------------------------------------------------
function varargout=avgamp(h, eventdata, handles, varargin)

char=get(h,'currentcharacter');
switch double(char)
case 30, m=-1;
case 31, m=1;
otherwise m=[];
end

if ~isempty(m)
    for i=1:handles.chnum
        ylim=get(handles.axes(i),'ylim');
        set(handles.axes(i),'ylim',[ylim(1)*2^m ylim(2)*2^m]);
    end
end


% --------------------------------------------------------------------
function event_plot_menu_Callback(hObject, eventdata, handles)

prompt  = {'Which channel''s event do you want to analyse?'};
title   = 'Give the parameters!';
lines= 1;
def     = {''};
answer  = inputdlg(prompt,title,lines,def);
set_treshold_plot(handles,str2num(answer{1}));


% --------------------------------------------------------------------
function phase_finder_menu_Callback(hObject, eventdata, handles)
% hObject    handle to phase_finder_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'binx1') && ~isfield(handles,'binx2') %& volt
    errordlg('There is no block specified!');
    return;
end

prompt  = {'Which channel do you want to analyse?','Which phase? (in radians bw 0 2 pi)'};
title   = 'Give the parameters!';
lines= 1;
def     = {'','0'};
answer  = inputdlg(prompt,title,lines,def);
ch=str2num(answer{1});
phase=str2num(answer{2});

begin=handles.event{handles.binx1,1}./handles.srate;
lengt=handles.event{handles.binx2,1}./handles.srate-begin;
[beg, len, fbeg, fend]=fragment(handles,begin,lengt,handles.srate,'');

for i=1:length(beg)
    hand=inport(beg(i),len(i),handles);
    data=hand.data;
    
    evs=hilb_phase(data(:,ch),phase);
    for i=1:length(evs)
        handles=putmark(hObject,{hand.inxp+evs(i)-1 num2str(ch)},handles);
    end
end


% --------------------------------------------------------------------
function aver_menu_Callback(hObject, eventdata, handles)
% hObject    handle to aver_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.event), return; end

n=size(handles.event,1);
ecs={}; list='';
for i=1:n
    if ~any(strcmp(ecs,handles.event{i,2})) && (handles.event{i,2}~='a')
        ecs(end+1)=handles.event(i,2); 
        list=[list, ', ', ecs{end}];
    end
end
list=list(3:end);

answer=inputdlg({['Which events to use for averaging?' list],'For wich channels','Lag:'},'Give the parameters',1,{'all','all',num2str(handles.srate./2)});

if isempty(answer), return; end

if strcmp('all',answer{1})
    ec=ecs;
else
    ec=wordsc(answer{1});
end
if strcmp('all',answer{2})
    el=0;
else
    el=str2num(answer{2});
end

lag=str2num(answer{3});

evpos=[]; evart=[];
for a1=1:n
    if strcmp(handles.event{a1,2},'a')
        evart(end+1)=handles.event{a1,1};
    elseif any(strcmp(handles.event{a1,2},ec))
        evpos(end+1)=handles.event{a1,1};
    end
    
end

if strcmpi(handles.type,'ASC') %strcmp(upper(handles.type),'ASC') volt
    avg=aver_asc(evpos,hObject,el,lag);
else
    [avg,used]=aver(evpos,hObject,el,lag,evart);
end

[fn, pa]=uiputfile('*_avg.mat','Give the file name');
if fn==0, return; end
poi=strfind(fn,'_avg'); %findstr volt
if ~isempty(poi), fn=fn(1:poi(1)-1); end
fn=[fn '_avg'];

save([pa fn],'avg','used')


% --------------------------------------------------------------------
function wavelet_Callback(hObject, eventdata, handles)
% hObject    handle to wavelet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% pad=1; dj=0.1; s0=2*dt; j1=10/dj; mother='Morlet'; lag1=0.72;

if strcmp(get(hObject,'checked'),'on')
    handles=task_menu_turn_off(hObject,'task_wavelet',handles);
    close(handles.wavefig)
    return;
end

if isfield(handles,'wav')
    i=num2str(handles.wav.ch);
    frb=num2str(handles.wav.frb);
    fra=num2str(handles.wav.fra);
    nf=num2str(handles.wav.nf);
else
    i='1'; frb='50'; fra='500'; nf='50';
end
dt=1./handles.srate;
prompt  = {'Which channel do you want to analyse? ','Frequency bellow',['Frequency above (sr=' num2str(1./dt) ')'],'Number of scales','Display it for every step: 1'};
titl   = 'Give the parameters';
lines= 1;
%          ch  frb fra   NF   
def     = {i,frb,fra,nf,num2str(1)};
answer  = inputdlg(prompt,titl,lines,def);

i=str2num(answer{1}); handles.wav.ch=i;
frb=str2num(answer{2}); handles.wav.frb=frb;
fra=str2num(answer{3}); handles.wav.fra=fra;
nf=str2num(answer{4}); handles.wav.nf=nf;
keep=str2num(answer{5});

if keep
    param=struct('ch',i,'frb',frb,'fra',fra,'nf',nf,'es',1,...
                 'info',['Ch: ',num2str(i),', ',num2str(frb),'-',num2str(fra),' Hz, Scalenum:',num2str(nf)]);
    handles=task_menu_add(hObject,{'draw','task_wavelet'},handles,param);                    
else
    handles=wavelet_Callback_DO(hObject,handles.wav,handles);
end

guidata(hObject,handles);
% --------------------------------------------------------------------
function handles=wavelet_Callback_DO(hObject, param, handles)

i=param.ch;
frb=param.frb;
fra=param.fra;
nf=param.nf;

% If there is any events in the window
le=size(handles.event,1);
b=zeros(1,le); 
for a=1:le
    b(a)=handles.event{a,1};
end
inc=find(handles.time(1)*handles.srate<b & b<handles.time(end)*handles.srate);
if ~isempty(inc)
    i=str2double(handles.event{inc(1),2});
end
%%%%%


newfig=0;
if ~isfield(handles,'wavefig')
    newfig=1;
elseif ~ishandle(handles.wavefig)
    newfig=1;
end

if newfig && isfield(param,'es') %& volt
    pos=get(handles.figure1,'position');
    handles.wavefig=figure(...
        'name',num2str(i),...
        'numbertitle','off',...
        'pointer','fullcrosshair',...
        'units','normalized',...
        'position',[pos(1)	0.7 pos(3) 0.25]);
    
    ax=axes('clim',[-2 2],...
            'unit','normalized',...
            'position',[0.05 0.11 0.93 0.815]);
        
    ui=uicontrol('string','Compare',...
                 'Callback','nswiew(''wav_cont_callback'',gcbo,[],guidata(gcbo))',...
                 'units','normalized',...
                 'position',[0.03 0.12 0.05 0.05]);
             
    u4=uicontrol('style','edit',...
                 'units','normalized',...
                 'position',[0.03 0.2 0.05 0.05],...
                 'Callback',...
        ['f=get(gcbo,''parent'');', ...
         'ud=get(f,''userdata'');', ...
         'h=guidata(ud.ns);',...
         'ch=str2num(get(gcbo,''string''));',...
         'h.taskparam{ud.tn}.ch=ch;', ...
         'guidata(ns,h);', ...
         'nswiew(''reload_menu_Callback'',ud.ns,[],h);', ...
         'set(f,''name'',num2str(ch))']);
     
%     u5=uicontrol('style','edit',...
%                  'units','normalized',...
%                  'position',[0.03 0.28 0.05 0.05],...
%                  'Callback',...
%         ['f=get(gcbo,''parent'');', ...
%          'ud=get(f,''userdata'');', ...
%          'h=guidata(ud.ns);',...
%          'ch=str2num(get(f,''name''));',...
%          'fs=str2num(get(gcbo,''string''));',...
%          'sound(h.data(:,ch),fs)']);
             
    u1=uicontrol('style','edit',...
                 'tag','u1',...
                 'units','normalized',...
                 'position',[0.92,0.2,0.05,0.05],...
                 'Callback', ...
        ['n=str2num(get(gcbo,''string''));', ...
         'f=get(gcbo,''parent'');', ... 
         'ud=get(f,''userdata'');', ... 
         'clim=get(ud.ax,''clim'');', ...
         'set(ud.ax,''clim'',[clim(1) n]);']);
     
    u2=uicontrol('style','edit',...
                 'tag','u2',...
                 'units','normalized',...
                 'position',[0.92,0.12,0.05,0.05], ...
                 'Callback',...
        ['n=str2num(get(gcbo,''string''));', ...
         'f=get(gcbo,''parent'');', ...
         'ud=get(f,''userdata'');', ...
         'clim=get(ud.ax,''clim'');', ...
         'set(ud.ax,''clim'',[n clim(2)]);']);
     
    
    u3=uicontrol('style','text',...
                 'string','',...
                 'units','normalized',...
                 'position',[0.92,0.28,0.05,0.05]);
             
      
    for a=1:size(handles.task,1)
        if strcmp(handles.task{a,2},'task_wavelet')
            tn=a;
        end
    end
    ud.ns=handles.figure1;
    ud.tn=tn;
    ud.ax=ax;
        
    set(gcf,'windowbuttonmotionfcn', ...
        ['u3=findobj(gcbo,''style'',''text''); ', ...
         'ax=findobj(gcbo,''type'',''axes''); ', ...
         'point=get(ax(1),''currentpoint'');', ...
         'set(u3,''string'',[num2str(fix(100./(2^point(1,2)))/100), '' Hz''])'],...
         'windowbuttondownfcn','ns_wavelet_windowbuttonmotion',...
         'userdata',ud)
    
elseif isfield(param,'es')
    set(0,'currentfigure',handles.wavefig);
    set(handles.wavefig,'name',num2str(i));
end

if isfield(param,'es')
    if i==0
        for a=1:handles.chnum
            [wave,power,period,scale,coi]=nswave_fr(handles,a,frb,fra,nf,handles.wavefig);
        end
    else
        [wave,power,period,scale,coi]=nswave_fr(handles,i,frb,fra,nf,handles.wavefig);
    end
else
    if i==0
        for a=1:handles.chnum
            [wave,power,period,scale,coi]=nswave_fr(handles,a,frb,fra,nf);
        end
    else
        [wave,power,period,scale,coi]=nswave_fr(handles,i,frb,fra,nf);
    end
    
    ui=uicontrol('string','Continue','Callback','nswiew(''wav_cont_callback'',gcbo,[],guidata(gcbo))');
end

fig=get(0,'currentfigure');
handles.wav.scale=scale; 
handles.wav.power=power;
handles.wav.wave=wave; 
handles.wav.period=period; 
handles.wav.coi=coi;
guidata(fig,handles)


function handles=wavelet_Callback_DO2(hObject, param, handles)

ch=param.ch;
frb=param.frb;
fra=param.fra;
nf=param.nf;

% If there is any events in the window
% le=size(handles.event,1);
% b=zeros(1,le); 
% for a=1:le,
%     b(a)=handles.event{a,1};
% end;
% inc=find(handles.time(1)*handles.srate<b & b<handles.time(end)*handles.srate);
% if ~isempty(inc),
%     i=str2double(handles.event{inc(1),2});
% end;
%%%%%


newfig=0;
if ~isfield(handles,'wavefig')
    newfig=1;
elseif ~ishandle(handles.wavefig)
    newfig=1;
end

if newfig && isfield(param,'es')
    pos=get(handles.figure1,'position');
    handles.wavefig=figure(...
        'name',num2str(ch),...
        'numbertitle','off',...
        'pointer','fullcrosshair',...
        'units','normalized',...
        'position',[pos(1)	0.7 pos(3) 0.25]);
    
    ax=axes('clim',[-2 2],...
            'unit','normalized',...
            'position',[0.05 0.11 0.93 0.815]);
        
    ui=uicontrol('string','Compare',...
                 'Callback','nswiew(''wav_cont_callback'',gcbo,[],guidata(gcbo))',...
                 'units','normalized',...
                 'position',[0.03 0.12 0.05 0.05]);
             
    u4=uicontrol('style','edit',...
                 'units','normalized',...
                 'position',[0.03 0.2 0.05 0.05],...
                 'Callback',...
        ['f=get(gcbo,''parent'');', ...
         'ud=get(f,''userdata'');', ...
         'h=guidata(ud.ns);',...
         'ch=str2num(get(gcbo,''string''));',...
         'h.taskparam{ud.tn}.ch=ch;', ...
         'guidata(ns,h);', ...
         'nswiew(''reload_menu_Callback'',ud.ns,[],h);', ...
         'set(f,''name'',num2str(ch))']);
     
%     u5=uicontrol('style','edit',...
%                  'units','normalized',...
%                  'position',[0.03 0.28 0.05 0.05],...
%                  'Callback',...
%         ['f=get(gcbo,''parent'');', ...
%          'ud=get(f,''userdata'');', ...
%          'h=guidata(ud.ns);',...
%          'ch=str2num(get(f,''name''));',...
%          'fs=str2num(get(gcbo,''string''));',...
%          'sound(h.data(:,ch),fs)']);
             
    u1=uicontrol('style','edit',...
                 'tag','u1',...
                 'units','normalized',...
                 'position',[0.92,0.2,0.05,0.05],...
                 'Callback', ...
        ['n=str2num(get(gcbo,''string''));', ...
         'f=get(gcbo,''parent'');', ... 
         'ud=get(f,''userdata'');', ... 
         'clim=get(ud.ax,''clim'');', ...
         'set(ud.ax,''clim'',[clim(1) n]);']);
     
    u2=uicontrol('style','edit',...
                 'tag','u2',...
                 'units','normalized',...
                 'position',[0.92,0.12,0.05,0.05], ...
                 'Callback',...
        ['n=str2num(get(gcbo,''string''));', ...
         'f=get(gcbo,''parent'');', ...
         'ud=get(f,''userdata'');', ...
         'clim=get(ud.ax,''clim'');', ...
         'set(ud.ax,''clim'',[n clim(2)]);']);
     
    
    u3=uicontrol('style','text',...
                 'string','',...
                 'units','normalized',...
                 'position',[0.92,0.28,0.05,0.05]);
             
      
    for a=1:size(handles.task,1)
        if strcmp(handles.task{a,2},'task_wavelet')
            tn=a;
        end
    end
    ud.ns=handles.figure1;
    ud.tn=tn;
    ud.ax=ax;
        
    set(gcf,'windowbuttonmotionfcn', ...
        ['u3=findobj(gcbo,''style'',''text''); ', ...
         'ax=findobj(gcbo,''type'',''axes''); ', ...
         'point=get(ax(1),''currentpoint'');', ...
         'set(u3,''string'',[num2str(fix(100./(2^point(1,2)))/100), '' Hz''])'],...
         'windowbuttondownfcn','ns_wavelet_windowbuttonmotion',...
         'userdata',ud)
    
elseif isfield(param,'es')
    set(0,'currentfigure',handles.wavefig);
    set(handles.wavefig,'name',num2str(ch));
end

if isfield(param,'es')
    if ch==0
        for a=1:handles.chnum
            [wave,power,period,scale,coi]=nswave_fr(handles,a,frb,fra,nf,handles.wavefig);
        end
    else
        [wave,power,period,scale,coi]=nswave_fr(handles,ch,frb,fra,nf,handles.wavefig);
    end
else
    if ch==0
        for a=1:handles.chnum
            [wave,power,period,scale,coi]=nswave_fr(handles,a,frb,fra,nf);
        end
    else
        [wave,power,period,scale,coi]=nswave_fr(handles,ch,frb,fra,nf);
    end
    
    ui=uicontrol('string','Continue','Callback','nswiew(''wav_cont_callback'',gcbo,[],guidata(gcbo))');
end

fig=get(0,'currentfigure');
handles.wav.scale=scale; 
handles.wav.power=power;
handles.wav.wave=wave; 
handles.wav.period=period; 
handles.wav.coi=coi;
guidata(fig,handles)

% --------------------------------------------------------------------
function wav_cont_callback(hObject, eventdata, handles)
% hObject    handle to wavelet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt  = {'Frequency bellow','Frequency above'};
titl   = 'Give the parameters';
lines= 1;
%          ch  frb fra   NF   
def     = {'',''};
answer  = inputdlg(prompt,titl,lines,def);


    ff1=str2num(answer{1}); 
    ff2=str2num(answer{2});
    fra=handles.wav.fra; frb=handles.wav.frb; nf=handles.wav.nf; scale=handles.wav.scale; 
%     wave=handles.wave; period=handles.period;
    
    fi=figure('name',['EEG powers: ',num2str(ff1),'-',num2str(ff2),' Hz'],'numbertitle','off'); hold on;
    dt=1/handles.srate; n=size(handles.data,1);
%     time=[0:n-1]*dt'; 
    time=handles.time;
    xlim=[min(time),max(time)];
    xlabel('time (s)'); ylabel('power (s^2)'); set(gca,'XLim',xlim(:))
    col=...
    [1 0 1;...
    0 1 1;...
    1 0 0;...
    0 1 0;...
    0 0 1];
    for a1=1:10
        col=[col;col.*0.9];
    end
    s0=1./fra; J1=nf-1; dj=log(1./(frb*s0))/log(2)/J1; 
    avg=(scale>=1/ff2)&(scale<1/ff1); %avg=find((scale>=1/ff2)&(scale<1/ff1)) volt
    Cdelta=0.776;
%     disp(avg); 
    
    
    for a=1:length(handles.page{handles.apage})
        ach=handles.page{handles.apage}(a);
        indi(num2str(ach))
        [wave,power,period,scale,coi]=nswave_fr(handles,ach,frb,fra,nf,0);
       
        sa=(scale')*(ones(1,n));
        sa=power./sa;   
        variance=std(handles.data(:,ach))^2;
        scaleavg=variance*dj*dt/Cdelta*sum(sa(avg,:))'; %avg = változott fent
        
        set(0,'currentfigure',fi);
        plot(time,scaleavg,'color',col(a,:),'tag',num2str(ach))
        leg{a}=num2str(ach);
    end
    legend(leg);
    indi('del')
    
        


% --------------------------------------------------------------------
function pca_menu_Callback(hObject, eventdata, handles)
% hObject    handle to pca_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'pca_figure')
    if ishandle(handles.pca_figure)
        return;
    end
end

data=handles.data(:,handles.page{handles.apage});
[pc,score,latent,tsquare]=pca(data);
percent=100*latent./sum(latent);
pca_figure=figure('menubar','none','name','Principal Componets','numbertitle','off',...
                  'position',[973   253   480   675],'resize','off');

handles.pca_figure=pca_figure;
handles.pc=pc;
handles.score=score;
handles.latent=latent;
handles.tsquare=tsquare;


n=size(pc,2);
h=2/(3*n+1);
for a=1:n
    handles.pca_check(a)=uicontrol('style','checkbox', 'units','normalized',...
                                   'position',[0.03    h/2+(3*h/2*(a-1))    0.2    h], ...
                                   'string',['Component ',num2str(a)],...
                                   'callback','nswiew(''pca_Callback'',gcbo,[],guidata(gcbo))');
    inf=uicontrol('style','text','units','normalized',...
                    'position',[0.23    h/2+(3*h/2*(a-1))    0.2    h], ...
                    'string',num2str(percent(a)));
    ed=uicontrol('style','edit','units','normalized',...
                    'position',[0.46    h/2+(3*h/2*(a-1))    0.4    h]);
end
handles.pca_reset=uicontrol('style','pushbutton', 'units','normalized',...
                            'position',[0.9    h/2    0.08    0.3], ...
                            'string',['R'], ...
                            'callback','nswiew(''pca_reset_Callback'',gcbo,[],guidata(gcbo))');

handles.olddata=handles.data;
guidata(handles.figure1,handles);
guidata(pca_figure,handles);

% --------------------------------------------------------------------
function pca_Callback(hObject, eventdata, handles)

for a=1:size(handles.pc,2)
    pcn(a)=get(handles.pca_check(a),'value');
end

s=size(handles.data(:,handles.page{handles.apage}));
data=zeros(s);
pcn=find(pcn);

for a=1:length(pcn)
    pc=handles.pc(:,pcn(a))*handles.score(:,pcn(a))';
    data=data+pc';
end

if length(handles.page{handles.apage})~=handles.chnum
    for a=1:handles.chnum
        if isempty(find(handles.page{handles.apage}==a))
            data=[data(:,1:a-1),handles.olddata(:,a),data(:,a:end)];
        end
    end
end

handles.data=data;
handles=nswiew('draw',data,handles);
guidata(handles.figure1,handles);

% --------------------------------------------------------------------
function pca_reset_Callback(hObject, eventdata, handles)

set(handles.pca_check(:),'value',0);
handles.data=handles.olddata;
handles=nswiew('draw',handles.data,handles);
guidata(handles.figure1,handles);
    


% --------------------------------------------------------------------
function avg_hist_menu_Callback(hObject, eventdata, handles)
% hObject    handle to psth_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.event), return; end

n=size(handles.event,1);
ecs={}; list='';
for i=1:n
    if ~any(strcmp(ecs,handles.event{i,2}))
        ecs(end+1)=handles.event(i,2); 
        list=[list, ', ', ecs{end}];
    end
end
list=list(3:end);

prompt={['Which events to use for averaging?' list],'For wich channels','Binsize','Bin number [before the event, after the event]'};
title='Give the parameters';
lines=1;
def={'all','all',num2str(fix(handles.srate./30)),'15 15'};
answer=inputdlg(prompt,title,lines,def);

if isempty(answer), return; end

if strcmp('all',answer{1})
    ec=ecs;
else
    ec=wordsc(answer{1});
end
if strcmp('all',answer{2})
    el=0;
else
    el=str2num(answer{2});
end

bs=str2num(answer{3});
bn=str2num(answer{4});

evpos=[];
for a1=1:n
    if all(strcmp(handles.event{a1,2},ec))
        evpos(end+1)=handles.event{a1,1};
    end
end

avg=avg_hist(evpos,hObject,el,bs,bn);

[fn, pa]=uiputfile('*_avg.mat','Give the file name');
if fn==0, return; end
poi=strfind(fn,'.'); %findstr volt
if ~isempty(poi), fn=fn(1:poi(1)-1); end
fn=[fn '_avg'];

save([pa fn],'avg')

% --------------------------------------------------------------------
function varargout=montage_alap_Callback(handles)

handles.montage=[];
handles.alapmontage=1;
if ~isfield(handles,'orig')
    handles.orig.chnum=handles.chnum;
    handles.orig.chnames(:,1)=handles.c1;
    handles.orig.chnames(:,2)=handles.c2;
end    
handles.montage(1:handles.orig.chnum,1)=1:handles.orig.chnum;
handles.montage(1:handles.orig.chnum,2)=1000;
handles.c1=handles.orig.chnames(:,1);
handles.c2=handles.orig.chnames(:,2);
handles.chnum=handles.orig.chnum;
handles.page={[1:handles.chnum]};
handles.apage=1;

if nargout
	varargout{1}=handles;
end


% --------------------------------------------------------------------
function varargout=change_montage_Callback(hObject, eventdata, handles)
% hObject    handle to change_montage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[fa, pa]=uigetfile('*.mtg','NSWIEW montage file; *.mtg');

    if fa==0
        handles=montage_alap_Callback(handles);
    else
        handles.alapmontage=0;
        [n,c1,c2]=textscan([pa fa],'%n%s%s%*[^\n]'); %textread volt
        handles.montage=zeros(length(n),2);
        for a=1:length(n)
            c1toknums=find(double(c1{a})~=32);
            c2toknums=find(double(c2{a})~=32);
            for a1=1:length(handles.orig.chnames)
                origtoknums=find(double(handles.orig.chnames{a1,1})~=32);
                if length(origtoknums)==length(c1toknums)
                    if all(upper(handles.orig.chnames{a1,1}(origtoknums))==upper(c1{a}(c1toknums)))
                        handles.montage(a,1)=a1;
                    end
                end
            end
            for a1=1:length(handles.orig.chnames)
                origtoknums=find(double(handles.orig.chnames{a1,1})~=32);
                if length(origtoknums)==length(c2toknums)
                    if all(upper(handles.orig.chnames{a1,1}(origtoknums))==upper(c2{a}(c2toknums))),
                        handles.montage(a,2)=a1;
                    end
                end
            end
            if strcmpi(c2{a}(1:2),'G2') || strcmpi(c2{a},'REF') %strcmp(upper(c2{a}),'REF') és & volt
                handles.montage(a,2)=1000;
            end
            if strcmpi(c2{a},'AVG')
                handles.montage(a,2)=1001;
            end
        end
        handles.c1=c1; handles.c2=c2;
        handles.chnum=size(handles.montage,1);
        handles.page={[1:handles.chnum]};
        handles.apage=1;
    end
    
    reload_menu_Callback(hObject,[],handles);
%     guidata(hObject,handles);
%    
%     if nargout, 
%         varargout{1}=handles;
%     end; 


% --------------------------------------------------------------------
function disc_menu_Callback(hObject, eventdata, handles)
% hObject    handle to disc_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'binx1') || ~isfield(handles,'binx2') %| volt
    errordlg('There is no block');
elseif isempty(handles.binx1) || isempty(handles.binx2)
    errordlg('There is no block');
end

handles.evonum=size(handles.event,1);

prompt={'For wich channels /The first will be the master/','Minimum distance (ms)'};
title='Give the parameters';
lines=1;
def={'2 3','10'};
answer=inputdlg(prompt,title,lines,def);

ch=str2num(answer{1});
cho=ch(2:end); chs=ch(1);
mindist=handles.srate*str2num(answer{2})/1000;
treshold=0;

beg=handles.event{handles.binx1,1}/handles.srate;
len=(handles.event{handles.binx2,1}-handles.event{handles.binx1,1})/handles.srate;
h=inport(beg,len,handles);
data=h.data(:,ch); 
me=mean(data);
data=data-me(ones(size(data,1),1),:);

n=size(data,2)-1;

maxs=max(data(:,1)); mins=min(data(:,1));
[ups, unds]=amplfind(data(:,1),[treshold treshold]);
ups=exclude_dist(ups,mindist,data(:,1),'max'); unds=exclude_dist(unds,mindist,data(:,1),'min');
ups=shiftdim(ups); unds=shiftdim(unds);
event=[ups;unds];
event=sort(event);

vs=data(event,1);
for a=1:n
    vo(:,a)=data(event,a+1);
    maxo(a)=max(data(:,a+1)); 
    mino(a)=min(data(:,a+1));
end

d_woprt.ev=event;
d_woprt.ch=chs;
d_woprt.figure=[];
d_woprt.handles=handles;

for a=1:n
    f=figure('name','discplot','numbertitle','off','pointer','fullcrosshair'); 
    plot(vs,vo(:,a),'.');
    xlabel(chs); ylabel(cho(a)); 
    hold on
    if exist('mins')
        plot(mins,mino(a),'.m','userdata','margin');
        plot(maxs,maxo(a),'.m','userdata','margin');
    end
    
    d_woprt.figure(a)=f;
    
    ui=uicontrol('string','OK',...
            'Callback',...
            ['d_woprt=get(get(gcbo,''parent''),''userdata''); ' ...
             'd_woprt.handles.evonum=size(d_woprt.handles.event,1);' ...
             'guidata(d_woprt.handles.figure1,d_woprt.handles);' ...
             'close(d_woprt.figure);']);
    pos=get(ui,'position');
    ui=uicontrol('style','toggle','string','KEEP','position',[pos(1)+pos(3)+20 pos(2:4)]);
    ui=uicontrol('style','toggle','string','EXCLUDE','position',[pos(1)+2*(pos(3)+20) pos(2:4)]);
    set(gcf,...
        'windowbuttondownfcn',...
        ['d_woprt=get(gcbo,''userdata'');' ...
         'd_woprt.evsel=eventselectRbBox(gcbo);' ...
         'handles=selectedput(d_woprt);'], ...
        'userdata',d_woprt);
%     ui=uicontrol('string',['CLUSTER'],...
%             'position',[pos(1)+3*(pos(3)+20) pos(2:4)], ...
%             'callback','cls=discrimi_cluster_callback(gcbo,d_woprt,bl);',...
%             'enable','off');
end

% figure
% 
% plot(data(:,1))
% hold
% plot(event,data(event),'.r');


% --------------------------------------------------------------------
function metasave_menu_Callback(hObject, eventdata, handles)
% hObject    handle to metasave_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fa, pa]=uiputfile('*.emf','Enchanced metafile; *.emf');

saveas(handles.figure1,[pa fa],'emf');


% --------------------------------------------------------------------
function varargout=reload_menu_Callback(hObject, eventdata, handles)
% hObject    handle to reload_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

begin=handles.inx1;
wd=str2num(get(handles.wsize,'string'));
handles=inport(begin,wd,handles); 
handles=draw(handles.data,handles);
if nargout>0
    varargout{1}=handles;
end
guidata(hObject,handles);   

if nargout
    varagout{1}=handles;
end


% --------------------------------------------------------------------
function task_menu_Callback(hObject, eventdata, handles)
% hObject    handle to task_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

f=findobj(0,'name','Tasks');
if isempty(f)
    taskeditor(hObject,handles.taskinfo);
%     figure('name','Tasks','numbertitle','off');
%     l=uicontrol('style','listbox',...
%             'units','normalized', ...
%             'position',[0.05 0.05 0.9 0.9],...
%             'string',handles.taskinfo);
else 
    set(f,'visible','on');
    l=findobj(f,'style','listbox');
    set(l,'string',handles.taskinfo);
end

% --------------------------------------------------------------------
function task_delete(hObject, v, handles)

% f=get(hObject,'parent');
% l=findobj(f,'style','listbox');
% n=get(l,'value');
% 
% t={}; ti={}; tp={};
% for i=1:size(handles.task,1),
%     if ~strcmp(handles.task{i,2},n),
%         t{end+1,1}=handles.task{i,1};
%         t{end,2}=handles.task{i,2};
%         ti{end+1}=handles.taskinfo{i};
%         tp{end+1}=handles.taskparam{i};
%     end;
% end;
% handles.task=t; handles.taskinfo=ti; handles.taskparam=tp;
% guidata(h,handles);guidata(handles.figure1,handles);
msgbox('Not implemented yet - try check off the menu');

% --------------------------------------------------------------------
function handles=task_menu_turn_off(h, eventdata, handles)
handles.checked = 'off'; %en irtam
try
    set(h,'checked','off');
catch
end
t={}; ti={}; tp={};

if ~ischar(eventdata)  % Delete a specific task  %~isstr volt
    for i=1:size(handles.task,1)
        if i~=eventdata
            t{end+1,1}=handles.task{i,1};
            t{end,2}=handles.task{i,2};
            ti{end+1}=handles.taskinfo{i};
            tp{end+1}=handles.taskparam{i};
        end
    end
else                    % Delete a task type
    for i=1:size(handles.task,1)
        if ~strcmp(handles.task{i,2},eventdata)
            t{end+1,1}=handles.task{i,1};
            t{end,2}=handles.task{i,2};
            ti{end+1}=handles.taskinfo{i};
            tp{end+1}=handles.taskparam{i};
        end
    end
end
handles.task=t; handles.taskinfo=ti; handles.taskparam=tp;

handles=reload_menu_Callback(h,'',handles);

guidata(h,handles);

% --------------------------------------------------------------------
function handles=task_add(h, eventdata, handles, param)
handles.checked = 'on'; %en irtam
try
    set(h,'checked','on')
catch
end
tn=size(handles.task,1)+1;
handles.task{tn,1}=eventdata{1};
handles.task{tn,2}=eventdata{2};
handles.taskinfo{tn}=[eventdata{2},', ',eventdata{1},', ',param.info];
handles.taskparam{tn}=param;

% --------------------------------------------------------------------
function handles=task_wavelet(handles, tasknumber)

param=handles.taskparam{tasknumber};
handles=wavelet_Callback_DO(handles.wavelet,param,handles);

% --------------------------------------------------------------------
function handles=task_menu_add(h, eventdata, handles, param)

handles=task_add(h, eventdata, handles, param);

handles=reload_menu_Callback(h,'',handles);

% --------------------------------------------------------------------
function saveblock_menu_Callback(hObject, eventdata, handles)
% hObject    handle to saveblock_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~strcmpi(handles.type,'CNT') && ~strcmpi(handles.type,'WDQ') %strcmp és & volt
    errordlg('This routine is implemented only for CNT or WDQ file!');
    return;
end

if ~isfield(handles,'binx1') || ~isfield(handles,'binx2') %| volt
    error('There is no block specified!')
else
    begin=handles.event{handles.binx1,1}./handles.srate;
    fate=handles.event{handles.binx2,1}./handles.srate;
    lengt=fate-begin;
    
end
if lengt>10
    bb=[begin:10:fate]';
    bb(end)=[];
    bl=ones(size(bb))*10;
    bl(end)=mod(lengt,10)+10;
else
    bb=begin;
    bl=lengt;
end

%%%%%%%%%%%%%% SETTING UP THE FILE

type=['.' handles.type];
[fn,path] = uiputfile(['*' type],'Give the file name');
poi=strfind(fn,'.'); %findstr volt
if ~isempty(poi), fn=fn(1:poi(1)-1); end
fn=[fn type];
fw=fopen([path fn],'w');

begpoint=handles.event{handles.binx1,1};
endpoint=handles.event{handles.binx2,1};

save(strcat(fn(1:end-4), '_kezdet_veg_pont_eredeti_cntben.mat'),'begpoint',...
    'endpoint' );

fwrite(fw,handles.header,'int8');
if upper(handles.type)~='WDQ'
    fseek(fw,886,-1);
    maxbyte=handles.minbyte+lengt*handles.srate*handles.chnum*handles.databyte;
    fwrite(fw,maxbyte,'int32');
end
fseek(fw,0,1);

%%%%%%%%%%%%%% PROCEED

indi('0 %');

for e=1:length(bb)
    indi([num2str(round((bb(e)-bb(1))/lengt*100)) ' %']);
    disp([num2str(round((bb(e)-bb(1))/lengt*100)) ' %']);
    hand=inport(bb(e),bl(e),handles);
    data=hand.data;
    
    switch upper(handles.type)
    case {'CNT','WDQ'}
        fwrite(fw,data','int16');
    case 'AVG'
        fwrite(fw,data','float32');
    end
end
fclose(fw);
indi('del')


% --------------------------------------------------------------------
function pattern_set_menu_Callback(hObject, eventdata, handles)
% hObject    handle to pattern_set_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompt  = {'Percent 1','Percent 2','Smooth [point times]','Minimum distance','Channel','Eventcharacter'};
title   = 'Give the parameters';
lines= 1;
def     = {'0.05','0.25','5 1','100','44',''};
answer  = inputdlg(prompt,title,lines,def);
param.pc1=str2num(answer{1});
param.pc2=str2num(answer{2});
param.smooth=str2num(answer{3});
param.dist=str2num(answer{4});
param.ch=str2num(answer{5});
param.ec=answer{6};
if isempty(param.ec), param.ec=[num2str(param.ch(1))]; end;

a.type=4;
a.smooth=str2num(answer{3});
a.ch=str2num(answer{5});
set(handles.box_check,'userdata',a);
set(handles.pattern_menu,'userdata',param);

set(handles.figure1,'windowbuttonupfcn','');
set(handles.figure1,'windowbuttondownfcn','nswiew(''boxdraw'',gcbo,[],guidata(gcbo))');
set(hObject,'checked','on')

% --------------------------------------------------------------------
function pattern_menu_Callback(hObject, eventdata, handles)
% hObject    handle to pattern_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

param=get(hObject,'userdata');

if isempty(param)
    errordlg('No predefined pattern','Caution');
    return;
end

if ~strcmpi(handles.type,'CNT') && ~strcmpi(handles.type,'WDQ') %strcmp és & volt
    errordlg('This routine is implemented only for CNT or WDQ file!');
    return;
end

if ~isfield(handles,'binx1') || ~isfield(handles,'binx2') %| volt
    begin=0;
    lengt=handles.maxsec;
else
    begin=handles.event{handles.binx1,1}./handles.srate;
    lengt=handles.event{handles.binx2,1}./handles.srate-begin;
end

[bb, bl]=fragment(handles,begin,lengt,handles.srate,'');

for a=1:length(bb)
    indi([num2str(round((bb(a)-bb(1))/lengt*100)) ' %']);
    hand=inport(bb(a),bl(a),handles); 
    data=hand.data;
    
    for a2=1:length(param.ch)
        c=param.ch(a2);
        pos{a2}=patternfind(data(:,c),param.pat(:,a2),param);
    end

%     for a2=1:size(pos,2),
%         % multiple channels not evaluated
%     end
    p=pos{1};    
    
    p=exclude_dist(p,param.dist,data,'max');
    
    p=fix(p);
    for a2=1:length(p)
        handles=putmark(hObject,{hand.inxp+p(a2)-1 [num2str(param.ch(1))]},handles);
    end
end
indi('del')


% --- Executes on button press in sel_do.
function sel_do_Callback(hObject, eventdata, handles)
% hObject    handle to sel_do (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(handles.sel_pop,'enable'),'off')
    set(handles.sel_pop,'enable','on');
    C_check_Callback(hObject,[],handles);
    return;
end

list=get(handles.sel_pop,'string');
v=get(handles.sel_pop,'value');
sel=list{v};

switch sel
    case 'Mark', mark_check_Callback(hObject,[],handles);
    case 'Box', box_check_Callback(hObject,[],handles);
    case 'Block', block_check_Callback(hObject,[],handles);
    case 'Pattern', pattern_menu_Callback(hObject,[],handles);
    case 'C', C_check_Callback(hObject,[],handles);
    case 'WaveletBox', WaveletBox_Callback(hObject,[],handles);
end

% --- Executes on selection change in sel_pop.
function sel_pop_Callback(hObject, eventdata, handles)
% hObject    handle to sel_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns sel_pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sel_pop


% --- Executes during object creation, after setting all properties.
function sel_pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sel_pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function cntsave_menu_Callback(hObject, eventdata, handles)
% hObject    handle to cntsave_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%%
clear strc
strc=cell(2,handles.apage);
strc(1,:)=num2cell(1:handles.apage);
for e=1:size(strc,2)
    if length(handles.page{e})==handles.chnum
        strc{2,e}='all';
    else
        st=cell2str(handles.chnames(handles.page{e}));
        st(st==',' | st==';')=[]; 
        st2=strrep(st, char(39), ' ');
        strc{2,e}= st2;
    end
end
 tr = sprintf(' %d:%s ',strc{:});
%%
prompt  = {['Which page do to save? ' tr]};
title   = 'Give the number';
lines= 1;
def     = {num2str(handles.apage)};
answer  = inputdlg(prompt,title,lines,def);
pagenum=str2double(answer{1});
%%

[fid, pa, fn]=cnt_header_ns_on_page(hObject, eventdata, handles, pagenum);   % changed on 2015.03.04 by Emilia Toth
% [fid, pa, fn]=cnt_header_ns(hObject, eventdata, handles);         % original

%%%%% PROCEED %%%%%%%%%%

[beg, len, fbeg, fend]=fragment(handles,0,handles.maxsec,handles.srate,'',20);
disp('0%');
for a=1:length(beg)
    hand=inport(beg(a),len(a),handles);
    data=int16(hand.data);
    data2=data(:,handles.page{handles.apage});              % changed on 2015.03.04 by Emilia Toth
    data3=reshape(data2',size(data2,1)*size(data2,2),1);    % changed on 2015.03.04 by Emilia Toth
%     data=reshape(data',size(data,1)*size(data,2),1);      % original

    fwrite(fid,data3,'short');                              % changed on 2015.03.04 by Emilia Toth
%     fwrite(fid,data,'short');                             % original
    disp([num2str(beg(a)+len(a)),' sec: ',num2str(round(a/length(beg)*100)) '% ']);
end

%%%%% EVENTTABLE %%%%%%%%%%
for i=1:10
    fwrite(fid,0,'short');
end

fclose(fid);
disp('Ready')


% --------------------------------------------------------------------
function go_Callback(hObject, eventdata, handles)
% hObject    handle to go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'actualtransformout')
    handles.actualtransformout=[];
end

guidata(handles.figure1,handles);

evnum=size(handles.event,1);
notselected=1;
while notselected
    gos=goselect(handles.figure1);
    waitfor(gos,'userdata');
    ud=get(gos,'userdata');
    close(gos)
    funcselect=str2num(ud.tag(3));
    if isempty(funcselect)
        actualtransformerease(handles.figure1);
        handles.actualtransformout=[];
        disp('Actualtransformerease happend')
    else
        notselected=0;
    end
end

%%%%%%%%%%%%%%%%% SET THE PARAMETERS %%%%%%%%%%%%%%%%%
switch funcselect    
    case 0
        answer  = inputdlg({'Wait (sec)'},'Give the parameters',1,{'0'});
        wait=str2num(answer{1});
    case 1
        set(handles.figure1,'keypressfcn',...
                            'set(gcbo,''userdata'',get(gcbo,''currentcharacter''))');
        acc=ones(size(handles.event,1),1);
    case 2
        if isempty(ud.rb)
            answer  = inputdlg({'Transform number'},'Give the parameters',1,{'3'});
            trn=str2num(answer{1});
        else
            trn=ud.rb;
        end
        
end

%%%%%%%%%%%%%%%%%%%%%%%% RUN %%%%%%%%%%%%%%%%%%%%%%%%%%
switch evnum         
    case 0
        handles.actualtransformout=[];
        disp('Actualtransformout is empty')
        wsize=str2num(get(handles.wsize,'string'));
        [bb, ll, fb, fe]=fragment(handles,0,handles.maxsec,handles.srate,[],wsize);
        for a=1:length(bb),
            set(handles.gostep,'string',num2str(bb(a)));
            handles=step_Callback(handles.gostep,[],handles);
            
            switch funcselect
                case 0
                    pause(wait);
                case 2
                    handles=actualtransform(handles,trn);
            end
        end
        if trn<3
            out=handles.actualtransformout;
            out=reshape(out,size(out,1)*size(out,2),1);
            handles.actualtransformout=out;
        end
    otherwise 
        for a=1:evnum
            wsize=str2num(get(handles.wsize,'string'));
            begin=handles.event{a,1}/handles.srate-wsize/2;    
            set(handles.gostep,'string',num2str(begin));    
            handles=step_Callback(handles.gostep,[],handles);
            drawnow
        
            switch funcselect
                
                case 0
                    pause(wait);
                case 1
                    waitfor(handles.figure1,'userdata')
                    switch get(handles.figure1,'currentcharacter')
                        case 'r'
                            acc(a)=0;
                            set(handles.display,'string','rejected')
                        otherwise
                            set(handles.display,'string','accepted')
                    end
                    set(handles.figure1,'userdata','idle');
                case 2
                    handles=actualtransform(handles,trn);       
            end
        end
end

%%%%%%%%%%%%%%%%%%%%%%%% POST-PROCESS %%%%%%%%%%%%%%%%%%
switch evnum
    case 0
        switch funcselect
            case 0
            case 2
                if trn<3
                    out=handles.actualtransformout;
                    out=reshape(out,size(out,1)*size(out,2),1);
                    handles.actualtransformout=out;
                end
        end
    otherwise 
        switch funcselect   
            case 0
                if isfield(handles,'fourierint')
                    for a=1:size(handles.fourierint,2)
                    figure
                    im=imagesc(handles.fourierfc(:,:,a));
                    set(im,'xdata',handles.fourierf(1,:,a))
                    set(gca,'xlim',handles.fourierlim,...
                            'clim',[0 100000]);
                    set(gcf,'pointer','fullcrosshair',...
                            'windowbuttondownfcn',...
                            ['point=get(gca,''currentpoint''); '...
                             'disp([num2str(round(point(1,2))),'': '',num2str(round(point(1,1))),'' Hz'']);']);
%                              'tx=findobj(gcbo,''style'',''text''); '...
%                              'set(tx,''string'',[num2str(point(1,1)),'' '',num2str(point(1,2))]);']);
%                     tx=uicontrol('style','text','units','normalized','position',[0.1 0.98 0.4 0.05]);     
                    end
                end
                    
            case 1
                accf=~acc; %accf=find(~acc); volt
                handles.event(accf,:)=[];
        end
end

guidata(handles.figure1,handles)


% --------------------------------------------------------------------
function baseline_menu_Callback(hObject, eventdata, handles)
% hObject    handle to baseline_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(hObject,'checked'),'on') 
    handles=task_menu_turn_off(hObject,'task_baseline',handles);
    return;
end

prompt  = {'Baseline [ms ms]'};
title   = 'Give the parameters!';
lines= 1;
def     = {'-50 -20'};
answer  = inputdlg(prompt,title,lines,def);
bl=str2num(answer{1});
if diff(bl)<1
    errordlg('Invalid parameters');
    return;
end

param=struct('bl',bl,'info',[num2str(bl),' ms']);
handles=task_menu_add(hObject,{'inport','task_baseline'},handles,param);
guidata(hObject,handles);                     

% --------------------------------------------------------------------
function handles = task_baseline(handles,tasknumber)

x=size(handles.data,1);
xm=fix(x/2);
bl=handles.taskparam{tasknumber}.bl;
blp=fix(xm+bl*(handles.srate/1000));
if blp(1)<1 || blp(2)>x %| volt
    errordlg('Baseline epoch exceeds window limits');
    handles=task_menu_turn_off(handles.baseline_menu,'task_baseline',handles);
    return;
end
bas=handles.data([blp(1):blp(2)],:);
mbas=mean(bas);
handles.data=handles.data-ones(x,1)*mbas;

% --------------------------------------------------------------------
function handles = task_lindet(handles,tasknumber)

int=handles.taskparam{tasknumber}.int;
tint=[int(1):int(2)]';
yint=handles.data(tint,:);
tdata=[1:size(handles.data,1)];
X=[ones(length(tint),1),tint];
for a=1:handles.chnum
    coeff=X\yint(:,a);
    corr=-1*(coeff(2)*tdata+coeff(1));
    handles.data(:,a)=handles.data(:,a)+corr';
end

% --------------------------------------------------------------------
function handles = task_down(handles,tasknumber)

handles.data=handles.data*-1;


% --------------------------------------------------------------------
function lindet_menu_Callback(hObject, eventdata, handles)
% hObject    handle to lindet_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(hObject,'checked'),'on')
    handles=task_menu_turn_off(hObject,'task_lindet',handles);
    return;
end

prompt  = {'Interval [ms ms] /entire/'};
title   = 'Give the parameters!';
lines= 1;
def     = {'entire'};
answer  = inputdlg(prompt,title,lines,def);
x=size(handles.data,1);
xm=fix(x/2);
if strcmp(answer{1},'entire')
    int=[1 x];
    intms=fix([-xm xm]/(handles.srate/1000));
else
    intms=str2num(answer{1});
    int=fix(xm+intms*(handles.srate/1000));
end

param=struct('int',int,'info',[num2str(intms),' ms']);
handles=task_menu_add(hObject,{'inport','task_lindet'},handles,param);
guidata(hObject,handles);


% --- Executes on button press in updown_txt_pb.
function updown_pb_Callback(hObject, eventdata, handles)
% hObject    handle to updown_txt_pb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(handles.updown_txt,'string'),'up')
    param=struct('info','');
    handles=task_menu_add(hObject,{'inport','task_down'},handles,param);
    set(handles.updown_txt,'string','dwn');
else
    handles=task_menu_turn_off(hObject,'task_down',handles);
    set(handles.updown_txt,'string','up');
end


% --------------------------------------------------------------------
function readrej_menu_Callback(hObject, eventdata, handles)
% hObject    handle to readrej_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fname, path]=uigetfile({'*.dat', 'REJ file *REJ.dat'},'Select the data file');
rej=load([path fname]);
del=~rej; %del=find(~rej); volt

handles.event(del,:)=[];
guidata(hObject,handles);


% --------------------------------------------------------------------
function saveavg_Callback(hObject, eventdata, handles)
% hObject    handle to saveavg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

outavg.data=handles.data;
xdatamax=size(handles.data,1);
tdata=([1:xdatamax]-xdatamax/2)/(handles.srate/1000);

outavg.tdata=tdata;
outavg.srate=handles.srate;
outavg.event=handles.avgevent;
if isfield(handles,'nsweeps')
    outavg.evnum=handles.nsweeps;
end

[fname, path]=uiputfile('*_avg.mat');
save([path fname],'outavg');


% --------------------------------------------------------------------
function sound_menu_Callback(hObject, eventdata, handles)
% hObject    handle to sound_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 plays=play_sound_ns(handles.figure1);


% --------------------------------------------------------------------
function stimcut_Callback(hObject, eventdata, handles)
% hObject    handle to stimcut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(get(hObject,'checked'),'on')
    handles=task_menu_turn_off(hObject,'task_stimcut',handles);
    return;
end

prompt={'EP /position (ms) beg end/'};
name='Stim art. cut';
numlines=1;
defaultanswer={''};
answer=inputdlg(prompt,name,numlines,defaultanswer);
   
if ~isempty(answer{1})
	eppos=str2num(answer{1});
else
	eppos=0;
end

param=struct('eppos',eppos,'info',['eventpos.: ',num2str(eppos)]);

handles=task_menu_add(hObject,{'inport','task_stimcut'},handles,param);                    

guidata(hObject,handles);

% --------------------------------------------------------------------
function handles = task_stimcut(handles,tasknumber)

% eppos=handles.taskparam{tasknumber}.eppos;
% xdatamax=size(handles.data,1);
% wbeg=handles.inxp;
% wend=handles.inxp+xdatamax;
% p1=handles.event{x,1}+eppos(1)*handles.srate/1000;
% p2=hsndles.event{x,1}+eppos(2)*handles.srate/1000;
% x=1:xdatamax;
% xx=x;
% int=[p1:p2];
% x(int)=[];
% for a=1:handles.chnum,
% 	y=handles.data(x,a);
% 	handles.data(:,a)=spline(x,y,xx);
% end;

eppos=handles.taskparam{tasknumber}.eppos;
xdatamax=size(handles.data,1);
wbeg=handles.inxp;
wend=handles.inxp+xdatamax;
    
for o=1:length(handles.event(:,1))
    o;
    ev=handles.event{o,1};
    if wbeg<=ev && ev<=wend %& volt
        pos1=ev+eppos(1)*handles.srate/1000-wbeg;
        pos2=ev+eppos(2)*handles.srate/1000-wbeg;
    
        x=1:xdatamax;
        xx=x;
        int=[pos1:pos2];
        x(int)=[];
        for a=1:handles.chnum
            y=handles.data(x,a);
            handles.data(:,a)=spline(x,y,xx);
        end
    end
end

% --- Executes on button press in cntmv.
function cntmv_Callback(hObject, eventdata, h)
% hObject    handle to cntmv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cntmv

if get(hObject,'value')==0
   h.cnt_mv=0;
   h=rmfield(h,'orig');
   h=reload_menu_Callback(hObject,[],h);
   guidata(hObject,h);
   return;
end

prompt={'TYPE: 1-Ulbi EEG; 2-Ulbi Unit; 3-Custom'};
name='Give the conversion type';
numlines=1;
defaultanswer={'1'};
answer=inputdlg(prompt,name,numlines,defaultanswer);

type=str2num(answer{1});

h.cnt_mv=1;

switch type
    case 1
        h.orig.logic_min=-32768;
        h.orig.logic_max=32768;
        h.orig.logic_gnd=0;
        h.orig.physic_max=1024;
        h.orig.physic_min=-1024;
        set(h.apl,'string','0.1');
        h.amp=0.2;
    case 2
        h.orig.logic_min=-2048;
        h.orig.logic_max=2048;
        h.orig.logic_gnd=0;
        h.orig.physic_max=256;
        h.orig.physic_min=-256;
    otherwise 3
        prompt={'logic_min','logic_max','logic_gnd','physic_max','physic_min'};
        name='Give the parameters';
        numlines=1;
        defaultanswer={'0','0','0','1','0'};
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        h.orig.logic_min=str2num(answer{1});
        h.orig.logic_max=str2num(answer{2});
        h.orig.logic_gnd=str2num(answer{3});
        h.orig.physic_max=str2num(answer{4});
        h.orig.physic_min=str2num(answer{5});
end

set(h.ap,'string',num2str(h.amp));
h=reload_menu_Callback(hObject,[],h);

guidata(hObject,h)

%========================= SD CALC ============================
% --------------------------------------------------------------------
function varargout=sdcalc_Callback(hObject, eventdata, h)
% hObject    handle to sdcalc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
%     XXX: empty, rms, rect
% sum XXX mean_matr: local means of fragments
% sum XXX sd_matr: local SD of fragments
% sum XXX mean: global mean
% sum XXX sd: global SD
% szurt adatbol is szamol
% M�dos�tva 2015.05.22.-�n T�th Em�lia 
if isempty(eventdata)
    prompt={'Filter frequency','RMS window size (ms)','File fragment size (sec)'};
    name='SD Calc';                         
    numlines=1;
    defaultanswer={'80 500','3','50'};
    answer=inputdlg(prompt,name,numlines,defaultanswer);

    fr=str2num(answer{1});
    rmsms=str2num(answer{2});
    filefrag=str2num(answer{3});
else
    fr=h.sd.info.fr;
    rmsms=h.sd.info.rmsms;
    filefrag=h.sd.info.filefrag;
end

if ~isempty(fr)
    [cc, aa]=butter(2,[fr(1)/h.srate*2 fr(2)/h.srate*2], 'bandpass');
else
    cc=[];
    aa=[];
end

[bb,bl,fb,fe]=fragment2(h,0,h.maxsec,h.srate,0,filefrag);

chnum=h.chnum;
%%   MEAN
disp('MEAN & SD')    
summean=zeros(length(bb),chnum);
sumdata=zeros(length(bb),chnum);
rmsmean=zeros(length(bb),chnum);
sumrms=zeros(length(bb),chnum);
rectmean=zeros(length(bb),chnum);
sumrect=zeros(length(bb),chnum);
% sd2=zeros(length(bb),chnum);
% rmssd2=zeros(length(bb),chnum);
% rectsd2=zeros(length(bb),chnum);
vard=zeros(length(bb),chnum);
rectvar=zeros(length(bb),chnum);
rmsvar=zeros(length(bb),chnum);
n=zeros(length(bb), 1);
for a=1:length(bb)
    if a==1
        time1=cputime;
    end
    disp([num2str(a) '/' num2str(length(bb))]);
    hand=inport(bb(a),bl(a),h);
    data=hand.data;
    if fix(size(data,1))~=fix(bl(a)*h.srate)
        fprintf('Data: %d, Bl: %d \n',fix(size(data,1)),fix(bl(a)*h.srate))
    end
    n(a)=size(data,1);
    if ~isempty(fr)
        fdata=filtfilt(cc,aa,data);
    end
    summean(a,:)=mean(fdata);
    sumdata(a,:)=sum(fdata);
%     sd2(a,:)=std(fdata);
    vard(a,:)=variance(fdata);
    
    rmsdata=rms(fdata,fix(rmsms*h.srate/1000));
    rmsmean(a,:)=mean(rmsdata);
    sumrms(a,:)=sum(rmsdata);
%     rmssd2(a,:)=std(rmsdata);
    rmsvar(a,:)=variance(rmsdata);
    
    rectdata=abs(fdata);
    rectmean(a,:)=mean(rectdata);
    sumrect(a,:)=sum(rectdata);
%     rectsd2(a,:)=std(rectdata);
    rectvar(a,:)=variance(rectdata);
    if a==1
        time2=cputime;
        disp([ 'the sd calculation will take approx.' num2str(length(bb)*(time2-time1)) 's']);
    end
end
N=sum(n);
ni=repmat(n,1, h.chnum);
meand=sum(summean.*ni/N);
meanrect=sum(rectmean.*ni/N);
meanrms=sum(rmsmean.*ni/N);
meandm=repmat(meand,length(bb),1);
meanrectm=repmat(meanrect,length(bb),1);
meanrmsm=repmat(meanrms,length(bb),1);

meandif=sum((summean-meandm).^2.*ni);
meanrectdif=sum((rectmean-meanrectm).^2.*ni);
meanrmsdif=sum((rmsmean-meanrmsm).^2.*ni);

stddata=sqrt((sum(vard)+meandif)/(N-1));
stdrect=sqrt((sum(rectvar)+meanrectdif)/(N-1));
stdrms=sqrt((sum(rmsvar)+meanrmsdif)/(N-1));

h.sd.sumsd=stddata;
h.sd.sumrmssd=stdrms;
h.sd.sumrectsd=stdrect;
h.sd.summean=meand; %% meandm
h.sd.sumrmsmean=meanrms; %% meanrmsm
h.sd.sumrectmean=meanrect; %% meanrectm
h.sd.info.fr=fr;
h.sd.info.rmsms=rmsms;
h.sd.info.filefrag=filefrag;

if nargout>0
    varargout{1}=h;
else
    guidata(h.figure1,h);
end

disp('Ready summean, RMS SD, RECT SD')

% --------------------------------------------------------------------
function h=rippdetect_paramsedit(hObject, h)

if ~isfield(h,'event')
    defans2='0';
elseif isempty(h.event)
    defans2='0';
else
    defans2='500';
end

prompt={'Method','Apply to events? /0: No, Lag in ms: Yes/','Plot /y,n/'};
name='Ripple detector';                                                
numlines=1;
defaultanswer={'3',defans2,'n'};
answer=inputdlg(prompt,name,numlines,defaultanswer);

meth=str2num(answer{1});
plotswitch=answer{3};

% meth=3;
% plotswitch='n';

h.ripple.meth=meth;
h.ripple.plotswitch=plotswitch;
h.ripple.toevents=str2num(answer{2});

switch meth
    case 1
        errordlg('Not implemented');
        return;
    case 2
        prompt={'Channel','Frequency','SD limit','Cycle limit'};
        name='Ripple detector';                          
        numlines=1;
        defaultanswer={'45','19 25','5','3'};
        answer=inputdlg(prompt,name,numlines,defaultanswer);

        if isempty(answer)
            return;
        end

        ch=str2num(answer{1});
        fr=str2num(answer{2});
        sdlimit=str2num(answer{3});
        cyclelimit=str2num(answer{4});

        tit=['Method: M2; Filter: ',num2str(fr),' Hz, Minimum full cycle: ',num2str(cyclelimit),', Amplitude treshold: ',num2str(sdlimit),'  STD'];
        
        h.ripple.tit=tit;
        h.ripple.ch=ch;
        h.ripple.fr=fr;
        h.ripple.sdlimit=sdlimit;
        h.ripple.cyclelimit=cyclelimit;
    case 3
        prompt={...
            'Channel',... 1
            'Frequency',... 2
            'RMS SD limit', ... 3
            'Full cycle limit', ... 4
            'RMS window size', ... 5
            'Rect. SD limit',... 6
            'Ripple time limit (ms)', ... 7
            'Between ripple limit (ms)', ... 8
            ['Fragment size /',num2str(h.maxsec),' sec max/'], ... 9
            'Overlap (0-0.5)' ... 10
            };
        name='Ripple detector';                                               
        numlines=1;
        defaultanswer={'47', ... 1
                       '80 500', ... 2
                       '5', ... 3
                       '3', ... 4
                       '3', ... 5
                       '3', ... 6 
                       '6', ... 7
                       '10', ... 8
                       '50' ... 9
                       '0.001', ... 10
                       };
        answer=inputdlg(prompt,name,numlines,defaultanswer);

        if isempty(answer)
            return;
        end

        ch=str2num(answer{1});
        fr=str2num(answer{2});
        rmssdlimit=str2num(answer{3});
        cyclelimit=str2num(answer{4});
        rmsms=str2num(answer{5});
        rectsdlimit=str2num(answer{6});
        timelimit=str2num(answer{7});
        betweenlimit=str2num(answer{8});
        fragmentsize=str2num(answer{9});
        overlap=str2num(answer{10});
        if ~overlap
            overlap=[]; 
        end
        tit=['Method: M3; Filter: ',num2str(fr),' Hz, Minimum full cycle: ',num2str(cyclelimit),', RMS SD limit treshold: ',num2str(rmssdlimit),'  STD; RMS window: ',num2str(rmsms),'; Rect sd limit: ',num2str(rectsdlimit)];

        h.ripple.tit=tit;
        h.ripple.ch=ch;
        h.ripple.fr=fr;
        h.ripple.rmssdlimit=rmssdlimit;
        h.ripple.cyclelimit=cyclelimit;
        h.ripple.rmsms=rmsms;
        h.ripple.rectsdlimit=rectsdlimit;
        h.ripple.timelimit=timelimit;
        h.ripple.betweenlimit=betweenlimit;
        h.ripple.fragmentsize=fragmentsize;
        h.ripple.overlap=overlap;
    case 4
        prompt={...
            'Channel',... 1
            'Frequency',... 2
            'Full cycle limit', ... 3
            'Ripple window length (ms)', ... 4
            ['Fragment size /',num2str(h.maxsec),' sec max/'], ... 5
            };
        name='Ripple detector M4';                                               
        numlines=1;
        defaultanswer={'47', ... 1
                       '80 500', ... 2
                       '3', ... 3
                       '50' ... 4
                       '50' ... 5
                       };
        answer=inputdlg(prompt,name,numlines,defaultanswer);

        if isempty(answer)
            return;
        end

        ch=str2num(answer{1});
        fr=str2num(answer{2});
        cyclelimit=str2num(answer{3});
        shortwin=str2num(answer{3});
        fragmentsize=str2num(answer{5});
        overlap=0.3/fragmentsize;
        tit=['Method: M4; Filter: ',num2str(fr),' Hz, Minimum full cycle: ',num2str(cyclelimit),];

        h.ripple.tit=tit;
        h.ripple.ch=ch;
        h.ripple.fr=fr;
        h.ripple.cyclelimit=cyclelimit;
        h.ripple.shortwin=shortwin;
        h.ripple.fragmentsize=fragmentsize;
        h.ripple.overlap=overlap;
end

h.ripple.sd=h.sd;

h.ripple.databegs=0;
h.ripple.datalength=h.maxsec;

% --------------------------------------------------------------------
function [rk1,ripdata]=rippdetect_transform(hand, h, ch)

switch h.ripple.meth                   % Transform
    case 1
        return;
    case 2
        [rk1,ripdata]=feval(@ripple_m2,hand.data(:,ch),hand.srate,h.ripple.fr,h.ripple.rmssdlimit,h.ripple.cyclelimit,hand.sumsd(ch));
    case 3
            [rk1,ripdata]=feval(@ripple_m3, ...
                hand.data(:,ch), ... 0
                hand.srate, ... 1
                h.ripple.fr, ... 2
                h.ripple.rmsms, ... 3
                h.ripple.rmssdlimit, ... 4
                h.ripple.rectsdlimit, ... 5
                h.ripple.cyclelimit, ... 6
                h.ripple.timelimit, ... 7
                h.ripple.betweenlimit, ... 8
                hand.sd.sumrmssd(ch), ... 9
                hand.sd.sumrmsmean(ch), ... 10
                hand.sd.sumrectsd(ch), ... 11
                hand.sd.sumrectmean(ch), ... 12
                hand.inxp, ... 13  
                0 ...          14
                );
    case 4
        [rk1,ripdata]=feval(@ripple_m4, ...
            hand.data(:,ch), ... 0
            hand.srate, ... 1
            h.ripple.fr, ... 2
            hand.sd.peaktres(ch), ... 3
            h.ripple.cyclelimit, ... 4
            h.ripple.shortwin, ... 5
            hand.inxp, ... 6              
            0 ...   7
            );        
end
        
% --------------------------------------------------------------------
function varargout=rippdetect_Callback(hObject, eventdata, h)
% hObject    handle to rippdetect (see GCBO)
% eventdata  : contain the channel to analyse for auto ripple call
%              this type of call needs prior parametered call 
%              the parameters stored in handles.ripple is used
% handles    structure with handles and user data (see GUIDATA)


if isempty (eventdata)            % Parameter and variable setting
%     disp('paramsedit')
    h=rippdetect_paramsedit(hObject, h); %ez akkor fut le, ha az eventdata �res, vagyis, ha nem adjuk be neki a param�tereket
else
    h.ripple.toevents=0; %%%%% Ez MI??????? %én sem tudom :D
end

chnum=length(h.ripple.ch);

rk=cell(chnum,1); 
rippbeg=cell(chnum,1);
rippend=cell(chnum,1);
peaknum=cell(chnum,1);
amplitude=cell(chnum,1);
duration=cell(chnum,1);
putripborders=cell(chnum,1);
putripdata=cell(chnum,1); putripfdata=cell(chnum,1); putriprmsfdata=cell(chnum,1); putriprectfdata=cell(chnum,1);
putripmaxsrms=cell(chnum,1); putripmaxsrect=cell(chnum,1); putrippeaks=cell(chnum,1); putriptroughs=cell(chnum,1);
followup=cell(chnum,1);
freq=cell(chnum,1);

ripple_bad=[];
rmslimit=cell(chnum,1); 
fdata=[];

if h.ripple.toevents==0
    [cc, aa]=butter(2,[h.ripple.fr(1)/h.srate*2 h.ripple.fr(2)/h.srate*2], 'bandpass'); % Filter setting

    [bb,bl,fb,fe]=fragment2(h, ... % creating data points for fragment lengths
                           h.ripple.databegs, ... 
                           h.ripple.datalength, ...
                           h.srate, ...
                           h.ripple.overlap, ...
                           h.ripple.fragmentsize); 
else
    lagp=h.ripple.toevents*h.srate/1000;
    lagsec=h.ripple.toevents/1000;
    evnum=size(h.event,1);
    for a=1:evnum
        bb(a,1)=h.event{a,1}/h.srate-lagsec;
    end
    bl=ones(evnum,1)*lagsec*2;
    fb=ones(evnum,1);
    fe=ones(evnum,1)*lagp*2;
end
                   
out=zeros(size(h.ripple.rmssdlimit,2),size(h.ripple.cyclelimit,2),size(h.ripple.ch,2));
for a=1:length(bb)         %   Cycle through fragments
    if a==1
        time1=cputime;
    end
    disp(' ')
    fprintf('Fragment %d of %d: Channel ',[a, length(bb)]);
    
    hand=inport(bb(a),bl(a),h);     % Inport data
%     plot(hand.data(:,24))
    for b=1:chnum    % Cycle through channels
        if b==1
            time1b=cputime;
        end
        ch=h.ripple.ch(b);
        fprintf('%d ',ch)
        for tres=1:length(h.ripple.rmssdlimit)
            for cyc=1:length(h.ripple.cyclelimit)
                % A sokf�le iz�re nincs az �rt�kek elment�se megcsin�lva
                % !!
                h.ripple.rmssdlimit=h.ripple.rmssdlimit(tres);
                h.ripple.cyclelimit=h.ripple.cyclelimit(cyc);
%                 [rk1,ripdata]=rippdetect_transform(hand, h, ch);        % TRANSFORM LINE
                [rk1,ripdata, bck]=rippdetect_transform(hand, h, ch);   
%                 [rk1,ripdata]=feval(@ripple_m3, ...
%                     hand.data(:,ch), ... 0
%                     hand.srate, ... 1
%                     h.ripple.fr, ... 2
%                     h.ripple.rmsms, ... 3
%                     h.ripple.rmssdlimit(tres), ... 4
%                     h.ripple.rectsdlimit, ... 5
%                     h.ripple.cyclelimit(cyc), ... 6
%                     h.ripple.timelimit, ... 7
%                     h.ripple.betweenlimit, ... 8
%                     hand.sd.sumrmssd(ch), ... 9
%                     hand.sd.sumrmsmean(ch), ... 10
%                     hand.sd.sumrectsd(ch), ... 11
%                     hand.sd.sumrectmean(ch), ... 12
%                     hand.inxp ... 13                
%                     );

                rippbeg1=ripdata.rippbeg+hand.inxp;       % extracting the output variables
                rk1=rk1+hand.inxp;
                rippend1=ripdata.rippend+hand.inxp;
                peaknum1=ripdata.peaknum';
                putripborders1=ripdata.putripples+hand.inxp;
%                 rippbeg1=ripdata.rippbeg;       % extracting the output variables
%                 rk1=rk1+hand.inxp;
%                 rippend1=ripdata.rippend;
%                 peaknum1=ripdata.peaknum';
%                 putripborders1=ripdata.putripples;

                infragment_final=find(fb(a)<=rippbeg1 & rippbeg1<=fe(a));  % find fragment borders
                rippbeg1=rippbeg1(infragment_final);
                rippend1=rippend1(infragment_final);
                peaknum1=peaknum1(infragment_final);
                rk1=rk1(infragment_final);

                if size(putripborders1)~=0
                    infragment_putrip=find(fb(a)<=putripborders1(:,1) & putripborders1(:,1)<=fe(a));
                    prb1=putripborders1(infragment_putrip,:);
                    putripborders1=prb1;
                    putripdata1=bckdel(bck, infragment_putrip);
                end

                followup{b}=[followup{b}; ripdata.followup.ripples];
%                 putripborders{b}=[putripborders{b}; putripborders1+hand.inxp]; %%hand.inxp itt adja hozz� a kezd� indexeket !!!
                putripborders{b}=[putripborders{b}; putripborders1]; %%hand.inxp itt adja hozz� a kezd� indexeket !!!
                %%% 
                putripdata{b}=[ putripdata{b}; putripdata1.data];
%                 putripfdata{b}=[ putripfdata{b}; putripdata1.fdata];
%                 putriprmsfdata{b}=[ putriprmsfdata{b}; putripdata1.rmsfdata];
%                 putriprectfdata{b}=[ putriprectfdata{b}; putripdata1.rectfdata];
%                 putripmaxsrms{b}=[ putripmaxsrms{b}; putripdata1.maxsrms];
%                 putripmaxsrect{b}=[ putripmaxsrect{b}; putripdata1.maxsrect];
%                 putrippeaks{b}=[ putrippeaks{b}; putripdata1.peaks];
%                 putriptroughs{b}=[ putriptroughs{b}; putripdata1.troughs];
%                 
                if size(rk1,1)~=0
%                     rk{b}=[rk{b}; rk1+hand.inxp];               %% hand.inxp itt adja hozz� a kezd� indexeket !!!
                    rk{b}=[rk{b}; rk1];               %% hand.inxp itt adja hozz� a kezd� indexeket !!!
%                     rippbeg{b}=[rippbeg{b}; rippbeg1+hand.inxp]; %% hand.inxp adja hozz� a kezd� indexeket !!!
                    rippbeg{b}=[rippbeg{b}; rippbeg1]; %% hand.inxp adja hozz� a kezd� indexeket !!!
%                     rippend{b}=[rippend{b}; rippend1+hand.inxp]; %% hand.inxp itt adja hozz� a kezd� indexeket !!!
                    rippend{b}=[rippend{b}; rippend1]; %% hand.inxp itt adja hozz� a kezd� indexeket !!!
                    peaknum{b}=[peaknum{b}; peaknum1];
                    amplitude{b}=[amplitude{b}; ripdata.amplitude];
                    duration{b}=[duration{b}; ripdata.duration];
                    out(tres,cyc,b)=out(tres,cyc,b)+size(rk1,1);
                end   
                h.ripple.out=out;
                guidata(hObject,h)
            end
        end
            if b==1
                time1bend=cputime;
            end
    end
    [rk{b}, order]=sort(rk{b});          % if there are overlaping might be jumps in the order
    rippbeg{b}=rippbeg{b}(order);
    rippend{b}=rippend{b}(order);
    peaknum{b}=peaknum{b}(order);
end
disp(['ripple detection time elapse:' ((time1bend-time1b)+(time1b-time1))*length(bb)])
h.ripple.out=out;
guidata(hObject,h)

if isfield(ripdata,'rmslimit')
    rmslimit=ripdata.rmslimit;
end

disp(' '); disp(' ');

for b=1:chnum
    betw=diff(rk{b});                   % deleting close events again (Double detection due to overlap)
    short=find(betw<h.ripple.betweenlimit)+1;
    
    rk{b}(short)=[];
    rippbeg{b}(short)=[];
    rippend{b}(short)=[];
    peaknum{b}(short)=[];
    
    % Frequency calculation   
    rippint=rippend{b}-rippbeg{b};
    rippintsec=rippint./h.srate;
%     freq{b}=round(peaknum{b}./rippintsec);
    freq{b}=round((peaknum{b}/2)./rippintsec);
    
    % Display
    rippnum{b}=length(rk{b});
    putrippnum=sum(followup{b}(:,1));
    ch=h.ripple.ch(b);
    fprintf('On channel %d: Found %d ripples out of %d peeks over the RMS limit. \n', ...
            [ch,rippnum{b},putrippnum]); 
end
              
% fprintf('RMS limit out: %4.2f;  RMS limit in: %d; Cycle limit: %d; RECT SD limit: %d \n', ...
%         [rmslimit, h.ripple.rmssdlimit, h.ripple.cyclelimit, h.ripple.rectsdlimit]);

if isempty(eventdata)           % Put marks
    for ch=1:length(h.ripple.ch)
        for a=1:length(rk{ch})
            h=putmark(hObject,{rk{ch}(a) ['2_' num2str(h.ripple.ch(ch))]},h);
    %         h=putmark(hObject,{rippbeg(a) ['1_' num2str(ch)]},h);
    %         h=putmark(hObject,{rippend(a) ['3_' num2str(ch)]},h);
        end
    end
end

% if upper(plotswitch)=='Y',
%     h.ripple.fdata=fdata;
%     ripplot_Callback(hObject, eventdata, h);
% end

h.ripple.rk=rk;
h.ripple.rippbeg=rippbeg;
h.ripple.rippend=rippend;
h.ripple.peaknum=peaknum;
h.ripple.amplitude=amplitude;
h.ripple.duration=duration;
h.ripple.freq=freq;
h.ripple.rippnum=rippnum;
h.ripple.followup=followup;
h.ripple.putripborders=putripborders;
h.ripple.out=out;
guidata(hObject,h);

if exist('putripdata')==1
    save([h.file(1:end-4) '_putripdata'],'putripdata', 'putripfdata', 'putriprmsfdata', 'putriprectfdata', 'putripmaxsrms', 'putripmaxsrect', 'putrippeaks', 'putriptroughs');
end

if nargout>0
    varargout{1}=h;
else
     guidata(h.figure1,h);
end

% --------------------------------------------------------------------
function sdsave_Callback(hObject, eventdata, handles)
% hObject    handle to sdsave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fn, pa]=uiputfile('*.mat','Give the file name');

% m=handles.sd.summean;
% s=handles.sd.sumsd;
% rm=handles.sd.sumrmsmean;
% rs=handles.sd.sumrmssd;
% rectm=handles.sd.sumrectmean;
% rects=handles.sd.sumrectsd;
% 
% m_ma=handles.sd.summean_matr;
% s_ma=handles.sd.sumsd_matr;
% rm_ma=handles.sd.sumrmsmean_matr;
% rs_ma=handles.sd.sumrmssd_matr;
% rectm_ma=handles.sd.sumrectmean_matr;
% rects_ma=handles.sd.sumrectsd_matr;
% save([pa fn],'m','s','rm','rs','rectm','rects','m_ma','s_ma','rm_ma','rs_ma','rectm_ma','rects_ma');

sd=handles.sd;
save([pa fn],'sd');
% --------------------------------------------------------------------
function sdload_Callback(hObject, eventdata, handles)
% hObject    handle to sdload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fn, pa]=uigetfile({'*.mat', 'MAT file *.mat'},'Select the data file');
load([pa fn]);

if exist('m')==1
    handles.sd.summean=m;
    handles.sd.sumsd=s;   
    handles.sd.sumrmsmean=rm;
    handles.sd.sumrmssd=rs;
    handles.sd.sumrectmean=rectm;
    handles.sd.sumrectsd=rects;
else
    handles.sd=sd;
end
guidata(hObject,handles);

% --------------------------------------------------------------------
function ripplot_Callback(hObject, eventdata, h)
% hObject    handle to ripplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ms=20;
time=[0:length(h.ripple.fdata)-1]/h.srate; 
figure     % visualize

plot( time, h.ripple.fdata);
hold on;
plot(time(h.ripple.rippbeg),h.ripple.fdata(h.ripple.rippbeg),'.g','markersize',ms);
plot(time(h.ripple.rk),h.ripple.fdata(h.ripple.rk),'.y','markersize',ms);
plot(time(h.ripple.rippend),h.ripple.fdata(h.ripple.rippend),'.r','markersize',ms);
%plot(h.ripple.event,h.ripple.fdata(h.ripple.event),'.k','markersize',ms);
plot([min(time) max(time)],[h.ripple.rmslimit h.ripple.rmslimit],'r')
title(h.ripple.tit)


% --------------------------------------------------------------------
function rippauto_Callback(hObject, eventdata, h)
% hObject    handle to rippauto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Default parameters: 
%         h.ripple.meth=3;
%         h.ripple.plotswitch=0;
%         h.ripple.ch=[44:47];
%         h.ripple.fr=[80 500];
%         h.ripple.rmssdlimit=[5];
%         h.ripple.cyclelimit=[3];
%         h.ripple.rmsms=[3];
%         h.ripple.rectsdlimit=[3];
%         h.ripple.timelimit=[6];
%         h.ripple.betweenlimit=[10];
%         h.ripple.fragmentsize=50;
%         h.ripple.databegs=0;
%         h.ripple.datalength=h.maxsec;
%         h.ripple.overlap=0.001;
%         h.ripple.out={};



%%%%%%%%%%%%%%%%%% Parameter setting %%%%%%%%%%%%%%%%%%
h.ripple.meth=3;
h.ripple.plotswitch=0;
h.ripple.ch=[47];
h.ripple.fr=[80 500];
h.ripple.rmssdlimit=[5];
h.ripple.cyclelimit=[3];
h.ripple.rmsms=[3];
h.ripple.rectsdlimit=[3];
h.ripple.timelimit=[6];
h.ripple.betweenlimit=[10];
h.ripple.databegs=0;
h.ripple.datalength=h.maxsec;
h.ripple.fragmentsize=[50];
h.ripple.overlap=0.001;
h.ripple.out={};

% h.artefact=ev2read;
% [fn2, pa2]=uigetfile({'*.mat', 'All Files'},'Give the ep files');
% fname=uiputfile;

%%%%%%%%%%%%%%%%%% Calculate %%%%%%%%%%%%%%%%%%

treshold=2:0.2:8;
cyclelimit=2:0.5:4;

out=[];
for tres=1:length(treshold)
    fprintf('Treshold is %1.1f \n',treshold(tres));
    for cyc=1:length(cyclelimit)
        fprintf('Cyclelimit is %1.1f \n',cyclelimit(cyc));
        h.ripple.rmssdlimit=treshold(tres);
        h.ripple.cyclelimit=cyclelimit(cyc);
        
        h=nswiew('rippdetect_Callback',hObject,1,h);

        for b=1:length(h.ripple.ch)
            followup=sum(h.ripple.followup{b});
            out(tres,cyc,b,:)=[followup(4),followup(3)-followup(4),followup(2)-followup(3)];
        end
    end
end
% figure('name',num2str(ch),'numbertitle','off')
% area(treshold,out)
h.ripple.out{a}=out;

   
%%%%%%%%%%%%%%%%%% Sort, Save %%%%%%%%%%%%%%%%%%
    
%     h.ripple=ripple_sorter(h.ripple,h.ep1,h.ep2,h.ep3,h.ep4);
%     eval(['r', num2str(ch),'=h.ripple;']);
%     try
%         save(fname,['r', num2str(ch)],'-append');  
%     catch
%         save(fname,['r', num2str(ch)]);  
%     end
%     h.event(:,:)=[];


guidata(hObject,h);


% --------------------------------------------------------------------
function artefact_Callback(hObject, eventdata, handles)
% hObject    handle to artefact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Artefatcts are marked by 0 event pairs

if isempty(eventdata)
    prompt={'Load (L) or Save (S)'};
    name='Artefact';                                                
    numlines=1;
    defaultanswer={'L'};
    answer=inputdlg(prompt,name,numlines,defaultanswer);

    todo=answer{1};

    switch upper(todo)
        case 'L'
            art=ev2read;
            handles.artefact=art;
            for a=1:length(art)
                handles.event{end+1,1}=art(a);
                handles.event{end,2}='0';
            end
        case 'S'
            artefact=extractevent(handles.figure1,0);
            if ~isempty(artefact)
                artefact=sort(artefact);
                handles.artefact=artefact;            
            end
            ev2writer_bh(artefact,0);
    end
else
    handles.artefact=eventdata;
end

set(hObject,'checked','on');
guidata(handles.figure1,handles);


% --- Executes on button press in rippfilter.
function rippfilter_Callback(hObject, eventdata, handles)
% hObject    handle to rippfilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rippfilter

if get(hObject,'value')
    tn=size(handles.task,1)+1;
    handles.rippfiltertasknum=tn;
    fr1=80;
    fr2=500;
    F=[fr1 fr2]./(handles.srate/2);
    str='bandpass';
    o=2;
    [b,a]=butter(o,F,str);
    set(hObject,'string',['BP ',num2str(fr1),'-',num2str(fr2)]);
    
    param.a=a;
    param.b=b;
    param.filtfilt=1;
    param.info=['Butterworth 2.order, zero phase shift ',num2str(fr1),'-',num2str(fr2),' Hz bandpass'];
    param.rect=0;

    eventdata{1}='inport';
    eventdata{2}='task_filter';

    handles=task_add(hObject, eventdata, handles, param);
    set(hObject,'userdata',tn);
    handles=reload_menu_Callback(hObject, [], handles);
    guidata(hObject,handles);
else
    handles=task_menu_turn_off(hObject,handles.rippfiltertasknum,handles);
    set(hObject,'string','Ripple filter');
    guidata(hObject,handles);
end

% --------------------------------------------------------------------
function varargout = windowbuttondownfcn_Callback(h, eventdata, handles, varargin)

if ~isfield(handles,'data') || isfield(handles,'figure2') %| volt
    return;
end

point=get(handles.ax,'currentpoint');
[ach, value, inside]=mouseloc(point,handles);

if inside

    abstime=fix(point(1,1)*1000)/1000;
    if ~isfield(handles,'absmtime')
        handles.absmtime=[];
    end
    if isempty(handles.absmtime)
        handles.absmtime=abstime;
    else
        handles.absmtime=[];
    end
    
end
guidata(h,handles)


% --------------------------------------------------------------------
function osccont_Callback(hObject, eventdata, h)
% hObject    handle to osccont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(eventdata)
    prompt={'Filter frequency','Large window size','Small window size','File fragment size (sec)'};
    name='SD Calc';                         
    numlines=1;
    defaultanswer={'80 500','300','50','50'};
    answer=inputdlg(prompt,name,numlines,defaultanswer);

    fr=str2num(answer{1});
    lwin=str2num(answer{2});
    swin=str2num(answer{3});
    filefrag=str2num(answer{4});
    
    [fn, pa]=uiputfile(h.fname(1:end-4));
    if isempty(fn), return; end
    poi=strfind(fn,'.'); %findstr volt
    if ~isempty(poi), fn=fn(1:poi(1)-1); end
    fn=[fn '_osccon.mat'];
    fname=[pa fn];
else
    fr=h.osccon.info.fr;
    lwin=h.osccon.info.lwin;
    swin=h.osccon.info.swin;
    filefrag=h.osccon.info.filefrag;
    fname=h.osccon.info.oscconfname;
end

info=[h.path, h.fname, '; ', date, ' ', num2str(clock)];
completed='FALSE';
chnum=h.chnum;
channels=1:chnum;
if isfield(h,'chnames')
    if ~isempty(h.chnames)
        chnames=h.chnames;
    else
        chnames=1:chnum;
    end
else
    chnames=1:chnum;
end

h.osccon.info.fr=fr;
h.osccon.info.lwin=lwin;
h.osccon.info.swin=swin;
h.osccon.info.filefrag=filefrag;
lwpoint=fix(lwin*h.srate/1000);
[cc, aa]=butter(2,[fr(1)/h.srate*2 fr(2)/h.srate*2], 'bandpass');
overlay=0.15/filefrag;
[bb,bl,fb,fe]=fragment(h,0,h.maxsec,h.srate,overlay,filefrag);
h.osccon.info.cc=cc;
h.osccon.info.aa=aa;
fragnum=length(bb);
srate=h.srate;

save(fname,'info','swin','lwin','fr','filefrag','completed','chnames','chnum','cc','aa','srate');
save(fname,'bb','bl','fragnum','channels','-append');

%%   calculate

histbins=-20:0.25:80;
cratiohist=zeros(length(histbins),chnum);
fake_cratiohist=zeros(length(histbins),chnum);

N=0;
k=[];
maxvalue=zeros(1,chnum);

for a=1:fragnum
    disp([num2str(a) '/' num2str(length(bb))]);
    hand=inport(bb(a),bl(a),h);
    data=hand.data;
    k(a)=size(data,1);
    
    N=N+k(a);
    if fix(size(data,1))~=fix(bl(a)*h.srate)
        fprintf('Data: %d, Bl: %d \n',fix(size(data,1)),fix(bl(a)*h.srate))
    end
    
    data=filtfilt(cc,aa,data);
    hd=abs(hilbert(data));     % hilbert method
    data=abs(data);           % rectified filtered
    
    % random fake data
%     fake_data=zeros(size(data));
%     disp('Peakfind')
%     for c=1:size(data,2),
%         fprintf('%d',c)
%         [peaks troughs]=peakfind(data(:,c));     % Fake rect filtered
%         troughs=shiftdim(troughs);
%         intnum=size(troughs,1)+1;
%         intlims=[1; troughs; size(data,1)+1];
%         rord=randperm(intnum);
% 
%         fakeint_start=0;
%         for b=1:intnum
%             origint=[intlims(rord(b)):intlims(rord(b)+1)-1];
%             oil=1:length(origint);
%             fakeint=oil+fakeint_start;
%             fake_data(fakeint,c)=data(origint,c);
%             fakeint_start=fakeint_start+length(origint);
%         end
%     end
%     fprintf('\n')

    disp('Osc cont')
    ratio_matr=osc_contrast(data,swin,lwin,hand.srate);
    
%     disp('Osc cont Fake')             %FAKE
%     fake_ratio_matr=osc_contrast(fake_data,swin,lwin,hand.srate);
    time=0:size(data,1)-lwpoint;
    time=time'+hand.inxp+fix(lwpoint/2); % Time in data points
    
    if ~isempty(ratio_matr)
        for b=1:chnum
            arhist(:,b)=hist(ratio_matr(:,b),histbins);
    %         fakearhist(:,b)=hist(fake_ratio_matr(:,b),histbins); %FAKE
        end
        maxv=max(ratio_matr);
        maxvalue=max(maxvalue,maxv);
        cratiohist=cratiohist+arhist;
    %     fake_cratiohist=fake_cratiohist+fakearhist;   % FAKE
        eval(['ratio_matr_',num2str(a),'x=ratio_matr;']);
        eval(['time_',num2str(a),'x=time;']);   %Time in data points
        eval(['save(fname,''ratio_matr_',num2str(a),'x'',''-append'');']);
        eval(['save(fname,''time_',num2str(a),'x'',''-append'');']);
        eval(['clear(''ratio_matr_',num2str(a),'x'', ''time_',num2str(a),''')'])
    end
    
end

h.osccon.N=N;
h.osccon.cratiohist=cratiohist;
% h.osccon.fake_cratiohist=fake_cratiohist;     % FAKE
h.osccon.histbins=histbins;
h.osccon.maxvalue=maxvalue;
h.osccon.fname=fname;
completed='TRUE';
save(fname,'N','histbins','cratiohist','maxvalue','completed','-append');
if isfield(h,'sd')
    sd=h.sd;
    save(fname,'sd','-append');
else
    errormsg('SD detection will be needed');
end

% save([pa fn],'fake_cratiohist','-append');    % FAKE

guidata(h.figure1,h);
disp('Ready Oscillation Contrast')


function varargout = loadSUA_menu_Callback(h, eventdata, handles)
% % hObject    handle to median_threshold (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
 
% Neccessary lines were inserted in function handles=draw(data,handles)

%mappa eleres
path = uigetdir;

if isempty(path)
    return;
end

if ~isfield(handles,'page')
    return;
end
if exist([path, filesep,'log_deblock.mat'], 'file') == 2
filename_log_deblock = 'log_deblock.mat';
end

load([path, filesep, filename_log_deblock], 'polytrodes');
prompt=['Select the polytrode', newline, 'Existing pages:', newline]; 
sz = strings(size(cell2mat(handles.page)));
for i=1:size(cell2mat(handles.page), 2)-size(polytrodes, 2) + 1
    fajlnev = ['times_polytrode' num2str(i) '.mat'];
    if exist([path, filesep, 'Times_polytrodes', filesep, fajlnev], 'file') == 2
        sz(i) = [num2str(i), ' '];
    end
end
prompt = [prompt,  sz{1:end}]; 
answer=inputdlg(prompt,'Polytrodes',1,{''});
if ~isempty(answer)
    if strcmp(answer{1},'reset')
        if handles.apage~=1
            handles.apage=2;
            handles.page(2)=handles.page(handles.apage);
            handles.page(3:end)=[];
        else
            handles.page(2:end)=[];
        end
        handles=draw(handles.data,handles);
    elseif ~isempty(str2double(answer{1}))
        handles.page{end+1}=[str2double(answer{1}), str2double(answer{1})+1];
    end
end
polytrode = str2double(answer{1});



%% SUA

clusters_2_nswiew = wave_clus_2_nswiew(polytrode, filename_log_deblock, path);

handles.SUAs_cluster_class = clusters_2_nswiew; 
handles.SUApath=path;
handles.polytrode = polytrode;
handles.filename_log_deblock = filename_log_deblock;


%% noise level
[t_dp_thr, thr_step, ch_id, par] = noise_level_2_nswiew(polytrode, filename_log_deblock, path);
handles.thr(1).t_dp_thr = t_dp_thr; 
handles.thr(1).thr_step = thr_step;
handles.thr(1).type = par.detection;
handles.thr(1).ch_id = ch_id;
handles.thr(1).filename= ['polytrode' num2str(polytrode) '_spikes.mat'];
handles.thr(1).path=path;

handles=draw(handles.data,handles);


%% Filter: ha felrakom a filtert, akkor nem pipálja még ki a Transform -> filter fülnél
load([path, filesep, 'Times_polytrodes', filesep,...
    'times_polytrode' num2str(polytrode) '.mat'],'par');
    fmin = par.detect_fmin;
    fmax = par.detect_fmax;
    order = par.detect_order;
    type = 'Elliptic';
    zphs = 'zero phase shift';
    bp = 'bandpass';
txt = (['Do you want to replace existing filters with the following one used by wave_clus?', newline, ...
    'Min freq: ', num2str(fmin), 'Hz', newline, ...
    'Max freq: ', num2str(fmax), 'Hz', newline, ...
    'Order: ', type, ' ', num2str(order) '. order ', zphs, newline, ...
    'Type: ', bp]);
user_response = questdlg(txt,...
    'Applying a filter',...
    'Yes', 'No', 'Yes');
switch user_response
case 'No'
    
case 'Yes'
    handles=task_menu_turn_off(h,'task_filter',handles); %%még nézd át otthon!
    switch order
        case 2
            order = 1;
        case 4
            order = 2;
        case 6
            order = 3;
        case 8
            order = 4;
        case 10
            order = 5;
    end
   %%(1:4) bandpass, (5) zphs, (6) order, (7) elliptic
   vs = {0; 1; 0; 0; 1; order; 3; 0};
   frs = {num2str(fmin); num2str(fmax)};
   [b, a, info] = getfilter(vs, frs, handles);
   handles.filterset=struct('a',a,'b',b,'filtfilt', 1,'info',info,'rect',0);
   %handles.filterset
   handles=task_menu_add(h,{'inport','task_filter'},handles,handles.filterset);
   
end
guidata(h,handles);
%cd(path);


% --------------------------------------------------------------------
function gui_coeffs_vs_coeffs_Callback(hObject, eventdata, handles)
% hObject    handle to gui_coeffs_vs_coeffs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(handles.SUApath)
load([handles.SUApath, filesep, handles.filename_log_deblock], 'polytrodes');
prompt=['Existing pages:' newline];
sz = strings(size(cell2mat(handles.page)));
for i=1:size(cell2mat(handles.page), 2) - size(polytrodes, 2) + 1
    fajlnev = ['times_polytrode' num2str(i) '.mat'];
    if exist([handles.SUApath, filesep, 'Times_polytrodes', filesep, fajlnev], 'file') == 2
        sz(i) = [num2str(i), ' '];
    end
end
prompt = [prompt,  sz{1:end- size(polytrodes, 2) + 1}]; %%
answer=inputdlg(prompt,'Polytrodes',1,{''});
if ~isempty(answer)
    if strcmp(answer{1},'reset')
        if handles.apage~=1
            handles.apage=2;
            handles.page(2)=handles.page(handles.apage);
            handles.page(3:end)=[];
        else
            handles.page(2:end)=[];
        end
        handles=draw(handles.data,handles);
    elseif ~isempty(str2double(answer{1}))
        handles.page{end+1}=str2double(answer{1});
    end
end
polytrode = str2double(answer{1});
handles.coeff_vs_coeff_name = ['times_polytrode' num2str(polytrode) '.mat'];
Gui_plot_coeffs(polytrode, handles.SUApath);
end
guidata(hObject, handles);


function [b,a,info]= getfilter(vs, frs, handles)

%vs=get([handles.lp, handles.bp, handles.bs, handles.hp,handles.zphs, handles.order, handles.type, handles.rect],'value');
%frs=get([handles.frb, handles.fra],'string');

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
     % elliptic filter % should be added to the filter type options
   try     [b,a] = ellip(o,0.1,40,F,str); % the settings used by Wave_clus
       info=['Elliptic ', num2str(o), '.order, ',zphs{vs{5}+1}, num2str(F*(handles.srate/2)), ' Hz ', str,rrrr{vs{8}+1}];
   catch a=[]; b=[]; info='not found'; return;
   end
end
