function vars = getModelVars(obj,varsIn)
% Syntax:
%
% vars = getModelVars(obj)
% vars = getModelVars(obj,varsIn)
%
% Description:
%
% Get all variables to the model. That include dependent, endogenous
% and exogenous variables.
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isscalar(obj)
        error([mfilename ':: Only scalar nb_model_generic object are supported.'])
    end

    if isa(obj,'nb_dsge')
        vars = obj.observables.name;
    elseif isa(obj,'nb_exprModel')
        varFuncs = [obj.dependent.name, nb_nestedCell2Cell(obj.exogenous.name)];
        varsOne  = cell(1,length(varFuncs));
        nDep     = length(obj.dependent.name);
        if nargin < 2
            varsIn = obj.options.data.variables;
        end
        for jj = 1:nDep
            [~,~,varsOne{jj}] = nb_exprEstimator.eqs2funcSub(varsIn,varFuncs{jj},true);
        end
        for jj = nDep+1:length(varFuncs)
            [~,~,varsOne{jj}] = nb_exprEstimator.eqs2funcSub(varsIn,varFuncs{jj},false);
        end
        vars = unique([varsOne{:}]);
    else
        vars = {};
        if isprop(obj,'dependent')
            vars = [vars,obj.dependent.name];
        end
        if isprop(obj,'block_exogenous')
            vars = [vars,obj.block_exogenous.name];
        end
        if isprop(obj,'endogneous')
            vars = [vars,obj.endogneous.name];
        end
        if isprop(obj,'exogenous')
            vars = [vars,obj.exogenous.name];
        end
        if isprop(obj,'observables')
            vars = [vars,obj.observables.name];
        end
        if isprop(obj,'observableFast')
            vars = [vars,obj.observableFast.name];
        end
    end

end
