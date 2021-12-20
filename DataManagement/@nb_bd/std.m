function obj = std(obj,flag,outputType,dimension)
% Syntax:
%
% obj = std(obj,flag,outputType,dimension,varargin)
%
% Description:
%
% Calculate the std of each series. The result 
% will be an object of class nb_bd where all the non-nan 
% values of all the object are set to their std.
% 
% The output can also be set to be a double or a nb_cs object 
% consisting of the skewness values of the data.
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
% Caution: the <ignorenan> property of obj controls the behavior of 
%          how to handle NaNs. This is equal to the 'notHandleNaN'
%          optional input of the std method of the nb_ts class.
%
% Output:
% 
% - obj : See the input outputType for available options. 
% 
% Examples:
% 
% double   = std(obj,0,'double');
% nb_csObj = std(obj,0,'nb_cs');
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        dimension = 1;
        if nargin < 3
            outputType = 'nb_bd';
            if nargin < 2
                flag = 0;
            end
        end 
    end

    obj = evalStatOperator(obj,@std,outputType,dimension,{flag});

end
