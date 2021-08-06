function obj = min(obj,outputType,dimension)
% Syntax:
%
% obj = min(obj,outputType,dimension)
%
% Description:
%
% Calculate the min of object. The result will 
% be an object of class nb_cs where all the non-nan 
% values of all the object are beeing set to their min.
% 
% Input:
% 
% - obj        : An object of class nb_cs
% 
% - outputType : 
% 
%       > 'double' : Get the min values as doubles, where
%                    each column of the double matches the
%                    variable location in the 'variables' property. 
%                    If the object consist of more pages the double 
%                    will also consist of more pages.
%
%       > 'nb_cs'  : Get the min values as nb_cs object.
% 
% - dimension  : The dimension to calcualate the min over. 
% 
% Output:
% 
% - obj : See the input outputType for more one the output from 
%         this method  
% 
% - dimension  : The dimension to calcualate the min over. 
% 
% Examples:
% 
% double   = min(obj,'double');
% nb_csObj = min(obj,'nb_cs');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        dimension = 1;
        if nargin < 2
            outputType = 'nb_cs';
        end
    end

    obj = evalStatOperator(obj,@min,false,outputType,dimension,{});

end
