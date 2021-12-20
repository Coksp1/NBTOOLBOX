function nb_deleteDefaultWorksheets(filename)
% Syntax:
%
% nb_deleteDefaultWorksheets(filename)
%
% Description:
%
% Delete the 'Sheet1','Sheet2','Sheet3' worksheets of an excel spreadsheet
% 
% Input:
% 
% - filename : The excel filename, as a string.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    try
        % First open Excel
        ind = strfind(filename,'\');
        if ~isempty(ind)
            XL_file = [filename '.xlsx'];
        else
            XL_file = [pwd '\' filename '.xlsx'];
        end
        Excel = actxserver('Excel.Application');
        set(Excel, 'Visible', 0);
        set(Excel,'DisplayAlerts',0);
        Workbooks = Excel.Workbooks;
        Workbooks.Open(XL_file);
        Sheets = Excel.ActiveWorkBook.Sheets;
        index_adjust = 0;

        % Cycle through the sheets and delete the sheets
        % 'Sheet1','Sheet2' and 'Sheet3'
        %--------------------------------------------------
        [~, sheet_names] = xlsfinfo(XL_file);
        for i = 1:max(size(sheet_names))

            switch sheet_names{i}

                case{'Sheet1','Sheet2','Sheet3'}

                    current_sheet = get(Sheets, 'Item', (i-index_adjust));
                    invoke(current_sheet, 'Delete')
                    index_adjust = index_adjust +1;

            end

        end

        Excel.ActiveWorkbook.Save;
        Excel.ActiveWorkbook.Close;
        Excel.Quit;
        Excel.delete;

    catch Err

        % Close excel objects
        %--------------------------------------------------
        Excel.ActiveWorkbook.Save;
        Excel.ActiveWorkbook.Close;
        Excel.Quit;
        Excel.delete;

        rethrow(Err);

    end

end
