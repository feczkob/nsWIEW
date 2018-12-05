function indi(str);

% indicator
% Fab� 2003

is=findobj('type','figure','userdata','indicator');

if strcmp(str,'del') & ~isempty(is),
    delete(is); return;
end;

if isempty(is),
    is=figure('menubar','none','position',[319   510   154    76],'resize','on',...
             'name','PROCESS','numbertitle','off','userdata','indicator');
    ind=uicontrol('style','text');     
elseif length(is)==1,
    ind=findobj(is,'style','text');
else
    ind=findobj(is(1),'style','text');
    delete(is(2:end));
end;

set(ind,'string',str);
set(gcf,'visible','on');

