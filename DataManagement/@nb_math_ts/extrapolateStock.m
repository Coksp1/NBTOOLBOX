function obj = extrapolateStock(stock,flow,depreciation)
% Syntax:
%
% obj = extrapolateStock(stock,flow,depreciation)
%
% Description:
%
% Extrapolate stock with the flow from where the stock ends (first nan 
% value - 1).
% 
% stock(t+1) = (1 - depreciation)*stock(t) + flow(t)
%
% Input:
% 
% - stock        : A nb_math_ts object.
%
% - flow         : A nb_math_ts object.
% 
% - depreciation : A scalar number between 0 and 1.
% 
% Output:
% 
% - obj          : A nb_math_ts object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~nb_isScalarNumber(depreciation)
        error([mfilename ':: The depreciation input must be a scalar double between 0 and 1.'])
    end
    if depreciation > 1 || depreciation < 0
        error([mfilename ':: The depreciation input must be a scalar double between 0 and 1.'])
    end
    
    if stock.endDate ~= flow.endDate
        error([mfilename ':: The stock and flow input must have the same end date.'])
    end
    
    if stock.startDate ~= flow.startDate
        error([mfilename ':: The stock and flow input must have the same end date.'])
    end
    
    % Locate the two series
    stockD = double(stock);
    flowD  = double(flow);
    
    % Do the merging
    newSeries = stockD;
    for pp = 1:size(stockD,3)
        ind = find(~isnan(stockD(:,:,pp)),1,'last'); 
        per = size(stockD,1) - ind;
        for i = 1:per
            newSeries(ind + i,:,pp) = (1 - depreciation)*newSeries(ind + i - 1,:,pp) + flowD(ind + i,:,pp);
        end
    end
    obj = nb_math_ts(newSeries,stock.startDate);   

end
