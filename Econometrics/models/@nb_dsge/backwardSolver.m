function [A,B,BE,err] = backwardSolver(model,solution,options,expandedOnly)
% Syntax:
%
% [A,B,BE,err] = nb_dsge.backwardSolver(model,solution,options,expandedOnly)
%
% Description:
%
% Solving purly backward looking models.
% 
% Input:
% 
% - model        : See nb_dsge.solveNB
%
% - solution     : See nb_dsge.solveNB
%
% - options      : See nb_dsge.solveNB
% 
% - expandedOnly : true if only the expanded solution is to be solved for.
%
% Output:
% 
% - A        : Transition matrix, as a nEndo x nEndo.
%
% - B        : Shock impact matrix as a nEndo x nExo.
%
% - BE       : Shock impact matrix as a nEndo x nExo x nHor, when solved
%              with anticipated shocks, otherwise [].
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    err = ''; 
    ind = solution.jacobianType;
    JAC = full(solution.jacobian);
    if max(abs(imag(JAC(:)))) < eps^(0.8)
        JAC = real(JAC);
    else
        error([mfilename ':: Cannot solve the model the jacobian is not real.'])
    end

    if ~expandedOnly

        F0 = JAC(:,ind == 0);
        if rcond(F0) < eps^(0.5)
            ind  = any(F0,2);
            ind2 = any(F0,1);
            if any(~ind)
                message = {'The following equations only contain lags of variables (Please lead the equations!):'};
                eqs     = model.equations(~ind);
                message = [message,eqs];
                err     = [mfilename ':: ' nb_cellstr2String(message,nb_newLine)];
            elseif any(~ind2)
                message = {'The following variables do not affect the model:'};
                vars    = model.endogenous(~ind2);
                message = [message,vars];
                err     = [mfilename ':: ' nb_cellstr2String(message,nb_newLine)];
            else
                err = [mfilename ':: The model cannot be solved as some of the equations are linearly dependent.'];
            end
            
            if nargout < 4
                error(err)
            else
                [A,B,BE] = errorReturn();
                return    
            end
            
        end
        F0inv = F0\eye(size(F0));
        
        % Find the transition matrix
        FB        = JAC(:,ind == -1);
        gy        = -F0inv*FB;
        endo      = model.endogenous;
        nEndo     = length(endo);
        state     = endo(model.isBackwardOrMixed);
        [~,locS]  = ismember(state,endo);
        A         = zeros(nEndo,nEndo);
        A(:,locS) = gy;
        
        % The innovation (exogenous variables)
        FU = JAC(:,ind == 2);
        B  = -F0inv*FU;
 
    end
    
    % Do we want the expanded solution?
    if ~isempty(options.numAntSteps) && ~isempty(options.shockProperties)
        err = [mfilename ':: Backward models cannot be solved with anticipated shocks.'];
        if nargout < 4
            error(err)
        else
            [A,B,BE] = errorReturn();
            return    
        end
    else
        BE = [];
    end
    
end

%==========================================================================
function [A,B,BE] = errorReturn()

    A  = [];
    B  = [];
    BE = [];
    
end
