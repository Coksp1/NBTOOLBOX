function ss = ssStruct2ssDouble(parser,s,default)
% Syntax:
%
% ss = nb_dsge.ssStruct2ssDouble(parser,s)
% ss = nb_dsge.ssStruct2ssDouble(parser,s,default)
%
% Description:
%
% Convert struct storing steady-state variables to a double. Private 
% static method.
% 
% Input:
% 
% - parser : A struct with the following fields:
%            - endogenous  : Storing the all the endogenous variables of 
%                            the model. As a cellstr.
%            - isAuxiliary : A logical vector returning the auxiliary
%                            endogenous variables in endogenous.
%
% - s       : A struct with the steady-state values of some variables of 
%             the model. If s has some fieldnames which is not part of the 
%             model it will be discarded. All endogenous variables  
%             (dependent property) not assign will get the steady-state 
%             value 0.
%
%             Caution: Auxiliary variable should not be assign!
%         
% - default : A function handle on how to initialize the steady-state
%             values. Default is @zeros.
%
% Output:
% 
% - ss    : A nEndo x 1 double with steady-state values. (Excluding 
%           auxiliary variables)
%
% See also:
% nb_dsge.solveSteadyStateStatic, nb_dsge.assignSteadyState
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        default = @zeros;
    end

    isAux     = parser.isAuxiliary;
    ss        = default(sum(~isAux),1);
    endo      = parser.endogenous(~isAux);
    assigned  = fieldnames(s);
    [ind,loc] = ismember(assigned,endo);
    loc       = loc(ind);
    ssNew     = struct2cell(s);
    ssNew     = [ssNew{:}];
    ss(loc)   = ssNew(ind);
    
end
