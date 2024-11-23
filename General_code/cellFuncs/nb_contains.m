function ind = nb_contains(s,pattern,varargin)
% Syntax:
%
% ind = nb_contains(s,pattern,varargin)
%
% Description:
%
% Robust implementation of the MATLAB function contains over different
% versions of MATLAB.
% 
% Input:
% 
% - s       : A M x N cellstr or a M x 1 char.
%
% - pattern : A one line char with the pattern to look for.
% 
% Optional input:
%
% - 'ignoreCase' : Set to true to ignore case.
%
% Output:
% 
% - ind     : A M x N logical if input is cellstr, otherwise M x 1. true 
%             if pattern found, otherwise false. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~nb_isOneLineChar(pattern)
        error([mfilename ':: pattern must be a one line char.'])
    end

    try
        ind = contains(s,pattern,varargin{:});
    catch % verLessThan('matlab','9.1')
        if ischar(s)
            s = cellstr(s);
        elseif ~iscellstr(s)
            error([mfilename ':: s must either be a cellstr of a char array.'])
        end
        ignoreCase = nb_parseOneOptional('IgnoreCase',false,varargin{:});
        if ignoreCase
            ind = ~cellfun(@isempty,strfind(lower(s),lower(pattern))); %#ok<STRCLFH>
        else
            ind = ~cellfun(@isempty,strfind(s,pattern)); %#ok<STRCLFH>
        end
    end
    
end
