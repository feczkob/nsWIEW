function [rk1,ripdata, varargout]=rippdetect_transform2(hand, h, ch)

switch h.ripple.meth,                    % Transform
    case 1,
        return;
    case 2,
        [rk1,ripdata]=feval(@ripple_m2,hand.data(:,ch),hand.srate,h.ripple.fr,h.ripple.rmssdlimit,h.ripple.cyclelimit,hand.sumsd(ch));
    case 3,
        if nargout<2
            [rk1,ripdata]=feval(@ripple_m3, ...
                hand.data(:,ch), ... 0
                hand.srate, ... 1
                h.ripple.fr, ... 2
                h.ripple.rmsms, ... 3
                h.ripple.rmssdlimit, ... 4
                h.ripple.rectsdlimit, ... 5
                h.ripple.cyclelimit, ... 6
                h.ripple.timelimit, ... 7
                h.ripple.betweenlimit, ... 8
                hand.sd.sumrmssd(ch), ... 9
                hand.sd.sumrmsmean(ch), ... 10
                hand.sd.sumrectsd(ch), ... 11
                hand.sd.sumrectmean(ch), ... 12
                hand.inxp, ... 13  
                0 ...          14
                );
        else
            [rk1,ripdata, bck]=feval(@ripple_m3_bck300, ...
                hand.data(:,ch), ... 0
                hand.srate, ... 1
                h.ripple.fr, ... 2
                h.ripple.rmsms, ... 3
                h.ripple.rmssdlimit, ... 4
                h.ripple.rectsdlimit, ... 5
                h.ripple.cyclelimit, ... 6
                h.ripple.timelimit, ... 7
                h.ripple.betweenlimit, ... 8
                hand.sd.sumrmssd(ch), ... 9
                hand.sd.sumrmsmean(ch), ... 10
                hand.sd.sumrectsd(ch), ... 11
                hand.sd.sumrectmean(ch), ... 12
                hand.inxp, ... 13  
                0 ...          14
                );
            varargout{1}=bck;
        end
    case 4,
        [rk1,ripdata]=feval(@ripple_m4, ...
            hand.data(:,ch), ... 0
            hand.srate, ... 1
            h.ripple.fr, ... 2
            hand.sd.peaktres(ch), ... 3
            h.ripple.cyclelimit, ... 4
            h.ripple.shortwin, ... 5
            hand.inxp, ... 6              
            0 ...   7
            );        
end