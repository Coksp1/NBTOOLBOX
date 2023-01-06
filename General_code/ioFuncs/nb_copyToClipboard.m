function nb_copyToClipboard(x,dec,hSep,vSep)
% Syntax:
%
% nb_copyToClipboard(x)
% nb_copyToClipboard(x,dec,hSep,vSep)
%
% Description:
%
% This function puts a string, cell array, or numerical array into 
% the clipboard. 
% 
% Input:
% 
% - x    : One of:
%          > A char array.
%          > A numerical array.
%          > A cell array of the above.
%
%          Limited to 2-dimensional arrays.
%
% - dec  : A character that indicates the decimal separator. Default is   
%          the period ('.').
% 
% - hSep : A character that indicates how to split horizontal elements in
%          a given row vector. Default is char(9)
%
% - vSep : A character that indicates how to split horizontal elements in
%          a given row vector. Default char(10)
%  
% Examples:
%
% nb_copyToClipboard('Test')
% nb_copyToClipboard(char('Test','2'))
% nb_copyToClipboard(rand(3,3))
%
% See also:
% nb_pasteFromClipboard
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 4
        vSep = nb_newLine;
        if nargin < 3
            hSep = char(9);
            if nargin < 2
                dec = '.';
            end
        end
    end

    [r,c,p] = size(x);
    if p > 1
        error([mfilename ':: This function does not take array with more than 2 dimensions.'])
    end
    
    if ischar(x)
        
        % Copy char array to clipboard
        if r == 1
            clipboard('copy',x);
        else
            x          = strtrim(cellstr(x));
            x(1:end-1) = cellfun(@(x)[x,vSep],x(1:end-1),'UniformOutput',false);
            x          = [x{:}];
            clipboard('copy',x);
        end
    elseif isnumeric(x) || islogical(x)
        
        % Copy numerical matrix to clipboard
        xStr = mat2str(x);                
        xStr = strrep(xStr,'.',dec);
        if strncmp(xStr,'[',1)
            xStr = xStr(2:end-1);
        end
        xStr = strrep(xStr,' ',hSep);
        xStr = strrep(xStr,';',vSep);
        clipboard('copy',xStr);
        
    elseif iscell(x)
        
        cStr = '';
        for rInd = 1:r
            for cInd = 1:c-1
                cStr = aCellElement(cStr, x{rInd,cInd}, hSep, dec); 
            end
            cStr = aCellElement(cStr, x{rInd,end}, vSep, dec);     
        end
        cStr = cStr(1:end-1);
        clipboard('copy',cStr);    
        
    else
        error([mfilename ':: Cannot copy the object of class ' class(x) ' to the clipboard.'])
    end

end

function str = aCellElement(str,cellElement,hSep,dec)
% Transform on cell element to output that can be casted to the clipboard
% function

    if isempty(cellElement)
        str = [str, hSep];
    elseif isa(cellElement,'char')
        if size(cellElement,1) == 1
            str = [str, cellElement, hSep];
        else
            str = [str, mat2str(cellElement), hSep];
        end
    elseif isnumeric(cellElement) || islogical(cellElement)
        str = [str, strrep(mat2str(cellElement),'.',dec), hSep];
    else
        error([mfilename ':: Cannot copy a cell array to the clipboard when all the elements are not scalar numbers or one line char.'])
    end
    
end
