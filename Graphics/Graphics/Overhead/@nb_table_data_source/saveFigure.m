function saveFigure(obj,extraName,format)
% Syntax:
% 
% saveFigure(obj,extraName,format)
% 
% Description:
% 
% Save the figure(s) produced by the nb_graph object to 
% (a) file(s) on the wanted format and name(s).
% 
% Input:
%
% - obj       : An object of class nb_table_data_source
% 
% - extraName : If you want to add some extra name to the saveName
%               property of the nb_graph_ts object before saving 
%               the file. (If the saveName property of the 
%               nb_graph_ts object is empty this will be the full 
%               name of the output file.)
% 
% - format    : The format of the saved output. Default is given by 
%               the property fileFormat of the nb_graph. Either
%               'eps', 'jpg', 'pdf', 'png', 'svg' or 'emf'.
%     
% Output:
%
% The produced figure(s) saved to the wanted formats.
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        format = obj.fileFormat;
        if nargin < 2
            extraName = '';
        end
    end
    
    fig = obj.figureHandle;
    if isa(fig,'nb_figure') || isa(fig,'nb_graphPanel')
        fig = fig.figureHandle;
    end
    
    if ~isempty(obj.saveName) || ~isempty(extraName)

        if ~obj.pdfBook

            if ~isempty(obj.saveName) && ~isempty(extraName)
                saveN = [obj.saveName '_' extraName];
            elseif ~isempty(extraName)
                saveN = extraName;
            else
                saveN = obj.saveName;
            end
            
            if ~obj.crop
                inputs = {'-nocrop'};
            else
                inputs = {};
            end
            
            if ~obj.flip
                inputs = [inputs,{'-noflip'}];
            end
            
            if obj.a4Portrait
                inputs = [inputs,{'-a4Portrait'}];
            end

            nb_saveas(fig,saveN,format,inputs{:})

        elseif obj.pdfBook

            format = 'pdf';

            if ~isempty(obj.saveName) 
                saveN = obj.saveName;
            else
                saveN = extraName;
            end
            
            if obj.a4Portrait
                inputs = {'-a4Portrait','-append'};
            else
                if ~obj.crop
                    inputs = {'-nocrop','-append'};
                else
                    inputs = {'-append'};
                end
            end
            
            if ~obj.flip
                inputs = [inputs,{'-noflip'}];
            end
            
            nb_saveas(fig,saveN,format,inputs{:});

        end

    end

end
