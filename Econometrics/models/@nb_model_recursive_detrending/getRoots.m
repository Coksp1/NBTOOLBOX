function [roots,plotter] = getRoots(obj)
% Syntax:
%
% roots = getRoots(obj)
%
% Description:
%
% Get the eigenvalues of the companion for. If all these eigenvalues are
% inside the unit circle the model is stable.
%
% If some eigenvalues are on the unit circle the model is non-stationary 
% and you need to use cointegration relations.
%
% If the eigenvalues are outside the unit circle the model is explosive.
% 
% Caution : See page ModelX (ii), where ii will be the index for the 
%           recursive estimation.
%
% Input:
% 
% - obj     : A vector of nb_model_recursive_detrending objects.
% 
% Output:
% 
% - roots   : A nb_data object. Each page (dataset) gives the roots of each
%             model. This output has three variables 'Real', 'Imaginary' 
%             and 'Modulus' storing the given parts of the roots.
%
% - plotter : A nb_graph_data object. Use the graph method.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    obj  = obj(:);
    nobj = numel(obj);
    if nobj == 0
        error('Cannot get the roots of a empty vector of nb_model_recursive_detrending objects.')
    else
        
        roots = nb_data;
        vars  = {'Real','Imaginary','Modulus'};
        for ii = 1:nobj 
            
            for tt = 1:length(obj.modelInit)
                modelT = solve(obj.modelInit(tt));
                A      = modelT.solution.A;
                if iscell(A)
                    error([mfilename ':: Cannot calculate the roots of a Markov switching model yet'])
                end
                [realD,imagD,modulus] = nb_calcRoots(A);
                root                  = nb_data([realD,imagD,modulus],['Model',int2str(ii) '(' int2str(tt) ')'],1,vars);
                roots                 = addPages(roots,root);
            end
            
        end
        
        % Produce graph object if wanted
        if nargout > 1
            
            % Draw the cicrle
            realPart1 = -1:0.01:1;
            realPart  = [realPart1,1:-0.01:-1];
            imagPart1 = sqrt(1 - realPart1.^2);
            imagPart  = [imagPart1,-imagPart1];
            circle    = nb_drawLine('xData',      realPart,...
                                    'yData',      imagPart,...
                                    'lineWidth',  1,...
                                    'cData',      'red');
            
            % Get the limits
            yLim = [nan,nan];
            if all(imagPart < 1.1)
                yLim(2) = 1.1;
            end
            if all(imagPart > -1.1)
                yLim(1) = -1.1;
            end
            
            xLim = [nan,nan];
            if all(realPart < 1.1)
                xLim(2) = 1.1;
            end
            if all(realPart > -1.1)
                xLim(1) = -1.1;
            end
            
            % Get the graph object
            plotter = nb_graph_data(roots);
            plotter.set('annotation',           {circle},...
                        'legendText',           {'Imaginary',''},...               
                        'variableToPlotX',      'Real',...
                        'variablesToPlot',      {'Imaginary'},...
                        'lineStyles',           {'Imaginary','none'},...
                        'markers',              {'Imaginary','o'},...
                        'verticalLine',         0,...
                        'verticalLineColor',    {'black'},...
                        'verticalLineStyle',    {'-'},...
                        'verticalLineWidth',    1,...
                        'xLim',                 xLim,...
                        'yLim',                 yLim);

        end
        
    end

end
