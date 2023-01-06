function ss = assignSteadyState(parser,s)
% Syntax:
%
% ss = nb_dsge.assignSteadyState(parser,s)
%
% Description:
%
% Assign steady-state values from a struct.
% 
% Input:
% 
% - parser : A struct with the following fields:
%            - endogenous  : Storing the all the endogenous variables of the
%                            model. As a cellstr.
%            - isAuxiliary : A logical vector returning the auxiliary
%                            endogenous variables in endogenous.
%
% - s      : A struct with the steady-state values of some variables of the
%            model. If s has some fieldnames which is not part of the model
%            it will be discarded. All endogenous variables (dependent 
%            property) not assign will get the steady-state value 0.
%
%            Caution: Auxiliary variable should not be assign!
%
%            Caution: Can also be a nEndo x 1 double vector. Also in this
%                     case the auxiliary variable should not be assign.
%         
% Output:
% 
% - ss  : A nEndo x 1 double with steady-state values. (Including 
%         auxiliary variables)
%
% See also:
% nb_dsge.solveSteadyStateStatic
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isnumeric(s)
        ss = s;
    else
        ss = nb_dsge.ssStruct2ssDouble(parser,s);
    end
    
    isAux = parser.isAuxiliary;
    if isfield(parser,'isMultiplier')
        isAux = isAux(~parser.isMultiplier);
    end
    
    if any(isAux)
        ss = nb_dsge.fillAuxiliarySteadyState(parser,ss);
    end
    
end
