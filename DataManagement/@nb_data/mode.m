function obj = mode(obj,outputType,dimension,varargin)
% Syntax:
%
% obj = mode(obj,outputType,dimension,varargin)
%
% Description:
%
% Calculate the mode of each series. The result 
% will be an object of class nb_data where all the non-nan 
% values of all the series are beeing set to their mode.
% 
% The output can also be set to be a double or a nb_cs object 
% consisting of the mode values of the data.
% 
% Input:
% 
% - obj        : An object of class nb_data
% 
% - outputType : 
%
%       > 'nb_data': The result will be an object of class nb_data 
%                    where all the non-nan values of all the 
%                    series are beeing set to their mode. Default
% 
%       > 'double' : Get the mode values as doubles, where
%                    each column of the double matches the
%                    variable location in the 'variables' property. 
%                    If the object consist of more pages the double 
%                    will also consist of more pages.
%
%       > 'nb_cs'  : Get the mode values as nb_cs object.
%                    The mode will when this option is used only be 
%                    calculated over the number of observations.
%                    (I.e. dimension set to 1.)
%
% - dimension  : The dimension to calcualate the mode over. 
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
% nb_dataObj = mode(obj); 
% double     = mode(obj,'double');
% nb_csObj   = mode(obj,'nb_cs');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        dimension = 1;
        if nargin < 2
            outputType = 'nb_data';
        end
    end

    notHandleNaN = nb_parseOneOptionalSingle('notHandleNaN',false,true,varargin{:});
    obj = evalStatOperator(obj,@mode,notHandleNaN,outputType,dimension,{});

end
