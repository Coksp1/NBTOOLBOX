function obj = std(obj,flag,outputType,dimension,varargin)
% Syntax:
%
% obj = std(obj,flag,outputType,dimension,varargin)
%
% Description:
%
% Calculate the std of each series. The result 
% will be an object of class nb_cs where all the non-nan 
% values of all the object are beeing set to their std.
% 
% The output can also be set to be a double.
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
%       > 'double' : Get the std values as doubles, where
%                    each column of the double matches the
%                    variable location in the 'variables' property. 
%                    If the object consist of more pages the double 
%                    will also consist of more pages.
%
%       > 'nb_cs'  : Get the std values as nb_cs object.
%
% - dimension  : The dimension to calcualate the std over. 
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
% double   = std(obj,0,'double');
% nb_csObj = std(obj,0,'nb_cs');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

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
    obj          = evalStatOperator(obj,@std,outputType,notHandleNaN,dimension,{flag});

end
