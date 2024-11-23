function ret = isSampled(obj)
% Syntax:
%
% ret = isSampled(obj)
%
% Description:
%
% Is the nb_model_sampling object sampled or not.
% 
% Input:
% 
% - obj : A nb_model_sampling object (matrix)
% 
% Output:
% 
% - ret : A logical with same size as obj.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    [s1,s2,s3] = size(obj);
    ret        = false(s1,s2,s3);
    for ii = 1:s1
        for jj = 1:s2
            for kk = 1:s3
                if isfield(obj(ii,jj,kk).estOptions,'pathToSave')
                    posterior     = nb_loadDraws(obj(ii,jj,kk).estOptions.pathToSave);
                    ret(ii,jj,kk) = ~nb_isempty(posterior.output);
                end
            end
        end
    end

end
