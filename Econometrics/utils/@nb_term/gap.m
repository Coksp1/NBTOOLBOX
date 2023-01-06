function obj = gap(obj)
% Syntax:
%
% obj = gap(obj)
%
% Description:
%
% Gap operator.
% 
% Input:
% 
% - obj : A vector of nb_term objects.
%
% Output:
% 
% - obj : A vector of nb_term objects.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin == 1
        obj = generalFunc(obj,'gap');
    end
    
end
