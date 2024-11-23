function ret = isRise(obj)
% Syntax:
%
% ret = isRise(obj)
%
% Description:
%
% Is the nb_dsge object a wrapper of a RISE dsge object or not.
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
                if isfield(obj(ii,jj,kk).estOptions,'riseObject')
                    ret(ii,jj,kk) = ~isempty(obj(ii,jj,kk).estOptions.riseObject);
                end
            end
        end
    end
    
end
