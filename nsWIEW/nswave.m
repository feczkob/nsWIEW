% wavelet spectrum calculation for the total EEG frequency band
% and for the theta and gamma activity 

if exist('ns')
    h=guidata(ns);
    data=h.data;
    dt=1/h.srate;
else
    dt=0.0005;							% for sample frequency of 2 kHz
end;
% pad=1;      
% dj=0.1;    
% s0=2*dt;    
% j1=10/dj;    
lag1=0.72;  
% mother='Morlet';
prompt  = {'Which channel do you want to analyse? ','pad','dj',['s0 (dt=' num2str(dt) ')'],'j1','mother'};
titl   = 'Give the parameters';
lines= 1;
%          ch  pad  dj    s0     j1      mother
def     = {'23','1','0.12','0.1','20','MORLET'};
answer  = inputdlg(prompt,titl,lines,def);

i=str2num(answer{1});
pad=str2num(answer{2});
dj=str2num(answer{3});
if isempty(answer{4}) | strcmp(answer{4},'2*dt'),
    s0=2*dt;
else
    s0=str2num(answer{4});
end;
if isempty(answer{5}) | strcmp(answer{5},'10/dj'),
    j1=10/dj;
else
    j1=str2num(answer{5});
end;
if isempty(answer{5}),
    mother='MORLET';
else
    mother=answer{6};
end;

dat=data(:,i);

variance=std(dat)^2;
dat=(dat-mean(dat))/sqrt(variance) ;
n=length(dat);
time=[0:n-1]*dt; 
xlim=[min(time),max(time)];  

disp(' COMPUTING THE WAVELET SPECTRUM ...')
[wave,period,scale,coi]=wavelet(dat,dt,pad,dj,s0,j1,mother);

power=(abs(wave)).^2 ;        
f1=1.8; f2=9;
pf1=1/f1; pf2=1/f2;
i2=max(find(period<=pf1)); i1=max(find(period<=pf2));

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

figure
subplot(2,1,1)
plot(time,dat)
set(gca,'XLim',xlim(:))
xlabel('time (s)')
title(' EEG WAVELET POWER SPECTRUM ')
subplot(2,1,2)
% levels = [0.0625,0.125,0.25,0.5,1,2,4,8,16] ;
levels=2.^[-3:0.66:6];
Yticks1=(period(i1:i2)); % Yticks1=Yticks1(1:8:length(Yticks1));
contourf_noedge(time,log2(period(i1:i2)),log2(power(i1:i2,:)),log2(levels));  
xlabel('time (s)')
ylabel('frequency (Hz)')
set(gca,'XLim',xlim(:))
set(gca,'YLim',log2([period(i1),period(i2)]), ...
        'YDir','reverse', ...
        'YTick',log2(Yticks1(:)), ...
        'YTickLabel',fix(1./Yticks1))
hold
plot([min(time) max(time)],[log2(1/10) log2(1/10) ],'k')
plot([min(time) max(time)],[log2(1/2) log2(1/2) ],'k')
plot([min(time) max(time)],[log2(1/100) log2(1/100) ],'k')
plot([min(time) max(time)],[log2(1/40) log2(1/40) ],'k')

% figure
% subplot(2,1,1)
% levels=[0.0625,0.125,0.25,0.5,1,2,4,8,16] ;
% Yticks2=(period(if1:if2)); Yticks2=Yticks2(1:4:length(Yticks2));
% contour(time,log2(period(if1:if2)),log2(power(if1:if2,:)),log2(levels));  
% xlabel('time (s)')
% ylabel('frequency (Hz)')
% set(gca,'XLim',xlim(:))
% set(gca,'YLim',log2([period(if1),period(if2)]), ...
% 	'YDir','reverse', ...
% 	'YTick',log2(Yticks2(:)), ...
%    'YTickLabel',fix(1./Yticks2))
% title(' EEG THETA ACTIVITY WAVELET POWER SPECTRUM ')
% subplot(2,1,2)
% plot(time,scaleavg)
% set(gca,'XLim',xlim(:))
% xlabel('time (s)')
% ylabel('power (s^2)')
% title(' EEG THETA POWER  ')
% 
% figure
% subplot(2,1,1)
% levels=[0.0625,0.125,0.25,0.5,1,2,4,8,16] ;
% Yticks3=(period(if3:if4)); Yticks3=Yticks3(1:2:length(Yticks3));
% contour(time,log2(period(if3:if4)),log2(power(if3:if4,:)),log2(levels));  
% xlabel('time (s)')
% ylabel('frequency (Hz)')
% set(gca,'XLim',xlim(:))
% set(gca,'YLim',log2([period(if3),period(if4)]), ...
% 	'YDir','reverse', ...
% 	'YTick',log2(Yticks3(:)), ...
%    'YTickLabel',fix(1./Yticks3))
% title(' EEG GAMMA ACTIVITY WAVELET POWER SPECTRUM ')
% subplot(2,1,2)
% plot(time,scalavg2)
% set(gca,'XLim',xlim(:))
% xlabel('time (s)')
% ylabel('power (s^2)')
% title(' EEG GAMMA POWER  ')
% 
% figure
% plot(time,scaleavg)
% hold 
% plot(time,scalavg2,'r')
% set(gca,'XLim',xlim(:))
% xlabel('time (s)')
% ylabel('power (s^2)')
% title(' EEG THETA (BLUE) AND GAMMA (RED) POWER  ')
% 
% figure
% subplot(222)
% axis off
% text(0.3, .7', 'TIME AVERAGED ')
% text(0.2, .5', 'EEG WAVELET POWER ')
% 
% subplot(221)
% plot(log2(period(i1:i2)),globws,'r')
% ylabel('power (s^2)')
% xlabel('frequency (Hz)')
% title('...for the 1 - 250 Hz frequency band ')
% set(gca,'XLim',log2([(period(i1)),(period(i2))]), ...
%         'XDir','reverse', ...
%         'XTick',log2(Yticks1(:)), ...
%         'XTickLabel',fix(1./Yticks1))
%         %'XTickLabel','')
%         set(gca,'YLim',[0,1.1*max(globws)])
%         
%         
% subplot(223)
% Yticks2a=Yticks2(1:(length(Yticks2)-1));
% plot(log2(period(if1:if2)),totws,'r')
% ylabel('power (s^2)')
% xlabel('frequency (Hz)')
% title('...for the theta frequency band ')
% set(gca,'XLim',log2([(period(if1)),(period(if2))]), ...
%         'XDir','reverse', ...
%         'XTick',log2(Yticks2a(:)), ...
%         'XTickLabel',fix(1./Yticks2a))
%         %'XTickLabel','')
%         set(gca,'YLim',[0,1.1*max(totws)])
%        
% subplot(224)
% plot(log2(period(if3:if4)),totws2,'b')
% ylabel('power (s^2)')
% xlabel('frequency (Hz)')
% title('...for the gamma frequency band ')
% set(gca,'XLim',log2([(period(if3)),(period(if4))]), ...
%         'XDir','reverse', ...
%         'XTick',log2(Yticks3(:)), ...
%         'XTickLabel',fix(1./Yticks3))
%         %'XTickLabel','')
%         set(gca,'YLim',[0,1.1*max(totws2)])
        




        
      
