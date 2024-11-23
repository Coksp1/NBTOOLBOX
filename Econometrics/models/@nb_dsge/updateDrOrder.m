function parser = updateDrOrder(parser)
% Syntax:
% 
% parser = nb_dsge.updateDrOrder(parser)
%
% Description:
%
% Update derivative order. 
%
% Static private method.
% 
% See also:
% nb_dsge.parse, nb_dsge.addEquation
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    endo           = parser.endogenous;
    static         = endo(parser.isStatic);
    purlyBackward  = endo(parser.isPurlyBackward);
    forward        = endo(parser.isForwardOrMixed);
    drOrder        = [static,purlyBackward,forward];
    [~,reorder]    = ismember(endo,drOrder);
    parser.drOrder = reorder;
    
end
