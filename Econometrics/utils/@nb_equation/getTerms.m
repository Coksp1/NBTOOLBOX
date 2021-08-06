function terms = getTerms(obj)
% Syntax:
%
% terms = getTerms(obj)
%
% Description:
%
% Get the expression(s) the object(s) represents.
% 
% Input:
% 
% - obj  : A Nx1 vector of nb_term objects.
% 
% Output:
% 
% - expr : A Nx1 cellstr with the terms of the nb_term objects.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    terms = collect(obj);
    if ischar(terms)
        terms = cellstr(terms);
    end
    
end
