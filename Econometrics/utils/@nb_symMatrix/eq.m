function ret = eq(obj,another)
% Syntax:
%
% ret = eq(obj,another)
%
% Description:
%
% Equality operator (==) for nb_symMatrix objects.
% 
% Input:
% 
% - obj     : A nb_symMatrix object or double.
%
% - another : A nb_symMatrix object or double.
% 
% Output:
% 
% - obj     : A nb_symMatrix object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen
    
    [obj,another,err] = checkTypes(obj,another,mfilename);
    if isempty(err)
        error(err);
    end
    [obj,another,err] = checkSizes(obj,another);
    if isempty(err)
        error(err);
    end
    ret = arrayfun(@eq,obj.symbols,another.symbols);

end
