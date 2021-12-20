function factors = getFactors(results,options)
% Syntax:
%
% factors = nb_fmEstimator.getFactors(results,options)
%
% Description:
%
% Get the estimated factors of the estimated model as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isfield(results,'predicted')
        factors = nb_ts();
    else

        startInd = options.estim_start_ind;
        endInd   = options.estim_end_ind;
        if isempty(startInd)
            start = nb_date.date2freq(options.dataStartDate);
        else
            start = nb_date.date2freq(options.dataStartDate) + (options.estim_start_ind - 1);
        end
        
        factors  = regexp(options.dataVariables,'Factor[0-9]*','match');
        factors  = nb_nestedCell2Cell(factors);
        [~,indF] = ismember(factors,options.dataVariables);
        F        = options.data(startInd:endInd,indF); 
        factors  = nb_ts(F, 'Factors', start, factors); 

    end

end
