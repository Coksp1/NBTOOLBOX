function obj = skewness(obj,flag,outputType,dimension)
% Syntax:
%
% obj = skewness(obj,flag,outputType,dimension)
%
% Description:
%
% Calculate the skewness of each timeseries. The result 
% will be an object of class nb_bd where all the non-nan 
% values of all the timeseries are beeing set to their skewness.
% 
% The output can also be set to be a double or a nb_cs object 
% consisting of the skewness values of the data.
% 
% Input:
% 
% - obj        : An object of class nb_bd
% 
% - flag       : Same as for the function skewness created by 
%                MATLAB.
% 
% - outputType : 
%
%       > 'nb_bd'  : The result will be an object of class nb_bd 
%                    where all the non-nan values of all the 
%                    timeseries are beeing set to their skewness. 
% 
%       > 'double' : Get the skewness values as doubles, where
%                    each column of the double matches the
%                    variable location in the 'variables' property. 
%                    If the object consist of more pages the double 
%                    will also consist of more pages.
%
%       > 'nb_cs'  : Get the skewness values as nb_cs object.
%                    The skewness will when this option is used  
%                    only be calculated over the number of 
%                    observations. (I.e. dimension set to 1.)
%
% - dimension  : The dimension to calcualate the skewness over. 
% 
% Caution: the <ignorenan> property of obj controls the behavior of 
%          how to handle NaNs. This is equal to the 'notHandleNaN'
%          optional input of the std method of the nb_ts class.
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
% nb_tsObj = skewness(obj); 
% double   = skewness(obj,0,'double');
% nb_csObj = skewness(obj,0,'nb_cs');
% 
% Written by Per Bjarne Bye

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 4
        dimension = 1;
        if nargin < 3
            outputType = 'nb_bd';
            if nargin < 2
                flag = 0;
            end
        end 
    end

    obj = evalStatOperator(obj,@skewness,outputType,dimension,{flag});

end
