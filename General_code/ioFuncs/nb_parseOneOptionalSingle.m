function [value,rest] = nb_parseOneOptionalSingle(name,ifNotGiven,ifGiven,varargin)
% Syntax:
%
% [value,rest] = nb_parseOneOptionalSingle(name,ifNotGiven,ifGiven,varargin)
%
% Description:
%
% Parse one optional input at the time.
% 
% Input:
% 
% - name       : Name of the optional input as a string.
% 
% - ifNotGiven : The value return if name is not found in varargin.
%
% - ifGiven    : The value return if name is found in varargin.
%
% - varargin   : All the optional inputs.
%
% Output:
% 
% - value    : Either ifNotGiven or ifGiven.
%
% - rest     : Rest of the optional inputs.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    ind = find(strcmpi(name,varargin));
    if isempty(ind)
        value = ifNotGiven;
    else
        value    = ifGiven;
        varargin = [varargin(1:ind-1),varargin(ind+1:end)];
    end
    rest = varargin;
    
end
