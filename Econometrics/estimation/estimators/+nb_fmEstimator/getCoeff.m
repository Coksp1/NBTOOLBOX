function [coeff,numCoeff] = getCoeff(options,observationEq)
% Syntax:
%
% [coeff,numCoeff] = nb_fmEstimator.getCoeff(options,observationEq)
%
% Description:
%
% Get names of coefficients.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 2
        observationEq = false;
    end

    % Construct the coeff names
    options = options(end);
    if observationEq
        
        if strcmpi(options.modelType,'favar')
            if isempty(options.observablesFast)
                coeff = ['constant',options.factors,options.dependent];
            else
                coeff = ['constant',options.factors];
            end
        elseif strcmpi(options.modelType,'dynamic')
            coeff         = nb_fmEstimator.getAllDynamicRegressors(options);
            allRegressors = nb_fmEstimator.getAllDynamicRegressors(options,'all');
            coeff         = allRegressors(length(coeff)+1:end);
        else
            coeff = ['constant',options.factors];
        end
        
    else
    
        if strcmpi(options.modelType,'dynamic')

            coeff = nb_fmEstimator.getAllDynamicRegressors(options);

        elseif strcmpi(options.modelType,'favar') 

            coeff = [options.exogenous, options.factorsRHS];
            if options.constant && options.time_trend
                coeff = [{'Constant','Time Trend'},coeff];
            elseif options.constant
                coeff = [{'Constant'},coeff];
            elseif options.time_trend
                coeff = [{'Time Trend'},coeff];
            end

        elseif strcmpi(options.modelType,'singleEq') 

            coeff = options.exogenous;
            if options.constant && options.time_trend
                coeff = ['Constant','Time Trend',coeff,options.factorsRHS];
            elseif options.constant
                coeff = ['Constant',coeff,options.factorsRHS];
            elseif options.time_trend
                coeff = ['Time Trend',coeff,options.factorsRHS];
            else
                coeff = [coeff,options.factorsRHS];
            end

        else

            if options.constant && options.time_trend
                coeff = [{'Constant','Time Trend'},options.factorsRHS{:}];
            elseif options.constant
                coeff = [{'Constant'},options.factorsRHS{:}];
            elseif options.time_trend
                coeff = [{'Time Trend'},options.factorsRHS{:}];
            else
                coeff = [{},options.factorsRHS{:}];
            end

        end
        
    end
    
    numCoeff = length(coeff);

end
