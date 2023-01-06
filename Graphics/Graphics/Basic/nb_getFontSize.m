function fontSize = nb_getFontSize(fontSize,newFontUnits,oldFontUnits,normalizeFactor)
% Syntax:
% 
% fontSize = nb_getFontSize(fontSize,newFontUnits,oldFontUnits,...
%                           normalizeFactor)
% 
% Description:
% 
% Transform the given font size from a font units from a old to a 
% new one while keeping the font size on the plot. (See below for 
% an exception)
%
% Caution : If you transform from 'points','inches' and 
%           'centimeters' to 'normalized' this function will not
%           keep the font size, it will normalize the font size to
%           how the given font size would have been plotted
%           on a axes with positions [0.13 0.11 0.775 0.815] on a
%           screen with resolution 1680x1050 pixels.
%
%           Adjust the normalizeFactor to change which axes
%           positions and screen resolution to normalize against.
% 
% Input:
% 
% - fontSize        : The font size to convert. As a scalar.
% 
% - newFontUnits    : The font units to convert to.
%
%                     Either 'points','inches', 'centimeters' or 
%                     'normalized'.
% 
% - oldFontUnits    : The font to convert from. 
%
%                     Either 'points','inches', 'centimeters' or 
%                     'normalized'.
%
% - normalizeFactor : The factor that transform the font size in 
%                     'points' to the font size in 'normalized'
%                     units. The default factor is 
%                     0.001787310098302, which will normalize the 
%                     font size to how the given font size would 
%                     have been plotted on a axes with positions 
%                     [0.13 0.11 0.775 0.815] on a screen with 
%                     resolution 1680x1050 pixels.
% 
% Output:
% 
% - fontSize        : The converted font size. As a scalar.
% 
% Examples:
% 
% fontSize = nb_getFontSize(12,'normalized','points');
% 
% See also:
% 
% Written by Kenneth Sæterhagen Paulsen
 
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        normalizeFactor = 0.001787310098302;
    end

    switch lower(oldFontUnits)

        case 'points'

            switch lower(newFontUnits)

                case 'points'

                    % Do nothing

                case 'normalized'

                    fontSize   = fontSize*normalizeFactor;

                case 'inches'

                    fontSize   = fontSize/72;

                case 'centimeters'

                    fontSize   = fontSize*2.54/72;

                otherwise

                    error([mfilename ':: Unsupported font units ' newFontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])

            end

        case 'normalized'

            switch lower(newFontUnits)

                case 'points'

                    fontSize   = fontSize/normalizeFactor;

                case 'normalized'

                    % Do nothing

                case 'inches'

                    fontSize   = (fontSize/normalizeFactor)/72;

                case 'centimeters'

                    fontSize   = (fontSize/normalizeFactor)*2.54/72;

                otherwise

                    error([mfilename ':: Unsupported font units ' newFontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])

            end

        case 'inches'

            switch lower(newFontUnits)

                case 'points'

                    fontSize   = fontSize*72;

                case 'normalized'

                    fontSize   = (fontSize*72)*normalizeFactor;

                case 'inches'

                    % Do nothing

                case 'centimeters'

                    fontSize   = fontSize*2.54;

                otherwise

                    error([mfilename ':: Unsupported font units ' newFontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])

            end

        case 'centimeters' 

            switch lower(newFontUnits)

                case 'points'

                    fontSize   = (fontSize/2.54)*72;

                case 'normalized'

                    fontSize   = ((fontSize/2.54)*72)*normalizeFactor;

                case 'inches'

                    fontSize   = fontSize/2.54;

                case 'centimeters'

                    % Do nothing

                otherwise

                    error([mfilename ':: Unsupported font units ' newFontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])

            end

    end

end
