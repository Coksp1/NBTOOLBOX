function saveFigure(obj)
% Syntax:
% 
% saveFigure(obj)
% 
% Description:
% 
% Save the figure to a pdf file
% 
% Input:
% 
% - obj : An object of class nb_graph_adv
%
% Output:
%
% The plotted graph saved to a pdf file, given by the saveName 
% property of the object.
%     
% Examples:
%
% obj.saveFigure()
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isempty(obj.saveName)
        
        if obj.a4Portrait
            inputs = {'-a4Portrait','-append'};
        else
            inputs = {'-nocrop','-append'};
        end
        
        if ~obj.flip
            inputs = [inputs,{'-noflip'}];
        end
        
        format = 'pdf';
        
        fig = get(obj.plotter,'figureHandle');
        if isa(fig,'nb_figure') || isa(fig,'nb_graphPanel')
            fig = fig.figureHandle;
        end
        nb_saveas(fig,obj.saveName,format,inputs{:});

    end

end
