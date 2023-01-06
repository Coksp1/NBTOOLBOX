function [res,estOpt] = estimateOneLoop(estOpt)
% Syntax:
%
% [res,estOpt] = nb_model_estimate.loopEstimate(estOpt,names,inputs)
%
% Description:
%
% Call estimator of a given model.
% 
% Written by Kenneth Sæterhagen Paulsen
  
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    real_time_estim = false;
    if isfield(estOpt,'real_time_estim')
        real_time_estim  = estOpt.real_time_estim;
    end
    missing = false;
    if isfield(estOpt,'missingMethod')
        missing = ~isempty(estOpt.missingMethod);
    end
    if missing
        [res,estOpt] = nb_missingEstimator.estimate(estOpt);
    elseif real_time_estim
        [res,estOpt] = nb_realTimeEstimator.estimate(estOpt);
    else
        estim_method = estOpt.estim_method;
        if strcmpi(estim_method,'bVar')
            estim_method = 'bVar';
        end
        estimator    = str2func(['nb_' estim_method 'Estimator.estimate']);
        [res,estOpt] = estimator(estOpt);
    end

end
        
        
        
        
