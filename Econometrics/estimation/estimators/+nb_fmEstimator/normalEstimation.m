function [res,options] = normalEstimation(options,res)
% Syntax:
%
% [res,options] = nb_fmEstimator.normalEstimation(options,res)
%
% Description:
%
% Selects the wanted model class and estimate the model.
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Estimate the rest of the model conditional on the factors
    %----------------------------------------------------------
    if strcmpi(options.modelType,'dynamic')
        [res,options] = nb_fmEstimator.normalEstimationDynamic(options,res);
    elseif strcmpi(options.modelType,'favar') 
        [res,options] = nb_fmEstimator.normalEstimationFAVAR(options,res);
    elseif strcmpi(options.modelType,'singleEq') 
        [res,options] = nb_fmEstimator.normalEstimationSingleEq(options,res);
    else
        [res,options] = nb_fmEstimator.normalEstimationStepAhead(options,res);
    end

end
