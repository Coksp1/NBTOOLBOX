function [nbFile,file] = readFile(filename,remove)
% Syntax:
%
% nbFile        = nb_model_parse.readFile(filename)
% [nbFile,file] = nb_model_parse.readFile(filename,remove)
%
% Description:
%
% No doc provided. Used by nb_dsge.parse and nb_nonLinearEq.parse. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        remove = true;
    end

    % Open model file
    [p,f,e] = fileparts(filename);
    if isempty(e)
        warning('dsge:readFile:AddedNB',['Added .nb as the extension to the file ' filename])
        e = '.nb';
    else
        if ~any(strcmpi(e,{'.nb','.mod','.dyn','.rs'}))
            error([mfilename ':: The model file must have extension .nb or .mod'])
        end
    end
    file = nb_joinPath(p,f,e);
    fid  = fopen(file);
    if fid == -1
        error([mfilename ':: Could not open ' file ' for reading.'])
    end
    
    % Read the model file
    nbFile   = cell(0,3);
    lineNum  = 1;
    nbIgnore = false;
    while ~feof(fid)
        line = fgetl(fid);
        if remove
            line = removeComment(line);
        end
        [line,nbIgnore] = removeNBIgnore(line,lineNum,nbIgnore,filename);
        indInc          = strfind(line,'@#include');
        if ~isempty(indInc)
            
            % Include the specified file
            ind = strfind(line,'"');
            if size(ind,2) ~= 2
                error([mfilename ':: Syntax error:: The @#include statement must be follow with the filename enclosed with " ". ' nb_dsge.lineError(lineNum,filename) ])
            end
            includedFile   = line(ind(1)+1:ind(2)-1);
            nbFileIncluded = nb_model_parse.readFile(includedFile);
            nbFile         = [nbFile;nbFileIncluded]; %#ok<AGROW>
            
            % The other stuff on this line is added as normal
            lineBefore = line(1:indInc-1);
            lineAfter  = line(ind(2)+1:end);
            line       = [lineBefore,lineAfter];
            
        end
        if ~isempty(line)
            nbFile = [nbFile;{line,lineNum,filename}]; %#ok<AGROW>
        end
        lineNum = lineNum + 1;
    end
    fclose(fid);
    
end

%==========================================================================
function line = removeComment(line)

    line = strtrim(line);
    indS = regexp(line,'(/{2,2}|%)','start');
    if ~isempty(indS)
        indS = min(indS);
        line = line(1:indS-1);
    end
    line = strtrim(line);
    
end

%==========================================================================
function [line,nbIgnore] = removeNBIgnore(line,lineNum,nbIgnore,filename)

    if isempty(line)
        return
    end

    if nbIgnore
        indIgnoreE = strfind(line,'/*NB-IGNORE-END*/');
        if isempty(indIgnoreE)
            line = '';
        else
            line     = line(indIgnoreE + 17:end); 
            nbIgnore = false;
        end
    else
        indIgnoreB = strfind(line,'/*NB-IGNORE-BEGIN*/');
        indIgnoreE = strfind(line,'/*NB-IGNORE-END*/');
        if isempty(indIgnoreB)
            if ~isempty(indIgnoreE)
                error([mfilename ':: Cannot have /*NB-IGNORE-END*/ before opening an ignore block with /*NB-IGNORE-BEGIN*/. ' nb_dsge.lineError(lineNum,filename)])
            else
                return
            end
        elseif length(indIgnoreB) > 1
            error([mfilename ':: Cannot have more than one /*NB-IGNORE-BEGIN*/ statement in one line. ' nb_dsge.lineError(lineNum,filename)])
        else
            if isempty(indIgnoreE)
                nbIgnore = true;
                line     = line(1:indIgnoreB-1);
            elseif length(indIgnoreE) > 1
                error([mfilename ':: Cannot have more than one /*NB-IGNORE-END*/ statement in one line. ' nb_dsge.lineError(lineNum,filename)])
            else
                line = [line(1:indIgnoreB-1),line(indIgnoreE + 17:end)];
            end
        end

    end
    
end
