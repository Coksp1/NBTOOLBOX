function plotter = plotMCFValues(paramD,params,values,nameValue)
% Syntax:
%
% plotter = nb_model_generic.plotMCFValues(paramD,params,nameValue)
%
% Description:
%
% Plot parameter draws from Monte Carlo filtering and matching results.
% 
% Input:
% 
% - paramD     : A draws x N double with the parameter draws. E.g. use
%                paramD(success,:) from the output of the 
%                monteCarloFiltering method. N is the number of parameters.
% 
% - params     : A 1 x N cellstr with the names of the parameters.
%
% - values     : A draws x 1 double with the values of the monte carlo 
%                filtering.
%
% - nameValue  : Name of the values used in the graphs produced. Default 
%                is 'Value'. Must be a one line char.
%
% Output:
% 
% - plotter : A vector of nb_graph_data objects with size 1 x N. Use the 
%             graph method or the nb_graphMultiGUI class to produce the 
%             graphs.
%
% See also:
% nb_model_generic.monteCarloFiltering
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        nameValue = 'Value';
    end
    
    if ~islogical(values) || ~isvector(values)
        error('The values input must be logical array')
    end
    values = values(:);
    if size(values,1) ~= size(paramD,1)
        error('The values input must have as many elements as the paramD input has rows.');
    end
    if ~iscellstr(params)
        error('The params input must be a cellstr.')
    end
    params = nb_rowVector(params);
    if size(params,2) ~= size(paramD,2)
        error('The params input must have as many elements, as the paramD input has columns.')
    end
    if ~nb_isOneLineChar(nameValue)
        error('The nameValue input must be a one line char.')
    end

    numPar            = size(paramD,2);
    plotter(1,numPar) = nb_graph_data();
    for ii = 1:numPar 
            vars              = {params{ii},nameValue};
            [paramSorted,ind] = sort(paramD(:,ii)); 
            data              = nb_data([paramSorted,values(ind)],'',1,vars);
            plotter(ii)       = nb_graph_data(data);
            plotter(ii).set('title',params{ii},...
                            'variableToPlotX',params{ii},...
                            'variablesToPlot',{nameValue});
    end
        
    
end
