function obj = var(obj,~,outputType)
% Syntax:
%
% obj = var(obj,dim,outputType)
% 
% Description:
%
% Variance
% 
% Input:
% 
% - obj        : An object of class nb_objectInExpr
% 
% - dim        : Any
% 
% - outputType : - 'nb_math_ts': The result will be an object
%                  of class nb_objectInExpr.
% 
%                - 'double': The result will be an object
%                  of class nb_objectInExpr.
%                  
% 
% Output:
% 
% - obj : An object of class nb_objectInExpr 
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        outputType = 'nb_math_ts';
    end

    % I cannot vectorize here because the function kurtosis made by
    % matlab does not handle nan values as wanted.
    switch lower(outputType)
        case 'nb_math_ts'
            return
        case 'double'
            emptyObject(obj);
        otherwise
            error([mfilename ':: Non supported output type; ' outputType])
    end

end
