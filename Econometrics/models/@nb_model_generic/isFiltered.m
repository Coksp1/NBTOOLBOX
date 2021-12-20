function ret = isFiltered(obj,tested)
% Syntax:
%
% ret = isFiltered(obj)
%
% Description:
%
% Test if a nb_dsge object is filtered or not.
% 
% Input:
% 
% - obj    : An object of class nb_dsge.
% 
% - tested : Either 'smoothed', 'filtered' or 'updated'. Default is 
%            'smoothed'.
%
% Output:
% 
% - ret : 1 if filtered, otherwise 0.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin<2
        tested = 'smoothed';
    end

    [s1,s2,s3] = size(obj);
    ret        = false(s1,s2,s3);
    for ii = 1:s1
        for jj = 1:s2
            for kk = 1:s3
                try ret(ii,jj,kk) = ~nb_isempty(obj(ii,jj,kk).results.(tested)); catch;end %#ok<CTCH>
            end
        end
    end
    
end
