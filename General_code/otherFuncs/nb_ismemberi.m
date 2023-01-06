function varargout = nb_ismemberi(varargin)
% Syntax:
%
% varargout = nb_ismemberi(varargin)
%
% Description:
%
% Case insensitive ismember
% 
% Input:
% 
% See ismember
% 
% Output:
% 
% See ismember
%
% See also:
% ismember
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    for ii = 1:length(varargin)
        if iscellstr(varargin{ii}) || ischar(varargin{ii})
            varargin{ii} = lower(varargin{ii});
        end
    end
    [varargout{1:nargout}] = ismember(varargin{:});
    
end
