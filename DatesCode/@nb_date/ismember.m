function varargout = ismember(obj1,obj2)
% Syntax:
%
% - varargout = ismember(obj1,obj2)
%
% Description:
%
% Utilizes the inbuilt MATLAB function 'ismember' for nb_date objects.
%
% Input:
% 
% - obj1 : A nb_date object
%
% - obj2 : A nb_date object
%
% Output:
% 
% - varargout : See help on MATLAB function 'ismember'.
%
% See also:
% ismember
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    dateObj1 = toString(obj1);
    if ischar(dateObj1)
        dateObj1 = {dateObj1};
    end
    dateObj2 = toString(obj2);
    if ischar(dateObj2)
        dateObj2 = {dateObj2};
    end
    [varargout{1:nargout}] = ismember(dateObj1,dateObj2);
    
end
