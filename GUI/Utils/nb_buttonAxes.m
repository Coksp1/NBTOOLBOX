function ax = nb_buttonAxes(parent,varargin)
% Syntax:
%
% ax = nb_buttonAxes(parent)
%
% Description:
%
% Make axes with frame and background, but nothing else.
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

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 1
        parent = figure;
    end

    ax = axes(...
        'box',      'on',...
        'parent',   parent,...
        'yLim',     [0,1],...
        'xLim',     [0,1],...
        'xTick',    [],...
        'yTick',    [],...
        varargin{:});
    
end
