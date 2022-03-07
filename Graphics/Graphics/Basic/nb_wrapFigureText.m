function nb_wrapFigureText(obj,t,place)
% Syntax:
%
% nb_wrapFigureText(obj,t,place)
%
% Description:
%
% Wrap footer or figure title.
% 
% Input:
% 
% - obj   : An object of class nb_figure or nb_figureTitle.
%
% - t     : A text handle of the displayed footer or figure title.
%
% - place : x-axis position of where the text is positioned.
% 
% See also:
% nb_footer, nb_figureTitle
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    switch obj.placement
        
        case 'center'
            
            placeLeft  = 10000;
            axs        = obj.parent.children;
            for ii = 1:size(axs,2)
                p = getLeftMost(axs(ii));
                if p < placeLeft
                    placeLeft = p;
                end
            end
            
            placeRight = -10000;
            axs   = obj.parent.children;
            for ii = 1:size(axs,2)
                p = getRightMost(axs(ii));
                if p > placeRight
                    placeRight = p;
                end
            end
        
        case 'right'

            placeRight = place;
            placeLeft  = 10000;
            axs        = obj.parent.children;
            for ii = 1:size(axs,2)
                p = getLeftMost(axs(ii));
                if p < placeLeft
                    placeLeft = p;
                end
            end

        case 'left'

            placeLeft  = place;
            placeRight = -10000;
            axs   = obj.parent.children;
            for ii = 1:size(axs,2)
                p = getRightMost(axs(ii));
                if p > placeRight
                    placeRight = p;
                end
            end

        case 'leftaxes'
            
            placeLeft  = place;
            placeRight = -10000;
            axs        = obj.parent.children;
            for ii = 1:size(axs,2)
                p = get(axs(ii),'position');
                if p(1) + p(3) > placeRight
                    placeRight = p(1) + p(3);
                end
            end

    end

    pos = [placeLeft,0,placeRight - placeLeft,0];
    nb_breakText(t, pos);
                        
end

