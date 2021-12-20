function [varsExo,varsExoN,varsExoNS] = getExo(parser)
% Syntax:
%
% [varsExo,varsExoN,varsExoNS] = nb_perfectForesight.getExo(parser)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [varsExoN,varsExoNS,varsExo] = nb_createGenericNames(parser.exogenous,'varsExo');
    
end
