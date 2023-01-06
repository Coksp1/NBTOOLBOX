function obj = checkObsModelEqs(obj)
% Syntax:
%
% obj = checkObsModelEqs(obj)
%
% Description:
%
% Check model and create the eqFunction to be used to evaluate the 
% derivatives.
% 
% See also:
% nb_dsge.obsModel2func
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    numEndo = size(obj.parser.all_endogenous,2);
    if isfield(obj.parser,'obs_equationsParsed')

        numEq = size(nb_func2Cellstr(obj.parser.eqFunction),1) + size(obj.parser.obs_equationsParsed,1);
        if numEndo > numEq

            matches = nb_dsge.getUniqueMatches([obj.parser.equations; obj.parser.obs_equations]);
            test    = ~ismember(obj.parser.all_endogenous(~obj.parser.all_isAuxiliary),matches);
            if any(test)
                endo = obj.parser.all_endogenous(~obj.parser.all_isAuxiliary);
                error([mfilename ':: You have more endogenous variables (' int2str(numEndo) ') than equations (' int2str(numEq) ') ',...
                                 'in the obs_model block. The following variables are not used (in the full model); ' toString(endo(test))])
            else

                firstMatches = nb_dsge.getFirstMatches([obj.parser.equations; obj.parser.obs_equations],obj.parser.parameters);
                endo         = obj.parser.all_endogenous(~obj.parser.all_isAuxiliary);
                disp(' ')
                ind = ismember(endo,firstMatches);
                disp(char(endo(~ind)));

                error([mfilename ':: You have more endogenous variables (' int2str(numEndo) ') than equations (' int2str(numEq) ') (in the full model). ',...
                                 'All variables are used. (See above for good candidates)'])
            end

        elseif numEndo < numEq
            error([mfilename ':: You have more equations (' int2str(numEq) ') than endogenous variables (' int2str(numEndo) ') (in the full model).'])
        end

    end
    
end
