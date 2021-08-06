function plotter = nb_plotPPAMultipliers(mult,shock,variable,perc)
% Syntax:
%
% plotter = nb_plotPPAMultipliers(mult,shock,variable,perc)
%
% Description:
%
% Plot output from the priorPredictiveAnalysis method when the method
% input is set to calculateMultipliers.
% 
% Input:
% 
% - mult     : The output from priorPredictiveAnalysis.
%
% - shock    : The shock you want to graph. As a one line char.
%
% - variable : The variable you want to graph. As a one line char.
%
% - perc     : This options sets the error band percentiles of the 
%              graph. As a 1 x numErrorBand double. E.g. [0.3,0.5,0.7,0.9]. 
%              Default is 0.68.
% 
% Output:
% 
% - plotter  : An object of class nb_graph_cs, use the graph method or the
%              nb_graphPagesGUI class. If nargout == 0, the graph will be
%              made using the nb_graphPagesGUI class.
%
% See also:
% nb_graph_cs, nb_graphPagesGUI
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        perc = 0.99;
    end
    
    aPerc  = nb_interpretPerc(perc,false);
    aPerc  = flipud(aPerc(:));
    aPercN = strcat('Percentile_',strtrim(cellstr(num2str(aPerc)))');

    if ~nb_isOneLineChar(variable)
        error([mfilename ':: The variable input must be a one line char'])
    end
    if ~nb_isOneLineChar(shock)
        error([mfilename ':: The shock input must be a one line char'])
    end

    fields = fieldnames(mult);
    indR   = nb_contains(fields,'RMSD');
    fields = fields(~indR);
    data   = nb_cs([],'','','',false);
    for ii = 1:length(fields)
        temp  = window(mult.(fields{ii}),shock,variable);
        p     = permute(prctile(temp.data,aPerc,3),[2,3,1]);
        m     = mean(temp,'double',3);
        dataP = nb_cs([p,m],'',fields(ii),[aPercN,[variable '_' shock]],false);
        data  = data.merge(dataP);
    end
    
    plotter = nb_graph_cs(data);
    plotter.set('plotTypes',{[variable '_' shock],'grouped'});
    if nargout < 1
        nb_graphPagesGUI(plotter);
    end
    
end
