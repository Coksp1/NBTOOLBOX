function obj = mean(obj,outputType,dimension)
% Syntax:
%
% obj = mean(obj,outputType,dimension,varargin)
%
% Description:
%
% Calculate the mean of each timeseries. The result 
% will be an object of class nb_bd where all the non-nan 
% values of all the timeseries are being set to their mean.
% 
% The output can also be set to be a double or a nb_cs object
% consisting of the mean values of the data.
% 
% Input:
% 
% - obj        : An object of class nb_bd
% 
% - outputType : 
%
%       > 'nb_bd'  : The result will be an object of class nb_bd
%                    where all the non-nan values of all the 
%                    timeseries are set to the mean. 
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
% Caution: the <ignorenan> property of obj controls the behavior of 
%          how to handle NaNs. This is equal to the 'notHandleNaN'
%          optional input of the mean method of the nb_ts class.
%
% Output:   
% 
% - obj : See the input outputType for avalable options.
% 
% Examples:
% 
% nb_bdObj = mean(obj); 
% double   = mean(obj,'double');
% nb_csObj = mean(obj,'nb_cs');
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        dimension = 1;
        if nargin < 2
            outputType = 'nb_bd';
        end
    end
    
    obj = evalStatOperator(obj,@mean,outputType,dimension,{});
    
end
