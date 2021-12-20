function [R,numOfAnt,AARestr] = buildShockRestrictions(AA,B,endoRestInd,numRestShocks,numCondPer,numAntPer,states,append)
% Syntax:
%
% [R,shocksNumOfAnt,states] = nb_forecast.buildShockRestrictions(AA,B,...
%       endoRestInd,numRestShocks,numCondPer,numAntPer,states,append)
%
% Description:
% 
% Build the a matrix representing the restrictions made by the conditional
% information. Used to identify the shocks/residual to match the
% conditional information.
%
% See Kenneth Sæterhagen Paulsen (2010), "Conditional forecast in DSGE 
% models - A conditional copula approach".
%
% Implements the steps in section 3 of setting up the matrix R.
%
% The model is on the form y(t) = A y(t-1) + sum_j_n[B(j) eps(t+j)]
%
% Inputs:
%
% - AA : Model transition matrix raised to the j - 1, i.e. page AA(1) = A, 
%        AA(2) = A^2 and so on. As a nEndo x nEndo x j double.
%
% - B  : Impact matrices for the shocks. (Also anticipated). As a 
%        nEndo x nExo x nAnt double.
%
% Outputs:
%
% - R  : See equation (20) on page 7 of Kenneth Sæterhagen Paulsen (2010).
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 8
        append = true;
    end

    if ~iscell(B)
        B = {B};
    end
    numOfAnt    = numAntPer + numCondPer;
    sizeC       = size(B{1});
    nEndo       = sizeC(1);
    nExo        = sizeC(2);
    numRestEndo = numel(endoRestInd);
    bound       = numRestEndo*numCondPer;
    R           = zeros(bound,nExo*numOfAnt);
    restSInd    = 1:numRestShocks;
    S           = zeros(numRestShocks*numCondPer,nExo*numOfAnt);

    % Construct the restricted R matrix of Junior Maih (2010) with
    % anticipated shocks
    %-------------------------------------------------------------------
    for k = 1:numCondPer

        % The map of the restrictions on the endogenous
        UPS = zeros(nEndo,nExo*numOfAnt);
        for j = 1:numOfAnt

            UPS_k_j = zeros(nEndo,nExo);
            for i = 1:j
                k_i    = k - i;
                j_i_1  = j - i + 1;
                test   = j_i_1 <= numAntPer && k_i >= 0;
                if test
                    if k_i == 0
                        UPS_k_j = UPS_k_j + B{states(k)}(:,:,j_i_1);
                    else
                        UPS_k_j = UPS_k_j + AA(:,:,k_i)*B{states(k)}(:,:,j_i_1);
                    end
                end
            end
            ind        = (j-1)*nExo+1:j*nExo;
            UPS(:,ind) = UPS_k_j;
        end
        indR      = (k-1)*numRestEndo+(1:numRestEndo);
        R(indR,:) = UPS(endoRestInd,:);

        % The shock maps themself by the identity matrix
        indS1          = (k-1)*numRestShocks+(1:numRestShocks);
        indS2          = (k-1)*nExo + restSInd;
        S(indS1,indS2) = eye(numRestShocks);

    end
    
    % Append the restrictions on the endogenous variables with the
    % restrictions of the shocks
    if append
        R = [R;S];
    end
    
    if nargout > 2
        AARestr = nan(bound,nEndo);
        for j = 1:numCondPer
            AARestr((j-1)*numRestEndo+1:j*numRestEndo,:) = AA(endoRestInd,:,j);
        end
    end
        
end
