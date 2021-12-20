function dependent = getDependent(results,options)
% Syntax:
%
% dependent = nb_fmEstimator.getDependent(results,options)
%
% Description:
%
% Get the estimated model dependent values as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isfield(results,'predicted')
        dependent = nb_ts();
    else

        if strcmpi(options.modelType,'favar')
            dep   = [options.dependent,options.factors];
            pred  = results.predicted;
            resid = results.residual;
        elseif strcmpi(options.modelType,'dynamic')
            dep   = [options.dependent,options.factors];
            pred  = [results.predicted{:}];
            resid = [results.residual{:}];
        elseif strcmpi(options.modelType,'stepAhead')
            dep   = nb_cellstrlead(options.dependent,options.nStep);
            pred  = results.predicted;
            resid = results.residual;
        else
            dep   = options.dependent;
            pred  = results.predicted;
            resid = results.residual;
        end
        
        endInd    = options.estim_end_ind;
        start     = nb_date.date2freq(options.dataStartDate) + (endInd - size(resid,1) + 1);
        dependent = nb_ts(pred + resid, 'Dependent', start, dep); 

    end

end
