function plotter = plot(obj,x,type,index)
% Syntax:
%
% plotter = plot(obj,type)
%
% Description:
%
% Graph either the PDF or CDF of one of the marginal distribution
% 
% Input:
% 
% - obj   : A nb_distribution object.
%
% - x     : The values to evaluate the distribution. x must be a Nx1 double.
%
%           If not provided or empty the full domain of the distribution(s)
%           will be used
%
% - type  : A string with either 'pdf' (default) or 'cdf'
% 
% - index : The index of the marginal distribution to plot. Default is 1.
%
% Output:
% 
% - plotter : A nb_graph_data object. If nargout is 0 the graph will be
%             plotted automatically, otherwise you need to call the graph
%             method on the plotter object.
%
% Examples:
%
% obj = nb_distribution
% plot(obj)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        index = 1;
        if nargin < 3
            type = 'pdf';
            if nargin < 2
                x = [];
            end
        end
    end

    try
        obj = obj.distributions(index);
    catch Err
        error([mfilename ':: index outside bounds of the marginal distributions property:: ' Err.message])
    end
    
    if isempty(x)
        start  = getStartOfDomain(obj);
        finish = getEndOfDomain(obj);
        if finish - start > 1
            start  = round(start);
            finish = round(finish);
        elseif finish - start > 0.1
            start  = round(start*10)/10;
            finish = round(finish*10)/10;
        elseif finish - start > 0.01
            start  = round(start*100)/100;
            finish = round(finish*100)/100;
        else
            start  = round(start*1000)/1000;
            finish = round(finish*1000)/1000;
        end
        incr   = (finish - start)/99;
        x      = start:incr:finish;
    end
    
    if size(x,2) ~= 1
        if size(x,1) ~=1
            error([mfilename ':: The x input must be a column vector.'])
        else
            x = x';
        end
    end

    switch lower(type)
        
        case 'cdf'
            
            f = cdf(obj,x);
            
        otherwise
            
            f = pdf(obj,x);
    end

    % Make a nb_graph_data object
    vars    = {obj.name};
    data    = nb_data([x,f],'',1,['domain',vars]);
    plotter = nb_graph_data(data);
    plotter.set('variableToPlotX','domain',...
                'variablesToPlot',vars,...
                'legInterpreter','latex');
            
    if nargout == 0
        plotter.graph();
    end
    
end
