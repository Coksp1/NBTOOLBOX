function parser = updateDynamicOrder(parser)
% Syntax:
% 
% parser = nb_dsge.updateDynamicOrder(parser)
%
% Description:
%
% Update order of dynamic variables. 
%
% Static private method.
% 
% See also:
% nb_dsge.parse, nb_dsge.addEquation
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    endo                = parser.endogenous;
    purlyBackward       = endo(parser.isPurlyBackward);
    forward             = endo(parser.isForwardOrMixed);
    drOrder             = [purlyBackward,forward];
    dynamic             = endo(~parser.isStatic);
    [~,reorder]         = ismember(dynamic,drOrder);
    parser.dynamicOrder = reorder;
    
end
