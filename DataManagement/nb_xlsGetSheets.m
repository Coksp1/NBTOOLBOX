function [sheets,Excel] = nb_xlsGetSheets(file)
% Syntax:
%
% [sheets,Excel] = nb_xlsGetSheets(file)
%
% Description:
%
% Get sheets of an excel file.
% 
% Input:
% 
% - file : Either a filename as a string or a 
%          actxserver('Excel.Application') object, see nb_xlsrerad.
% 
% Output:
% 
% - sheets : A cellstr with the sheets of the selected excel file.
%
% - Excel  : A actxserver('Excel.Application') object.
%
% See also:
% nb_xlsread
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ischar(file)
        
        [found,file,ext] = nb_validpath(file);
        if ~found                                                     %#ok<CTCH>
            error([mfilename ':: Could not locate the file ' file])
        end
        switch ext
            case {'.xlsx','.xls','.xlm'}
            otherwise
                error([mfilename ':: Extension ' ext ' is not supported.'])
        end
        
        Excel         = actxserver('Excel.Application');
        Excel.Visible = false;
        try
            Workbook = Excel.Workbooks.Open(file);
        catch  %#ok<CTCH>
            error([mfilename ':: Could not open file with excel application.']) 
        end
    else
        Excel = file; 
    end

    nSheets = Excel.Worksheets.Count;
    sheets  = cell(1,nSheets);
    for n = 1:nSheets
       sheets{n} = Excel.Sheets.Item(n).Name;
    end

    if ischar(file) && nargout == 1
        Workbook.Close(false);
        Quit(Excel);
    end
   
end
