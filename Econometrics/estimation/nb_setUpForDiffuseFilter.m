function [M,G,C,x0,PS0,PINF0,fail] = nb_setUpForDiffuseFilter(H,A,B)
% Syntax:
%
% [M,G,C,x0,PS0,PINF0,fail] = nb_setUpForDiffuseFilter(H,A,B)
%
% Description:
%
% Set up for diffuse Kalman filtering.
% 
% See also:
% nb_kalmanSmootherDiffuseDSGE
%
% Written by Kenneth Sæterhagen Paulsen

    % Do the Schur decomposition
    [W,G] = schur(A);  

    % Get the number of eigenvalues outside the unit circle 
    E      = ordeig(G);
    select = abs(E)>1-eps;
    nOut   = sum(select);
    
    % Do the reordering of the shur decomposition
    [W,G] = ordschur(W,G,select);
    
    % Get the transformed system
    WT = W';
    M  = H*W;
    C  = WT*B;
    
    % Initialization of filter
    nEndo = size(A,1);
    CC    = C*C';
    ind   = nOut+1:size(A,1);
    G22   = G(ind,ind);
    CC22  = CC(ind,ind);
    x0    = zeros(nEndo,1);
    PS0   = zeros(nEndo,nEndo);
    if isempty(G22)
        fail = false;
    else
        [PS0(ind,ind),fail] = nb_lyapunovEquation(G22,CC22);
    end
    
    % Check for the trending variables effect on the other variables
    PINF0   = zeros(nEndo,nEndo);
    nObs    = size(M,1);
    [~,O,E] = qr(M*G(:,1:nOut),0);
    Od      = diag([O; zeros(nOut-nObs,size(O,2))]);
    indO    = abs(Od) < 1e-8;
    I       = ones(nOut,1);
    if any(indO)
       I(E(:,indO)) = 0; 
    end
    PINF0(1:nOut,1:nOut) = diag(I);
    
    % Final step
    PS0   = W*PS0*W';
    PINF0 = W*PINF0*W';

end
