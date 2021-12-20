function ret = isbayesian(obj)
% Syntax:
%
% ret = isbayesian(obj)
%
% Description:
%
% Can the nb_model_genric object be estimated using bayesian methods
% (usiing the NB Toolbox) or not.
% 
% Input:
% 
% - obj : A nb_model_genric object (matrix).
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
                ret(ii,jj,kk) = isfield(obj(ii,jj,kk).options,'prior');
            end
        end
    end

end


    
