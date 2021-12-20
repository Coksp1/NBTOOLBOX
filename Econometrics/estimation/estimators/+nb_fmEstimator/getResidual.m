function residual = getResidual(results,options)
% Syntax:
%
% residual = nb_fmEstimator.getResidual(results,options)
%
% Description:
%
% Get the estimated model residuals as a nb_ts object
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isfield(results,'residual')
        residual = nb_ts();
    else
        
        if strcmpi(options.modelType,'favar')
            dep   = [options.dependent,options.factors];
            resid = results.residual;
        elseif strcmpi(options.modelType,'dynamic')
            dep   = [options.dependent,options.factors];
            resid = [results.residual{:}];
        elseif strcmpi(options.modelType,'stepAhead')
            dep   = nb_cellstrlead(options.dependent,options.nStep);
            resid = results.residual;
        else
            dep   = options.dependent;
            resid = results.residual;
        end

        endInd   = options.estim_end_ind;
        start    = nb_date.date2freq(options.dataStartDate) + (endInd - size(resid,1) + 1);
        vars     = strcat('E_',dep);
        residual = nb_ts(resid, 'Residuals', start, vars); 

    end

end
