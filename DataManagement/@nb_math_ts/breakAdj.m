function obj = breakAdj(obj,method,varargin)
% Syntax:
%
% obj = breakAdj(obj,method,varargin)
%
% Description:
%
% The intent of this method is to set observations around break points to
% nan, and interpolate the observation at these break-points. I.e. if you
% have a level series that has a break, and want smooth growth rates. In 
% this case you can calculate the growth rates of the level series, and
% then use this method to smooth out the growth rate at the break-points.
% Then you can use the inverse growth methods to transform back to a level
% series without breaks.
%
% Input:
% 
% - obj    : An object of class nb_math_ts
% 
% - method : The wanted interpolation method to use. See the 
%            nb_interpolate function.
%   
% Optional input:
%
% - A set of nb_date objects or one line chars with the dates that should
%   be set to nan and interpolated.
%
% Output:
% 
% - obj : An object of class nb_math_ts.
% 
% See also:
% nb_interpolate, growth, egrowth, pcn, epcn, igrowth, iegrowth, ipcn, 
% iepcn
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    indexes  = nb_ts.findIndexesOfDates(obj.startDate,obj.endDate,varargin);
    obj.data = nb_breakAdj(obj.data,method,indexes);  

end
