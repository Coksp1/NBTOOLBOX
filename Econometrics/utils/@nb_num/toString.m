function c = toString(obj)
% Syntax:
%
% c = toString(obj)
%
% Description:
%
% Convert nb_num object to string or cellstr.
%
% Inputs:
%
% - obj : A nb_num object. May also be a matrix.
%
% Output:
%
% - c   : If obj is scalar the output will be a one line char, 
%         otherwise it will be a cellstr with same size as obj.  
%
% Written by Kenneth Sæterhagen Paulsen

    if isscalar(obj)
        val = obj.value;
        if abs(val) < 1e-10
            val = 0;
        end
        c = num2str(val,10);
    else
        c = nb_callMethod(obj,@toString,'cell');
    end

end
