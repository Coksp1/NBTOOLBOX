function ret = isMS(obj)
% Syntax:
%
% ret = isMS(obj)
%
% Description:
%
% Is the nb_model_genric object a Markov switching model or not.
% 
% Caution : Model must be solved, otherwise ret is always false!
%
% Input:
% 
% - obj : A nb_model_genric object (matrix)
% 
% Output:
% 
% - ret : A logical with same size as obj.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    [s1,s2,s3] = size(obj);
    ret        = false(s1,s2,s3);
    for ii = 1:s1
        for jj = 1:s2
            for kk = 1:s3
                retT = isfield(obj(ii,jj,kk).solution,'A');
                if retT
                    ret(ii,jj,kk) = iscell(obj(ii,jj,kk).solution.A) && ~strcmpi(obj(ii,jj,kk).solution.type,'nb');
                end
            end
        end
    end

end
