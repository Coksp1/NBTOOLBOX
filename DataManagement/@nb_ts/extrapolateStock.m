function obj = extrapolateStock(obj,stock,flow,depreciation)
% Syntax:
%
% obj = extrapolateStock(obj,stock,flow,depreciation)
%
% Description:
%
% Extrapolate stock with the flow from where the stock ends.
% 
% stock(t+1) = (1 - depreciation)*stock(t) + flow(t)
%
% Input:
% 
% - obj          : An object of class nb_dataSource.
%
% - stock        : A one line char with the name of the stock series.
%
% - flow         : A one line char with the name of the flow series.
% 
% - depreciation : A scalara number between 0 and 1.
% 
% Output:
% 
% - obj          : An object of class nb_dataSource.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~nb_isOneLineChar(stock)
        error([mfilename ':: The stock input must be a one line char with the name of a variable.'])
    end
    
    if ~nb_isOneLineChar(flow)
        error([mfilename ':: The flow input must be a one line char with the name of a variable.'])
    end
    
    if ~nb_isScalarNumber(depreciation)
        error([mfilename ':: The depreciation input must be a scalar double between 0 and 1.'])
    end
    if depreciation > 1 || depreciation < 0
        error([mfilename ':: The depreciation input must be a scalar double between 0 and 1.'])
    end
    
    % Locate the two series
    indV1  = strcmp(stock,obj.variables);
    stockD = obj.data(:,indV1,:);
    if isempty(stockD)
        error([mfilename ':: Cannot locate the variable given by the stock input.'])
    end
    
    indV2 = strcmp(flow,obj.variables);
    flowD = obj.data(:,indV2,:);
    if isempty(flowD)
        error([mfilename ':: Cannot locate the variable given by the flow input.'])
    end
    
    % Do the merging
    newSeries = stockD;
    for pp = 1:obj.numberOfDatasets
        ind = find(~isnan(stockD(:,:,pp)),1,'last');
        if isa(obj,'nb_ts') || isa(obj,'nb_data')
            per = obj.numberOfObservations - ind;
        else
            per = obj.numberOfTypes - ind;
        end
        for i = 1:per
            newSeries(ind + i,:,pp) = (1 - depreciation)*newSeries(ind + i - 1,:,pp) + flowD(ind + i,:,pp);
        end
    end
    
    obj.data(:,indV1,:) = newSeries;   
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@extrapolateStock,{stock,flow,depreciation});
        
    end

end
