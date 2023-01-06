function agg = getAggregationScheme(options,index)
% Syntax:
%
% agg = nb_tvpmfsvEstimator.getAggregationScheme(options,index)
%
% Description:
%
% Get the mixed frequency aggregation scheme for the selected variable.
%
% Inputs:
%
% - options : A struct with estimation options. See 
%             nb_tvpmfsvEstimator.template or nb_tvpmfsvEstimator.help.
%
% - index   : The index of the low frequency variable of interest.
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    divFreq = 3;
    switch lower(options.mapping{index})
        case 'levelsummed'
            agg = ones(1,2*divFreq - 1);
        case 'levelaverage'
            agg = ones(1,2*divFreq - 1)/divFreq;
        case 'diffsummed'
            Hi1 = 1:divFreq;
            Hi2 = divFreq-1:-1:1;
            agg = [Hi1,Hi2];     
        case {'diffaverage',''} % If empty, we default to this!
            Hi1 = 1:divFreq;
            Hi2 = divFreq-1:-1:1;
            agg = [Hi1,Hi2]/divFreq; 
        case 'end'
            agg    = zeros(1,2*divFreq - 1);
            agg(1) = 1;
        otherwise
            error([mfilename ':: Unsupported mapping ' options.mapping{nLow+ii}])
    end

end
