function obj = kurtosis(obj,flag,outputType,dimension,varargin)
% Syntax:
%
% obj = kurtosis(obj,flag,outputType,dimension,varargin)
%
% Description:
%
% Calculate the kurtosis of object. The result 
% will be an object of class nb_cs where all the non-nan 
% values of all the object are beeing set to their kurtosis.
% 
% Input:
% 
% - obj        : An object of class nb_cs
% 
% - flag       : > 0 : normalises by N-1 (Default)
%                > 1 : normalises by N
% 
%                Where N is the sample length.
% 
% - outputType : 
%
%       > 'double' : Get the kurtosis values as doubles, where
%                    each column of the double matches the
%                    variable location in the 'variables' property. 
%                    If the object consist of more pages the double 
%                    will also consist of more pages.
%
%       > 'nb_cs'  : Get the kurtosis values as nb_cs object.
% 
% - dimension  : The dimension to calcualate the kurtosis over. 
% 
% Optional input:
%
% - 'notHandleNaN' : Give this to not handle nan values.
%
% Output:
% 
% - obj : See the input outputType for more one the output from 
%         this method  
% 
% Examples:
%
% double   = kurtosis(obj,0,'double');
% nb_csObj = kurtosis(obj,0,'nb_cs');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        dimension = 1;
        if nargin < 3
            outputType = 'nb_cs';
            if nargin < 2
                flag = 0;
            end
        end
    end

    notHandleNaN = nb_parseOneOptionalSingle('notHandleNaN',false,true,varargin{:});
    obj          = evalStatOperator(obj,@kurtosis,notHandleNaN,outputType,dimension,{flag});

end
