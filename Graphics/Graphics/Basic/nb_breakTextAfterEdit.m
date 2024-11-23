function index = nb_breakTextAfterEdit(textObj,fitTo,index)
% Syntax:
%
% index = nb_breakTextAfterEdit(textObj,fitTo,index)
%
% Description:
%
% Break text of a object given some area to fit to, after editing. I.e. 
% after one string element is added to the string property of the object. 
% The object is already assumed to be included in the area fitTo, and 
% therefore only the extent of the text is checked to not cross the right 
% border.
% 
% Input:
% 
% - textObj : Handle to a text object
%
% - fitTo   : A 1x4 double with position to fit the text to.
% 
% - index   : A 1x2 double with the index for where the string property of
%             the text handle is breaked. index(1) is the current row, and
%             index(2) is the current column. Will be updated if the
%             breakpoint is before the current position in a line. I.e.
%             the current point must then be switched to the next line
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    string = get(textObj,'string');
    if ~iscell(string)
        error('The string property of the text handle must be cellstr.')
    end
    
    parent   = get(textObj,'parent');
    pos      = get(textObj,'position');
    fAngle   = get(textObj,'fontAngle');
    fSize    = get(textObj,'FontSize');
    fUnits   = get(textObj,'fontUnits');
    fWeight  = get(textObj,'fontWeight');
    int      = get(textObj,'interpreter');
    margin   = get(textObj,'margin');
    
    indexLine = index(1);
    for ii = index(1):size(string,1)
    
        str = string{ii};
        t   = text(pos(1),pos(2),str,...
                   'visible',       'off',...
                   'parent',        parent,...
                   'fontAngle',     fAngle,...
                   'fontSize',      fSize,...
                   'fontUnits',     fUnits,...
                   'fontWeight',    fWeight,...
                   'interpreter',   int,...
                   'margin',        margin);
        drawnow;
        ext = get(t,'extent');  
        delete(t);
        if ext(1) + ext(3) > fitTo(1) + fitTo(3) 

            breakPoint = regexp(str,'\s');
            if ~isempty(breakPoint)

                if breakPoint(end) ~= size(str,2)

                    addedToNextLine = str(1,breakPoint(end)+1:end);
                    try
                        string{ii+1} = [addedToNextLine,' ', string{ii+1}];
                    catch %#ok<CTCH>
                        % Now we add new line
                        string{ii+1,1} = addedToNextLine;
                    end
                    string{ii} = str(1,1:breakPoint(end)-1);

                    if ii == indexLine 
                        if index(2) > breakPoint(end)

                            % Now the current point is switch to a new line, so we
                            % need to update the index property
                            index(1) = index(1) + 1;
                            index(2) = index(2) - size(string{ii},2) - 1;
                            
                        elseif index(2) == breakPoint(end)
                            index(2) = size(string{ii},2);
                        end
                    end

                end

            end

        end
        
    end
    
    % Assign back to text object
    set(textObj,'string',string);
     
end
