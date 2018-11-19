% Coincidence detector
%
% ev1=maxs;
% ev2=ev11-bl(1);
% ev12=[];
% for a=1:size(ev1,1),
%     if find(ev2>ev1(a)-4 & ev2<ev1(a)+4),
%         ev12(end+1,1)=ev1(a);
%     end
% end

% PHASE 
%
% chs=[4 4 8 9 11 11 11 12 12 12 19 20 20 21];
% for a=1:length(chs),
% ch=chs(a);    
% ep=readvalue(nse,bl,ch);
% [fy,f]=fourier_bas(ep,1024,2000);
% figure
% bar(f,fy);
% set(gca,'xlim',[0 100],'ylim',[0 max(fy)]);
% answer=inputdlg('Give the filter specs','Give the parameter');
% Wn=str2num(answer{1});
% [b a]=butter(2,Wn/1000);
% epf=filtfilt(b,a,ep);
% ph=angle(hilbert(epf));
% [his1 xout]=hist(ph(ev),20);
% 
% bar(xout,his1,'hist');
% [m mh]=max(his1);
% his=hist(ph(ev),2);
% pr=1-binocdf(max(his),sum(his),0.5);
% disp(['Ch ' num2str(ch) ', ' answer{1} ' Hz, peak: ' num2str(xout(mh)) ', p=' num2str(pr)]);
% end

% STA
%
% avg=aver(ev,nse,0,200,5,100);
% [m,n]=size(avg);
% mav=mean(avg);
% avg=avg-mav(ones(m,1),:);
% ma=max(max(avg)); mi=min(min(avg));
% for i=1:24,
%     subplot(4,6,i)
%     plot(avg(:,i))
%     set(gca,'ylim',[mi ma])
%     title(i)
% end

% f=fopen('c:\data\anal\out\m2.txt','w');
% for a=3:size(m2txt,1);
%     if mod(a-2,4)~=0, 
%         x=fprintf(f,'%s\n',m2txt{a});
%         [a x]
%     end
% end

% Distribution finder
% ch,bl needed
%
% for a=1:length(ch),
%     ep=readvalue(nsu,bl,ch(a));
%     [his xout]=histcum(ep,30,1);
%     hisc{a}=[shiftdim(xout) shiftdim(his)];
% end;
% for a=1:length(ch),
%     a
%     for a2=1:length(ev11),
%         v=readvalue(nsu,[ev11(a2)-3 ev11(a2)+3],ch(a));
%         for a3=1:length(v),
%             bin=max(find(hisc{a}(:,1)<v(a3)));
%             if isempty(bin), bin=1; end
%             pr(a3)=hisc{a}(bin,2);
%         end
%         pma(a2)=max(pr);
%         pmi(a2)=min(pr);
%         p(a2)=mean(pr);
%     end;
%     pmean(a)=mean(p);
%     pmax(a)=mean(pma);
%     pmin(a)=mean(pmi);
% end;

% De Noise wavelet
% sw1dtool.m

% Burst tresholding
% ok=1;
% while ok
% [fn pa]=uigetfile('*.ev2');
% cd(pa)
% ev=load([pa fn]);
% ev=ev(:,6);
% dev=diff(ev);
% f=figure('toolbar','figure','name',fn,'numbertitle','off');
% plot(dev(1:end-1),dev(2:end),'.b','markersize',6);
% ui=uicontrol('style','edit');
% waitfor(ui,'string');
% treshold=str2num(get(ui,'string'));
% save([pa fn(1:end-4) '_tr'],'treshold');
% delete(f)
% ButtonName=questdlg('Continue?', ...
%                        'Select', ...
%                        'Yes','No','Yes');  
% if strcmp(ButtonName,'No'),
%     ok=0;
% end
% end

% Event unifier
%
% eve=[];
% for a=1:3
%     [f pa]=uigetfile('*.ev2');
%     ev=load([pa f]);
%     ch=ev(1,2);
%     eve=[eve;ev(:,6)];
% end
% ev2writer_bh(eve,ch);

% Cell_comp
% for a=1:10,
%     figure('name',num2str(a),'numbertitle','off'); 
%     hold on;
%     plot(a56(:,a));
%     plot(a67(:,a),'r');
%     legend({'5-6','6-7'});
% end;
% 
% figure
% chn=length(ch);
% 
% for i=1:chn,
%     a=fix(sqrt(chn)); b=ceil(chn/a);
%     subplot(a,b,i);
%     pl=imagesc(time,log2(period),real(log2(avg_wave(:,:,i))));
%     set(pl,'buttondownfcn','x=get(gcbo,''userdata''); disp(''ok''); p2;', ...
%             'userdata',i);
%     set(gca,'YLim',log2([period(1),period(end)]), ...
%             'buttondownfcn','x=get(gcbo,''userdata''); disp(''ok''); p2;', ...
%             'userdata',i,...
%             'xlim',[min(time) max(time)],...
%             'YTick',log2(period(:)), ...
%             'YTickLabel',fix(100./period)./100)
%         
%    
%     title(num2str(ch(i)),'verticalalignment','bottom','color','k');     
% end;
% 
% ax=findobj(gcf,'type','axes');
% clim=get(ax,'clim');
% cmin=[]; cmax=[];
% for a=1:length(clim),
%     cmin(end+1)=clim{a}(1);
%     cmax(end+1)=clim{a}(2);
% end
% clim=[min(cmin) max(cmax)];
% clim=round(clim*100)/100;
% set(ax,'clim',clim);
% set(gcf,'userdata',{ax, clim});
% 
% u1=uicontrol('style','edit','string',clim(2),'parent',gcf); 
% u2=uicontrol('style','edit','string',clim(1),'parent',gcf);
% set(u1,'units','normalized','position',[0.92,0.2,0.05,0.05],...
%         'Callback', ...
%         ['n=str2num(get(gcbo,''string''));', ...
%          'f=get(gcbo,''parent''); ', ...
%          'd=get(f,''userdata''); ', ...
%          'if n>d{2}(2), n=d{2}(2); set(gcbo,''string'',d{2}(2)); end; ', ...
%          'clim=get(d{1}(1),''clim''); ', ...
%          'set(d{1},''clim'',[clim(1) n]);'] );
% set(u2,'units','normalized','position',[0.92,0.12,0.05,0.05], ...
%         'Callback',...
%         ['n=str2num(get(gcbo,''string'')); ', ...
%          'f=get(gcbo,''parent''); ', ...
%          'd=get(f,''userdata''); ', ...
%          'if n<d{2}(1), n=d{2}(1); set(gcbo,''string'',d{2}(1)); end; ', ...
%          'clim=get(d{1}(1),''clim''); ', ...
%          'set(d{1},''clim'',[n clim(2)]);'] );   

