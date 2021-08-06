function [paramN,paramNS,pars] = getParameters(parser)
% Syntax:
%
% [paramN,paramNS,pars] = nb_perfectForesight.getParameters(parser)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    [paramN,paramNS,pars] = nb_createGenericNames(parser.parameters,'pars'); 
    
end
