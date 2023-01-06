function model = nb_rf(y,X,options)
% Syntax:
%
% model = nb_rf(y,X,options)
%
% Description:
%
% Random forest.
% 
% Input:
% 
% - y        : A double matrix of size nobs x neq of the dependent 
%              variable of the regression(s).
%
% - X        : A double matrix of size nobs x nxvar of the right  
%              hand side variables of all equations of the 
%              regression.
%
% - options  : Estimation options. As a struct. See nb_randomForest.optimset.
%
% Output:
% 
% - model    : An 1 x nEq object array of class nb_randomForest.
%
% - exitflag : The reason for exiting. One of:
%
%              See also: nb_interpretExitFlag. Set type to 
%              'nb_randomForest'.
% 
% See also:
% nb_randomForest, nb_randomForest.optimset, nb_ols
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        options = nb_randomForest.optimset();
    end
    if ~isnumeric(y)
        error('The y input must be numeric.')
    end
    if size(y,2) > 1
        nEq          = size(y,2);
        model(1,nEq) = nb_randomForest();
        for ii = 1:nEq
            model(ii) = nb_randomForest(y(:,ii),X,options);
            fit(model(ii));
        end
    else
        model = nb_randomForest(y,X,options);
        fit(model);
    end
    
end
