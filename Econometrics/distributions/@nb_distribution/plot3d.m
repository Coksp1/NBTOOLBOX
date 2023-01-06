function [f,ax,p] = plot3d(obj,x,type,func)
% Syntax:
%
% plotter = plot(obj,type)
%
% Description:
%
% Graph either the PDF or CDF of the distribution
% 
% Input:
% 
% - obj  : A vector of nb_distribution objects.
%
% - x    : The values to evaluate the distribution. x must be a Nx1 double.
%
%          If not provided or empty the full domain of the distribution(s)
%          will be used
%
% - type : A string with either 'pdf' (default) or 'cdf'
% 
% - plot : To set plottype. Either 'surf' (default) or 'mesh'. Either as a
%          string or a function handle.
%
% Output:
% 
% - plotter : A nb_graph_data object. If nargout is 0 the graph will be
%             plotted automatically, otherwise you need to call the graph
%             method on the plotter object.
%
% Examples:
%
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
       func = 'surf';
        if nargin < 3
             type = 'pdf';
            if nargin < 2
                x = [];
            end
        end
    end
    if ischar(func)
        func = str2func(func);
    end
    data   = obj.asData(x, type);
    T      = length(obj);
    FF     = data.data(:,2:end);
    domain = data.data(:,1);
    f      = figure;
    ax     = axes('parent',f);
    p      = func(ax,1:T,domain,FF);
   % set(pl,'lineStyle','none')
end
