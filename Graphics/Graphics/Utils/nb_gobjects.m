function array = nb_gobjects(varargin)
% Syntax:
%
% array = nb_gobjects(varargin)
%
% Description:
%
% Preallocate array for storing graphical objects that are robust to
% different versions of MATLAB.
% 
% Input:
% 
% - See gobjects or nan.
% 
% Output:
% 
% - array : Either a matrix of nan or a matrix of default graphics objects.
%           See gobjects or nan. If nb_oldGraphVersion returns true
%           then doubles are returned.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    try
        array = gobjects(varargin{:});
    catch % Make robust to old versions
        array = nan(varargin{:});
    end

end
