function obj = saveData(obj,filename,strip,sheetName)
% Syntax:
% 
% obj = saveData(obj,filename,strip,sheetName)
% 
% Description:
% 
% Saves the data of the figure
% 
% Input:
% 
% - obj       : An object of class nb_graph_subplot
% 
% - filename  : A string with the saved output name
% 
% - strip     : > 'on'  : Strip all observation dates where all the 
%                        variables has no value. Default. 
% 
%               > 'off' : Does not strip all observation dates 
%                         where all the variables has no value. 
% 
% - sheetName : A string with the name of the saved worksheets. 
%               I.e. the data of the subplots will be saved in the
%               sheets with name [sheetName '(<jj>)'. E.g. if
%               sheetName is given as 'GDP' the worksheet for the
%               first subplot will get the name 'GDP(1)', while 
%               the second will get the name 'GDP(2)'. Default is
%               'Graph'.
%
% Example:
% 
% obj.saveData('test');
% obj.saveData('test','on');
% obj.saveData('test','on','Name of figure');
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        sheetName = 'Graph';
        if nargin < 3
            strip = 'on';
            if nargin < 2
                filename = 'data';
            end
        end
    end

    %--------------------------------------------------------------
    % Get the data of all the subplots as cell matrices, and store 
    % them for later in a struct.
    %--------------------------------------------------------------
    s = struct();  
    for ii = 1:size(obj.graphObjects,2)
    
        plotter = obj.graphObjects{ii};
        if isa(plotter,'nb_graph_adv')
            plotter = plotter.plotter;
        end
        
        data = getData(plotter);
        if isa(data,'nb_ts')
            s.(['Graph' int2str(ii) '']) = data.asCell('xls',strip);
        else
            s.(['Graph' int2str(ii) '']) = data.asCell();
        end
        
    end
    
    %--------------------------------------------------------------
    % Save the data stored in the struct down to a excel 
    % spreadsheet. Each field stored in a separate worksheet.
    %--------------------------------------------------------------
    fnames = fieldnames(s);
    for ii = 1:size(fnames,1)
        
        dataset = s.(fnames{ii});
        xlswrite([filename '.xlsx'], dataset, [sheetName int2str(ii)]);
        
    end
    
    %--------------------------------------------------------------
    % Delete the sheets sheet1, sheet2 and sheet3.
    %--------------------------------------------------------------
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
        Err.message % DEBUG
        % Close excel objects
        %--------------------------------------------------
        Excel.ActiveWorkbook.Save;
        Excel.ActiveWorkbook.Close;
        Excel.Quit;
        Excel.delete;

        rethrow(Err);

    end
    
end
