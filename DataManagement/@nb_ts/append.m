function obj = append(obj,DB,interpolateDate,method,rename,type)
% Syntax:
%
% obj = append(obj,DB,interpolateDate,method,rename,type)
%
% Description:
%
% Append a nb_ts object to another nb_ts object.
%
% Caution: 
% 
% - It is possible to merge datasets with the same variables as 
%   long as they represent the same data or have different 
%   timespans.
% 
% - If the datsets has different number of datasets and one of the 
%   merged objects only consists of one, this object will add as
%   many datasets as needed (copies of the first dataset) so they
%   the one object can append the other.
%
% - In contrast to the vertcat method, this method will keep the
%   first inputs end date and cut all the shared dates of the
%   appended object.
%
% - If the frequencies of the objects is not the same the object
%   with the lowest frequency will be converted.
% 
% Input:
% 
% - obj             : An object of class nb_ts
% 
% - DB              : An object of class nb_ts
% 
% - interpolateDate : 
%
%         How to transform the database with the lowest 
%         frequency.
%
%         - 'start' : The interpolated data are taken as given at 
%                     the start of the periods. I.e. use 01.01.2012 
%                     and 01.01.2013 when interpolating data with 
%                     yearly frequency. (Default)                             
% 
%         - 'end'   : The interpolated data are taken as given at 
%                     the end of the periods. I.e. use 31.12.2012 
%                     and 31.12.2013 when interpolating data with 
%                     yearly frequency.
% 
% - method          : The method to use when converting:
%
%                     - 'linear'   : Linear interpolation
%                     - 'cubic'    : Shape-preserving piecewise 
%                                    cubic interpolation 
%                     - 'spline'   : Piecewise cubic spline 
%                                    interpolation  
%                     - 'none'     : No interpolation. All data in  
%                                    between is given by nans 
%                                    (missing values)(Default)
%                     - 'fill'     : No interpolation. All periods  
%                                    of the higher frequency get 
%                                    the same value as that of the 
%                                    lower frequency.
% 
% - rename          : > 'on'  : Renames the prefixes (default)
%                     > 'off' : Do not rename the prefixes
%
%                     For more see the 'rename' option of the 
%                     convert method.
%
% - type            : The type of series to merge. Only when append is 
%                     equal to 1.
%
%                     > 'levelGrowth' : Append level data with growth
%                                       rates. Must be one period growth.
%                                       The merged series will be in level.
%
%                     > 'growthLevel' : Append growth rates with level data. 
%                                       Must be one period growth. The
%                                       merged series will be in growth
%                                       rates.
%
%                     > 'levelLevel'  : Append level series, where the
%                                       merging is done in growth rates,
%                                       but the end result is still in
%                                       levels. 
%
%                     > ''            : Standard merging
%
% Output:
% 
% - obj : An nb_ts object where the datasets from the two nb_ts 
%         objects are merged
% 
% Examples:
% 
% obj = append(obj,DB)
% obj = obj.append(DB)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

   if nargin < 6
       type = '';
       if nargin < 5
            rename = 'on';
            if nargin < 4
                method = 'none';
                if nargin < 3
                    interpolateDate = 'start';
                end
            end
       end
   end

    obj = merge(obj,DB,interpolateDate,method,rename,1,type);

end
