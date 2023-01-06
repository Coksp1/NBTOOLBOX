function options = parseOptions(varargin)
% Syntax:
%
% options = nb_gridcontainer.parseOptions(varargin)
%
% Description:
%
% Takes structs and key/value-pairs as inputs and returns a struct 
% with lowercase keys
% 
% Written by Henrik Halvorsen Hortemo

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    options = nb_parseOptions(varargin{:});
    
end
