function [m,c] = nb_calculateMoments(A,B,C,vcv,mX,varX,nLags,type,tol,maxiter)
% Syntax:
%
% [m,c] = nb_calculateMoments(A,B,C,vcv,mX,varX,nLags,type,tol,maxIter)
%
% Description:
%
% Calculate moments given the companion form of the model:
%
% y_t = Ay_t-1 + Bx_t + Ce_t, where e_t ~ N(0,vcv) and 
% x_t ~ PHI(mX,varX)
% 
% Input:
% 
% - A,B,C,vcv,,mX,varX : See description of function.
% 
% - nLags              : The number of autocorrelation/autovariances to
%                        calculate.
%
% - type               : Either 'covariance' or 'correlation'.
%
% - tol                : The tolerance of the iteration procedure of the  
%                        lyapunov equation. Default is eps^(1/3).
%
% - maxiter            : Maximum number of iterations of the iteration   
%                        procedure of the lyapunov equation.. Default is 
%                        1000.
%
% Output:
% 
% - m : Unconditional mean of the model. As a nVar x 1 double.
%
% - c : Uconditional (auto)covarianse/correlation matrix. As a 
%       nVar x nVar x nLags + 1 double.
%
% See also:
% nb_model_generic.theoreticalMoments
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 10
        maxiter = 1000;
        if nargin < 9
            tol = [];
        end
    end
    
    if isempty(tol)
        tol = eps^(1/3);
    end
    
    if isempty(maxiter)
        maxiter = 1000;
    end

    % Calculate the mean
    if isempty(B)
        m = zeros(size(A,1),1);
    else
        IA = eye(size(A,1)) - A;
        EX = B*mX;
        m  = IA\EX;
    end
    if isempty(C)
        c = zeros(size(A,1),size(A,2),nLags+1);
        return
    end
    
    % Calculate the autocovariances 
    if nLags > -1

        % Shrink to state variables only
        sVar = any(A,1);
        As   = A(:,sVar);
        if isempty(As)
            Bs    = B;
            Cs    = C;
            if nLags > 0
                error([mfilename ':: The model is not dynamic, so autocorrelations/autocovariances are not possible to calculate.'])
            end
        else
            Bs = B(sVar,:);
            Cs = C(sVar,:,:);
        end

        % The model may have excpected shocks
        CvcvC   = C(:,:,1)*vcv*C(:,:,1)';
        CsvcvCs = Cs(:,:,1)*vcv*Cs(:,:,1)';
        for ii = 2:size(C,3)
            CvcvC   = CvcvC + C(:,:,ii)*vcv*C(:,:,ii)';
            CsvcvCs = CsvcvCs + Cs(:,:,ii)*vcv*Cs(:,:,ii)';
        end

        % Find the variance due to shocks and exogenous variables
        Rs = Bs*varX*Bs' + CsvcvCs;
        R  = B*varX*B' + CvcvC;

        % Then we need to solve the lyapunov equation
        if isempty(As)
            varS = 0;
        else
            [~,~,modulus] = nb_calcRoots(A);
            if any(modulus > 1)
                error([mfilename ':: The model is not stable'])
            end
            [varS,retcode] = nb_lyapunovEquation(As(sVar,:),Rs,tol,maxiter);
            if retcode
                error([mfilename ':: Did not find the solution in ' int2str(maxiter) ' iterations.'])
            end
        end

        % Then we want to calculate the covariance of the full system, as well
        % as the autocovariances
        ct       = As*varS*As' + R;
        c        = nan(size(ct,1),size(ct,2),nLags+1);
        c(:,:,1) = ct;
        for ii = 2:nLags+1
            ct        = As*ct(sVar,:);
            c(:,:,ii) = ct;
        end

        if strcmpi(type,'correlation')
            stds = sqrt(diag(c(:,:,1)));
            stds = stds*stds';
            for ii = 1:nLags+1
               c(:,:,ii) = c(:,:,ii)./stds;
            end
        end
        
    else
        c = nan(size(A,1),size(A,2),0);
    end

end
