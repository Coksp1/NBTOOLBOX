function data = nb_readExcel(filename,sheet,range,transpose,sorted,c)
% Syntax:
%
% data = nb_readExcel(filename)
% data = nb_readExcel(filename,sheet)
% data = nb_readExcel(filename,sheet,range)
% data = nb_readExcel(filename,sheet,range,transpose)
% data = nb_readExcel(filename,sheet,range,transpose,sorted)
% 
% Description:
%
% This is a function for reading an excel spreadsheet and return, a 
% nb_data object (dimensionless data), a nb_ts object (timeseries   
% data) or a nb_cs object (cross sectional data).
%
% Input:
%
% - filename  : A string with the filename of the excel spreadsheet. 
%               If full path is given the data will be updateable.
%
% - sheet     : A string with the sheet name you want to read.
%
% - range     : A cell with the range of the dates/types/obs, 
%               variables and data. (1 x 3 cell array).
%
%               E.g. {'A2:A5','B1:C1','B2:C5'}
%
% - transpose : 1 (true) or 0 (false). Default is 0.
%
% - sorted    : 1 (true) or 0 (false). Default is 1.
%
% - c         : A cell with already read data from excel
%
% Formats:
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
% - data    : An object of class nb_data, nb_ts or nb_cs
%
% See also:
% nb_data, nb_ts, nb_cs
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 6
        c = {};
        if nargin < 5
            sorted = 1;
            if nargin < 4
                transpose = 0;
                if nargin < 3
                    range = {};
                    if nargin < 2
                        sheet = '';
                    end
                end
            end
        end
    end
    
    if ~isempty(range)
        if not(size(range,1) == 1 && size(range,2) == 3)
            error([mfilename ':: The ''range'' input must be a cell arrary of size 1x3.'])
        end
    end
        
    if ~(ischar(filename) || iscell(filename))
        error([mfilename ':: The ''filename'' input must be a string.'])
    end

    if ~ischar(sheet)
        error([mfilename ':: The ''sheet'' input must be a string.'])
    end
    
    if isempty(c)
        c = nb_xlsread(filename,sheet,range,transpose,'nb');
    end
    try
        data = nb_cell2obj(c,true,sorted);
    catch  %#ok<CTCH>
        error([mfilename ':: Can''t convert the excel file to a nb_ts, nb_cs or nb_data object.'])
    end

    %==========================================================================
    % Add link to data object
    %==========================================================================
    if nb_contains(filename,':\') || nb_contains(filename,'\\')
        
        newSubLink            = nb_createDefaultLink();
        newSubLink.source     = filename;
        newSubLink.sourceType = 'xls';
        newSubLink.variables  = data.variables;
        newSubLink.range      = range;
        newSubLink.sheet      = sheet;
        newSubLink.transpose  = transpose;
        newSubLink.data       = double(data);
        switch class(data)
            case 'nb_data'
                newSubLink.startDate  = data.startObs; % This is correct!
                newSubLink.endDate    = data.endObs; % This is correct!
            case 'nb_ts'
                newSubLink.startDate  = toString(data.startDate);
                newSubLink.endDate    = toString(data.endDate);
            case 'nb_cs'
                newSubLink.types      = data.types;
        end
        links          = struct();
        links.subLinks = newSubLink;
        data           = data.setLinks(links);
        
    end

end

