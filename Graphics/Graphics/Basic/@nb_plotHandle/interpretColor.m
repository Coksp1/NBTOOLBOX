function colors = interpretColor(colors)
% Syntax:
%
% colors = nb_plotHandle.interpretColor(colors)
%
% Description:
%
% A static method of the nb_plotHandle class.
%
% Interpret the colors when given as a cell array of strings
%
% Supported color names are:
%
% > 'blue','blå','b'
% > 'red','rød','r'
% > 'green','grønn','g'
% > 'orange','o'
% > 'light blue','lys blå','lb'
% > 'black','svart','k'
% > 'grey','grå','gr'
% > 'purple','lilla','p'
% > 'yellow','gul','y'
% > 'magenta','m'
% > 'white','hvit','w'
% > 'cyan','c'
% > 'burgundy','burgunder'
% > 'sky blue','himmelblå','hb'
% > 'deep blue','mørk blå','db'
% > 'water blue','vannblå','vb'
% > 'cool grey','kald grå','cgr'
% > 'sand','s'
% > 'pink','rosa','pi'
% > 'turquoise','turkis','t'
%
% Input:
%
% - colors : A cellstr with the colornames. E.g. {'red','green'}
% 
% Output:
%
% - colors : A M x 3 double with the RGB colors matching the
%            input cellstr. Where M is the length of the input.
%
% Written by Kenneth Sæterhagen Paulsen
           
% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ischar(colors)
        colors = cellstr(colors);
    end

    cellOfColors = colors;
    colorS       = size(cellOfColors,2);
    doubleColors = nan(colorS,3);
    for ii = 1:colorS
        
        if isnumeric(cellOfColors{ii})
            doubleColors(ii,:) = cellOfColors{ii};
            continue
        end

        switch lower(cellOfColors{ii})
            case 'nbcolor1'
                doubleColors(ii,:) = [34 89 120]/255;
            case 'nbcolor2'
                doubleColors(ii,:) = [205 140 65]/255;
            case 'nbcolor3'
                doubleColors(ii,:) = [150 90 150]/255;    
            case 'nbcolor4'
                doubleColors(ii,:) = [120 165 125]/255;
            case 'nbcolor5'
                doubleColors(ii,:) = [221 34 45]/255;   
            case 'nbcolor6'
                doubleColors(ii,:) = [73 180 223]/255;   
            case 'nbcolor7'
                doubleColors(ii,:) = [195 185 150]/255;
            case 'nbcolor8'
                doubleColors(ii,:) = [176 222 241]/255;   
            case {'blue','blå','b'}
                doubleColors(ii,:) = [52 114 166]/255;
            case {'nbblue','nbblå','nbb'}
                doubleColors(ii,:) = [34 89 120]/255;
            case {'light blue','lys blå','lb'}
                doubleColors(ii,:) = [73 180 223]/255;
            case {'sky blue','himmelblå','hb'}
                doubleColors(ii,:) = [44 115 153]/255;
            case {'deep blue','mørk blå','db'}
                doubleColors(ii,:) = [34 89 120]/255; 
            case {'water blue','wate blue','vannblå','vb'}
                doubleColors(ii,:) = [176 222 241]/255; 
            case {'red','rød','r'}
                doubleColors(ii,:) = [221 34 45]/255;
            case {'green','grønn','g'}
                doubleColors(ii,:) = [120 165 125]/255;
            case {'orange','o'}
                doubleColors(ii,:) = [205 140 65]/255;
            case {'black','svart','k'}
                doubleColors(ii,:) = [0 0 0]/255;
            case {'grey','grå','gr'}
                doubleColors(ii,:) = [130 130 130]/255;
            case {'cool grey','kald grå','cgr'}
                doubleColors(ii,:) = [164 172 177]/255;    
            case {'lilla','purple','p'}
                doubleColors(ii,:) = [150 90 150]/255;
            case {'yellow','gul','y'}
                doubleColors(ii,:) = [245 239 5]/255;
            case {'sand','s'}
                doubleColors(ii,:) = [195 185 150]/255;
            case {'pink','rosa','pi'}
                doubleColors(ii,:) = [150 115 150]/255;    
            case {'pink80','rosa80','pi80'}
                doubleColors(ii,:) = [171 143 171]/255;   
            case {'magenta','m'}
                doubleColors(ii,:) = [255 0 255]/255;
            case {'white','hvit','w'}
                doubleColors(ii,:) = [255 255 255]/255;
            case {'cyan','c'}
                doubleColors(ii,:) = [0 255 255]/255;
            case {'burgunder','burgundy'}
                doubleColors(ii,:) = [128 0 64]/255;
            case {'turquoise','turkis','t'}
                doubleColors(ii,:) = [0 125 130]/255;    
            case {'auto','same','none'}
                doubleColors = cellOfColors{ii};
            otherwise
                error([mfilename ':: Unsupported color name ' cellOfColors{ii}])
        end

    end

    colors = doubleColors;

end
