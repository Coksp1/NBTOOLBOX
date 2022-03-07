function x = nb_pasteFromClipboard(dec,hSep,vSep,convert)
% Syntax:
%
% x = nb_pasteFromClipboard
% x = nb_pasteFromClipboard(dec,hSep,vSep,convert)
%
% Description
%
% Does the inverse operation of nb_copyToClipboard, but it can also
% interpret copied ranges from a excel spreadsheet.
%
% If it cannot figure out the input, a one line char will be returned.
%
% Input:
%
% - dec      : A character that indicates the decimal separator. Default is   
%              the period ('.').
% 
% - hSep    : A character that indicates how to split horizontal elements 
%             in a given row vector. Default is char(9)
%
% - vSep    : A character that indicates how to split horizontal elements 
%             in a given row vector. Default char(10)
%
% - convert : Try to convert to numerical or not. true or false. Default 
%             is true. If all elements are numbers a double matrix is
%             returned, otherwise a cell array.
%
% Output :
%
% x     : A char, cell or double depending on the input.
%
% Examples:
%
% nb_copyToClipboard(char('Test','2'));
% p1 = nb_pasteFromClipboard
% 
% nb_copyToClipboard(rand(3,3));
% p2 = nb_pasteFromClipboard
% 
% nb_copyToClipboard('Test');
% p3 = nb_pasteFromClipboard
% 
% c = {'Var1','Var2';2,2};
% nb_copyToClipboard(c);
% p4 = nb_pasteFromClipboard
%
% See also:
% nb_copyToClipboard
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        convert = true;
        if nargin < 3
            vSep = nb_newLine;
            if nargin < 2
                hSep = char(9);
                if nargin < 1
                    dec = '.';
                end
            end
        end
    end
    
    if strcmp(dec,'.')
        decInt = '\.';
    else
        decInt = dec;
    end

    % Get the string stored in the clipboard
    pasted = clipboard('paste');
    
    % Split the input into rows
    rows      = regexp(pasted,vSep,'split');
    numRows   = length(rows);
    numCols   = nan(numRows,1);
    isNumeric = true;
    for row = 1:numRows
        
        % Split row into columns
        cols         = regexp(rows{row},hSep,'split');
        numCols(row) = length(cols);
        if convert
            for col = 1:numCols(row)
                cols{col} = try2Convert(cols{col},decInt);
                isNumeric = isNumeric & isnumeric(cols{col});
            end
        else
            isNumeric = false;
        end
        rows{row} = cols;
           
    end
    
    nCols = numel(unique(numCols));
    if nCols == 1
        
        x = vertcat(rows{:});
        if isNumeric
            x = cell2mat(x);
        else
            if isscalar(x)  
                x = x{1};
            end
        end
        
    else
        x = pasted;
    end

end

%==========================================================================
function element = try2Convert(element,dec)

    tElement = strtrim(element);
    if ismember(tElement,{'NaN','#N/A'})
        element = nan;
        return
    end
    
    match = regexp(tElement,['\d+' dec '?\d*'],'match');
    if numel(match) == 1
        match = match{1};
        if size(match,2) == size(tElement,2)
            match   = strrep(match,',','.');
            element = str2double(match);
            return
        end
    end
    
    % Check 1.000,2335434
    match = regexp(tElement,'\d+\.\d+,?\d*','match');
    if numel(match) == 1
        match = match{1};
        if size(match,2) == size(tElement,2)
            match   = strrep(match,'.','');
            match   = strrep(match,',','.');
            element = str2double(match);
            return
        end
    end
end
