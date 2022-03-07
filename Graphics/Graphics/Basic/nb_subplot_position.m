function position = nb_subplot_position(m,n,p)
% Syntax:
% 
% position = nb_subplot_position(m,n,p)
% 
% Description:
% 
% Get the axes position when divided into subplots.
% 
% obj = nb_subplot(m,n,p), breaks the Figure window into an m-by-n 
% matrix of small axes, selects the p-th axes for the current plot,
% and returns the nb_axes handle.  The axes are counted along the 
% top row of the Figure window, then the second row, etc. 
% 
% Input:
% 
% - m        : Number of axes rows of current figure
% 
% - n        : Number of axes columns of current figure
% 
% - p        : The p-th axes of the subplot
% 
% Output:
% 
% - position : A 1x4 double. [xLow,yLow,xWidth,yWidth].
% 
% Examples:
% 
% position = nb_subplot(2,2,1);
% 
% See also:
% subplot, nb_subplot, nb_subplotSpecial
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

if nargin < 3
    p = 1;
    if nargin < 2
        n = 1;
        if nargin < 1
            m = 1;
        end
    end
end

if p == 1 && n == 1 && m == 1
    position = [0.1 0.1 0.8 0.8];
    return
end

%------------------------------------------------------------------
% Get the postions from the MATLAB function subplot
%------------------------------------------------------------------
f        = figure;
ax       = subplot(m,n,p,'parent',f);
position = get(ax,'position');
delete(f);

end
