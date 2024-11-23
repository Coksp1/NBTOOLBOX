function obj = max(obj,outputType,dimension)
% Syntax:
%
% obj = max(obj,outputType,dimension)
%
% Description:
%
% Calculate the max of each timeseries. The result 
% will be an object of class nb_ts where all the non-nan 
% values of all the timeseries are beeing set to their max.
% 
% The output can also be set to be a double or a nb_cs object 
% consisting of the max values of the data.
% 
% Input:
% 
% - obj        : An object of class nb_ts
% 
% - outputType : 
%
%       > 'nb_ts'  : The result will be an object of class nb_ts 
%                    where all the non-nan values of all the 
%                    timeseries are beeing set to their max. 
% 
%       > 'double' : Get the max values as doubles, where
%                    each column of the double matches the
%                    variable location in the 'variables' property. 
%                    If the object consist of more pages the double 
%                    will also consist of more pages.
%
%       > 'nb_cs'  : Get the max values as nb_cs object.
%                    The max will when this option is used only be 
%                    calculated over the number of observations.
%                    (I.e. dimension set to 1.)
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
% nb_tsObj = max(obj); 
% double   = max(obj,'double');
% nb_csObj = max(obj,'nb_cs');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        dimension = 1;
        if nargin < 2
            outputType = 'nb_ts';
        end
    end
    
    obj = evalStatOperator(obj,@max,false,outputType,dimension,{});

end
