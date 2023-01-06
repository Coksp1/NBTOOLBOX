function nb_breakText(textObj, fitTo)
% Syntax:
%
% nb_breakText(textObj,fitTo)
%
% Description:
%
% Wrap text of a object given some area to fit to. The object is already
% assumed to be included in the area fitTo, and therefore only the extent 
% of the text is checked to not cross the right border.
% 
% Input:
% 
% - textObj : Handle to a text object
%
% - fitTo   : A 1x4 double with position to fit the text to.
% 
% Written by Kenneth Sæterhagen Paulsen and Henrik Halvorsen Hortemo
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    string  = get(textObj,'string');
    convert = false;
    if ~iscellstr(string)
        if ischar(string)
            string  = cellstr(string);
            convert = true;
        else
            error('The string property of the text handle must be cellstr.')
        end
    end
    
    bindingWidth = fitTo(3) - fitTo(1);
    
    % Store line numbers of inserted breaks
    wrappedLines = [];
    
    splittedLines = regexp(string, '\s', 'split');
    output = cell(0);
    
    for j = 1:length(splittedLines)
        tokens = splittedLines{j};
        output = [output; tokens(1)]; %#ok<AGROW>
        for i = 2:length(tokens)
            token = tokens{i};

            temp = output;
            temp{end, 1} = [temp{end} ' ' token];
            set(textObj, 'string', temp(end));

            ext = get(textObj, 'extent');
            if (ext(3) - ext(1)) <= bindingWidth
                output = temp;
            else
                % Store line number of inserted break
                wrappedLines(end + 1) = size(output, 1); %#ok<AGROW>
                
                % Break text
                output = [output; token];  %#ok<AGROW>
            end
        end

    end
    
    % Store line numbers of inserted breaks
    userData = get(textObj, 'UserData');
    if isstruct(userData) || isempty(userData)
        userData.WrappedLines = wrappedLines;
        set(textObj, 'UserData', userData);
    end
    
    % Update text object
    if convert
       output = char(output); 
    end
    set(textObj, 'String', output);
end
