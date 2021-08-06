function [res,options] = recursiveEstimation(options,res)
% Syntax:
%
% [res,options] = nb_fmEstimator.recursiveEstimation(options,res)
%
% Description:
%
% Selects the wanted model class and recursivly estimate the model.
%
% Written by Kenneth S. Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Estimate the rest of the model conditional on the factors
    %----------------------------------------------------------
    if strcmpi(options.modelType,'dynamic')
        [res,options] = nb_fmEstimator.recursiveEstimationDynamic(options,res);
    elseif strcmpi(options.modelType,'favar') 
        [res,options] = nb_fmEstimator.recursiveEstimationFAVAR(options,res);
    elseif strcmpi(options.modelType,'singleEq') 
        [res,options] = nb_fmEstimator.recursiveEstimationSingleEq(options,res);    
    else
        [res,options] = nb_fmEstimator.recursiveEstimationStepAhead(options,res);
    end

end
