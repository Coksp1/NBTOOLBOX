function ret = isempty(obj)
% Syntax:
%
% ret = isempty(obj)
%
% Description:
%
% Is the nb_term object empty or not. Also work for matrices of nb_term
% objects.
% 
% Input:
% 
% - obj : A nb_term object (matrix)
% 
% Output:
% 
% - ret : A logical with same size as obj.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    siz = size(obj);
    c   = [obj.numberOfTerms];
    ret = c == 0;
    ret = reshape(ret,siz);
    
end
