function [ys,allEndo,exo] = getAllMFVariablesRec(options,ys,H,tempDep,ss,start)
% Syntax:
%
% [ys,allEndo,exo] = nb_bVarEstimator.getAllMFVariablesRec(options,...
%                       ys,H,tempDep,ss,start)
%
% Description:
%
% Get recursive smoothed estimates of all variables of the MF-VAR model.
% 
% See also:
% nb_bVarEstimator.recursiveEstimation
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    N   = size(H,1);
    T   = size(ys,1);
    P   = size(ys,3);
    ysl = nan(N,T,P);
    if size(H,3) > 1
        % Time-varying measurement equations 
        ysT = permute(ys,[2,1,3]);
        for pp = 1:P
            for tt = ss(pp):start + pp - 1
                ysl(:,tt,pp) = H(:,:,tt)*ysT(:,tt,pp);
            end
        end
    else
        ysT = permute(ys,[2,1,3]);
        for pp = 1:P
            ysl(:,:,pp) = H*ysT(:,:,pp);
        end
    end
    tempObs = tempDep;
    tempDep = tempDep(~options.indObservedOnly);
    nStates = size(H,2)/length(tempDep);
    allEndo = [tempDep,nb_cellstrlag(tempDep,nStates-1,'varFast')];
    ys      = [ys,permute(ysl,[2,1,3])];
    allEndo = strcat('AUX_',allEndo);
    allEndo = [allEndo,tempObs];
    exo     = strcat('E_',tempDep);

end
