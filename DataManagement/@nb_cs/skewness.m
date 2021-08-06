function obj = skewness(obj,flag,outputType,dimension,varargin)
% Syntax:
%
% obj = skewness(obj,flag,outputType,dimension,varargin)
%
% Description:
%
% Calculate the skewness of object. The result will be 
% an object of class nb_cs where all the non-nan 
% values of all the object are beeing set to their skewness.
% 
% Input:
% 
% - obj        : An object of class nb_cs
% 
% - flag       : Same as for the function skewness created by 
%                MATLAB.
% 
% - outputType : 
%
%       > 'double' : Get the skewness values as doubles, where
%                    each column of the double matches the
%                    variable location in the 'variables' property. 
%                    If the object consist of more pages the double 
%                    will also consist of more pages.
%
%       > 'nb_cs'  : Get the skewness values as nb_cs object.
%
% - dimension  : The dimension to calcualate the skewness over. 
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
% - dimension  : The dimension to calcualate the skewness over. 
% 
% Examples:
%
% double   = skewness(obj,0,'double');
% nb_csObj = skewness(obj,0,'nb_cs');
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
    obj          = evalStatOperator(obj,@skewness,notHandleNaN,outputType,dimension,{flag});

end
