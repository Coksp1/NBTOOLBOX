function createFigure(obj)
% Syntax:
%
% createFigure(obj)
%
% Description:
%
% Create figure to plot in.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen 

    if obj.manuallySetFigureHandle == 0
        if isempty(obj.figurePosition)
            inputs = {'name',obj.figureName,'color',obj.figureColor,'units','characters'};
        else
            inputs = {'name',obj.figureName,'color',obj.figureColor,'units','characters','position',obj.figurePosition};
        end
        if ~isempty(obj.plotAspectRatio)
            inputs           = [inputs 'advanced',obj.advanced]; 
            obj.figureHandle = [obj.figureHandle, nb_graphPanel(obj.plotAspectRatio,inputs{:})];
        else
            obj.figureHandle = [obj.figureHandle, nb_figure(inputs{:})];
        end
    else
        if ~isempty(obj.figurePosition)
            pos    = get(obj.figureHandle,'position');
            pos(3) = obj.figurePosition(3);
            pos(4) = obj.figurePosition(4);
            if isa(obj.figureHandle,'nb_graphPanel')
                set(obj.figureHandle,'position',pos,...
                    'AspectRatio',obj.plotAspectRatio);  
            else
                set(obj.figureHandle,'position',obj.figurePosition);
            end
        end
        if ~isempty(obj.axesHandle)
            if isvalid(obj.axesHandle)
                obj.axesHandle.deleteOption = 'all';
                delete(obj.axesHandle);
            end
        end
    end

end
