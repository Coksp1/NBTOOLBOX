function [numStr,counter] = nb_getDataNumbering(graphObj,numberObj,counter)
% Syntax:
%
% [numStr,counter] = nb_getFigureNumbering(graphObj,numberObj,counter)
%
% Description:
%
% Help function for numbering graphs.
%
% Caution : numberObj is a nb_numbering object handle, and therfore need 
%           not be returned!
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isempty(graphObj.chapter)
        old               = numberObj.chapter;
        numberObj.chapter = graphObj.chapter;
    end
    
    if isprop(graphObj,'letterRestart')
        letterRestart = graphObj.letterRestart;
    else
        letterRestart = 0;
    end

    if isempty(graphObj.number) && isempty(graphObj.counter)

        if graphObj.letter && or(counter == 1,letterRestart)
            numberObj.hold('on')
            counter = counter + 1;
        elseif ~graphObj.letter
            numberObj.hold('off')
            counter = 1;
        end
        numberObj.plus(graphObj.jump); 
        numStr = charData(numberObj);

    elseif isempty(graphObj.number)

        numberObj = nb_numbering(graphObj.counter,numberObj.chapter,'english',numberObj.bigLetter);
        if graphObj.letter && or(counter == 1,letterRestart)
            numberObj.hold('on')
            numberObj.counter = 2;
            counter = counter + 1;
        elseif ~graphObj.letter
            numberObj.hold('off')
            counter = 1;
        end
        numStr = charData(numberObj);

    else
        numStr = ['Data ' int2str(graphObj.number)];
    end
    
    if ~isempty(graphObj.chapter)
        numberObj.chapter = old;
    end

end
