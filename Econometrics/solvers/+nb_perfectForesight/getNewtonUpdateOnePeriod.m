function [DY,err] = getNewtonUpdateOnePeriod(funcs,JF,solveIter,Y,varargin)
% Syntax:
%
% [DY,err] = nb_perfectForesight.getNewtonUpdateOnePeriod(funcs,JF,...
%                 solveIter,Y,varargin)
%
% Description:
%
% Get the Newton update for one period utilizing sparsity of the jacobian 
% JF
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    FY = funcs.F(Y,varargin{:});
    if norm(FY) < sqrt(eps)
        err = false;
        DY  = 0;
        return
    end
    
    % Do newton update
    [DY,err] = nb_perfectForesight.doNewtonUpdate(FY,JF,solveIter);
    
end
