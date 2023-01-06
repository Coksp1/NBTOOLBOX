function ind = isnan(obj)
% Syntax:
%
%
%
% Description:
%
% 
% 
% Input:
% 
% 
% 
% Output:
% 
% 
%
% Examples:
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    siz = size(obj);
    obj = obj(:);
    n   = prod(siz);
    ind = false(n,1);
    for ii = 1:n
        ind(ii) = strcmpi(obj(ii).type,'constant') && isnan(obj(ii).parameters{1});
    end
    ind = reshape(ind,siz);

end
