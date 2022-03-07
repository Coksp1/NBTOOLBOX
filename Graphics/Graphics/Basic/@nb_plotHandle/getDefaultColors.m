function defaultColors = getDefaultColors(dataSize)
% Syntax:
%
% defaultColors = nb_plotHandle.getDefaultColors(dataSize)
%
% Description:
%
% A static method of the nb_plotHandle class.
%
% Get the default colors given the number of plotted variables.
%
% Input:
%
% - dataSize      : Number of plotted variables.
% 
% Output:
%
% - defaultColors : The default colors, as a M x 3 double of the
%                   RGB colors. M is the number of plotted 
%                   variables.
%
% Examples:
%
% See also:
%
% Written by Kenneth Sæterhagen Paulsen
        
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if dataSize == 0
        
        defaultColors = [];
        
    elseif dataSize < 0
        
        defaultColors = [];
        warning('It''s not possible to give a negative input to the getDefaultColors function. Output set to Empty.');

    else

        defaultColors = nb_defaultColors;
        
        % If the dataSize is too big (i.e greater than 20), we simply 
        % repeat the 20 standard colours until we have enough colours for 
        % the graphs.       
        defaultColorsSize = size(defaultColors,1);
        index             = ceil(dataSize/defaultColorsSize);
        defaultColors     = repmat(defaultColors,index,1);
        defaultColors     = defaultColors(1:dataSize,:);
        
    end

end
