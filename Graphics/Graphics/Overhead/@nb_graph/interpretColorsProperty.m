function tempColors = interpretColorsProperty(obj,cols,vars)
% Syntax:
%
% tempColors = interpretColorsProperty(obj,cols,vars)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen 

    numVar = size(vars,2);
    if isa(obj.parent,'nb_GUI')
        defaultColors = obj.parent.settings.defaultColors;
        rep           = ceil(numVar/size(defaultColors,1));
        defaultColors = repmat(defaultColors,[rep,1,1]);
        defaultColors = defaultColors(1:numVar,:);   
    else
        defaultColors = nb_defaultColors(numVar);
    end

    tempColors    = nan(numVar,3);
    giveDefaultC  = false(1,numVar);
    for ii = 1:numVar

       ind = find(strcmp(vars{ii},cols),1,'last');
       if isempty(ind)
           giveDefaultC(ii) = true;
       else

           colorTemp = cols{ind + 1};
           if ischar(colorTemp)

               try
                   colorTemp = nb_plotHandle.interpretColor(colorTemp);
               catch %#ok<CTCH>
                   error([mfilename ':: Unsupported color name ' colorTemp ' given to the variable ' vars{ii} ' by the colors property.'])
               end
               tempColors(ii,:) = colorTemp;

           elseif isnumeric(colorTemp)

               try
                   tempColors(ii,:) = colorTemp;
               catch %#ok<CTCH>
                   error([mfilename ':: The color provided by the colors property for the variable ' vars{ii} ' is not a valid color. Must be an 1x3 double.'])
               end

           else
               error([mfilename ':: The color provided by the colors property for the variable ' vars{ii} ' is not a valid color. Must be an 1x3 double or a string with the color name.'])
           end

       end

    end

    % Assign default colors
    ind  = find(giveDefaultC);
    if iscell(defaultColors)
        for ii = 1:length(ind)
            color = defaultColors{ii};
            if ischar(color)
                color = nb_plotHandle.interpretColor(color);
            end
            tempColors(ind(ii),:) = color;
        end
    else
        for ii = 1:length(ind)
            tempColors(ind(ii),:) = defaultColors(ii,:);
        end
    end

end 
