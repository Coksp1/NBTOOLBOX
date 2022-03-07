function plotter = plotMCF(paramD,params,lowerBound,upperBound,method)
% Syntax:
%
% plotter = nb_model_generic.plotMCF(paramD,params,lowerBound,...
%               upperBound,method)
%
% Description:
%
% Plot parameter draws from Monte Carlo filtering.
% 
% Input:
% 
% - paramD     : A draws x N double with the parameter draws. E.g. use
%                paramD(success,:) from the output of the 
%                monteCarloFiltering method. N is the number of parameters.
% 
% - params     : A 1 x N cellstr with the names of the parameters.
%
% - lowerBound : A 1 x N double with the lower bound on the parameters of
%                interest.
%
% - upperBound : A 1 x N double with the upper bound on the parameters of
%                interest.
%
% - method     : Either 'biplot' or 'allInOne'. 'biPlot' will plot all 
%                pairwise combination against each other in a scatter plot. 
%                'allInOne' will plot the parameters on the x-axis and the 
%                the accepted parameter values of each of the parameters  
%                on the y-axis. Default is 'allInOne'.
%
% Output:
% 
% - plotter : > 'allInOne' : A nb_graph_cs object. Use the graph method
%                            or the nb_graphPagesGUI class to produce the
%                            graphs.
%             > 'biplot'   : A vector of nb_graph_data objects with size
%                            equal to the number of pairwise combination of
%                            the parameters that can be made. Use the 
%                            graph method or the nb_graphMultiGUI class to 
%                            produce the graphs.
%
% See also:
% nb_model_generic.monteCarloFiltering
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        method = '';
    end
    if isempty(method)
        method = 'allInOne';
    else
        if ~nb_isOneLineChar(method)
            error([mfilename ':: The method input must be a one line char.'])
        end
    end

    if ~iscellstr(params)
        error([mfilename ':: The names input must be a cellstr.'])
    end
    
    params = params(:)';
    if size(params,2) ~= size(paramD,2)
        error([mfilename ':: The names input must match the number of columns of the param input (' int2str(size(paramD,2)) ')'])
    end
    
    if strcmpi(method,'allInOne')
        
        % Scale 
        for ii = 1:size(paramD,2)
            paramD(:,ii) = (paramD(:,ii) - lowerBound(ii))/(upperBound(ii) - lowerBound(ii));
        end
        
        % Make graph object
        draws          = size(paramD,1);
        drawNames      = nb_appendIndexes('Draw',1:draws);
        data           = nb_cs(paramD','',params,drawNames);
        plotter        = nb_graph_cs(data);
        lineS          = cell(1,draws*2);
        lineS(1:2:end) = drawNames;
        marks          = lineS;
        lineS(2:2:end) = {'none'};
        marks(2:2:end) = {'d'};
        plotter.set('lineStyles',lineS,'markers',marks,'noLegend',1,'addSpace',[0.5,0.5],'yLim',[0,1]);
        
    elseif strcmpi(method,'biplot')

        % Get combination indexes
        draws     = size(paramD,1);
        numParam  = length(params);
        if numParam == 1
            error([mfilename ':: The biplot method is not supported when dealing with only one parameter!'])
        elseif numParam == 2
            cn = [1,2];
        else
            id1       = cumsum((numParam-1):-1:2)+1;
            cn        = zeros((numParam-1)*numParam / 2,2);
            cn(:,2)   = 1;
            cn(1,:)   = [1 2];
            cn(id1,1) = 1;
            cn(id1,2) = -((numParam-3):-1:0);
            cn        = cumsum(cn);
        end
        
        % Create graph objects
        num            = size(cn,1);
        plotter(1,num) = nb_graph_data();
        for ii = 1:num
            data        = nb_data(paramD(:,cn(ii,:)),'',1,params(cn(ii,:)));
            plotter(ii) = nb_graph_data(data);
            set(plotter(ii),'scatterObs',{'scatterGroup1',{1,draws}},'scatterVariables',params(cn(ii,:)),'noLegend',1,...
                            'xLabel',params{cn(ii,1)},'yLabel',params{cn(ii,2)},'plotType','scatter',...
                            'xLim',[lowerBound(cn(ii,1)),upperBound(cn(ii,1))],'yLim',[lowerBound(cn(ii,2)),upperBound(cn(ii,2))],...
                            'markerSize',2);
        end
        
    else
        error([mfilename ':: The method ' method ' is not supported.'])
    end

end
