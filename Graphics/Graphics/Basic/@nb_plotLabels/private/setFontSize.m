function setFontSize(obj,oldFontUnits)
       
    if strcmpi(obj.fontUnits,oldFontUnits)
        return
    end

    normalizeFactor = 0.002911226571376; 
    switch lower(oldFontUnits)

        case 'points'

            switch lower(obj.fontUnits)
                case 'points'
                    factor = 1;
                case 'normalized'
                    factor = normalizeFactor;
                case 'inches'
                    factor = 1/72;
                case 'centimeters'
                    factor = 2.54/72;
                otherwise
                    error([mfilename ':: Unsupported font units ' obj.fontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])
            end

        case 'normalized'

            switch lower(obj.fontUnits)
                case 'points'
                    factor = 1/normalizeFactor;
                case 'normalized'
                    factor = 1;
                case 'inches'
                    factor = (1/normalizeFactor)/72;
                case 'centimeters'
                    factor = (1/normalizeFactor)*2.54/72;
                otherwise
                    error([mfilename ':: Unsupported font units ' obj.fontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])
            end

        case 'inches'

            switch lower(obj.fontUnits)
                case 'points'
                    factor = 72;
                case 'normalized'
                    factor = 72*normalizeFactor;
                case 'inches'
                    factor = 1;
                case 'centimeters'
                    factor = 2.54;
                otherwise
                    error([mfilename ':: Unsupported font units ' obj.fontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])
            end

        case 'centimeters' 

            switch lower(obj.fontUnits)
                case 'points'
                    factor = (1/2.54)*72;
                case 'normalized'
                    factor = ((1/2.54)*72)*normalizeFactor;
                case 'inches'
                    factor = 1/2.54;
                case 'centimeters'
                    factor = 1;
                otherwise
                    error([mfilename ':: Unsupported font units ' obj.fontUnits ' given to the fontUnits property. Be aware that pixels are not supported.'])
            end

    end
    
    % Adjust font sizes accordingly to font units change
    obj.formatAll.fontSize = obj.formatAll.fontSize*factor;
    for ii = 1:length(obj.formatColumns)
        obj.formatColumns{ii}.fontSize = obj.formatColumns{ii}.fontSize*factor;
    end
    for ii = 1:length(obj.formatRows)
        obj.formatRows{ii}.fontSize = obj.formatRows{ii}.fontSize*factor;
    end
    for ii = 1:length(obj.formatColumns)
        obj.formatCells{ii}.fontSize = obj.formatCells{ii}.fontSize*factor;
    end
    
end
