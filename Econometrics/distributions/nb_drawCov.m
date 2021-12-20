function C = nb_drawCov(N,draws)
% Syntax:
%
% C = nb_drawCov(N,P)
%
% Description:
%
% Draw random correlation matrices of size N x N.
% 
% Input:
% 
% - N     : The size of the correlation matrix.
%
% - draws : Number of draws. Added as separate pages.
% 
% Output:
% 
% - C     : A N x N x draws double.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        draws = 1;
    end
    
    C = nan(N,N,draws);
    for ii = 1:draws
        CO        = rand(N,N) - 0.5;
        C(:,:,ii) = CO*CO';
    end
    
end
