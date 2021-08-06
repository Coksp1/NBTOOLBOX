function cellStr = colon(a,d,b)
% Syntax:
%
% cellStr = colon(a,d,b)
%
% Description:
%
% Overload the : operator. The result is a cellstr array of all the
% dates between the a and b (Including the a and b dates).
% 
% Input:
% 
% - a         : An object of class nb_date or of a subclass of the 
%               nb_date class
% 
% - d         : Increments between the dates
% 
% - b         : An object of class nb_date or of a subclass of the 
%               nb_date class
% 
% Output:
% 
% - cellStr   : A cellstr array of the periods between the dates 
%               represented by a and b. (Including the dates a and 
%               b). If a and b are nb_date object an empty cell is
%               returned.
%     
% Examples:
%
% dates = a:b;
% dates = a:2:b;
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

if nargin < 3
    b = d;
    d = 1;
end

if ~isa(a,'nb_date') || ~isa(b,'nb_date')
    error([mfilename ':: Both objects must be of a subclass of the nb_date class.'])
end

if ~isEqualFreq(a,b)
    error([mfilename ':: Both objects must be of the same subclass. Cannot use the colon operator for objects of ' class(a) ' and ' class(b) '.'])
end

if isempty(a) || isempty(b)
    cellStr = {};
    return
end

periods = b - a;
if periods < 0

    cellStr = {};

else

    cellStr = strtrim(a.toDates(0:d:periods)); 

end

end
