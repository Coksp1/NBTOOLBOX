function nb_forecast2Excel(fcst,filename)
% Syntax:
%
% nb_forecast2Excel(fcst,filename)
%
% Description:
%
% Save down forecast return by the nb_model_vintages.getForecast method
% to excel.
% 
% Input:
% 
% - fcst     : An object of class nb_ts.
%
% - filename : Name of excel file. E.g. 'test'.
% 
% See also:
% nb_model_vintages.getForecast
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    fcstP     = asCell(permute(fcst)); %#ok<LTARG>
    [~,s2,s3] = size(fcstP);
    startD    = fcst.userData(:,2:end);
    fcstP     = [fcstP(1,:,:);cell(1,s2,s3);fcstP(2:end,:,:)];
    for ii = 1:size(fcstP,3)
        fcstP{2,1,ii}     = 'StartDate';
        fcstP(2,2:end,ii) = startD(ii,:);
    end
    
    Excel = nb_xlswrite(filename,fcstP(:,:,1),fcst.variables{1},true);
    for ii = 2:s3
        nb_xlswrite(filename,fcstP(:,:,ii),fcst.variables{ii},false,Excel);
    end
    
    try %#ok<TRYNC> No catch block
        Excel.DisplayAlerts = 0; 
        [~, name, ext] = fileparts(filename);
        fileName = [name ext];
        Excel.Workbooks.Item(fileName).Close(false);
    end
    Excel.Quit;

end
