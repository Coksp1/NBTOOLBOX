function [A,D,err] = kleinSolver(parser,FF,F0,FB,FU)
% Syntax:
%
% [A,D,err] = nb_dsge.kleinSolver(parser,FF,F0,FB,FU)
%
% Description:
%
% Uses the Klein algorithm to solve th rational expectation mode.
%
% See also:
% nb_solveLinearRationalExpModel
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Get the static variables
    isStatic  = parser.isStatic;
    F0S       = F0(:,isStatic);
    hasStatic = ~isempty(F0S);
    if hasStatic

        % We do a QR factorization of FOS as to make the part for the static
        % variables upper triangular, i.e. makes it possible to separate the
        % solution for the dynamic and static variables.
        [Q,~] = qr(F0S);
        Qinv  = Q'; % Because of orthogonality of Q
        AF    = Qinv*FF;
        A0    = Qinv*F0;
        AB    = Qinv*FB;

    else
        AF   = FF;
        A0   = F0;
        AB   = FB;
    end

    % Which variables are forward and possibly also backward 
    isForwardOrMixed  = parser.isForwardOrMixed;
    isBackwardOrMixed = parser.isBackwardOrMixed;
    isMixedInForward  = parser.isMixedInForward;
    isMixedInBackward = parser.isMixedInBackward;
    isPurlyBackward   = parser.isPurlyBackward;
    nForwardOrMixed   = parser.nForwardOrMixed;
    nBackwardOrMixed  = parser.nBackwardOrMixed;
    nMixed            = parser.nMixed;  
    nStatic           = parser.nStatic;

    % Remove the static variables
    nEqs                            = size(AF,1);
    dynIndex                        = nStatic+1:nEqs;
    AF_tilde                        = AF(dynIndex,:);
    nDynamic                        = size(AF_tilde,1);
    A0F_tilde                       = A0(dynIndex,isForwardOrMixed);
    A0B_tilde                       = zeros(nDynamic,nBackwardOrMixed);
    A0B_tilde(:,~isMixedInBackward) = A0(dynIndex,isPurlyBackward);
    AB_tilde                        = AB(dynIndex,:);

    % Fill in some matrices needed for the solution
    Z_F = zeros(nMixed,nForwardOrMixed);
    I_B = zeros(nMixed,nBackwardOrMixed);
    Z_B = zeros(nMixed,nBackwardOrMixed);
    I_F = zeros(nMixed,nForwardOrMixed);

    % Fill in selection matrices of mixed variables
    indexMiB = find(isMixedInBackward); 
    for ii = 1:nMixed
        I_B(ii,indexMiB(ii)) = 1;
    end
    indexMiF = find(isMixedInForward); 
    for ii = 1:nMixed
        I_F(ii,indexMiF(ii)) = 1;
    end

    % Get the solution of non-static variables
    D             = [A0B_tilde,AF_tilde;I_B,Z_F];
    E             = [-AB_tilde,-A0F_tilde;Z_B,I_F];
    [gyp,gym,err] = nb_solveLinearRationalExpModel(D,E,nBackwardOrMixed);
    if ~isempty(err)
        [A,D] = errorReturn();
        return
    end
    gy = [gym(~isMixedInBackward,:);gyp];

    if hasStatic

        % Remove the dynamic variables
        indU  = 1:nStatic;
        AF_u  = AF(indU,:);
        A0D_u = A0(indU,~isStatic);
        A0S_u = A0(indU,isStatic);
        AB_u  = AB(indU,:);
        if rcond(A0S_u) <= eps
            err   = [mfilename ':: Could not solve for the solution of the static variables. ',...
                     'Matrix is close to singular or badly scaled. RCOND = ' num2str(rcond(A0S_u))]; 
            [A,D] = errorReturn();
            return
        end
        
        % Get the solution of the static variables
        gys = A0S_u\(AF_u*gyp*gym + A0D_u*gy(parser.dynamicOrder,:) + AB_u);
        gy  = [-gys;gy];

    end

    % Reorder solution
    gy = gy(parser.drOrder,:);

    % The innovation (exogenous variables)
    n         = size(gy,1);
    Jm        = zeros(nBackwardOrMixed,n);
    indexBORM = find(isBackwardOrMixed); 
    for ii = 1:nBackwardOrMixed
        Jm(ii,indexBORM(ii)) = 1;
    end
    DNUM = FF*gyp*Jm + F0;
    if rcond(DNUM) <= eps
        err   = [mfilename ':: Could not solve for the solution of the shock impact matrix. ',...
                 'Matrix is close to singular or badly scaled. RCOND = ' num2str(rcond(DNUM))]; 
        [A,D] = errorReturn();
        return
    end
    D = -(DNUM\FU);

    % Find the transition matrix
    endo      = parser.endogenous;
    nEndo     = length(endo);
    state     = endo(parser.isBackwardOrMixed);
    [~,locS]  = ismember(state,endo);
    A         = zeros(nEndo,nEndo);
    A(:,locS) = gy;
        
end

%==========================================================================
function [A,D] = errorReturn()

    A  = [];
    D  = [];
    
end
