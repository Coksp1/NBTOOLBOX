function [ys,allEndo,exo] = getAllMFVariables(options,ys,H,tempDep)
% Syntax:
%
% [ys,allEndo,exo] = nb_bVarEstimator.getAllMFVariables(options,...
%                       ys,H,tempDep)
%
% Description:
%
% Get smoothed estimates of all variables of the MF-VAR model.
% 
% See also:
% nb_bVarEstimator.estimate, nb_mfvar.filter
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if size(H,3) > 1
        N   = size(H,1);
        T   = size(ys,1);
        ysl = nan(N,T);
        ysT = ys';
        for tt = 1:T
            ysl(:,tt) = H(:,:,tt)*ysT(:,tt);
        end
    else
        ysl = H*ys';
    end
    tempObs = tempDep;
    tempDep = tempDep(~options.indObservedOnly);
    nStates = size(H,2)/length(tempDep);
    allEndo = [tempDep,nb_cellstrlag(tempDep,nStates-1,'varFast')];
    ys      = [ys,ysl'];
    allEndo = strcat('AUX_',allEndo);
    allEndo = [allEndo,tempObs];
    exo     = strcat('E_',tempDep);

end
