function c = nb_conditionalSecondOrderMoments(A,B,C,vcv,Q,varX,nSteps,type,depInd)
% Syntax:
%
% c = nb_conditionalSecondOrderMoments(A,B,C,vcv,varX,nSteps)
% c = nb_conditionalSecondOrderMoments(A,B,C,vcv,varX,nSteps,...
%                                           type,depInd)
%
% Description:
%
% Calculate conditional second order moments of a model on a state
% space form.
% 
% y(t) = A(s)y(t-1) + B(s)x(t) + C(s)e(t)
%
% where:
% x(t) ~ N(0,varX)
% e(t) ~ N(0,vcv(s))
%
% Input:
% 
% - A      : See above.
%
% - B      : See above.
%
% - C      : See above.
% 
% - vcv    : See above.
%
% - varX   : See above.
%
% - Q      : Transition probability matrix. If this is not empty
%            the A, B, C and vcv inputs must be of class cell.
%
% - nSteps : Numbr of steps ahead to calculate the condition second order 
%            moments.
%
% - type   : Either 'covariance' (default) or 'correlation'.
%
% - depInd : Index of the endogneous variables you want the second order 
%            matrix of. As a 1 x N integer. Defualt is to return the
%            covariance/correlation matrix of all endogneous variables.
%            
% Output:
% 
% - c     : A nVar*nSteps x nVar*nSteps double.
%
% See also:
% nb_forecast.buildShockRestrictions
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 7
        type = '';
        if nargin < 8
            depInd = [];
        end
    end

    if ~isempty(Q)
        [A,B,C,vcv] = ms.integrateOverRegime(Q,A,B,C,vcv);
    end
        
    % Construct A^k for all k
    nEndo     = size(A,1);
    HH        = nan(nEndo,nEndo,nSteps);
    HH(:,:,1) = A;
    for k = 2:nSteps
        HH(:,:,k) = HH(:,:,k-1)*A;
    end

    if isempty(depInd)
        depInd = 1:nEndo;
    end
    nDep = length(depInd);
    
    % Scale C matrix
    nAnt = size(C,3);
    for ii = 1:nAnt
        C(:,:,ii) = C(:,:,ii)*chol(vcv);
    end
    
    % Merge shocks and exogneous
    if ~isempty(B)
        B = B*chol(varX);
        B = B(:,:,ones(1,nAnt));
        C = [B,C]; 
    end

    % Construct the PHI matrix
    nRes    = size(C,2);
    nShocks = (nAnt + nSteps - 1);
    PHI     = zeros(nDep*nSteps,nShocks*nRes);
    for k = 1:nSteps

        PHI_k = zeros(nEndo,nShocks*nRes);
        for j = 1:nShocks

            PHI_k_j = zeros(nEndo,nRes);
            for i = 1:j
                sss = k-i;
                if sss > 0
                    Hs = HH(:,:,sss);
                elseif sss == 0
                    Hs = 1;
                else
                    Hs = 0;
                end
                ttt  = j - i + 1;
                test = ttt <= nAnt && sss >= 0;
                if test
                    PHI_k_j = PHI_k_j + Hs*C(:,:,ttt);
                end
            end
            ind          = (j-1)*nRes+1:j*nRes;
            PHI_k(:,ind) = PHI_k_j;
        end

        indR        = (k-1)*nDep + (1:nDep);
        PHI(indR,:) = PHI_k(depInd,:);

    end

    % Construct the covariance/correlation matrix
    c = PHI*PHI';
    if strcmpi(type,'correlation')
        stds = sqrt(diag(c));
        stds = stds*stds';
        c    = c./stds;
    end
    
end
