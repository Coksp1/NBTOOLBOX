function jacobian = structuralMatrices2JacobianNB(Alead,A0,Alag,B,leadCurrentLag)
% Syntax:
%
% jacobian = nb_dsge.structuralMatrices2JacobianNB(Alead,A0,Alag,B,...
%                           leadCurrentLag)
%
% Description:
% 
% Derive the jacobian given the structural matrices.
%
% On the form: Alead*y(t+1) + A0*y + Alag*y(t-1) + B*epsilon = 0
% 
% Input:
% 
% - Alead          : The structural matrix of the endogenous 
%                    variables in the period t+1.
% 
% - A0             : The structural matrix of the endogenous 
%                    variables in the period t.
% 
% - Alag           : The structural matrix of the endogenous 
%                    variables in the period t-1.
% 
% - B              : The structural matrix of the exogenous 
%                    variables in period t.
%
% - leadCurrentLag : A nEndo x 3 double with the lead, current and lag
%                    indicies of the endogenous variables of the model.
% 
% Output:
%
% - jacobian       : A matrix with the jacobian of the DSGE model.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Get the indexes
    nForward  = sum(leadCurrentLag(:,1));
    nBackward = sum(leadCurrentLag(:,3));
    nEndo     = size(leadCurrentLag,1);
    nExo      = size(B,2);
    nEq       = size(A0,1);
    indF      = 1:nForward;
    ind0      = nForward + 1:nEndo;
    indB      = nForward + nEndo + 1:nBackward;
    indI      = nForward + nEndo + nBackward + 1:nExo;
    
    % Assign jacobian
    jacobian         = zeros(nEq,nForward+nBackward+nEndo+nExo);
    jacobian(:,indF) = Alead(:,leadCurrentLag(:,1));
    jacobian(:,ind0) = A0;
    jacobian(:,indB) = Alag(:,leadCurrentLag(:,3));
    jacobian(:,indI) = B;

end
