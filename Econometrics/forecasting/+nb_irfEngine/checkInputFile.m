function [paused,canceling] = checkInputFile(filename)
% Syntax:
%
% [paused,canceling] = nb_irfEngine.checkInputFile(filename)
%
% Description:
%
% Check input file
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    paused    = false;
    canceling = false;
    reader    = fopen(filename,'r');
    if reader == -1
       return 
    end
    tline = fgetl(reader);
    if tline == -1
        return
    end
    tline = strtrim(tline);
    if strcmpi(tline,'pause')
        paused = true;
    elseif strcmpi(tline,'cancel')
        canceling = true;
    end
    fclose(reader);
    
end
