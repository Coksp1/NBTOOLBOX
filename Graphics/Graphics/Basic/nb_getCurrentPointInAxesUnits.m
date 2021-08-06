function [cPoint,cAxPoint] = nb_getCurrentPointInAxesUnits(fig,ax)
% Syntax:
%
% [cPoint,cAxPoint] = nb_getCurrentPointInAxesUnits(fig,ax)
%
% Description:
%
% Get current point of the mouse in the axes units of an nb_axes
% object.
% 
% Input:
% 
% - fig      : Either a figure, a nb_figure or a nb_graphPanel object.
%
% - ax       : As a nb_axes or axes object.
% 
% Output:
% 
% - cPoint   : Current point in figure or panel units. Will
%              depend on if the fig input i an nb_figure or an
%              nb_graphPanel object.
% 
% - cAxPoint : Current point of the mouse in the axes units of an 
%              nb_axes object. (in normalized units).
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isa(fig,'nb_figure')
        hObject = fig.figureHandle;
    else
        hObject = fig;
    end
    oldU    = get(hObject,'units');
    set(hObject,'units','normalized');
    cPoint  = get(hObject,'CurrentPoint');
    set(hObject,'units',oldU);
    if isa(ax,'nb_axes')
        axPos   = get(ax,'position');
    else
        oldAxU  = get(ax,'units');
        set(ax,'units','normalized');
        axPos   = get(ax,'position');
        set(hObject,'units',oldAxU);
    end
    
    % In axes units
    if isa(fig,'nb_graphPanel')

        % Get panel position
        panelH      = fig.panelHandle;
        oldUnits    = get(panelH,'units');
        set(panelH,'units','normalized');
        uipPos      = get(panelH,'Position');
        set(panelH,'units',oldUnits);

        % Get current position in panel units
        cPoint(1) = (cPoint(1) - uipPos(1))/uipPos(3);
        cPoint(2) = (cPoint(2) - uipPos(2))/uipPos(4);

        % Get current point in axes units
        cAxPoint    = nan(1,2);
        cAxPoint(1) = (cPoint(1) - axPos(1))/axPos(3);
        cAxPoint(2) = (cPoint(2) - axPos(2))/axPos(4);

    else

        % Get current point in axes units
        cAxPoint    = nan(1,2);
        cAxPoint(1) = (cPoint(1) - axPos(1))/axPos(3);
        cAxPoint(2) = (cPoint(2) - axPos(2))/axPos(4);

    end


end
