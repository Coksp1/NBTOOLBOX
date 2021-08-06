function data = nb_readExcelMoreSheets(filename)
% Syntax:
%
% data = nb_readExcelMoreSheets(filename)
%
% Description:
%
% Read all the sheets of an excel file given by the input filname 
% and return it as an object of class nb_DataCollection.
%
% Input:
% 
% - filename : A string with the filename of the excel spreadsheet.
%
% Output:
%
% - data     : An nb_DataCollection object. (Much like an  
%              spreadsheet in excel, with each worksheets given as 
%              an nb_ts object or an nb_cs objects.)
%
% Format of the worksheets of the excel spreadsheet:
% 
% - Timeseries : 
% 
%    dates       Var1 Var2
%    30.06.2012     3    4
%    30.09.2012     5    6
% 
%    Caution : Nothing else could be included in the page!!
%
% - Cross sectional data :
%
%    types Var1  Var2
%    var      1     4
%    std      1     2
%
%    Caution : Nothing else could be included in the page!!
%
% Output:
%
% - data    : An object of class nb_DataCollection
%
% See also:
% nb_DataCollection, nb_ts, nb_cs, nb_readExcel
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    [~,sheets] = xlsfinfo(filename);

    % Test if the excel spreadsheet includes a description page, if it does we
    % use the full sheet names from that page as the name of the data objects
    % stored in the nb_DataCollection object.
    foundDP = find(strcmp('Description page',sheets),1);
    if ~isempty(foundDP)  
        [~,text]   = xlsread(filename,'Description page');
        sheetNames = text(4:end,2); 
        sheets     = [sheets(1:foundDP - 1), sheets(foundDP + 1:end)];
    else
        sheetNames = sheets;  
    end

    % Intialize an empty nb_DataCollection object
    data = nb_DataCollection();

    % Read each sheet
    for ii = 1:size(sheets,2)
        dataObj = nb_readExcel(filename,sheets{ii});
        if ~isempty(dataObj)
            dataObj.dataNames{1} = sheetNames{ii};
            data = data.add(dataObj,sheetNames{ii});
        end
    end

end

