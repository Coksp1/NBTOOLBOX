function [c,sheets,Excel] = nb_xlsread(filename,sheet,range,transpose,mode,Excel)
% Syntax:
%
% c = nb_xlsread(filename)
% c = nb_xlsread(filename,sheet)
% c = nb_xlsread(filename,sheet,range)
% c = nb_xlsread(filename,sheet,range,transpose)
% c = nb_xlsread(filename,sheet,range,transpose,mode)
% [c,sheets,Excel] = nb_xlsread(filename,sheet,range,transpose,mode,Excel)
%
% Description:
%
% Read an excel file and return an cell matrix representing the selected 
% worksheet. 
%
% Caution : xls files 
% 
% Input:
% 
% - filename : The name of the excel file. If extension not provided, .xlsx
%              is assumed.
%
% - sheet    : Name of the read sheet. If empty (default) the first sheet 
%              of the file is read.
%
% - range    : The range to read. Must be given as 'A1:B2', or a 1 x M cell
%              of ranges. If it is given as a cell of ranges the output 
%              will also be a cell with the same size as range.
%
%              Caution: range must be empty for for mode 'nb'.
% 
% - mode     : > 'default' : Will read the excel sheet as is.
%              > 'nb'      : If the range input is a cell with size 1 x 3 
%                            with the range of the dates/types/obs, 
%                            variables and data. 
%
%                            E.g. {'A2:A5','B1:C1','B2:C5'}
%
%                            The output will be a cell matrix instead of
%                            nested cell. Of cource the dimensions of the
%                            range must match!
%
% - Excel    : Handle to the Excel application. Same as the Excel ouput.  
%              It is assumed that a excel file has been opened with this 
%              application!
%
% Output:
% 
% - c      : Either a cell matrix or a nested cell row. See range input.
%
% - sheets : The sheets of the excel spreadsheet, as a cellstr.
%
% - Excel  : Handle to the Excel application used for reading the excel
%            spreadsheet. The Excel application has the selected file open 
%            for reading!
%
% Examples:
%
% c = nb_xlsread('data.xlsx')
%
% See also:
% xlsread
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 6
        Excel = [];
        if nargin < 5
            mode = 'default';
            if nargin < 4
                transpose = false;
                if nargin < 3
                    range = '';
                    if nargin < 2
                        sheet = '';
                    end
                end
            end
        end
    end
    
    if nargout > 1
        returnSheets = true;
    else
        returnSheets = false;
    end
    if nargout > 1
        returnExcel = true;
    else
        returnExcel = false;
    end
    
    % Check filename input
    [found,filename,ext] = nb_validpath(filename);
    if ~found
        error([mfilename ':: Could not locate the file ' filename])
    end
    
    % Read file
    switch ext
        case {'.xlsx','.xls','.xlsm'}
            [c,sheets,Excel] = readXLSX(filename,sheet,range,transpose,mode,returnSheets,returnExcel,Excel);
        case '.csv'
            c      = readCSV(filename,',');
            sheets = {};
            Excel  = [];
        otherwise
            error([mfilename ':: Extension ' ext ' is not supported.'])
    end

end

%==========================================================================
% SUB
%==========================================================================
function [c,sheets,Excel] = readXLSX(filename,sheet,range,transpose,mode,returnSheets,returnExcel,Excel)

    quitExcel = false;
    if isempty(Excel)
        try
            Excel = actxserver('Excel.Application');
        catch %#ok<CTCH>
            error([mfilename ':: Can''t open up an excel application.'])
        end
        Excel.Visible       = false;
        Excel.DisplayAlerts = 0;
        quitExcel           = true;
        try
            Workbook = Excel.Workbooks.Open(filename,0,true);
        catch  %#ok<CTCH>
            error([mfilename ':: Could not open file with excel application.']) 
        end
    end
    
    if isempty(sheet)
        ActiveSheet = Excel.Worksheets.Item(1);
    else
        try
            ActiveSheet = Excel.Worksheets.Item(sheet);
        catch %#ok<CTCH>
            error([mfilename ':: The sheet ''' sheet ''' is not located in the provided file: ' filename]) 
        end
    end

    % Read sheet
    if isempty(range) 
%         r1 = ActiveSheet.Range('A1');
%         r2 = getEndCell(ActiveSheet);
%         try
%             c = ActiveSheet.get('Range',r).Value;
%         catch Err
%             if strcmpi(Err.identifier,'MATLAB:COM:E2147942414')
%                 c = {};
%             else
%                 error([mfilename 'Cannot read the default range.'])
%             end
%         end
        r = ActiveSheet.UsedRange;
        try
            c = r.Value;
        catch % Empty sheet
            c = {};
        end
        if ischar(c)
            c = cellstr(c);
        elseif isnumeric(c)
            c = num2cell(c);
        end
        c = cleanCellMatrix(c);
    else
        if ischar(range)
            c = readOneRange(ActiveSheet,range);
        elseif iscellstr(range)
            c = cell(1,length(range));
            for ii = 1:length(range)
                c{ii} = readOneRange(ActiveSheet,range{ii});
            end
        else
            error([mfilename ':: The range input must be either a char or cellstr.'])
        end
        if ischar(c)
            c = cellstr(c);
        elseif isnumeric(c)
            c = num2cell(c);
        end
        if strcmpi(mode,'nb')
            c = combine2matrix(c,transpose); 
        end
        
    end
    
    if transpose
        c = c';
    end
    
    if returnSheets
        sheets = nb_xlsGetSheets(Excel);
    else
        sheets = {};
    end
    
    % Close the Excel file and application if not Excel is returned
    if ~returnExcel && quitExcel
        Workbook.Close(false);
        Quit(Excel);
        Excel = [];
    end

end

%======================================================================
function c = readOneRange(ActiveSheet,range)

    indC = strfind(range,':');
    if isempty(indC) || numel(indC) > 1
        error([mfilename ':: The range input is wrong. It must contain : (and only one): ' range])
    end
    try
        c = ActiveSheet.Range(range).Value;
    catch %#ok<CTCH>
        error([mfilename ':: Cannot read the selected range: ' range])
    end
    
end

%==========================================================================
function c = combine2matrix(c,transpose)

    if length(c) ~= 3
        error([mfilename ':: When range is given, and the reading mode is ''nb'' the range input must be a 1 x 3 cellstr.'])
    end
    
    xx   = c{1};
    vars = c{2};
    data = c{3};
    
    try
        if transpose
            c = [{''},xx;vars,data]; 
        else
            c = [{''},vars;xx,data];
        end
    catch %#ok<CTCH>
        error([mfilename ':: The selected range cannot be concatenated to a matrix representing the dataset.'])
    end
    
end

function c = cleanCellMatrix(c)

    ind  = cellfun(@(x)nb_conditional(isnumeric(x),isnan(x),false),c);
    cInd = ~all(ind,1);
    rInd = ~all(ind,2);
    c    = c(rInd,cInd);
    
end

% function r2 = getEndCell(ActiveSheet)
% 
%     % Get the last cell rightwards to read
%     let  = 66;
%     let2 = []; % Max is 'ZZ1'
%     t2   = 0;
%     tol  = 3;
%     while t2 < tol
%         
%         c2 = [char(let2),char(let) ,'1'];
%         r2 = ActiveSheet.Range(c2);
%         try
%             if any(isnan(r2.Value))  || isempty(r2.Value)
%                 t2 = t2 + 1;
%             else
%                 t2 = 0;
%             end
%         catch %#ok<CTCH>
%             t2 = t2 + 1;
%         end
%         let = let + 1;
%         if let > 90 
%             let = 65;
%             if isempty(let2) 
%                 let2 = 65;
%             else
%                 let2 = let2 + 1;
%             end
%         end
%         
%         if let2 > 90 
%             break
%         end
%         
%     end
%     
%     if isempty(let2)
%         c2 = char(let-tol-1);
%     else
%         if let - 65 <= tol
%             if let2 == 65
%                 c2 = char(90 + let - tol - 65);
%             else
%                 c2 = [char(let2-1),char(90 + let - tol - 65)];
%             end
%         elseif let2 < 90
%             c2 = [char(let2),char(let-tol-1)];
%         else
%             c2 = 'ZZ';
%         end
%     end
% 
%     % Get the last cell downwards to read
%     num  = 2;
%     t3   = 0;
%     while t3 < tol
%         
%         c3 = ['A' ,int2str(num)];
%         r3 = ActiveSheet.Range(c3);
%         try
%             if any(isnan(r3.Value)) || isempty(r3.Value)
%                 t3 = t3 + 1;
%             else
%                 t3 = 0;
%             end
%         catch %#ok<CTCH>
%             t3 = t3 + 1;
%         end
%         num = num + 1;
%         
%     end
%     
%     % Get the lower right cell which we are going to read
%     r2 = [c2,int2str(num-tol-1)];
%     r2 = ActiveSheet.Range(r2);
% 
% end

function c = readCSV(filename,sep)

    fid = fopen(filename);
    if fid == -1
        error([mfilename ':: Could not open the file ' filename])
    end
    c  = cell(100,1);
    ii = 1;
    jj = 1;
    while ~feof(fid)
        if ii > 100
            c  = [c;cell(100,1)]; %#ok<AGROW>
            ii = 1;
        end
        line  = fgetl(fid);
        c{jj} = splitLine(line);
        jj    = jj + 1;
        ii    = ii + 1;
    end
    fclose(fid);
    
    m  = cellfun(@(x)size(x,2),c);
    c  = c(m~=0);
    mm = max(m);      
    if any(m ~= mm)
       loc = find(m(m~=mm));
       for ii = loc'
          c{ii} = [c{ii},cell(1,mm-m(ii))]; 
       end
    end
    
    try
        c = vertcat(c{:});
    catch 
        error([mfilename ':: A comma seperated file must give as many columns for each row!'])
    end
    c  = cellfun(@(x)str2doubleLocal(x),c,'UniformOutput',false);
    c  = cellfun(@(x)strrepLocal(x,'"',''),c,'UniformOutput',false);
    
end

%==========================================================================
function split = splitLine(expr)

    breakTerm  = false(1,length(expr));
    num        = 0; % Number of "
    for ii = 1:length(expr)

        if strncmp(expr(ii),'"',1)
            num   = num + 1;
            continue
        end
        if any(strncmp(expr(ii),',',1)) && rem(num,2) == 0
            breakTerm(ii) = true;
        end

    end
    breaks  = find(breakTerm);
    nBreaks = size(breaks,2);
    split   = cell(1,nBreaks + 1);
    breaksT = [0,breaks];
    for ii = 2:nBreaks+1
        split{ii-1} = expr(breaksT(ii-1)+1:breaksT(ii)-1);
    end
    split{end} = expr(breaksT(end)+1:end);
    
end

%==========================================================================
function x = strrepLocal(x,pattern,new)

    if ischar(x)
        x = strrep(x,pattern,new);
    end
    
end

%==========================================================================
function x = str2doubleLocal(x)

    if isempty(x)
        x = nan;
        return
    end
    d = str2double(x);
    if ~isnan(d)
        x = d;
    end
    
    
end
