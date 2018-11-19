function draw(ns)


h=guidata(ns);

chs=h.page{h.apage};
prompt  = {'Channels: ','AMPLITUDE',};
tit   = 'Give the parameters';
lines=fix(length(chs)/20)+1;
def     = {num2str(chs),'1'};
answer  = inputdlg(prompt,tit,lines,def);

chs_sel=str2num(answer{1});
amp=str2num(answer{2});
h.amp=h.amp*amp;

time=[0:length(h.data)-1]./h.srate+h.inx1;
t0=time(1); t1=time(end);

maxi=length(chs_sel);
for a=1:maxi,
	d(:,a)=h.data(:,chs_sel(a))*h.amp+(maxi-a)*10;
end;
data=d;
figure
plot(time,data,'color','black');

 set(gca,'ylim',[-10 maxi*10], ...
               'ytick',[1:10:maxi*10], ...
               'yticklabel',[chs_sel(end:-1:1)], ...
               'xlim',[t0 t1], ...
               'xtick',[t0:(t1-t0)/10:t1], ...
               'xticklabel',round([t0:(t1-t0)/10:t1].*100)./100);
set(gcf,'paperpositionmode','auto')           