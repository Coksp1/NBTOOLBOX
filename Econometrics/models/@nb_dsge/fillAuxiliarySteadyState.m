function ss = fillAuxiliarySteadyState(model,ss)
% Syntax:
%
% ss = nb_dsge.fillAuxiliarySteadyState(model,ss)
%
% Description:
%
% Fill in for steady-state values of axiliary variables.
% 
% Input:
% 
% - model : A struct with the following fields:
%           - endogenous  : Storing the all the endogenous variables of the
%                           model. As a cellstr.
%           - isAuxiliary : A logical vector returning the auxiliary
%                           endogenous variables in endogenous.
%
% - ss    : The steady-state values of all non-auxiliary variables. The 
%           order is given by model.endogenous(~model.isAuxiliary)
% 
% Output:
% 
% - ss : The steady-state values of all endogenous variables of the model.
%        The order is given by model.endogenous.
%
% See also:
% nb_dsge.checkSteadyState
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isfield(model,'isMultiplier')
        isAux = model.isAuxiliary & ~model.isMultiplier;
    else
        isAux = model.isAuxiliary;
    end
    vars  = model.endogenous(~isAux);
    aux   = model.endogenous(isAux);
    aux   = cellfun(@(x)x(9:end),aux,'UniformOutput',false);
    ind   = strfind(aux,'_');
    ind   = cellfun(@(x)x(end),ind);
    ind   = num2cell(ind);
    aux   = cellfun(@(x,y)x(1:y-1),aux,ind,'UniformOutput',false);
    nAux  = length(aux);
    ssa   = nan(nAux,1);
    auxu  = unique(aux);
    nUiq  = length(auxu);
    for ii = 1:nUiq
        indU      = ismember(aux,auxu{ii});
        indV      = strcmpi(auxu{ii},vars);
        ssa(indU) = ss(indV);
    end
    ss = [ss;ssa];

end
