function ret = isDynare(obj)
% Syntax:
%
% ret = isDynare(obj)
%
% Description:
%
% Is the nb_dsge object a wrapper of a model parsed by Dynare or not.
% 
% Input:
% 
% - obj : A nb_dsge object
% 
% Output:
% 
% - ret : 1 if true, else 0.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

	[s1,s2,s3] = size(obj);
    ret        = false(s1,s2,s3);
    for ii = 1:s1
        for jj = 1:s2
            for kk = 1:s3
                if isfield(obj(ii,jj,kk).estOptions,'M_')
                    ret(ii,jj,kk) = ~nb_isempty(obj(ii,jj,kk).estOptions.M_);
                end
            end
        end
    end
    
end
