function obj = var(obj,outputType,dimension,varargin)
% Syntax:
%
% obj = var(obj,outputType,dimension,varargin)
%
% Description:
%
% Calculate the var of each timeseries. The result 
% will be an object of class nb_ts where all the non-nan 
% values of all the timeseries are beeing set to their var.
% 
% The output can also be set to be a double or a nb_cs object 
% consisting of the var values of the data.
% 
% Input:
% 
% - obj        : An object of class nb_ts
% 
% - outputType : 
%
%       > 'nb_ts'  : The result will be an object of class nb_ts 
%                    where all the non-nan values of all the 
%                    timeseries are beeing set to their var. 
% 
%       > 'double' : Get the var values as doubles, where
%                    each column of the double matches the
%                    variable location in the 'variables' property. 
%                    If the object consist of more pages the double 
%                    will also consist of more pages.
%
%       > 'nb_cs'  : Get the var values as nb_cs object.
%                    The variance will when this option is used  
%                    only be calculated over the number of 
%                    observations. (I.e. dimension set to 1.)
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
% nb_tsObj = var(obj); 
% double   = var(obj,'double');
% nb_csObj = var(obj,'nb_cs');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        dimension = 1;
        if nargin < 2
            outputType = 'nb_ts';
        end
    end
    
    notHandleNaN = nb_parseOneOptionalSingle('notHandleNaN',false,true,varargin{:});
    obj          = evalStatOperator(obj,@var,notHandleNaN,outputType,dimension,{0});

end
