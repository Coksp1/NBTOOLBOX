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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if any(strcmpi(options(1).algorithm,{'unrestricted','beta'}))
        if options(1).unbalanced
            exo   = options(1).exogenous(1:options.nExo);
            nLags = options(1).nLags - options(1).exogenousLead;
            if options(1).exogenousLead > 0
                exoLead = nb_cellstrlead(exo,options(1).exogenousLead,'varFast',true);
            else
                exoLead = {};
            end
            if nLags < 0
                coeff = exoLead;
            else
                coeff = [exoLead, exo, nb_cellstrlag(exo,nLags,'varFast')];
            end
        else
            coeff = options(1).exogenous;
        end
        if strcmpi(options(1).algorithm,'beta')
            coeff = [coeff, {'beta','theta1','theta2'}];
        end
    elseif strcmpi(options(1).algorithm,'mean')
        coeff = strcat({'Mean '}, options(1).exogenous(1:options.nExo));
    else
        coeff = nb_appendIndexes('Coeff',1:options(1).polyLags*options(1).nExo)';
    end
    if options(1).AR
        coeff = [{'AR'},coeff];
    end
    if options(1).constant
        coeff = [{'Constant'},coeff];
    end
    numCoeff = length(coeff);
    
end
