function varargout=rippdetect_Callback2(hObject, eventdata, h)
% hObject    handle to rippdetect (see GCBO)
% eventdata  : contain the channel to analyse for auto ripple call
%              this type of call needs prior parametered call 
%              the parameters stored in handles.ripple is used
% handles    structure with handles and user data (see GUIDATA)
if isempty (eventdata),             % Parameter and variable setting
%     disp('paramsedit')
    h=rippdetect_paramsedit(hObject, h); %ez akkor fut le, ha az eventdata üres, vagyis, ha nem adjuk be neki a paramétereket
else
    h.ripple.toevents=0; %%%%% Ez MI???????
end

chnum=length(h.ripple.ch);
rk=cell(chnum,1); 
rippbeg=cell(chnum,1);
rippend=cell(chnum,1);
peaknum=cell(chnum,1);
amplitude=cell(chnum,1);
duration=cell(chnum,1);
putripborders=cell(chnum,1);
isripple=cell(chnum,1); timelim=cell(chnum,1); cyclelim=cell(chnum,1); peaknum=cell(chnum,1); amplitude=cell(chnum,1); duration=cell(chnum,1);
putripples=cell(chnum,1);indx=cell(chnum,1); maxfdata=cell(chnum,1); data=cell(chnum,1); fdata=cell(chnum,1);
rmsfdata=cell(chnum,1); rectfdata=cell(chnum,1); maxsrms=cell(chnum,1); maxsrect=cell(chnum,1); peaks=cell(chnum,1);
troughs=cell(chnum,1); rectpeakratio=cell(chnum,1); wavpow=cell(chnum,1); freq=cell(chnum,1); instfreqavg=cell(chnum,1);
instfreqmin=cell(chnum,1); instfreqmax=cell(chnum,1); 
rmslimit=cell(chnum,1); 

rmslimit=cell(chnum,1); 

[bb,bl,fb,fe]=fragment2(h, ... % creating data points for fragment lengths
                       h.ripple.databegs, ... 
                       h.ripple.datalength, ...
                       h.srate, ...
                       h.ripple.overlap, ...
                       h.ripple.fragmentsize);      
out=zeros(size(h.ripple.rmssdlimit,2),size(h.ripple.cyclelimit,2),size(h.ripple.ch,2));
for a=1:length(bb),         %   Cycle through fragments
    if a==1
        time1=cputime;
    end
    disp(' ')
    fprintf('Fragment %d of %d: Channel ',[a, length(bb)]);
    hand=inport(bb(a),bl(a),h);     % Inport data
    for b=1:chnum;                  % Cycle through channels
        if b==1
            time1b=cputime;
        end
       ch=h.ripple.ch(b);
       fprintf('%d ',ch)
%        if ch==8
%            disp(' ');
%        end
       [putrip]=feval(@ripple_m3_bck300, ...
                hand.data(:,ch), ... 0
                h.srate, ... 1
                h.ripple.fr, ... 2
                h.ripple.rmsms, ... 3
                h.ripple.rmssdlimit, ... 4
                h.ripple.rectsdlimit, ... 5
                h.ripple.cyclelimit, ... 6
                h.ripple.timelimit, ... 7
                h.ripple.betweenlimit, ... 8
                h.sd.sumrmssd(ch), ... 9
                h.sd.sumrmsmean(ch), ... 10
                h.sd.sumrectsd(ch), ... 11
                h.sd.sumrectmean(ch), ... 12
                hand.inxp, ... 13  
                0 ...          14
                );
%             figure(1)
%             plot(putrip.rectfdata(4, :))
%             hold on
%             plot(putrip.maxsrect{4,1}-putrip.indx(4,1)+1, putrip.rectfdata(4,putrip.maxsrect{4,1}-putrip.indx(4,1)+1), 'ro')
%             
%             figure(2)
%             plot(putrip.rmsfdata(4, :))
%             hold on
%             plot(putrip.maxsrms{4,1}-putrip.indx(4,1)+1, putrip.rmsfdata(4,putrip.maxsrms{4,1}-putrip.indx(4,1)+1), 'ro')
        
        isripple{b,1}=[isripple{b,1}; putrip.isripple];
        timelim{b,1}=[timelim{b,1}; putrip.timelim];
        duration{b,1}=[duration{b,1}; putrip.duration];
        cyclelim{b,1}=[cyclelim{b,1}; putrip.cyclelim];
        peaknum{b,1}=[peaknum{b,1}; putrip.peaknum];
        amplitude{b,1}=[amplitude{b,1}; putrip.amplitude];
        putripples{b,1}=[putripples{b,1}; putrip.putripples];
        indx{b,1}=[indx{b,1}; putrip.indx]; % putative ablak eleje, vége adatpontban, ABSZOLÚT indexben
        maxfdata{b,1}=[maxfdata{b,1}; putrip.maxfdata];
        data{b,1}=[data{b,1}; putrip.data];
        fdata{b,1}=[fdata{b,1}; putrip.fdata];
        rmsfdata{b,1}=[rmsfdata{b,1}; putrip.rmsfdata];
        rectfdata{b,1}=[rectfdata{b,1}; putrip.rectfdata];
        maxsrms{b,1}=[maxsrms{b,1}; putrip.maxsrms];
        maxsrect{b,1}=[maxsrect{b,1}; putrip.maxsrect];
        peaks{b,1}=[peaks{b,1}; putrip.peaks];
        troughs{b,1}=[troughs{b,1}; putrip.troughs];
        rectpeakratio{b,1}=[rectpeakratio{b,1}; putrip.rectpeakratio]; 
        wavpow{b,1}=[wavpow{b,1}; putrip.wavpow];
        freq{b,1}=[freq{b,1}; putrip.fr];
        instfreqavg{b,1}=[instfreqavg{b,1}; putrip.instfreqavg];
        instfreqmin{b,1}=[instfreqmin{b,1}; putrip.instfreqmin];
        instfreqmax{b,1}=[instfreqmax{b,1}; putrip.instfreqmax];
        
%         rk{b,1}=[rk{b,1}; putrip.maxfdata(putrip.isripple==1)];
    end
       
end
h.putrip.isripple=isripple;
h.putrip.timelim=timelim;
h.putrip.duration=duration;
h.putrip.cyclelim=cyclelim;
h.putrip.peaknum=peaknum;
h.putrip.amplitude=amplitude;
h.putrip.putripples=putripples;
h.putrip.indx=indx; % putative körüli 300 ms hosszú ablak eleje, vége adatpontban, ABSZOLÚT indexben
h.putrip.maxfdata=maxfdata;
h.putrip.data=data;
h.putrip.fdata=fdata;
h.putrip.rmsfdata=rmsfdata;
h.putrip.rectfdata=rectfdata;
h.putrip.maxsrms=maxsrms;
h.putrip.maxsrect=maxsrect;
h.putrip.peaks=peaks;
h.putrip.troughs=troughs;
h.putrip.rectpeakratio=rectpeakratio; 
% h.putrip.wavpow=wavpow;
h.putrip.freq=freq;
h.putrip.instfreqavg=instfreqavg;
h.putrip.instfreqmin=instfreqmin;
h.putrip.instfreqmax=instfreqmax;
% h.putrip.rk=rk;
% h.ripple.rippbeg=rippbeg;
% h.ripple.rippend=rippend;
% h.ripple.peaknum=peaknum;
% h.ripple.amplitude=amplitude;
% h.ripple.duration=duration;
% h.ripple.freq=freq;
% h.ripple.rippnum=rippnum;
% h.ripple.followup=followup;
% h.ripple.putripborders=putripborders;
% h.ripple.out=out;
guidata(hObject,h);

% if exist('putripdata')==1
%     save([h.file(1:end-4) '_putripdata'],'putripdata', 'putripfdata', 'putriprmsfdata', 'putriprectfdata', 'putripmaxsrms', 'putripmaxsrect', 'putrippeaks', 'putriptroughs');
% end

if nargout>0,
    varargout{1}=h;
end
%%% SAVE ????