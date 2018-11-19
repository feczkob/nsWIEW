function [pr]=ripple_m3_bck300(data,varargin)
% [ripmax,varargout]=ripple_m3(data,varargin)
% csak vectorra fut, vagyis az eredmény az adott csatornára vonatkozik, az
% adott szakaszon belüli indexekkel
% Before running this, run SD Calc, or load SD data from file

% method based on Staba 2002+
% input:    data: unfiltered data
%           varargin(1): sample rate
%           varargin(2): range of the band pass filtering        [80-500Hz] 
%           varargin(3): LIMIT RMS WINDOW size                        [3ms]
%           varargin(4): LIMIT multiplier number of RMS std             [5]
%           varargin(5): LIMIT multiplier number of RECTIFIED std       [3]
%           varargin(6): LIMIT number of the minimum FULL cycles,       [3]
%                              (will be doubled for the RECTIFIED data) 
%           varargin(7): LIMIT time of minimum ripple duration        [6ms]
%           varargin(8): LIMIT time minimum between ripples,         [10ms]                
%                              (under it putative ripples will be merged) 
%           varargin(9): the RMS SD value
%           varargin(10): the RMS MEAN value
%           varargin(11): the RECTIFIED SD value
%           varargin(12): the RECTIFIED MEAN value 
%           varargin(13): index of the window begining EZT NEM ITT ADJA HOZZÁ!!
%           varargin(14): plotswitch
% output:   ripmax: the index of the RECT FDATA max value above the 5*RMS
% SD limit szakaszon belül
%           varargout{1}: rippdata.rippbeg=ripbeg;
%                         rippdata.rippend=ripend;
%                         rippdata.peaknum=peaknum;
%                         rippdata.rmssdlimit=rmssdlimit_;
%                         rippdata.followup=followup;
%                         rippdata.putripborders
%           varargout{2}:
%                         bckdata.fdata=fdata;
%                         bckdata.rmsfdata=rmsfdata;
%                         bckdata.rectfdata=rectfdata;
%                         bckdata.time=time;
%                         bckdata.maxsrms=maxsrms;
%                         bckdata.maxsrect=maxsrect;
%                         varargout{2}=bckdata;


%%%%%%%%%%% PLOTSWITCH  %%%%%%%%%%%%%%%%%

if nargin==15,
    plotswitch=varargin{14};
else
    plotswitch=1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if nargin==1,
    prompt  = {'Sampling rate (Hz)','Fr','RMS ms (recommended: 1/fr_expected)','RMS std limit','Rect. std limit','Minimum rect cycles','Ripple timelimit (ms)','Between ripple time limit (ms)'};
    ftitle   = 'Give the parameters';
    lines= 1;
    def     = {'2000','80 500','3','5','3','3','6','10'};
    answer  = inputdlg(prompt,ftitle,lines,def);
    srate=str2double(answer{1}); %sampling rate
    si=regexp(answer{2}, '\s');
    fr=[str2double(answer{2}(1:si-1)) str2double(answer{2}(si+1:end))];  %str2double(answer{2});  %frequency
%     fr=str2double(answer{2});  %frequency
    rmsms=str2double(answer{3}); %rms window size
    limit1=str2double(answer{4}); %rms std limit
    limit2=str2double(answer{5}); %rect. std limit
    limit3=str2double(answer{6}); %minimum cycle limit (FULL)
    limit4=str2double(answer{7}); %timelimit
    limit5=str2double(answer{8}); %between ripple
    index=1;
else
    srate=varargin{1}; 
    fr=varargin{2}; 
    rmsms=varargin{3}; 
    limit1=varargin{4};  %rms std limit 5
    limit2=varargin{5};  %rect. std limit
    limit3=varargin{6};  %minimum cycle limit (FULL)
    limit4=varargin{7};  %timelimit
    limit5=varargin{8}; %between limit
    sumrmssd=varargin{9};   %RMS SD
    sumrmsmean=varargin{10}; %RMS MEAN
    sumrectsd=varargin{11}; %RECT SD
    sumrectmean=varargin{12}; %RECT MEAN
    index=varargin{13}; %hand.inxp
end

%% DATA PreProcessing
[cc, aa]=butter(2,[fr(1)/srate*2 fr(2)/srate*2],'bandpass'); 

fdata=filtfilt(cc,aa,data);
rmsfdata=rms(fdata,fix(rmsms*srate/1000));
rectfdata=abs(fdata);

time=[0:length(fdata)-1]*1000/srate; 

sdrmslocaldata=std(rmsfdata);
sdrectlocaldata=std(rectfdata);
meanrmslocaldata=mean(rmsfdata);

%% LIMITS
if nargin==1,
    rmssdlimit_=limit1*sdrmslocaldata+meanrmslocaldata; %rms std limit
    rectsdlimit=limit2*sdrectlocaldata; %rect. std limit
else
    rmssdlimit_=(limit1*sumrmssd)+sumrmsmean; %rms std limit
    rectsdlimit=limit2*sumrectsd+sumrectmean; %rect. std limit    
end
cyclelimit=limit3*2;
timelimit=limit4*srate/1000;
betweenlimit=limit5*srate/1000;

%% CALCULATION

[maxsrms mins putripborders]=amplfind(rmsfdata,[min(rmsfdata) rmssdlimit_]);    % find the peaks for putative events
% [maxsrect mins2 maxintsrect]= amplfind(rectfdata,[0 rectsdlimit]);  % subjecting
[peaks troughs]=peakfind(rectfdata);
valpeaks=rectfdata(peaks);
crosstreshold=find(valpeaks>rectsdlimit);
maxsrect=peaks(crosstreshold);

% Delete those significant peaks that are not separated from the others by 
% significant troughs
valpeaks=rectfdata(maxsrect);
maxsrecttodelete=[];
ratio=zeros(length(maxsrect)-1,1);
for o=1:length(maxsrect)-1,
    acttroughs=find(maxsrect(o)<troughs & troughs<maxsrect(o+1));
    actpeaks=maxsrect(o:o+1);
    valacttroughs=rectfdata(troughs(acttroughs));
    valtrough=min(valacttroughs);
    valactpeaks=rectfdata(actpeaks);
    [mmmm maxvalpeak]=max(valactpeaks);
    maxvalpeak=maxvalpeak-1;
    smallerpeak=1-maxvalpeak+o;
    valsmallerpeak=valpeaks(smallerpeak);
    ratio(o,1)=valsmallerpeak-valtrough;
    if ratio(o,1)<rectsdlimit,
        maxsrecttodelete(end+1)=smallerpeak;
    end
end
maxsrect(maxsrecttodelete)=[];
putripborders_merge=[];
putripples_out=putripborders;
if size(maxsrms)~=0,
    % Validating putative ripples
    % Between Ripple time
    beetw=putripborders(2:end,1)-putripborders(1:end-1,2);
    short=find(beetw<betweenlimit);
    putripborders_merge=putripborders;
    for e=length(short):-1:1;
        putripborders_merge(short(e),2)=putripborders_merge(short(e)+1,2);
        putripborders_merge(short(e)+1,:)=[];
    end
    followup.ripples(2)=size(putripborders_merge,1);
    putripples_out=putripborders_merge;
   
    % Ripple time limit 
    putriptime=ones(length(putripples_out),1);
    rippint=putripborders_merge(:,2)-putripborders_merge(:,1);
    ripp_no=find(rippint<timelimit);
    putripborders_merge_timelim=putripborders_merge;
    putripborders_merge_timelim(ripp_no,:)=[];
    putriptime(ripp_no)=0; %% azok a putative ripple-k, amiknek nincsen meg az idõ limitjük, túl rövidek
  
    % Cycle limit
    parit=ones(1,size(putripples_out,1));
    peaknum=zeros(size(putripples_out,1),1);
    putripcycle=ones(length(putripples_out),1);
    ws=300; % ms 
    wst=50; % ms
    wsdp=floor(ms2dp(ws, srate));
    wstdp=floor(ms2dp(wst, srate));
    prmid=floor(mean(putripples_out, 2));           % putative ripple közepe
    indxb=prmid-floor(wsdp/2); %indxb(indxb<0)=1;    % adott putative ripple-t tartalmazó 300 ms  ablak kezdeti RELATÍV indexe 
    indxe=prmid+floor(wsdp/2); %indxe(indxe>size(data,1))=size(data,1); % vége RELATÍV indexe  a beolvasott adatból
    theowinb=prmid-floor(wstdp/2);                  % relatív kezdeti indexe a belsõ ablakocskának
    theowine=prmid+floor(wstdp/2);                  % relatív vég indexe a belsõ ablaknak
    winratio=fix(wst/(ws-wst));              % ablak arány, vagyis, hogy a belsõ ablak hogyan arányul a nagy ablakhoz  winratio=fix(50*100/(windowsize*1000-50));          

    putripfdatamax=zeros(length(putripples_out),1);
    putripmaxsrms=cell(size(putripples_out,1),1);
    putripmaxsrect=cell(size(putripples_out,1),1);
    putrippeaks=cell(size(putripples_out,1),1);
    putriptrough=cell(size(putripples_out,1),1);
    data2=zeros(size(putripples_out,1), wsdp); fdata2=zeros(size(putripples_out,1), wsdp); rmsfdata2=zeros(size(putripples_out,1), wsdp); rectfdata2=zeros(size(putripples_out,1), wsdp);
    wavpow=zeros(size(putripples_out,1),1); wavfr=zeros(size(putripples_out,1),1);
    avgfreq=zeros(size(putripples_out,1),1); maxfreq=zeros(size(putripples_out,1),1); minfreq=zeros(size(putripples_out,1),1);
    amplitude=zeros(size(putripples_out,1),1);
    for o=1:size(putripples_out,1)
         peaknum(o)=length(find(putripples_out(o,1)<=maxsrect & maxsrect<=putripples_out(o,2)));
         if peaknum(o)<cyclelimit,
            putripcycle(o)=0;
         end
         
        [~, fdatamaxi]=max(fdata(putripples_out(o,1):putripples_out(o,2)));
        putripfdatamax(o,1)=fdatamaxi+putripples_out(o,1);    % a putrip-ek legmagasabb csúcs az fdata-n indexben
        %AMPLITUTUDE: envelope max    
        maxsrms_inevent=find(putripples_out(o,1)<=maxsrms & maxsrms<=putripples_out(o,2));
        putripmaxsrms{o,1}= maxsrms(maxsrms_inevent)+index;
        max_amplsrms_inevent=max(rmsfdata(maxsrms(maxsrms_inevent)));
        amplitude(o,1)=max_amplsrms_inevent;    %% rmsfdata-n a legnagyobb csúcs amplitudója
        %%% RECTPEAKRATIO                                                   %
        %a rect peak csúcsok amplitudó értékeinak aránya az ablak közepiekkel és a széleikkel
        %viszonyítva
        if indxb(o)<1 || indxe(o)>size(data,1) % length(rectfdata(indxb(o):indxe(o)))< size(rectfdata2,2); %% ha nem egész hosszú adatunk van a határok miatt
            if indxb(o)<0
                rectfdata2(o,1:length(rectfdata(1:indxe(o))))=rectfdata(1:indxe(o));
                data2(o,1:length(rectfdata(1:indxe(o))))=data(1:indxe(o));
                fdata2(o,1:length(rectfdata(1:indxe(o))))=fdata(1:indxe(o));
                rmsfdata2(o,1:length(rectfdata(1:indxe(o))))=rmsfdata(1:indxe(o));
            end
            if indxe(o)>size(data,1)
                rectfdata2(o,end-length(rectfdata(indxb(o):end))+1:end)=rectfdata(indxb(o):end);
                data2(o,end-length(rectfdata(indxb(o):end))+1:end)=data(indxb(o):end);
                fdata2(o,end-length(rectfdata(indxb(o):end))+1:end)=fdata(indxb(o):end);
                rmsfdata2(o,end-length(rectfdata(indxb(o):end))+1:end)=rmsfdata(indxb(o):end);
            end
        else
            rectfdata2(o,:)=rectfdata(indxb(o):indxe(o));
            data2(o,:)=data(indxb(o):indxe(o));
            fdata2(o,:)=fdata(indxb(o):indxe(o));
            rmsfdata2(o,:)=rmsfdata(indxb(o):indxe(o));
        end
        maxsrectwin=maxsrect(indxb(o)<=maxsrect & indxe(o)>=maxsrect)-indxb(o)+1;      % data for rectfdata peak ratio in the window
        inwin=maxsrect(theowinb(o)<=maxsrect & theowine(o)>=maxsrect)-indxb(o)+1;
        outwin=setdiff(maxsrectwin, inwin);
%         figure(1)
%         plot(rectfdata2(o, :))
%         hold on
%         plot(maxsrectwin, rectfdata2(o,maxsrectwin), 'ro')
        if isempty(outwin)==0 && isempty(inwin)==0
            if sum(rectfdata2(o,outwin))==0,
                ratio2=sum(rectfdata2(o,inwin))/1;
            else
                ratio2=sum(rectfdata2(o,inwin))/sum(rectfdata2(o,outwin));
            end
        else
            ratio2=0;
        end
        ratio2(o,1)=fix(ratio2*100)-winratio;  % ratio over expected based on inside/outside time ratio % de miért szorozza meg 100zal?
        putripmaxsrect{o,1}=maxsrect(putripples_out(o,1)<=maxsrect & putripples_out(o,2)>=maxsrect)+index;
        putrippeaks{o,1}=peaks(putripples_out(o,1)<=peaks & putripples_out(o,2)>=peaks)+index;
        putriptrough{o,1}=troughs(putripples_out(o,1)<=troughs & putripples_out(o,2)>=troughs)+index;
        %%% wavelet freq
        Y=data2(o,:); %%%szamunkra erdekes szakasz
        variance=std(Y)^2; %%% adott szakasz varianciája
        Y=(Y-mean(Y))/sqrt(variance) ;        
        [~,power,period,~,~]=wavelet_morlet_fr(Y,1/srate,fr(1),fr(2), 100); % a szûretlen, DE NORMALIZÁLT adatból számol waveletet!!!!
        dt=1/srate*1000;
        tlength=length(Y);
        time=[0:tlength-1];
        time=(time-fix(tlength/2))*dt;
        timeindex= -wst/2<=time & time<=wst/2; % kiveszi a középsõ 50 ms-t
        lgpower=log2(power)';
        mean_lgpower=mean(lgpower(timeindex,:)); % átlagolja
        [~, loc]=max(mean_lgpower);               % megkeresi a csúcsát                  % és a csúcsához tartozó frekvencia értéket
        [~, powpeaksi]=findpeaks(mean_lgpower, 'sortstr', 'descend');
%         wavpow(o,:)=mean_lgpower;    % elmenti az átlagos frekvencia érték  görbét
        if isempty(powpeaksi)==0
            wavfr(o)=1./period(powpeaksi(1));                      % és a legnagyobb csúcsához tartozó frekvenciát
        else
            wavfr(o)=1./period(loc);    
        end
        %%% instant freq
%         diwp=diff(putripmaxsrect{o,1})*2; %% a putripen belüli rect csúcsokra, és mivel csúcstól csúcsig csak fél periódus, azért a teljes periódusidõ kiszámolásához szorozni kell 2 vel!!! Javítva Tóth Emília, 2015.05.29.
        diwp=diff( putrippeaks{o,1})*2;
        if isempty(diwp)==0,
            avgfreq(o,1)=srate/mean(diwp); % átlagos instant freq
            maxfreq(o,1)=srate/min(diwp);  % legnagyobb instant freq
            minfreq(o,1)=srate/max(diwp);  % legkisebb instant freq
        end
    end 

    ripple=(putriptime & putripcycle); %%% logikai vector, mutatja, hogy aputative ripple-k közül melyik valóban ripple a STABA kritériumok szerint
    pr.isripple=ripple;
    pr.timelim=putriptime;
    pr.duration=(putripples_out(:,2)-putripples_out(:,1))/srate*1000;
    pr.cyclelim=putripcycle;
    pr.peaknum=peaknum;
    pr.amplitude=amplitude;
    pr.putripples=putripples_out+index;
    pr.indx=[indxb+index indxe+index]; % putative ablak eleje, vége adatpontban, ABSZOLÚT indexben
    pr.maxfdata=putripfdatamax+index;
    pr.data=data2;
    pr.fdata=fdata2;
    pr.rmsfdata=rmsfdata2;
    pr.rectfdata=rectfdata2;
    pr.maxsrms=putripmaxsrms;
    pr.maxsrect=putripmaxsrect;
    pr.peaks=putrippeaks;
    pr.troughs=putriptrough;
    pr.rectpeakratio=ratio2; 
    pr.rmslimit=rmssdlimit_;
    pr.wavpow=wavpow;
    pr.fr=wavfr;
    pr.instfreqavg=avgfreq;
    pr.instfreqmin=minfreq;
    pr.instfreqmax=maxfreq;

%     figure(2)
%     subplot(3,1,1)
%     plot(rmsfdata), hold on
%     plot(putripborders_merge, rmsfdata(putripborders_merge), 'ro')
%     plot([0 length(rmsfdata)], [rmssdlimit_ rmssdlimit_], 'r-'), hold off
%     subplot(3,1,2)
%     plot(rectfdata), hold on
%     plot(maxsrect, rectfdata(maxsrect), 'ro')
%     plot([0 length(rectfdata)], [rectsdlimit rectsdlimit], 'r-'), hold off
else
    %%%%%%%%% NO PUTATIVE RIPPLE
    pr.isripple=[];
    pr.timelim=[];
    pr.duration=[];
    pr.cyclelim=[];
    pr.peaknum=[];
    pr.amplitude=[];
    pr.putripples=[];
    pr.indx=[]; % putative ablak eleje, vége adatpontban, ABSZOLÚT indexben
    pr.maxfdata=[];
    pr.data=[];
    pr.fdata=[];
    pr.rmsfdata=[];
    pr.rectfdata=[];
    pr.maxsrms=[];
    pr.maxsrect=[];
    pr.peaks=[];
    pr.troughs=[];
    pr.rectpeakratio=[];
    pr.rmslimit=[];
    pr.amplitude=[];
    pr.wavpow=[];
    pr.fr=[];
    pr.instfreqavg=[];
    pr.instfreqmin=[];
    pr.instfreqmax=[];
end

% %% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%
% % 
% if nargout>1
%     varargout{1}=pr;
% end
