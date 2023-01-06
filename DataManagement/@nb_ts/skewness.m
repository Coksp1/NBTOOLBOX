function obj = skewness(obj,flag,outputType,dimension,varargin)
% Syntax:
%
% obj = skewness(obj,flag,outputType,dimension,varargin)
%
% Description:
%
% Calculate the skewness of each timeseries. The result 
% will be an object of class nb_ts where all the non-nan 
% values of all the timeseries are beeing set to their skewness.
% 
% The output can also be set to be a double or a nb_cs object 
% consisting of the skewness values of the data.
% 
% Input:
% 
% - obj        : An object of class nb_ts
% 
% - flag       : Same as for the function skewness created by 
%                MATLAB.
% 
% - outputType : 
%
%       > 'nb_ts'  : The result will be an object of class nb_ts 
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
% nb_tsObj = skewness(obj); 
% double   = skewness(obj,0,'double');
% nb_csObj = skewness(obj,0,'nb_cs');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        dimension = 1;
        if nargin < 3
            outputType = 'nb_ts';
            if nargin < 2
                flag = 0;
            end
        end 
    end
    
    notHandleNaN = nb_parseOneOptionalSingle('notHandleNaN',false,true,varargin{:});
    obj          = evalStatOperator(obj,@skewness,notHandleNaN,outputType,dimension,{flag});

end
