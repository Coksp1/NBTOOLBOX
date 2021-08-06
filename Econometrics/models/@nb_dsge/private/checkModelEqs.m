function obj = checkModelEqs(obj)
% Syntax:
%
% obj = checkModelEqs(obj)
%
% Description:
%
% Check model.
% 
% See also:
% nb_dsge.solvNB, nb_dsge.blockDecompose, nb_dsge.optimalSimpleRules
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    numEndo = size(obj.parser.endogenous,2);
    if isfield(obj.parser,'equationsParsed')

        numEq = size(obj.parser.equationsParsed,1);
        if obj.parser.optimal
            if numEndo <= numEq
                error([mfilename ':: When solving the model with optimal monetary policy you need at least one degree of freedom. ',...
                                 'You need more endogenous variables (' int2str(numEndo) ') than equations (' int2str(numEq) ').'])
            end
        else
            if numEndo > numEq

                matches = nb_dsge.getUniqueMatches(obj.parser.equations);
                test    = ~ismember(obj.parser.endogenous(~obj.parser.isAuxiliary),matches);
                if any(test)
                    endo = obj.parser.endogenous(~obj.parser.isAuxiliary);
                    error([mfilename ':: You have more endogenous variables (' int2str(numEndo) ') than equations (' int2str(numEq) ').',...
                                     'The following variables are not used; ' toString(endo(test))])
                else

                    firstMatches = nb_dsge.getFirstMatches(obj.parser.equations,obj.parser.parameters);
                    endo         = obj.parser.endogenous(~obj.parser.isAuxiliary);
                    disp(' ')
                    ind = ismember(endo,firstMatches);
                    disp(char(endo(~ind)));

                    error([mfilename ':: You have more endogenous variables (' int2str(numEndo) ') than equations (' int2str(numEq) '). ',...
                                     'All variables are used. (See above for good candidates)'])
                end

            end
            if numEndo < numEq
                error([mfilename ':: You have more equations (' int2str(numEq) ') than endogenous variables (' int2str(numEndo) ').'])
            end
        end

    end
    
end
