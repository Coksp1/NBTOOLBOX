function Excel = nb_xlswrite(filename,c,sheet,del,Excel)
% Syntax:
%
% nb_xlswrite(filename,c,sheet)
%
% Description:
%
% Write data to excel spreadsheet.
% 
% Input:
% 
% - filename : Name of excel file to write to, as a string.
%
% - c        : Cell matrix to write to excel
% 
% - sheet    : The name of the sheet to save the data to, as a string.
%
% - del      : Give true to delete default sheet names 
%              ('Sheet1','Sheet2','Sheet3'). Default is false.
%
%              Caution: This only works for files that are created with
%              this function (for some reason).
%
% - Excel    : An Excel application object
%              (actxserver('Excel.Application')). May be smart to only
%              intialize once if writing data to an excel file in a loop!
%
%              Caution: It is assumed that the excel file has already been  
%                       opened by the application for writing! 
%
% Examples:
% nb_xlswrite('test.xlsx',num2cell(rand(3,3)))
%
% See also:
% xlswrite
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 5
        Excel = [];
        if nargin < 4
            del = false;
            if nargin < 3
                sheet = 1;
            end
        end
    end

    if ~nb_isOneLineChar(filename)
       error([mfilename ':: The filename input must be a one line char.']) 
    end
    
    % Check filename input
    [found,filename,ext] = nb_validpath(filename,'write');
    if ~found
        folder = fileparts(filename);
        if ~exist(folder,'dir')
            mkdir(folder);
        end
    end
    
    % Check data
    if ~iscell(c)
        error([mfilename ':: The c input must be a cell matrix is ' class(c)])
    end
    if ~ismatrix(c)
        error([mfilename ':: The c input is not a cell matrix. (I.e. it has more than 2 dimensions)'])
    end
    
    % Check sheet
    if ~(ischar(sheet) || nb_iswholenumber(sheet))
        error([mfilename ':: Sheet must be a char or an integer. Is ' class(sheet)])
    end
    if isempty(sheet)
        sheet = 1;
    end
    
    if nargout > 0
        returnExcel = true;
    else
        returnExcel = false;
    end
    
    % Read file
    switch ext
        case {'.xlsx','.xls','.xlsm'}
            Excel = writeXLSX(filename,c,sheet,~found,del,returnExcel,Excel);
        otherwise
            error([mfilename ':: Extension ' ext ' is not supported.'])
    end
    
end

%==========================================================================
function Excel = writeXLSX(filename,c,sheet,newFile,del,returnExcel,Excel)

    also = false;
    if isempty(Excel)
        
        try
            Excel = actxserver('Excel.Application');
        catch %#ok<CTCH>
            error([mfilename ':: Can''t open up an excel application.'])
        end
        Excel.Visible       = false;
        Excel.DisplayAlerts = 0;
        also                = true;
        
        % Here I use the same work around as in xlswrite
        if newFile
            [~,~,ext]     = fileparts(filename);
            ExcelWorkbook = Excel.workbooks.Add;
            switch ext
                case '.xls' %xlExcel8 or xlWorkbookNormal
                   xlFormat = -4143;
                case '.xlsx' %xlOpenXMLWorkbook
                   xlFormat = 51;
                case '.xlsm' %xlOpenXMLWorkbookMacroEnabled 
                   xlFormat = 52;
                otherwise
                   xlFormat = -4143;
            end
            ExcelWorkbook.SaveAs(filename, xlFormat);
            ExcelWorkbook.Close(false);
        end

        % Check for accessability
        ExcelWorkbook = Excel.workbooks.Open(filename);
        if ExcelWorkbook.ReadOnly ~= 0
            xlsShutDownSimple(Excel)
            error([mfilename ':: The file ' filename ' is in read-only mode.'])
        end
        
    else
        ExcelWorkbook = Excel.Workbooks.Item(1);
    end
    
    % Activate sheet to write to
    try
        activateSheet(Excel,sheet);
    catch Err
        xlsShutDown(Excel,filename)
        if isnumeric(sheet)
            sheet = int2str(sheet);
        end
        nb_error([mfilename ':: Could not select the wanted sheet (' sheet ').'],Err); 
    end
    
    % Find range to write the data to
    [m,n] = size(c);
    range = nb_excelRange('A1',m,n);
    try 
        Select(Range(Excel,sprintf('%s',range)));
    catch Err 
        xlsShutDown(Excel,filename)
        nb_error([mfilename ':: Could not select the range.'],Err); 
    end

    % Export data to selected region.
    try
        set(Excel.selection,'Value',c);
    catch Err
        xlsShutDown(Excel,filename)
        nb_error([mfilename ':: Could not write the data to the selected range.'],Err); 
    end
    
    % Delete default sheets
    if del
        try deleteSheets(Excel,ExcelWorkbook); catch; end %#ok<CTCH>
    end
    
    ExcelWorkbook.Save  
    
    if also && ~returnExcel
        ExcelWorkbook.Close(false);
        Excel.Quit;
    end

end

%==========================================================================
function activateSheet(Excel,sheet)

    WorkSheets = Excel.sheets;
    try
        selectedSheet = get(WorkSheets,'item',sheet);
    catch exception  %#ok<NASGU>
        selectedSheet = addSheet(WorkSheets,sheet);
    end
    Activate(selectedSheet);

end

%==========================================================================
function newsheet = addSheet(WorkSheets,sheet)

    if isnumeric(sheet)
        while WorkSheets.Count < sheet
            lastsheet = WorkSheets.Item(WorkSheets.Count);
            newsheet  = WorkSheets.Add([],lastsheet);
        end
    else
        lastsheet = WorkSheets.Item(WorkSheets.Count);
        newsheet  = WorkSheets.Add([],lastsheet);
    end
    if ischar(sheet)
        set(newsheet,'Name',sheet);
    end

end

%==========================================================================
function xlsShutDown(Excel,filename)

    try %#ok<TRYNC> No catch block
        Excel.DisplayAlerts = 0; 
        [~, name, ext] = fileparts(filename);
        fileName = [name ext];
        Excel.Workbooks.Item(fileName).Close(false);
    end
    Excel.Quit;

end

%==========================================================================
function xlsShutDownSimple(Excel)

    Excel.Quit;

end

%==========================================================================
function deleteSheets(Excel,ExcelWorkbook)

    Sheets       = ExcelWorkbook.Sheets;
    sheetsNames  = nb_xlsGetSheets(Excel);
    index_adjust = 0;
    for i = 1:length(sheetsNames)
        switch sheetsNames{i}
            case{'Sheet1','Sheet2','Sheet3'}
                currentSheet = get(Sheets, 'Item', (i-index_adjust));
                invoke(currentSheet, 'Delete')
                index_adjust = index_adjust + 1;
        end
    end

end
