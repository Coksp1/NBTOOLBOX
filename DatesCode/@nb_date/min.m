function obj = min(obj1,obj2)
% Syntax:
%
% obj = nb_date.min(obj1,obj2)
%
% Description:
%
% Find the first date of the two. The frequency must be the same!
% 
% Input:
% 
% - obj1 : A scalar nb_date object.
%
% - obj2 : A scalar nb_date object.
% 
% Output:
% 
% - obj  : The first of the two dates, as a nb_date object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isempty(obj1)
        obj = obj2;
        return
    elseif isempty(obj2)
        obj = obj1;
        return
    end

    if ~isscalar(obj1)
        error('The first input must be a scalar')
    end
    if ~isscalar(obj2)
        error('The second input must be a scalar')
    end
    if obj1.frequency ~= obj2.frequency
        error('The frequency of the two objects must be the same.')
    end
    obj = min(obj1,obj2);

end
