function [coeff,numCoeff] = getCoeff(options,type)
% Syntax:
%
% [coeff,numCoeff] = nb_bVarEstimator.getCoeff(options,type)
%
% Description:
%
% Get names of coefficients.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        type = '';
    end

    prior = options.prior;
    if isempty(prior)
        priorType = '';
    else
        priorType = options.prior.type;
    end
    if any(strcmpi(priorType,nb_var.mfPriors()))
        vars = [options.dependent,options.block_exogenous];
        if isfield(options,'indObservedOnly')
            vars = vars(~options.indObservedOnly);
        end
        exo = nb_cellstrlag(vars,options.nLags,'varFast');
        exo = [options.exogenous, exo];
    else
        exo = options.exogenous;
    end
    
    if strcmpi(type,'priors')

        % Standard errors are not included in this list!
        if size(exo,1) > 1
            exo = exo';
        end
        if options.constant && options.time_trend
            exo = [{'Constant','Time Trend'},exo];
        elseif options.constant
            exo = [{'Constant'},exo];
        elseif options.time_trend
            exo = [{'Time Trend'},exo];
        end
        secDim = [options.dependent,options.block_exogenous]';
        if isfield(options,'indObservedOnly')
            secDim = secDim(~options.indObservedOnly);
        end
        coeff  = nb_strcomb(secDim,exo');
        
    else
        
        if options.constant && options.time_trend
            coeff = [{'Constant','Time Trend'},exo];
        elseif options.constant
            coeff = [{'Constant'},exo];
        elseif options.time_trend
            coeff = [{'Time Trend'},exo];
        else
            coeff = exo;
        end
        
    end
    numCoeff = length(coeff);
    
end
