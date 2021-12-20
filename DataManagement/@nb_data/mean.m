function obj = mean(obj,outputType,dimension,varargin)
% Syntax:
%
% obj = mean(obj,outputType,dimension,varargin)
%
% Description:
%
% Calculate the mean of each series. The result 
% will be an object of class nb_data where all the non-nan 
% values of all the timeseries are beeing set to their mean.
% 
% The output can also be set to be a double or a nb_cs object 
% consisting of the mean values of the data.
% 
% Input:
% 
% - obj        : An object of class nb_data
% 
% - outputType : 
%
%       > 'nb_data': The result will be an object of class nb_data 
%                    where all the non-nan values of all the 
%                    series are beeing set to their mean. 
% 
%       > 'double' : Get the mean values as doubles, where
%                    each column of the double matches the
%                    variable location in the 'variables' property. 
%                    If the object consist of more pages the double 
%                    will also consist of more pages.
%
%       > 'nb_cs'  : Get the mean values as nb_cs object.
%                    The mean will when this option is used only be 
%                    calculated over the number of observations.
%                    (I.e. dimension set to 1.)
%
% - dimension  : The dimension to calcualate the mean over. 
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
% nb_tsObj = mean(obj); 
% double   = mean(obj,'double');
% nb_csObj = mean(obj,'nb_cs');
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
    obj          = evalStatOperator(obj,@mean,notHandleNaN,outputType,dimension,{});

end
