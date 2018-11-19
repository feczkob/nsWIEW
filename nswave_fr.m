% wavelet spectrum calculation for the total EEG frequency band
% and for the theta and gamma activity 

function [wave,power,period,scale,coi]=nswave_fr(h,i,frb,fra,nf,figneed),

if nargin<1,
    return;
elseif nargin==1,
    data=h.data;
    dt=1/h.srate;
    % pad=1;      
    % dj=0.1;    
    % s0=2*dt;    
    % j1=10/dj;    
    lag1=0.72;  
    % mother='Morlet';
    prompt  = {'Which channel do you want to analyse? ','Frequency bellow',['Frequency above (sr=' num2str(1./dt) ')'],'Number of scales'};
    titl   = 'Give the parameters';
    lines= 1;
%          ch  frb fra   NF   
    def     = {'2','20','60','40'};
    answer  = inputdlg(prompt,titl,lines,def);

    i=str2num(answer{1});
    frb=str2num(answer{2});
    fra=str2num(answer{3});
    nf=str2num(answer{4});
    data=h.data(:,i);
else
    data=h.data(:,i);
    dt=1/h.srate;
end;


variance=std(data)^2;
data=(data-mean(data))/sqrt(variance) ;
n=length(data);
% time=[0:n-1]*dt; 
time=h.time;
xlim=[min(time),max(time)];  

if nargin<6,
    disp(' COMPUTING THE WAVELET SPECTRUM ...')
end;

[wave,power,period,scale,coi]=wavelet_morlet_fr(data,dt,frb,fra,nf); 

% f1=10; f2=65;
% pf1=1/f1; pf2=1/f2;
% i2=max(find(period<=pf1)); i1=max(find(period<=pf2)); 
% if isempty(i1),
%     i1=1;
% end;

% ff1=2; ff2=10; ff3=30; ff4=80;
% pff1=1/ff1; pff2=1/ff2; pff3=1/ff3; pff4=1/ff4;
% if2=max(find(period<=pff1)); if1=max(find(period<=pff2));
% if4=max(find(period<=pff3)); if3=max(find(period<=pff4));
% pow=power(i1:i2,:); pow=pow';			 
% globws=variance*(sum(pow)/n);   		 
% pow1=power(if1:if2,:); pow1=pow1';	 	 
% glwsstd=variance*std(pow);
% totws=variance*mean(pow1);
% totwsstd=variance*std(pow1);
% pow2=power(if3:if4,:); pow2=pow2';	 	
% totws2=variance*mean(pow2);
% totwstd2=variance*std(pow2);
% Cdelta=0.776;   							
% avg=find((scale>=1/ff2)&(scale<1/ff1));
% scaleavg=(scale')*(ones(1,n));  
% scaleavg=power./scaleavg;   
% scaleavg=variance*dj*dt/Cdelta*sum(scaleavg(avg,:));  
% scav=mean(scaleavg);
% scavstd=std(scaleavg);
% avg2=find((scale>=1/ff4)&(scale<1/ff3));
% scalavg2=(scale')*(ones(1,n));  
% scalavg2=power./scalavg2;   
% scalavg2=variance*dj*dt/Cdelta*sum(scalavg2(avg2,:));  
% scav2=mean(scaleavg);
% scavstd2=std(scaleavg);


if nargin<6, 
    figure('name',num2str(i),'numbertitle','off','pointer','fullcrosshair')
    
    subplot(2,1,1)
    plot(time,data)
    set(gca,'XLim',xlim(:))
    xlabel('time (s)')
    title(' EEG WAVELET POWER SPECTRUM ')
    ax=subplot(2,1,2);
    
    colormap jet
    imagesc(time,log2(period),log2(power));
    ax=gca;
    clim=round(get(ax,'clim')*10)/10;
    
    set(gcf,'userdata',[ax clim]);
    clim=[-2.5 clim(2)];
    set(gca,'clim',clim);
    
    indx=round(1:size(period,2)/20:size(period,2));
    
    set(gca,'YLim',log2([period(1),period(end)]), ...
            ... % 'YDir','reverse', ...
            'YTick',log2(period(indx)), ...
            'YTickLabel',fix(100./period(indx))./100)
    u1=uicontrol('style','edit','string',clim(2)); 
    u2=uicontrol('style','edit','string',clim(1));
    u3=uicontrol('style','text','string','','units','normalized','position',[0.92,0.28,0.05,0.05]);
    
    set(u1,'units','normalized','position',[0.92,0.2,0.05,0.05],...
        'Callback', ...
        ['n=str2num(get(gcbo,''string''));', ...
         'f=get(gcbo,''parent'');', ... 
         'd=get(f,''userdata'');', ... 
         'if n>d(3), n=d(3); set(gcbo,''string'',d(3)); end;', ...
         'clim=get(d(1),''clim'');', ...
         'set(d(1),''clim'',[clim(1) n]);']);
    set(u2,'units','normalized','position',[0.92,0.12,0.05,0.05], ...
        'Callback',...
        ['n=str2num(get(gcbo,''string''));', ...
         'f=get(gcbo,''parent'');', ...
         'd=get(f,''userdata'');', ...
         'if n<d(2), n=d(2); set(gcbo,''string'',d(2)); end;', ...
         'clim=get(d(1),''clim'');', ...
         'set(d(1),''clim'',[n clim(2)]);']);
    set(gcf,'windowbuttonmotionfcn', ...
        ['u3=findobj(gcbo,''style'',''text''); ', ...
         'ax=findobj(gcbo,''type'',''axes''); ', ...
         'point=get(ax(1),''currentpoint'');', ...
         'set(u3,''string'',[num2str(fix(100./(2^point(1,2)))/100), '' Hz''])'])
    
%  return; 
    
    % levels = [0.0625,0.125,0.25,0.5,1,2,4,8,16] ;
%     levels=2.^[-3:0.66:6];
%     Yticks1=(period); % Yticks1=Yticks1(1:8:length(Yticks1));
%     contourf_noedge(time,log2(period),log2(power),log2(levels));  
%     xlabel('time (s)')
%     ylabel('frequency (Hz)')
%     set(gca,'XLim',xlim(:))
%     set(gca,'YLim',log2([period(1),period(end)]), ...
%             'YDir','reverse', ...
%             'YTick',log2(Yticks1(:)), ...
%             'YTickLabel',fix(100./Yticks1)./100)
%     set(gcf,'pointer','fullcrosshair')
    
%     hold on;
%     plot([min(time) max(time)],[log2(1/10) log2(1/10) ],'k');
%     plot([min(time) max(time)],[log2(1/2) log2(1/2) ],'k');
elseif figneed~=0,
    set(0,'currentfigure',figneed)
    ax=findobj(gcf,'type','axes');
    clim=get(ax,'clim');
    
    colormap jet
    imagesc(time,log2(period),log2(power));
    set(gca,'clim',clim);
    
    indx=round(1:size(period,2)/20:size(period,2));
    
    set(gca,'YLim',log2([period(1),period(end)]), ...
            ... % 'YDir','reverse', ...
            'YTick',log2(period(indx)), ...
            'YTickLabel',fix(10./period(indx))./10);

    u1=findobj(gcf,'tag','u1');
    u2=findobj(gcf,'tag','u2');
    set(u1,'string',clim(2)); 
    set(u2,'string',clim(1));
end