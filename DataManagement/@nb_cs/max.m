function obj = max(obj,outputType,dimension)
% Syntax:
%
% obj = max(obj,outputType,dimension)
%
% Description:
%
% Calculate the max of object. The result will 
% be an object of class nb_cs where all the non-nan 
% values of all the object are beeing set to their max.
% 
% Input:
% 
% - obj        : An object of class nb_cs
% 
% - outputType : 
%
%       > 'double' : Get the max values as doubles, where
%                    each column of the double matches the
%                    variable location in the 'variables' property. 
%                    If the object consist of more pages the double 
%                    will also consist of more pages.
%
%       > 'nb_cs'  : Get the max values as nb_cs object.
%
% - dimension  : The dimension to calcualate the max over. 
% 
% Output:
% 
% - obj : See the input outputType for more one the output from 
%         this method  
% 
% Examples:
% 
% double   = max(obj,'double');
% nb_csObj = max(obj,'nb_cs');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        dimension = 1;
        if nargin < 2
            outputType = 'nb_cs';
        end
    end

    obj = evalStatOperator(obj,@max,false,outputType,dimension,{});

end
