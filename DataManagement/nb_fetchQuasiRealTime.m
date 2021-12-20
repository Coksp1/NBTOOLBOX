function data = nb_fetchQuasiRealTime(filename,sourceType,varargin)
% Syntax:
%
% data = nb_fetchQuasiRealTime(filename,sourceType,varargin)
%
% Description:
%
% Fetch and order the quasi-real-time data of a single series.
%
% Caution: If the series is weekly or daily it will be converted to 
%          monthly.
% 
% Input:
% 
% - filename   : The name of the file to import or the name of the 
%                variable to fetch from a database. E.g. 'QSA_YMN'.
% 
% - sourceType : Give 'excel' if the source is an excel spreadsheet, 'mat'
%                if it is a MATLAB mat file, 'fame' if it is a fame 
%                database or 'smart' if it a series (variable without 
%                vintages in the SMART database). Default is 'mat'.
%
% Optional input:
%
% - 'Database' : If source type is set to 'fame' you can use this 
%                option to set the FAME database to fetch the data  
%                from. Default is 'histdata.db'.
%
% - 'freq'     : If provided the fetched series is converted to this
%                frequency. Default is to convert daily and weekly to
%                monthly, otherwise no the frequency is kept as it is 
%                fetched.
%
% - 'method'   : Method used for converting from high to low frequency.
%                Default is 'average'. See the method input of the
%                nb_ts.convert method for more on this option.
%
% - 'sheet'    : A one line char with the sheet to read. Only
%                supported in the case sourceType is set to 'excel'.
%
% - 'start'    : Give the start date of the real data set. Must be on the
%                frequency of the fetched serie. Either an object of class
%                nb_date, or must be interpreted by the nb_date.date2freq.
%
% - 'business' : true or false (default). If true, the publishing calendar
%                will be the first business day after the end of the month.
%
% - 'cut'      : true, false or the number of forecasting periods to 
%                include. 
%                > true induce to cut the series at the period of 
%                  today minus 1 period. 
%                > E.g. 2 (X) (double case) induce to cut the series at the   
%                  period of today plus 1 (X-1) period. 
%                > Default is false. I.e. no cutting.
%
% - 'removeContext' : Remove all contexts strictly before this date. The  
%                     date must be given as a nb_day object or a one line 
%                     char on a format that the nb_day constructor handles. 
%                     E.g. 'yyyymmdd'. For all source types.
%
% Output:
% 
% - data       : A nObs x 1 x nVintages nb_ts object. Constructs a 
%                quasi-real-time series of a series that is not published 
%                in real time. I.e. it provided a publication calandar to 
%                the data of the returned object. Each publication will be  
%                assign one time-series (as a separate page). 
%
% Written by Kenneth Sæterhagen Paulsen and Sara Skjeggestad Meyer

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen
   
    if nargin < 2
        sourceType = 'mat';
    end
    
    switch lower(sourceType)       
        case 'excel'
            sheet = nb_parseOneOptional('sheet','',varargin{:});
            if isempty(sheet)
                data = nb_ts([filename,'.xlsx']);
            else
                data = nb_ts([filename,'.xlsx'],sheet);
            end          
        case 'mat'    
            data = nb_ts([filename,'.mat']);
        otherwise
            error(['The ' sourceType ' is not supported.'])
    end
    
    data = nb_fetchQuasiRealTimeFinalSteps(data,inputs);
    
end
    
