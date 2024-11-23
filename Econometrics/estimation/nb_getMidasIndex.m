function ind = nb_getMidasIndex(I,K,E)
% Syntax:
%
% ind = nb_getMidasIndex(I,K,E)
%
% Description:
%
% Get index of the lags of regressor I in the list of all regressors in a
% MIDAS model.
% 
% Input:
% 
% - I : The variable nuber. In [1,E].
%
% - K : Number of lags of the regressor. As a vector of integers with 
%       length E.
% 
% - E : The number of regressors in the MIDAS model.
%
% Output:
% 
% - ind : The index of the regressors associated with the variable I.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    c = cell(E,max(K));
    for ii = 1:E
        c(ii,1:K(ii)) = {ii};
    end
    c     = c(:);
    indNE = ~cellfun(@isempty,c);
    c     = c(indNE);
    c     = vertcat(c{:});
    ind   = I == c;
    
end
