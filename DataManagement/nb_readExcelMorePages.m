function data = nb_readExcelMorePages(filename,sorted,sheets)
% Syntax:
%
% data = nb_readExcelMorePages(filename)
% data = nb_readExcelMorePages(filename,sorted,sheets)
% 
% Description:
%
% This is a function for reading each sheet of an excel spreadsheet and 
% return, a nb_data object (dimensionless data), a nb_ts object (timeseries   
% data) or a nb_cs object (cross sectional data).
%
% This function can then be utilized to read real-time or panel data
% from excel spreadsheets. 
%
% If you want to read the data as real-time, each sheet must be given the
% name of the end date of that vintage series. The format of the date must 
% be supported by NB toolbox. Each vintage must give rise to one new
% observation (and only one!).
%
% Input:
%
% - filename  : A string with the filename of the excel spreadsheet. 
%               If full path is given the data will be updateable.
%
% - sorted    : 1 (true) or 0 (false). Default is 1.
%
% - sheets    : A cellstr with the sheet names you want to read. Default
%               is all.
%
% Formats (of each sheet):
%
% - Dimensionless:
%
%   obs       Var1 Var2
%   1         3    4
%   2         5    6
% 
%    Caution : obs in the cell A1:A1 is required!!!
%
%    Caution : Nothing else could be included in the worksheet as 
%              long as the range is not specified!!
% 
% - Timeseries : 
% 
%    dates       Var1 Var2
%    30.06.2012     3    4
%    30.09.2012     5    6
% 
%    Caution : Nothing else could be included in the worksheet as 
%              long as the range is not specified!!
%
% - Cross sectional data :
%
%    types Var1  Var2
%    var      1     4
%    std      1     2
%
%    Caution : Nothing else could be included in the worksheet as 
%              long as the range is not specified!!
%
% Output:
%
% - data    : An object of class nb_data, nb_ts or nb_cs, where each sheet
%             is added as a seperate dataset (page). The sheetnames will
%             appear in the dataNames property of the output.
%
% See also:
% nb_data, nb_ts, nb_cs
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        sheets = {};
        if nargin < 2
            sorted = true;
        end
    end

    if ~(ischar(filename) || iscell(filename))
        error([mfilename ':: The ''filename'' input must be a string.'])
    end

    if ~iscellstr(sheets)
        error([mfilename ':: The ''sheets'' input must be a cellstr.'])
    end
    
    [allSheets,Excel] = nb_xlsGetSheets(filename);
    if isempty(sheets)
        sheetsIn = allSheets;
    else
        ind = ismember(sheets,allSheets);
        if any(~ind)
            Workbook = Excel.Workbooks.Item(1);
            Workbook.Close(false);
            Quit(Excel);
            error([mfilename ':: The following sheets where not located in the given excel spreadsheet; ' toString(sheets(~ind))])
        end
        sheetsIn = sheets;
    end
    
    % Read all sheets into a nb_dataSource object
    for ii = 1:length(sheetsIn)
        
        c = nb_xlsread(filename,sheetsIn{ii},'',0,'nb',Excel);
        try
            dataTemp = nb_cell2obj(c,true,sorted);
        catch  %#ok<CTCH>
            Workbook = Excel.Workbooks.Item(1);
            Workbook.Close(false);
            Quit(Excel);
            error([mfilename ':: Can''t convert the excel file to a nb_ts, nb_cs or nb_data object.'])
        end
        if ii == 1
            func = str2func(class(dataTemp));
            data = func();
        end
        try
            data = addPages(data,dataTemp);
        catch Err
            Workbook = Excel.Workbooks.Item(1);
            Workbook.Close(false);
            Quit(Excel);
            nb_error('Different pages of the spreadsheet must represent the same type of data.',Err)
        end
        
    end
    data.dataNames = sheetsIn;
    
    % Close Excel application
    Workbook = Excel.Workbooks.Item(1);
    Workbook.Close(false);
    Quit(Excel);
    
    % Add data source link
    if ~isempty(strfind(filename,':\')) || ~isempty(strfind(filename,'\\'))
        
        newLink            = nb_createDefaultLink();
        newLink.source     = filename;
        newLink.sourceType = 'xlsmp';
        newLink.variables  = data.variables;
        newLink.sheet      = sheets;
        newLink.data       = double(data);
        switch class(data)
            case 'nb_data'
                newLink.startDate  = data.startObs; % This is correct!
                newLink.endDate    = data.endObs; % This is correct!
            case 'nb_ts'
                newLink.startDate  = toString(data.startDate);
                newLink.endDate    = toString(data.endDate);
            case 'nb_cs'
                newLink.types      = data.types;
        end
        links          = struct();
        links.subLinks = newLink;
        data           = data.setLinks(links);
        
    end
    
end
