function [coeff,numCoeff] = getCoeff(options)
% Syntax:
%
% [coeff,numCoeff] = nb_midasEstimator.getCoeff(options)
%
% Description:
%
% Get names of coefficients.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if strcmpi(options(1).algorithm,'unrestricted')
        exo    = options(1).exogenous(1:options.nExo);
        nCoeff = max(options(1).nLags + 1);
        coeff  = cell(options.nExo,nCoeff);
        for ii = 1:options.nExo
            coeffThis = nb_appendIndexes('Coeff',1:options(1).nLags(ii) + 1)';
            coeffThis = strcat(coeffThis,['(' exo{ii} ')']);
            coeff(ii,1:length(coeffThis)) = coeffThis;
        end
        coeff = coeff(:);
        coeff = coeff(~cellfun(@isempty,coeff))';
    elseif strcmpi(options(1).algorithm,'beta')
        coeff = strcat('Coeff1(',options(1).exogenous(1:options.nExo),')');
        coeff = [coeff,{'theta2'}];
    elseif strcmpi(options(1).algorithm,'mean')
        coeff = strcat('Coeff1(', options(1).exogenous(1:options.nExo),')');
    else
        exo    = options(1).exogenous(1:options.nExo);
        nCoeff = max(options(1).polyLags + 1);
        coeff  = cell(options.nExo,nCoeff);
        for ii = 1:options.nExo
            coeffThis = nb_appendIndexes('Coeff',1:options(1).polyLags(ii))';
            coeffThis = strcat(coeffThis,['(' exo{ii} ')']);
            coeff(ii,1:length(coeffThis)) = coeffThis;
        end
        coeff = coeff(:);
        coeff = coeff(~cellfun(@isempty,coeff))';
    end
    if options(1).AR
        coeff = [{'AR'},coeff];
    end
    if options(1).constant
        coeff = [{'Constant'},coeff];
    end
    numCoeff = length(coeff);
    
end
