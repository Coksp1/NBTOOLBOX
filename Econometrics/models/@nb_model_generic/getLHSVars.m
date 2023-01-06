function vars = getLHSVars(obj,varsIn)
% Syntax:
%
% vars = getLHSVars(obj)
% vars = getLHSVars(obj,varsIn)
%
% Description:
%
% Get all left hand side variables of the model. 
%
% For factor models the observable (+ observableFast) are added as well.
% 
% The list will be sorted.
%
% Caution : For nb_dsge object only the observables are returned!
%
% Input:
% 
% - obj    : A scalar nb_model_generic object.
% 
% - varsIn : The variables that can be found in the data of the model.
%            If empty, they are found at obj.options.data.variables.
%
%            Caution: Only used in special cases.
% 
% Output:
% 
% - vars : A cellstr array with the variables of the model.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isscalar(obj)
        error([mfilename ':: Only scalar nb_model_generic object are supported.'])
    end

    if isa(obj,'nb_dsge') || isa(obj,'nb_fmdyn')
        vars = obj.observables.name;
    elseif isa(obj,'nb_exprModel')
        varFuncs = obj.dependent.name;
        varsOne  = cell(1,length(varFuncs));
        if nargin < 2
            varsIn = obj.options.data.variables;
        end
        for jj = 1:length(varFuncs)
            [~,~,varsOne{jj}] = nb_exprEstimator.eqs2funcSub(varsIn,varFuncs{jj},true);
        end
        vars = unique([varsOne{:}]);
    elseif isa(obj,'nb_manualModel')
        if ~isfield(obj.options,'LHSVariables')
            error(['You need to provide the LHSVariables field of the ',...
                'options property of a model of class nb_manualModel. It ',...
                'must be set to a cellstr with all the endogenous/left-hand ',...
                'side variables that the model uses.'])
        end
        vars = obj.options.LHSVariables;    
    else
        vars = {};
        if isprop(obj,'dependent')
            vars = [vars,obj.dependent.name];
        end
        if isprop(obj,'block_exogenous')
            vars = [vars,obj.block_exogenous.name];
        end
        if isprop(obj,'endogenous') && ~isa(obj,'nb_dsge')
            vars = [vars,obj.endogenous.name];
        end
        if isprop(obj,'observables')
            vars = [vars,obj.observables.name];
        end
        if isprop(obj,'observableFast')
            vars = [vars,obj.observableFast.name];
        end
        if isfield(obj.options,'measurementEqRestriction')
            if ~nb_isempty(obj.options.measurementEqRestriction)
                vars = [vars,{obj.options.measurementEqRestriction.restricted}];
            end
        end
    end

end
