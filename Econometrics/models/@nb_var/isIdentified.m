function ret = isIdentified(obj)
% Syntax:
%
% ret = isIdentified(obj)
%
% Description:
%
% Is the nb_var object identified or not.
% 
% Input:
% 
% - obj : A nb_var object (matrix)
% 
% Output:
% 
% - ret : A logical with same size as obj.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [s1,s2,s3] = size(obj);
    ret        = false(s1,s2,s3);
    for ii = 1:s1
        for jj = 1:s2
            for kk = 1:s3
                ret(ii,jj,kk) = ~nb_isempty(obj.solution.identification);
            end
        end
    end

end
