function obj = var(obj,outputType,dimension,varargin)
% Syntax:
%
% obj = var(obj,outputType,dimension,varargin)
%
% Description:
%
% Calculate the var of object. The result will be 
% an object of class nb_cs where all the non-nan 
% values of all the object are beeing set to their var.
% 
% The output can also be set to be a double or a nb_cs object 
% consisting of the var values of the data.
% 
% Input:
% 
% - obj        : An object of class nb_cs
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
% double   = var(obj,'double');
% nb_csObj = var(obj,'nb_cs');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        dimension = 1;
        if nargin < 2
            outputType = 'nb_cs';
        end
    end

    notHandleNaN = nb_parseOneOptionalSingle('notHandleNaN',false,true,varargin{:});
    obj          = evalStatOperator(obj,@var,notHandleNaN,outputType,dimension,{});

end
