function varargout=ev2writer_bh(eventpos,varargin)

c6=shiftdim(eventpos)';
if nargin>1,
    c2=ones(size(c6))*varargin{1};
else
    c2=ones(size(c6));
end;
c1=1:size(c6,2);
c3=zeros(1,length(c1));
c4=zeros(1,length(c1));
c5=zeros(1,length(c1));
if nargin<3,
    [fn pa]=uiputfile('*.ev2','Give the file name');
    if fn==0,
        return;
    end;
else 
    pa=varargin{2}{1};
    fn=varargin{2}{2};
end;
poi=findstr(fn,'.');
if ~isempty(poi), fn=fn(1:poi(1)-1); end;
fn=[fn '.ev2'];

f=fopen([pa fn],'w');
ok=fprintf(f,'%5d %4d %3d %4d %7.4f %8d\n',[c1; c2; c3; c4; c5; c6]);
fclose(f);
if nargout==1, varargout{1}=ok; end;
disp([pa fn])