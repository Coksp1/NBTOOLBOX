function c = toString(obj)
% Syntax:
%
% c = toString(obj)
%
% Description:
%
% Convert nb_base object to string or cellstr.
%
% Inputs:
%
% - obj : A nb_base object. May also be a matrix.
%
% Output:
%
% - c   : If obj is scalar the output will be a one line char, 
%         otherwise it will be a cellstr with same size as obj.  
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isscalar(obj)
        c = obj.value;
    else
        c = nb_callMethod(obj,@toString,'cell');
    end

end
