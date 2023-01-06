function obj = updateObject(obj,parser,paramI)
% Syntax:
%
% obj = updateObject(obj,parser)
% obj = updateObject(obj,parser,paramI)
%
% Description:
%
% Private method. Update the object properties given parsing.
% 
% See also:
% nb_dsge.parse, nb_dsge.addEquation
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 1
        paramI = [];
    end
    
    if numel(obj) ~= 1
        error([mfilename ':: The obj input must be a scalar nb_dsge object.'])
    end
    
    obj.dependent.name             = parser.all_endogenous;
    obj.dependent.tex_name         = strrep(parser.all_endogenous,'_','\_');
    obj.dependent.number           = length(parser.all_endogenous);
    obj.dependent.isAuxiliary      = parser.isAuxiliary';
    obj.endogenous                 = obj.dependent; 
    obj.exogenous.name             = parser.all_exogenous;
    obj.exogenous.tex_name         = strrep(parser.all_exogenous,'_','\_');
    obj.exogenous.number           = size(parser.all_exogenous,2);
    obj.observablesHidden.name     = parser.observables;
    obj.observablesHidden.tex_name = strrep(parser.observables,'_','\_');
    obj.observablesHidden.number   = length(parser.observables);
    if isfield(parser,'unitRootVars')
        obj.unitRootVariables.name     = parser.unitRootVars;
        obj.unitRootVariables.tex_name = strrep(parser.unitRootVars,'_','\_');
        obj.unitRootVariables.number   = length(parser.unitRootVars);
    end
    if isfield(obj.results,'beta')
        if ~isempty(obj.results.beta)
            nBeta  = size(obj.results.beta,1);
            nParam = size(parser.parameters,2);
            if nParam > nBeta
                obj.results.beta = [obj.results.beta;nan(nParam-nBeta,1)];
                if ~isempty(paramI) % Reordering given sorting in addEquation
                    obj.results.beta = obj.results.beta(paramI);
                end
            end
        else
            obj.results.beta = nan(size(parser.parameters,2),1);
        end
    else
        obj.results.beta = nan(size(parser.parameters,2),1);
    end
    
end
