function ax = nb_blankAxes(parent,varargin)
% Syntax:
%
% ax = nb_blankAxes(parent)
%
% Description:
%
% Make blank axes.
% 
% Input:
% 
% - varargin : Optional inputs given to the axes function.
% 
% Output:
% 
% - ax : A axes handle.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    ax = axes(...
        'parent',   parent,...
        'units',    'normalized',...
        'position', [0,0,1,1],...
        'yLim',     [0,1],...
        'xLim',     [0,1],...
        'xTick',    [],...
        'yTick',    [],...
        varargin{:});
    axis(ax,'off');
    
end
