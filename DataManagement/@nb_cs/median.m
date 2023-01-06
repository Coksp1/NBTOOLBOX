function obj = median(obj,outputType,dimension,varargin)
% Syntax:
%
% obj = median(obj,outputType,dimension,varargin)
%
% Description:
%
% Calculate the median of each timeseries. The result 
% will be an object of class nb_ts where all the non-nan 
% values of all the timeseries are beeing set to their median.
% 
% Input:
% 
% - obj        : An object of class nb_ts
% 
% - outputType : 
% 
%       > 'double' : Get the median values as doubles, where
%                    each column of the double matches the
%                    variable location in the 'variables' property. 
%                    If the object consist of more pages the double 
%                    will also consist of more pages.
%
%       > 'nb_cs'  : Get the median values as nb_cs object.
%
% - dimension  : The dimension to calcualate the median over. 
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
% double   = median(obj,'double');
% nb_csObj = median(obj,'nb_cs');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        dimension = 1;
        if nargin < 2
            outputType = 'nb_cs';
        end
    end

    notHandleNaN = nb_parseOneOptionalSingle('notHandleNaN',false,true,varargin{:});
    obj          = evalStatOperator(obj,@median,notHandleNaN,outputType,dimension,{});

end
