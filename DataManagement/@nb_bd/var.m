function obj = var(obj,outputType,dimension)
% Syntax:
%
% obj = var(obj,outputType,dimension,varargin)
%
% Description:
%
% Calculate the var of object. The result will be 
% an object of class nb_bd where all the non-nan 
% values of all the object are beeing set to their variance.
% 
% The output can also be set to be a double or a nb_cs object 
% consisting of the var values of the data.
% 
% Input:
% 
% - obj        : An object of class nb_bd
% 
% - outputType :  
% 
%       > 'double' : Get the var values as doubles, where
%                    each column of the double matches the
%                    variable location in the 'variables' property. 
%                    If the object consist of more pages the double 
%                    will also consist of more pages.
%
%       > 'nb_cs'  : Get the var values as nb_cs object.
%
% - dimension  : The dimension to calcualate the var over. 
% 
% Caution: the <ignorenan> property of obj controls the behavior of 
%          how to handle NaNs. This is equal to the 'notHandleNaN'
%          optional input of the std method of the nb_ts class.
%
% Output:
% 
% - obj : See the input outputType for available options
% 
% Examples:
%  
% double   = var(obj,'double');
% nb_csObj = var(obj,'nb_cs');
% 
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        dimension = 1;
        if nargin < 2
            outputType = 'nb_bd';
        end
    end
    
    obj = evalStatOperator(obj,@var,outputType,dimension,{});

end
