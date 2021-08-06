function value = nb_findGUIDefaultColor(colors,colorsUsed)
% Syntax:
%
% value = nb_findGUIDefaultColor(colors,colorsUsed)
%
% Description:
%
% Find default color used by GUI.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(colorsUsed)
        value  = 1;
    else

        % Get the next default color
        numCol = length(colorsUsed);
        locs   = nan(numCol,1);
        ff     = 1;
        for ii = 1:length(colorsUsed)
            colorTemp = colorsUsed{ii};
            locs(ff)  = nb_findColor(colorTemp,colors);
            ff        = ff + 1;
        end
        minVal = min(locs);
        if minVal > 1
            value = 1;
        else
            maxVal = max(locs);
            temp   = 1:maxVal;
            indT   = ismember(temp,locs);
            temp   = temp(~indT);
            if isempty(temp)
                value = maxVal + 1;
                if value > size(colors,1)
                    value = 1; % All the default colors are used so we use the first color
                end
            else
                value = min(temp);
            end
        end

    end

end
