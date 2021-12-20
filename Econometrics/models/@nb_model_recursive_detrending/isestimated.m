function ret = isestimated(obj)
% Syntax:
%
% ret = isestimated(obj)
%
% Description:
%
% Is the nb_model_recursive_detrending object empty (not estimated) or not.
% 
% Input:
% 
% - obj : A nb_model_recursive_detrending object (matrix)
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
                if isempty(obj(ii,jj,kk).modelIter)
                    ret(ii,jj,kk) = false;
                else
                    ret(ii,jj,kk) = isestimated(obj(ii,jj,kk).modelIter(1));
                end
            end
        end
    end

end
