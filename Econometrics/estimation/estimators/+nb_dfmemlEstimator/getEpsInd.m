function indEps = getEpsInd(options)
% Syntax:
%
% indEps = nb_dfmemlEstimator.getEpsInd(options)
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if options.mixedFrequency
        epsStart = options.nFactors*max(options.nLags,5) + 1;
        indEpsH  = epsStart:epsStart + options.nHigh - 1;
        indEpsL  = indEpsH(end)+1:indEpsH(end)+options.nLow; % Only the current eps equation has a residual for low frequency series!
        indEps   = [indEpsH,indEpsL];
    else
        N = options.nHigh;
        if N == 0
            N = options.nLow;
        end
        epsStart = options.nFactors*options.nLags + 1;
        indEps   = epsStart:epsStart + N - 1;
    end

end
