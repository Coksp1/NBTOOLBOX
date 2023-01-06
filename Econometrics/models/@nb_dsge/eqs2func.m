function parser = eqs2func(parser,eqId)
% Syntax:
% 
% parser = nb_dsge.eqs2func(parser)
% parser = nb_dsge.eqs2func(parser,eqId)
%
% Description:
%
% Convert equation of the model to a function handle. 
%
% Static private method.
% 
% See also:
% nb_dsge.parse, nb_dsge.addEquation
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 2
        eqId = 'equationsParsed';
    end
    [eqs,eqFunc]      = nb_dsge.eqs2funcSub(parser,parser.(eqId));
    parser.eqFunction = eqFunc;
    if strcmpi(eqId,'equationsParsed')
        parser.equationsParsed = eqs;
    end
    
end

