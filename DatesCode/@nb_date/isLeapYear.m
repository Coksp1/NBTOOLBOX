function ret = isLeapYear(obj)   
% Syntax:
% 
% ret = isLeapYear(obj)
%
% Description:
%   
% Test if the current year is a leap year
% 
% Input: 
% 
% - obj   : An object which is of class nb_date or a subclass of 
%           the nb_date class
% 
% Output:
% 
% - ret   : Logical. 1 if object is leap year, 0 else
% 
% Examples:
%
% ret = obj.isLeapYear(); 
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    ret = obj.leapYear;

end
