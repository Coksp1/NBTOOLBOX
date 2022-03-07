function setDefaultSettings(obj)
% Syntax:
%
% setDefaultSettings(obj)
%
% Description:
%
% Set the default settings given the graphing style
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen 

    if strcmpi(obj.graphStyle,'mpr')

        obj.noTitle               = 1;
        obj.shading               = 'grey';
        obj.axesFontSize          = 17;
        obj.titleFontSize         = 18;
        obj.legFontSize           = 14;
        obj.yLabelFontSize        = 14;  
        obj.xLabelFontSize        = 14;
        obj.legSpace              = 0.01;
        obj.legInterpreter        = 'tex';
        obj.yOffset               = 0.03;
        obj.position              = [.25, .25, .475, .5];
        obj.normalized            = 'axes';
        obj.plotAspectRatio       = '[4,3]';
        obj.markerSize            = 5.5;
        obj.lineWidth             = 1.75;
        obj.baseLineWidth         = 0.75;
        obj.legBox                = 'off';

        if isa(obj,'nb_graph_ts')
            obj.fanLegendFontSize     = 12;
        end

        % Normalize the font size to the axes position
        oldFontSize     = 'points';
        obj.fontUnits   = 'normalized';
        normalizeFactor = 0.002911226571376;
        setFontSize(obj,oldFontSize,normalizeFactor);

    elseif  strcmpi(obj.graphStyle,'mpr_white') 

        obj.noTitle               = 1;
        obj.axesFontSize          = 17;
        obj.titleFontSize         = 18;
        obj.legFontSize           = 14;
        obj.yLabelFontSize        = 14;  
        obj.xLabelFontSize        = 14;
        obj.legSpace              = 0.01;
        obj.legInterpreter        = 'tex';
        obj.yOffset               = 0.03;
        obj.position              = [.25, .25, .475, .5];
        obj.normalized            = 'axes';
        obj.plotAspectRatio       = '[4,3]';
        obj.markerSize            = 5.5;
        obj.lineWidth             = 1.75;
        obj.baseLineWidth         = 0.75;
        obj.legBox                = 'off';

        if isa(obj,'nb_graph_ts')
            obj.fanLegendFontSize     = 12;
        end

        % Normalize the font size to the axes position
        oldFontSize     = 'points';
        obj.fontUnits   = 'normalized';
        normalizeFactor = 0.002911226571376;
        setFontSize(obj,oldFontSize,normalizeFactor);

    elseif strcmpi(obj.graphStyle,'presentation')

        obj.crop                = 1;
        obj.shading             = 'grey';
        obj.axesFontSize        = 25; 
        obj.titleFontSize       = 25;
        obj.legFontSize         = 20; 
        obj.yLabelFontSize      = 20;  
        obj.xLabelFontSize      = 20;
        obj.markerSize          = 5;
        obj.lineWidth           = 1.5; 
        obj.baseLineWidth       = 0.25; 
        obj.legBox              = 'off';

        if isa(obj,'nb_graph_ts')
            obj.fanLegendFontSize     = 12;
        end

        % Normalize the font size to the axes position
        oldFontSize     = 'points';
        obj.fontUnits   = 'normalized';
        setFontSize(obj,oldFontSize);

    elseif strcmpi(obj.graphStyle,'presentation_white') 

        obj.crop                = 1;
        obj.axesFontSize        = 25; 
        obj.titleFontSize       = 25;
        obj.legFontSize         = 20; 
        obj.yLabelFontSize      = 20;  
        obj.xLabelFontSize      = 20;
        obj.markerSize          = 5;
        obj.lineWidth           = 1.5; 
        obj.baseLineWidth       = 0.25; 
        obj.legBox              = 'off';

        if isa(obj,'nb_graph_ts')
            obj.fanLegendFontSize     = 12;
        end

        % Normalize the font size to the axes position
        oldFontSize     = 'points';
        obj.fontUnits   = 'normalized';
        setFontSize(obj,oldFontSize);

    else

        if ~isempty(obj.graphStyle)
            eval(obj.graphStyle)
        end

    end

end
