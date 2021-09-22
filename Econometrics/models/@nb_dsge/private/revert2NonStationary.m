function obj = revert2NonStationary(obj)
% Syntax:
%
% obj = revert2NonStationary(obj)
%
% Description:
%
% Revert so that the parser property represent the non-stationary model
% again. I.e. this is triggered during resolving of the model.
% 
% See also:
% nb_dsge.solveNB
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c)  2019, Norges Bank

    % Remove and clean up fields set during stationarization of the model,
    % i.e. in solveBalancedGrowthPath and stationarize
    indKeep                 = ismember(obj.parser.endogenous,obj.parser.originalEndogenous);
    obj.parser.endogenous   = obj.parser.originalEndogenous;
    obj.parser.createStatic = true;
    obj.parser              = nb_rmfield(obj.parser,{'stationaryEquations','growthEquations','growthVariables'});
    
    % Update lead/lag incidence, and create the equationsParsed field that
    % stores all the equations of the model.
    obj.parser = nb_dsge.getLeadLag(obj.parser);
    
    % Update the depedent property
    obj.dependent.name        = obj.parser.endogenous;
    obj.dependent.tex_name    = obj.dependent.tex_name(indKeep);
    obj.dependent.number      = length(obj.parser.endogenous);
    obj.dependent.isAuxiliary = obj.parser.isAuxiliary(indKeep)';
    obj.endogenous            = obj.dependent;
    
end