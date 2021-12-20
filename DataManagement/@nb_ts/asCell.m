function cellMatrix = asCell(obj,dateFormat,strip)
% Syntax:
%
% cellMatrix = asCell(obj,dateFormat,strip)
%
% Description:
%
% Return the data of the object as a cell matrix. 
% (In the dyn_ts format, i.e. looks like a excel spreadsheet.)
% 
% Input:
% 
% - obj        : An object of class nb_ts
% 
% - dateFormat : The date format of the dates of the cell.
%
%                > 'default' :
%
%                   yearly       : 'yyyy' 
%                   semiannually : 'yyyySs' 
%                   quarterly    : 'yyyyQq' 
%                   monthly      : 'yyyyMm(m)' 
%                   daily        : 'yyyyMm(m)Dd(d)'
%
%                > 'xls'     : 'dd.mm.yyyy' for all frequencies
% 
% - strip      : - 'on'  : Strip all observation dates where all 
%                          the variables has no value. 
% 
%                - 'off' : Does not strip all observation dates 
%                          where all the variables has no value. 
%                          Default. 
% 
% Output:
% 
% - cellMatrix : The nb_ts objects data transformed to a cell. 
% 
% Examples:
% 
% cellMatrix = obj.asCell();
% cellMatrix = obj.asCell('xls');
% cellMatrix = obj.asCell('xls','on');
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        strip = 'off';
        if nargin < 2
            dateFormat = 'default';
        end
    end

    corner = {'Time'};
    corner = corner(:,:,ones(1,obj.numberOfDatasets));
    vars   = obj.variables(:,:,ones(1,obj.numberOfDatasets));
    if strcmpi(strip,'on')
          
        if isa(obj.data,'nb_distribution')
            error([mfilename ':: Cannot set strip to ''on'' if the data is of class nb_distribution.'])
        end
        
        d          = obj.data;
        ind        = all(all(isnan(d),2),3);
        d          = d(~ind,:,:);
        dates      = obj.startDate.toDates(0:obj.numberOfObservations - 1,dateFormat,obj.frequency);
        dates      = dates(~ind,1);
        dates      = dates(:,:,ones(1,obj.numberOfDatasets));
        cellMatrix = [corner, vars; dates, num2cell(d)];

    else
        
        if isa(obj.data,'nb_distribution')
            d = reshape({obj.data.name},[obj.numberOfObservations,obj.numberOfVariables,obj.numberOfDatasets]);
        else
            d = num2cell(obj.data);
        end
        dates      = obj.startDate.toDates(0:obj.numberOfObservations - 1,dateFormat,obj.frequency);
        dates      = dates(:,:,ones(1,obj.numberOfDatasets));
        cellMatrix = [corner, vars; dates, d];
        
    end

end
