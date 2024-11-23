function [value,rest] = nb_parseOneOptional(name,default,varargin)
% Syntax:
%
% [value,rest] = nb_parseOneOptional(name,default,varargin)
%
% Description:
%
% Parse one optional input at the time.
% 
% Input:
% 
% - name     : Name of the optional input as a string.
% 
% - default  : The default value of the optional input.
%
% - varargin : All the optional inputs.
%
% Output:
% 
% - value    : Either the found or default value.
%
% - rest     : Rest of the optional inputs.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    ind = find(strcmpi(name,varargin));
    if isempty(ind)
        value = default;
    else
        ind = ind(end); % Use last
        if nargin < ind + 3
            error([mfilename ':: Incorrect number of arguments. Input ''' name ''' must be followed with another input.'])
        end
        value    = varargin{ind+1};
        varargin = [varargin(1:ind-1),varargin(ind+2:end)];
    end
    rest = varargin;
    
end
