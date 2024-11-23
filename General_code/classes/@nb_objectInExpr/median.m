function obj = median(obj,~,outputType)
% Syntax:
%
% obj = median(obj,dim,outputType)
% 
% Description:
%
% Median.
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
%                - 'double': The result will be an empty object
%                  of class nb_objectInExpr.
%                  
% 
% Output:
% 
% - obj : An object of class nb_objectInExpr 
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        outputType = 'nb_math_ts';
    end
    
    switch outputType
        case 'nb_math_ts'
            return
        case 'double'
            obj = emptyObject(obj);
        otherwise
            error([mfilename ':: Non supported output type; ' outputType])    
    end
    
end
