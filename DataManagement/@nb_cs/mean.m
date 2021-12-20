function obj = mean(obj,outputType,dimension,varargin)
% Syntax:
%
% obj = mean(obj,outputType,dimension,varargin)
%
% Description:
%
% Calculate the mean of each the object. The result 
% will be an object of class nb_cs where all the non-nan 
% values of all the object are beeing set to their mean.
% 
% Input:
% 
% - obj        : An object of class nb_cs
% 
% - outputType :  
% 
%       > 'double'       : Get the mean values as doubles, where
%                          each column of the double matches the
%                          variable location in the 'variables' property. 
%                          If the object consist of more pages the double 
%                          will also consist of more pages.
%
%       > 'nb_cs'        : Get the mean values as nb_cs object. The output
%                          will keep the same size as the input object.
%
%       > 'nb_cs_scalar' : The result will be an object of class nb_cs 
%                          where all the non-nan values of all the 
%                          series are beeing set to their mean, but 
%                          where the dimension taking the mean over is 
%                          reduced to size 1. The name of the 
%                          type/variable/page will be 'mean'.
% 
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
% double   = mean(obj,'double');
% nb_csObj = mean(obj,'nb_cs');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        dimension = 1;
        if nargin < 2
            outputType = 'nb_cs';
        end
    end

    notHandleNaN = nb_parseOneOptionalSingle('notHandleNaN',false,true,varargin{:});
    obj          = evalStatOperator(obj,@mean,notHandleNaN,outputType,dimension,{});
    
end
