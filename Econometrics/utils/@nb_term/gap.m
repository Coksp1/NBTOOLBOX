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
% Written by Kenneth S�terhagen Paulsen

% Copyright (c) 2021, Kenneth S�terhagen Paulsen

    if nargin == 1
        obj = generalFunc(obj,'gap');
    end
    
end
