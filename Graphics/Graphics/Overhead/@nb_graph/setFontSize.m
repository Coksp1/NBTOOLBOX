function setFontSize(obj,oldFontSize,normalizeFactor)
% Syntax:
%
% setFontSize(obj,oldFontSize,normalizeFactor)
%
% Description:
%
% Set the font size properties, given the fontUnits property
% 
% This method is called each time the fontUnits property is 
% set
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen 

    if nargin < 3
        normalizeFactor = 0.001787310098302;
    end

    switch lower(oldFontSize)

        case 'points'

            switch lower(obj.fontUnits)

                case 'points'

                    % Do nothing

                case 'normalized'

                    obj.axesFontSize        = obj.axesFontSize*normalizeFactor;
                    obj.legFontSize         = obj.legFontSize*normalizeFactor;
                    obj.titleFontSize       = obj.titleFontSize*normalizeFactor;
                    obj.xLabelFontSize      = obj.xLabelFontSize*normalizeFactor;
                    obj.yLabelFontSize      = obj.yLabelFontSize*normalizeFactor;
                    if isa(obj,'nb_graph_ts')
                        obj.fanLegendFontSize = obj.fanLegendFontSize*normalizeFactor;
                    end

                case 'inches'

                    obj.axesFontSize        = obj.axesFontSize/72;
                    obj.legFontSize         = obj.legFontSize/72;
                    obj.titleFontSize       = obj.titleFontSize/72;
                    obj.xLabelFontSize      = obj.xLabelFontSize/72;
                    obj.yLabelFontSize      = obj.yLabelFontSize/72;
                    if isa(obj,'nb_graph_ts')
                        obj.fanLegendFontSize = obj.fanLegendFontSize/72;
                    end

                case 'centimeters'

                    obj.axesFontSize        = obj.axesFontSize*2.54/72;
                    obj.legFontSize         = obj.legFontSize*2.54/72;
                    obj.titleFontSize       = obj.titleFontSize*2.54/72;
                    obj.xLabelFontSize      = obj.xLabelFontSize*2.54/72;
                    obj.yLabelFontSize      = obj.yLabelFontSize*2.54/72;
                    if isa(obj,'nb_graph_ts')
                        obj.fanLegendFontSize = obj.fanLegendFontSize*2.54/72;
                    end

                otherwise

                    error([mfilename ':: Unsupported font units ' obj.fontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])

            end

        case 'normalized'

            switch lower(obj.fontUnits)

                case 'points'

                    obj.axesFontSize        = obj.axesFontSize/normalizeFactor;
                    obj.legFontSize         = obj.legFontSize/normalizeFactor;
                    obj.titleFontSize       = obj.titleFontSize/normalizeFactor;
                    obj.xLabelFontSize      = obj.xLabelFontSize/normalizeFactor;
                    obj.yLabelFontSize      = obj.yLabelFontSize/normalizeFactor;
                    if isa(obj,'nb_graph_ts')
                        obj.fanLegendFontSize = obj.fanLegendFontSize/normalizeFactor;
                    end

                case 'normalized'

                    % Do nothing

                case 'inches'

                    obj.axesFontSize        = (obj.axesFontSize/normalizeFactor)/72;
                    obj.legFontSize         = (obj.legFontSize/normalizeFactor)/72;
                    obj.titleFontSize       = (obj.titleFontSize/normalizeFactor)/72;
                    obj.xLabelFontSize      = (obj.xLabelFontSize/normalizeFactor)/72;
                    obj.yLabelFontSize      = (obj.yLabelFontSize/normalizeFactor)/72;
                    if isa(obj,'nb_graph_ts')
                        obj.fanLegendFontSize = (obj.fanLegendFontSize/normalizeFactor)/72;
                    end

                case 'centimeters'

                    obj.axesFontSize        = (obj.axesFontSize/normalizeFactor)*2.54/72;
                    obj.legFontSize         = (obj.titleFontSize/normalizeFactor)*2.54/72;
                    obj.titleFontSize       = (obj.xLabelFontSize/normalizeFactor)*2.54/72;
                    obj.xLabelFontSize      = (obj.xLabelFontSize/normalizeFactor)*2.54/72;
                    obj.yLabelFontSize      = (obj.yLabelFontSize/normalizeFactor)*2.54/72;
                    if isa(obj,'nb_graph_ts')
                        obj.fanLegendFontSize = (obj.fanLegendFontSize/normalizeFactor)*2.54/72;
                    end

                otherwise

                    error([mfilename ':: Unsupported font units ' obj.fontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])

            end

        case 'inches'

            switch lower(obj.fontUnits)

                case 'points'

                    obj.axesFontSize        = obj.axesFontSize*72;
                    obj.legFontSize         = obj.legFontSize*72;
                    obj.titleFontSize       = obj.titleFontSize*72;
                    obj.xLabelFontSize      = obj.xLabelFontSize*72;
                    obj.yLabelFontSize      = obj.yLabelFontSize*72;
                    if isa(obj,'nb_graph_ts')
                        obj.fanLegendFontSize = obj.fanLegendFontSize*72;
                    end

                case 'normalized'

                    obj.axesFontSize        = (obj.axesFontSize*72)*normalizeFactor;
                    obj.legFontSize         = (obj.legFontSize*72)*normalizeFactor;
                    obj.titleFontSize       = (obj.titleFontSize*72)*normalizeFactor;
                    obj.xLabelFontSize      = (obj.xLabelFontSize*72)*normalizeFactor;
                    obj.yLabelFontSize      = (obj.yLabelFontSize*72)*normalizeFactor;
                    if isa(obj,'nb_graph_ts')
                        obj.fanLegendFontSize = (obj.fanLegendFontSize*72)*normalizeFactor;
                    end

                case 'inches'

                    % Do nothing

                case 'centimeters'

                    obj.axesFontSize        = obj.axesFontSize*2.54;
                    obj.legFontSize         = obj.legFontSize*2.54;
                    obj.titleFontSize       = obj.titleFontSize*2.54;
                    obj.xLabelFontSize      = obj.xLabelFontSize*2.54;
                    obj.yLabelFontSize      = obj.yLabelFontSize*2.54;
                    if isa(obj,'nb_graph_ts')
                        obj.fanLegendFontSize = obj.fanLegendFontSize*2.54;
                    end

                otherwise

                    error([mfilename ':: Unsupported font units ' obj.fontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])

            end

        case 'centimeters' 

            switch lower(obj.fontUnits)

                case 'points'

                    obj.axesFontSize        = (obj.axesFontSize/2.54)*72;
                    obj.legFontSize         = (obj.legFontSize/2.54)*72;
                    obj.titleFontSize       = (obj.titleFontSize/2.54)*72;
                    obj.xLabelFontSize      = (obj.xLabelFontSize/2.54)*72;
                    obj.yLabelFontSize      = (obj.yLabelFontSize/2.54)*72;
                    if isa(obj,'nb_graph_ts')
                        obj.fanLegendFontSize = (obj.fanLegendFontSize/2.54)*72;
                    end

                case 'normalized'

                    obj.axesFontSize        = ((obj.axesFontSize/2.54)*72)*normalizeFactor;
                    obj.legFontSize         = ((obj.legFontSize/2.54)*72)*normalizeFactor;
                    obj.titleFontSize       = ((obj.titleFontSize/2.54)*72)*normalizeFactor;
                    obj.xLabelFontSize      = ((obj.xLabelFontSize/2.54)*72)*normalizeFactor;
                    obj.yLabelFontSize      = ((obj.yLabelFontSize/2.54)*72)*normalizeFactor;
                    if isa(obj,'nb_graph_ts')
                        obj.fanLegendFontSize = ((obj.fanLegendFontSize/2.54)*72)*normalizeFactor;
                    end

                case 'inches'

                    obj.axesFontSize        = obj.axesFontSize/2.54;
                    obj.legFontSize         = obj.legFontSize/2.54;
                    obj.titleFontSize       = obj.titleFontSize/2.54;
                    obj.xLabelFontSize      = obj.xLabelFontSize/2.54;
                    obj.yLabelFontSize      = obj.yLabelFontSize/2.54;
                    if isa(obj,'nb_graph_ts')
                        obj.fanLegendFontSize = obj.fanLegendFontSize/2.54;
                    end

                case 'centimeters'

                    % Do nothing

                otherwise

                    error([mfilename ':: Unsupported font units ' obj.fontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])

            end

    end

end
