function parser = getLeadLag(parser)
% Syntax:
% 
% parser = nb_dsge.getLeadLag(parser)
%
% Description:
%
% Get lead, current and lag incidence. 
%
% Static private method.
% 
% See also:
% nb_dsge.parse, nb_dsge.addEquation
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isfield(parser,'stationaryEquations')
        eqs = parser.stationaryEquations;
        eqs = [eqs;parser.growthEquations];
    else
        eqs = parser.equations;
    end
    [eqs,test,leadCLag,endoS] = nb_dsge.getLeadLagCore(parser,eqs,parser.endogenous,parser.exogenous);
    
    % Create auxiliary variables if needed
    checkForMoreLeads = cellfun(@(x)any(x > 1),test);
    if any(checkForMoreLeads)
        error([mfilename ':: Models with more leads than 1 is not yet supported.'])
    end
    
    numEndo          = size(endoS,2);
    checkForMoreLags = cellfun(@(x)any(x < -1),test);
    index            = 1:length(parser.endogenous);
    isAuxiliary      = false(numEndo,1);
    if any(checkForMoreLags)
        [eqs,leadCLag,auxLag] = nb_dsge.addAuxiliaryLagVariables(eqs,leadCLag,index(checkForMoreLags),endoS(checkForMoreLags),test(checkForMoreLags));
        endoS                 = [endoS,auxLag];
        isAuxiliary           = [isAuxiliary;true(length(auxLag),1)];
    end
    
    % Store output
    parser.equationsParsed = eqs;
    parser.leadCurrentLag  = leadCLag;
    parser.endogenous      = endoS;
    parser.isAuxiliary     = isAuxiliary;
    parser                 = nb_dsge.updateClassifications(parser);
    
    % Reorder solution
    parser = nb_dsge.updateDrOrder(parser);
    
    % Reorder of dynamic when solving for static variables
    parser = nb_dsge.updateDynamicOrder(parser);
    
end
