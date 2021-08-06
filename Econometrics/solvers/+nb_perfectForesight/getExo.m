function [varsExo,varsExoN,varsExoNS] = getExo(parser)
% Syntax:
%
% [varsExo,varsExoN,varsExoNS] = nb_perfectForesight.getExo(parser)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    [varsExoN,varsExoNS,varsExo] = nb_createGenericNames(parser.exogenous,'varsExo');
    
end
