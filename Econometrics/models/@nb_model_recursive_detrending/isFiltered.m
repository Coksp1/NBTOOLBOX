function ret = isFiltered(obj,tested)
% Syntax:
%
% ret = isFiltered(obj)
% ret = isFiltered(obj,tested)
%
% Description:
%
% Test if a nb_model_recursive_detrending object is filtered or not.
% 
% Input:
% 
% - obj    : An object of class nb_model_recursive_detrending.
% 
% - tested : Either 'smoothed', 'filtered' or 'updated'. Default is 
%            'smoothed'.
%
% Output:
% 
% - ret : 1 if filtered, otherwise 0.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin<2
        tested = 'smoothed';
    end

    [s1,s2,s3] = size(obj);
    ret        = false(s1,s2,s3);
    for ii = 1:s1
        for jj = 1:s2
            for kk = 1:s3
                ret(ii,jj,kk) = isFiltered(obj(ii,jj,kk).modelIter(1),tested);
            end
        end
    end
    
end
