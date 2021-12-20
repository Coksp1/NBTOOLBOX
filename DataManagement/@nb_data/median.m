function obj = median(obj,outputType,dimension,varargin)
% Syntax:
%
% obj = median(obj,outputType,dimension,varargin)
%
% Description:
%
% Calculate the median of each series. The result 
% will be an object of class nb_data where all the non-nan 
% values of all the series are beeing set to their median.
% 
% The output can also be set to be a double or a nb_cs object 
% consisting of the median values of the data.
% 
% Input:
% 
% - obj        : An object of class nb_data
% 
% - outputType : 
%
%       > 'nb_data': The result will be an object of class nb_data 
%                    where all the non-nan values of all the 
%                    series are beeing set to their median. 
% 
%       > 'double' : Get the median values as doubles, where
%                    each column of the double matches the
%                    variable location in the 'variables' property. 
%                    If the object consist of more pages the double 
%                    will also consist of more pages.
%
%       > 'nb_cs'  : Get the median values as nb_cs object.
%                    The median will when this option is used only 
%                    be calculated over the number of observations.
%                    (I.e. dimension set to 1.)
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
% nb_dataObj = median(obj); 
% double     = median(obj,'double');
% nb_csObj   = median(obj,'nb_cs');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        dimension = 1;
        if nargin < 2
            outputType = 'nb_data';
        end
    end

    notHandleNaN = nb_parseOneOptionalSingle('notHandleNaN',false,true,varargin{:});
    obj          = evalStatOperator(obj,@median,notHandleNaN,outputType,dimension,{});

end
