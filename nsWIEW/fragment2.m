function [b, l, fb, fe]=fragment2(h, begin,lengt,sr,overlap,varargin)
% nswiew-bol kiemelve es atalakitva Emilia Toth
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
end;

if isempty(overlap),
    overlap=0;
end

if overlap>0.5 || overlap<0,
    return;
end

if lengt>10 && fsec<lengt,        
    fn=fix(lengt/(fsec*(1-overlap)));
    if lengt-(fn*fsec*(1-overlap))<fsec*1/4, 
%         fn=fn-1; 
    end;
    if overlap>0
        b=[begin:fsec*(1-overlap):begin+(fn)*fsec*(1-overlap)]'; %:begin+(fn-1)*fsec*(1-overlap)
        l=ones(fn,1)*fsec; l(end+1)=lengt-(fn)*fsec*(1-overlap);
%         fb=ones(fn,1)+(fsec*(overlap/2)*sr); fb(1)=1;
%         fe=ones(fn,1)*fsec*(1-overlap/2)*sr; fe(end)=l(end)*sr;
        fb=floor(b*h.srate); if fb(1)==0 fb(1)=1; end
        fl=floor(l*h.srate); 
        fe=fb+(fl-1);
    end
    if overlap==0
        b=begin:fsec:begin+(fn)*fsec'; %:begin+(fn-1)*fsec*(1-overlap)
        l=ones(fn,1)*fsec; l(end+1)=lengt-(fn)*fsec;
%         fb=ones(fn+1,1)+(fsec*sr); fb(1)=1;      % eredeti fragment.m-ben 
        fb=[1:(fsec*sr):fn*(fsec*sr)]'; fb(end+1)=fn*(fsec*sr)+1;
%         fe=ones(fn+1,1)*fsec*sr; fe(end)=l(end)*sr;  % eredeti fragment.m-ben 
        fe=[fsec*sr:fsec*sr:fn*(fsec*sr)]';
        fe(end+1)=fn*(fsec*sr)+l(end)*sr;
    end
    str=0;
else
    b=begin;
    l=lengt;
    fb=1;
    fe=lengt*sr;
end;        

overhalf_sec=fsec*(overlap/2);
if isfield(h,'artefact'),               % Artefact detection: Artefacts are stored in handles.artefact (n) : (n+1)
    if mod(length(h.artefact),2)==0,
        for art=1:2:length(h.artefact),
            fragends=b+l;
            artbegsec=h.artefact(art)/sr;
            artendsec=h.artefact(art+1)/sr;
            begfrag=find(b<=artbegsec & artbegsec<fragends);
            midfrag=find(artbegsec<b & fragends<artendsec);
            endfrag=find(b<artendsec & artendsec<=fragends);
           
            if length(begfrag)>1 || length(endfrag)>1,
                split=0;
            elseif begfrag==endfrag,
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
            if l_endfrag<=overhalf_sec,
                fe_endfrag=l_endfrag*sr;
            else
                fe_endfrag=(l_endfrag-overhalf_sec)*sr;
            end
            
            if ~split,
                l(begfrag)=l_begfrag;
                fe(begfrag)=fe_begfrag;
                
                b(endfrag)=b_endfrag;
                fb(endfrag)=fb_endfrag;
                l(endfrag)=l_endfrag;
                fe(endfrag)=fe_endfrag;
            else
                b= [b(1:begfrag); artendsec; b(begfrag+1:end)];
                fb=[fb(1:begfrag); artendsec*sr; fb(begfrag+1:end)];
                l= [l(1:begfrag-1); l_begfrag; l_endfrag; l(begfrag+1:end)];
                fe=[fe(1:begfrag-1); fe_begfrag; fe_endfrag; fe(begfrag+1:end)];
            end
             
            b(midfrag)=[];
            l(midfrag)=[];
            fb(midfrag)=[];
            fe(midfrag)=[];
        end
    else disp('Nem párosak az artefactok!!! Ellenõrizd és készítsd újra!')
    end
end
short=find(l<=overhalf_sec | l<0.2);
b(short)=[];
l(short)=[];
fb(short)=[];
fe(short)=[];

fb=fix(fb);
fe=fix(fe);