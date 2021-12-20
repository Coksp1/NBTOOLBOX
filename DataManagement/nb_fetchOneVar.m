function data = nb_fetchOneVar(filename,sourceType,varargin)
% Syntax:
%
% data = nb_fetchOneVar(filename,sourceType,varargin)
%
% Description:
%
% Fetch and order the real-time data of a single series.
% 
% Input:
% 
% - filename   : The name of the file to import or the name of the 
%                variable to fetch from a database. E.g. 'QSA_YMN'.
% 
% - sourceType : Give 'excel' if the source is an excel spreadsheet, 'mat'
%                if it is a MATLAB mat file. Default is 'mat'.
% 
% Optional input:
%
% - 'freq'          : If provided the fetched series is converted to this
%                     frequency. Can only convert to a lower frequency.
%                     
% - 'method'        : Method used for converting from high to low 
%                     frequency. Default is 'average'. See the method 
%                     input of the nb_ts.convert method for more on this 
%                     option.
%
% - 'removeContext' : Remove all contexts strictly before this date. The  
%                     date must be given as a nb_day object or a one line 
%                     char on a format that the nb_day constructor handles. 
%                     E.g. 'yyyymmdd'. For all source types.
%
% - 'sheet'         : A one line char with the sheet to read. Only
%                     supported in the case sourceType is set to 'excel'.
%
% - 'reIndex'       : True or false. Default is false.
%
% Output:
% 
% - data     : A nObs x 1 x nVintages nb_ts object.
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
            data = rename(data,'variables',[filename '.*'],'');
            if isempty(sheet)
                data = rename(data,'dataset',[filename '.xlsx'],filename);
            else
                data = rename(data,'dataset',sheet,filename);
            end
            data = permute(data); %#ok<*LTARG>
            
        case 'mat'
            
            data = nb_ts([filename,'.mat']);
            data = rename(data,'dataset',[filename '.mat'],filename);
            data = permute(data);
                  
    end
     
    data = nb_fetchOneVarFinalSteps(data,sourceType,varargin);
    
end
