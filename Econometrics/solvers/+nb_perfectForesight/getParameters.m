function [paramN,paramNS,pars] = getParameters(parser)
% Syntax:
%
% [paramN,paramNS,pars] = nb_perfectForesight.getParameters(parser)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    [paramN,paramNS,pars] = nb_createGenericNames(parser.parameters,'pars'); 
    
end
