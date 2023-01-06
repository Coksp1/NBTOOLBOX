function plotter = plot(obj)
% Syntax:
%
% plotter = plot(obj)
%
% Description:
%
% Plot recursive chow test p-values
% 
% Input:
% 
% - obj : An object of class nb_chowTestStatistic.
% 
% Output:
% 
% - plotter : An object of class nb_graph_ts. Use the graph method.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    data    = nb_ts(obj.results.chowProb,'',obj.results.breakPoint{1},{'Recursive P-values'});
    plotter = nb_graph_ts(data);
    plotter.set('title','Recursive P-values of chow test. Null hypothesis: No breakpoint',...
                'noLegend',true,'yLim',[0,1]);

end
