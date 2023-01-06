function saveData(obj,saveName,descriptionPage)
% Syntax:
%
% saveData(obj,saveName,descriptionPage)
%
% Description:
%
% Write object to excel, where each stored object is saved in
% seperate worksheets
% 
% Input:
% 
% - obj             : An object of class nb_DataCollection
% 
% - saveName        : A string with the wanted name of the saved 
%                     excel file
% 
% - descriptionPage : Give 1 if you want a description page. 
%                     Default is 0.
% 
% Output:
% 
% The data of the object is saved to excel with the given save 
% name. Each worksheet is saved with the names of the objects 
% identifiers.
% 
% Examples:
% 
% obj        = nb_DataCollection();
% dataObject = nb_ts([2,2],'','2012Q1','Var1');
% obj        = obj.add(dataObject,'Dataset1');
% saveData(obj,'test')
% saveData(obj,'test',1)
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        descriptionPage = 0;
    end

    if ~ischar(saveName)
        error([mfilename ':: The given save name must be a string (char).'])
    end

    warning('off','MATLAB:xlswrite:AddSheet');

    if exist([pwd '\' saveName '.xlsx'],'file') == 2
        dos(['del ' saveName '.xlsx']);
    end

    % Collected the shortened sheetNames
    sheets = cell(size(obj.objectsID,2),1);
    for ii = 1:size(obj.objectsID,2)

        sheetName = obj.objectsID{ii};
        if size(sheetName,2) > 31
            sheetNameShort = sheetName(1,1:30); % The name of a sheet cannot have more than 31 chars
        else
            sheetNameShort = sheetName;
        end

        if size(sheetNameShort,2) == 30
            nrOfFound = findMatch(sheetNameShort,sheets);
        else
            nrOfFound = 0;
        end

        if nrOfFound == 0
            sheets{ii} = sheetNameShort;
        else
            sheets{ii} = [sheetNameShort int2str(nrOfFound + 1)];
        end

    end

    % A function for finding the number of matching short
    % sheetnames already made
    function numberOfFound = findMatch(string,cellOfStrings)

        numberOfFound = 0;
        for zz = 1:length(cellOfStrings)

            len = size(cellOfStrings{zz},2);
            if len == 30
                numberOfFound = numberOfFound + strcmp(string,cellOfStrings{zz});
            elseif len == 31
                numberOfFound = numberOfFound + strcmp(string,cellOfStrings{zz}(1,1:30));
            end

        end

    end


    % Create description page
    if descriptionPage

        dPage = cell(size(obj.objectsID,2) + 3,2);
        dPage{1,1} = 'Description of each shorted worksheet names';
        dPage{3,1} = 'Shortname';
        dPage{3,2} = 'Fullname';

        for ii = 1:size(obj.objectsID,2)
            dPage{3 + ii,1} = sheets{ii};
            dPage{3 + ii,2} = obj.objectsID{ii};
        end

        xlswrite([saveName '.xlsx'], dPage, 'Description page');

    end

    % Save each datasets as sheets
    temp = obj.list.getFirst();
    for ii = 1:size(obj.objectsID,2)

        worksheet = temp.getElement().asCell('xls');
        xlswrite([saveName '.xlsx'], worksheet, sheets{ii});
        temp = temp.getNext();

    end 

    %--------------------------------------------------------------
    % Delete the default sheets of a excel spreadsheet
    %--------------------------------------------------------------
    % Get information returned by XLSINFO on the workbook
    XL_file = [pwd '\' saveName '.xlsx'];
    [~, sheet_names] = xlsfinfo(XL_file);
    try
        % First open Excel
        Excel = actxserver('Excel.Application');
        set(Excel, 'Visible', 0);
        set(Excel,'DisplayAlerts',0);
        Workbooks = Excel.Workbooks;
        Workbooks.Open(XL_file);
        Sheets = Excel.ActiveWorkBook.Sheets;
        index_adjust = 0;

        % Cycle through the sheets and delete them based on user input
        for i = 1:max(size(sheet_names))

            switch sheet_names{i}
                case{'Sheet1','Sheet2','Sheet3'}
                    current_sheet = get(Sheets, 'Item', (i-index_adjust));
                    invoke(current_sheet, 'Delete')
                    index_adjust = index_adjust +1;
            end

        end

        % CLose excel objects
        Excel.ActiveWorkbook.Save;
        Excel.ActiveWorkbook.Close;
        Excel.Quit;
        Excel.delete;

    catch %#ok

        % CLose excel objects
        Excel.ActiveWorkbook.Save;
        Excel.ActiveWorkbook.Close;
        Excel.Quit;
        Excel.delete;
    end

end
