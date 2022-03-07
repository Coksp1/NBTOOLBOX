function [isDup,dup] = nb_duplicated(in)
% Syntax:
%
% isDup       = nb_duplicated(in)
% [isDup,dup] = nb_duplicated(in)
%
% Description:
%
% Find the unique duplicated elements of a vector.
% 
% Input:
% 
% - in : Any vector that are supported by the unique function made by
%        MATLAB.
% 
% Output:
% 
% - isDup : Return true if any duplicated values are located.
%
% - dup   : Return the (unique) located duplicated values.
%
% See also:
% unique
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isvector(in)
        error([mfilename ':: The in input must be a vector.'])
    end

    [~, I] = unique(in, 'first');
    x      = 1:length(in);
    x(I)   = [];
    isDup  = ~isempty(x);
    if nargout > 1
        dup = unique(in(x));
    end

end
