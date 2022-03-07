function [numStr,counter] = nb_getFigureNumbering(graphObj,numberObj,counter)
% Syntax:
%
% [numStr,counter] = nb_getFigureNumbering(graphObj,numberObj,counter)
%
% Description:
%
% Help function for numbering graphs.
%
% Caution : numberObj is a nb_numbering object handle, and therefore need 
%           not be returned!
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isempty(graphObj.chapter)
        old               = numberObj.chapter;
        numberObj.chapter = graphObj.chapter;
    end

    if isa(graphObj.plotter,'nb_table_data_source')
        table = 1;
    else
        table = 0;
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
        numStr = char(numberObj,table);

    elseif isempty(graphObj.number)

        numberObj = nb_numbering(graphObj.counter,numberObj.chapter,numberObj.language,numberObj.bigLetter);
        if graphObj.letter && or(counter == 1,letterRestart)
            numberObj.hold('on')
            numberObj.counter = 2;
            counter = counter + 1;
        elseif ~graphObj.letter
            numberObj.hold('off')
            counter = 1;
        end
        numStr = char(numberObj,table);

    else

        if table
            if any(strcmpi(numberObj.language,{'english','engelsk'}))
                numStr = 'Table ';
            else
                numStr = 'Tabell ' ;
            end
        else
            if any(strcmpi(numberObj.language,{'english','engelsk'}))
                numStr = 'Chart ';
            else
                numStr = 'Figur ' ;
            end
        end
        numStr = [numStr, int2str(graphObj.number)];

    end
    
    if ~isempty(graphObj.chapter)
        numberObj.chapter = old;
    end

end
