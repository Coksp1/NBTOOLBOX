function nb_axesObject = nb_subplotSpecial(m,n,p,varargin)
% Syntax:
% 
% nb_axesObject = nb_subplotSpecial(m,n,p,varargin)
% 
% Description:
% 
% Create axes in tiled positions. Contrary to th nb_subplot
% function this function will tile the 1x2 and 2x1 subplot in
% positions better fitted for inclusion in presentations.
% 
% obj = nb_subplotSpecial(m,n,p), breaks the Figure window into an  
% m-by-n matrix of small axes, selects the p-th axes for the 
% current plot, and returns the nb_axes handle.  The axes are 
% counted along the top row of the Figure window, then the second 
% row, etc. 
% 
% Input:
% 
% - m        : Number of axes rows of current figure
% 
% - n        : Number of axes columns of current figure
% 
% - p        : The p-th axes of the subplot
% 
% - varargin : ...,'propertyName',propertyValue,... combination 
%              given to the initialized nb_axes handles. Should not 
%              include the property name 'position', because then 
%              you overrule the position given by this function.
%              See the nb_axes class for more on the properties
%              to set.
% 
% Caution : If you want to add more sub axes to one figure it is 
%           important to provide the 'parent' property. E.g. if you 
%           want two axes in one figure, do the following:
% 
%           fig   = nb_figure;
%           axes1 = nb_subplotSpecial(2,1,1,'parent',fig);
%           axes2 = nb_subplotSpecial(2,1,2,'parent',fig);
% 
% Output:
% 
% - nb_axesObject : An object of class nb_axes
% 
% Examples:
% 
% nb_axesObject = nb_subplotSpecial(2,2,1);
% nb_axesObject = nb_subplotSpecial(2,2,1,'shading','grey');
% 
% See also:
% nb_axes, axes, subplot, nb_subplot
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

if nargin < 3
    p = 1;
    if nargin < 2
        n = 1;
        if nargin < 1
            m = 1;
        end
    end
end

%------------------------------------------------------------------
% Get the postions from the MATLAB function subplot
%------------------------------------------------------------------
if n == 1 && m == 1 && p == 1
    nb_axesObject = nb_axes(varargin{:});
    return
end

ax  = subplot(m,n,p);
pos = get(ax,'position');

if sum(strcmpi(varargin,'parent'))  
    delete(ax);
else
    delete(gcf);
end

if m == 2 && n == 1
    pos(1) = 0.3;
    pos(3) = 0.4;
elseif m == 1 && n == 2
    pos(2) = 0.3;
    pos(4) = 0.4;
end

%--------------------------------------------------------------------------
% Initialize the nb_axes object
%--------------------------------------------------------------------------
nb_axesObject = nb_axes('position',pos,varargin{:});

end
