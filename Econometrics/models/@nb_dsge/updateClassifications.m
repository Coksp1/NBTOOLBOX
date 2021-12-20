function parser = updateClassifications(parser) 
% Syntax:
%
% parser = nb_dsge.updateClassifications(parser) 
%
% Description:
%
% Update classification given a nEndo x 3 matrix storing the lead, current
% and lag incident of variables.
% 
% See also:
% nb_dsge.parse, nb_dsge
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get classification
    leadCurrentLag            = parser.leadCurrentLag;
    parser.isStatic           = not(leadCurrentLag(:,1) | leadCurrentLag(:,3));
    parser.isForwardOrMixed   = leadCurrentLag(:,1);
    parser.isBackwardOrMixed  = leadCurrentLag(:,3);
    parser.isMixed            = leadCurrentLag(:,1) & leadCurrentLag(:,3);
    parser.isMixedInForward   = parser.isMixed(parser.isForwardOrMixed);
    parser.isMixedInBackward  = parser.isMixed(parser.isBackwardOrMixed);
    parser.isPurlyForward     = parser.isForwardOrMixed & ~parser.isMixed;
    parser.isPurlyBackward    = parser.isBackwardOrMixed & ~parser.isMixed;
    parser.nStatic            = sum(parser.isStatic);
    parser.nForwardOrMixed    = sum(parser.isForwardOrMixed);
    parser.nBackwardOrMixed   = sum(parser.isBackwardOrMixed);
    parser.nMixed             = sum(parser.isMixed);
    parser.nPurlyForward      = sum(parser.isPurlyForward);
    parser.nPurlyBackward     = sum(parser.isPurlyBackward);
    nMult                     = size(leadCurrentLag,1) - size(parser.isAuxiliary,1);
    parser.isAuxiliary        = [parser.isAuxiliary;true(nMult,1)];
    parser.isBackwardOnly     = ~any(leadCurrentLag(:,1));
    
end
