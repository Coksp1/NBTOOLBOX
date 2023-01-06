function Hlow = getIdiosyncraticMapping(options)
% Syntax:
%
% Hlow = nb_dfmemlEstimator.getIdiosyncraticMapping(options)
%
% Description:
%
% Get the mixed frequency mapping matrix.
%
% Inputs:
%
% - options : A struct with estimation options. See 
%             nb_dfmemlEstimator.template or nb_dfmemlEstimator.help.
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    nHigh = options.nHigh;
    nLow  = options.nLow;
    Hlow  = zeros(nLow,5*nLow);
    for ii = 1:nLow
        Hlow(ii,ii:nLow:end) = getOne(options,nHigh + ii);
    end

end

%==========================================================================
function Hi = getOne(options,index)

    switch lower(options.mapping{index})
        case 'levelsummed'
            Hi = [1,1,1,0,0];
        case 'levelaverage'
            Hi = [1,1,1,0,0]/3;
        case 'diffsummed'
            Hi = [1,2,3,2,1];
        case 'diffaverage'
            Hi = [1,2,3,2,1]/3;
        case 'end'
            Hi = [1,0,0,0,0];
        otherwise
            error([mfilename ':: Unsupported mapping ' options.mapping{nLow+ii}])
    end

end
