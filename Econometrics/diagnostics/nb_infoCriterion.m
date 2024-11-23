function infoCrit = nb_infoCriterion(type,logLikelihood,T,numCoeff,kappa)
% Syntax:
%
% infoCrit = nb_infoCriterion(type,loglogLikelihood,T,numCoeff)
%
% Description:
%
% Calculates the information criterion for a model given the
% logLikelihood, sample size and number of coefficients.
%
% All input but the first can be given as vectors (of same size).
%
% Input:
%
% - type : Either:
%
%   > 'aic'  : Akaike information criterion.
%
%   > 'aicc' : Corrected Akaike information criterion.
%
%   > 'maic' : Modified Akaike information criterion.
%
%   > 'sic'  : Schwarz information criterion.
%
%   > 'msic' : Modified Schwarz information criterion.
%
%   > 'hqc'  : Hannan and Quinn information criterion.
%
%   > 'mhqc' : Modified Hannan and Quinn information criterion.
%
% - loglogLikelihood : The models log logLikelihood. As a 1 x neq 
%                      double.
%
% - T                : Size of estimation sample. As a scalar.
%
% - numCoeff         : The number of estimated coefficients of the 
%                      model. A 1 x neq double.
%
% - kappa            : Modifiying element for the 'maic', 'msic'
%                      and 'mhqc' criterion. A 1 x neq double.
% 
% Output:
% 
% - infoCrit : The calculated information criterion. A 1 x neq 
%              double.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 5
        kappa = 0;
    end

    switch lower(strtrim(type))
       
        case {'aic',''}
            
            infoCrit = -2*(logLikelihood./T) + 2*numCoeff./T;
            
        case 'aicc'
            
            correction = T./(T - numCoeff - 1);
            infoCrit   = -2*(logLikelihood./T) + (2*numCoeff.*correction)./T;
            
        case 'maic'
            
            infoCrit = -2*(logLikelihood./T) + 2*(numCoeff + kappa)./T;    
            
        case 'sic'
            
            infoCrit = -2*(logLikelihood./T) + (numCoeff.*log(T))./T;
            
        case 'msic'
            
            infoCrit = -2*(logLikelihood./T) + ((numCoeff + kappa).*log(T))./T;    
            
        case 'hqc'
            
            infoCrit = -2*(logLikelihood./T) + (2*numCoeff.*log(log(T)))./T;
            
        case 'mhqc'
        
           infoCrit = -2*(logLikelihood./T) + (2*(numCoeff + kappa).*log(log(T)))./T; 
            
        otherwise
            
            error([mfilename ':: Unsupported information criterion ' type])
            
    end

end
