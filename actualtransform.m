function h=actualtransform(h,varargin)

% NSWIEW function 
% handles=actualtransform(handles,transform number)
%
% transform number:
% 1: collect wavelet scale-average
% 2: collect 1 interpolated and corrigated channel
% 3: collect interpolated events INTERP EEG
% 4: calculate corrected csd; in the nswiew window: +c+l+b INTERP AVG
% 5: artefactreject only for events
% 6: give the max value allover the channels at the event 
% 7: peak detect within range on selected channel
% 8: HW on selected ch; if corr_eeg (at#3) is filled, interpolate the channel
% 9: AREA on selected ch; if corr_eeg (at#3) is filled, interpolate the channel
% 10: Give the maximum on 1 NOT interp channel
% 11: Average simple
% 12: FFT AVG
% 13: Signal to noise RMS (interp)
% 14: Extract 1 corrigated channel (interp)
% 15: Extract 1 channel (NOT interp)
% 16: Detect oscillation peaks (not interp)
% 17: Ripple detector (may not work)
% 18: Collect averaged period of time on all channels
% 19: Peaknum
% 20: RMS peak value
% 
% Output: h.actualtransformout

if ~isfield(h,'actualtransformout'),
	h.actualtransformout=[];
end;

if nargin==1, 
    trn=1; 
else
    trn=varargin{1};
end

eval(['h=at',num2str(trn),'(h);']);