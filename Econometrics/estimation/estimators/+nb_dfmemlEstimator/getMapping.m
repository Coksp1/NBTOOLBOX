function [R,r] = getMapping(options,index)
% Syntax:
%
% [R,r] = nb_dfmemlEstimator.getMapping(options,index)
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
% - index   : The index of the low frequency variable of interest.
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    switch lower(options.mapping{index})
        case {'levelsummed','levelaverage'}
            R = [1 -1  0  0  0;
                 1  0 -1  0  0
                 0  0  0 -1  0;
                 0  0  0  0 -1];
        case {'diffsummed','diffaverage'}
            R = [2 -1  0  0  0;
                 3  0 -1  0  0;
                 2  0  0 -1  0;
                 1  0  0  0 -1];
        case 'end'
            R = [0 -1  0  0  0;
                 0  0 -1  0  0
                 0  0  0 -1  0;
                 0  0  0  0 -1];
        otherwise
            error([mfilename ':: Unsupported mapping ' options.mapping{nLow+ii}])
    end
    r = zeros(4,1);

end
