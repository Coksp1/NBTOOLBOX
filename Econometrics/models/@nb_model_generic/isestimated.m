function ret = isestimated(obj)
% Syntax:
%
% ret = isestimated(obj)
%
% Description:
%
% Is the nb_model_genric object empty (not estimated) or not.
%
% Caution: For DSGE model it will return true also if the model is only
%          filtered.
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [s1,s2,s3] = size(obj);
    ret        = false(s1,s2,s3);
    for ii = 1:s1
        for jj = 1:s2
            for kk = 1:s3
                if isa(obj(ii,jj,kk),'nb_dsge')
                    ret(ii,jj,kk) = isFiltered(obj(ii,jj,kk),'smoothed') || isfield(obj(ii,jj,kk).results,'logLikelihood');
                else
                    ret(ii,jj,kk) = ~nb_isempty(obj(ii,jj,kk).results);
                end
            end
        end
    end

end
