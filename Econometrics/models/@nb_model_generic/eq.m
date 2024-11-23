function ret = eq(obj,others)
% Syntax:
%
% ret = eq(obj,other)
%
% Description:
%
% Test if nb_model_generic objects are equal. In the sens they have the
% same properties.
% 
% Input:
% 
% - obj    : A nb_model_generic object either with same size as others, or
%            equal to 1.
%
% - others : A nb_model_generic model with dim == 3 or less
% 
% Output:
% 
% - ret    : A logical matching the others input
%
% Examples:
%
% v(1,5) = nb_var;
% ind    = v(1) == v
%
% See also:
% isequal
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    [r1,r2,r3] = size(others);
    if numel(obj) == 1
        obj = obj(ones(1,r1),ones(1,r2),ones(1,r3));
    else
        [s1,s2,s3] = size(obj);
        if r1 ~= s1 || r2 ~= s2 || r3 ~= s3
            error([mfilename ':: The obj input and other must have same size'])
        end 
    end

    ret = false(r1,r2,r3);
    for ii = 1:r1
        for jj = 1:r2
            for kk = 1:r3
                ret(ii,jj,kk) = isequal(obj(ii,jj,kk),others(ii,jj,kk));
            end
        end
    end
    
end
