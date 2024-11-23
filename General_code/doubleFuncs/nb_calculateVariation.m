function [dataLow, dataHigh, dataMAVG, dataMSTD] = nb_calculateVariation(data)
% Syntax:
% 
% [dataLow, dataHigh, dataMAVG, dataMSTD] =...
%  nb_calculateVariation(data)
% 
% Description:
% 
% Get some statistical properties of dataseries stored in an
% nb_ts object.
%
% If number of arguments out is 1, all the statistical properties are
% stored in one nb_ts object. See the outputs for more.
% 
% Input:
% 
% - data      : An object of class nb_ts
% 
% Output:
% 
% - dataLow   : An object of class nb_ts with the moving average 
%               minus the moving standard deviation of the 
%               dataseries     
% 
% - dataHigh  : An object of class nb_ts with the moving average 
%               plus the moving standard deviation of the 
%               dataseries
% 
% - dataMAVG  : An object of class nb_ts with the 10-year moving 
%               average of the dataseries 
% 
% - dataMSTD  : An object of class nb_ts with the 10-year moving  
%               standard deviation of the dataseries
% 
% Examples:
% 
% [low, high] = nb_calculateVariation(data);
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargout == 1
       
        origVars        = data.variables;
        stdVariables    = strcat(data.variables,'_mstd');
        stdExpressions  = strcat('mstd(', data.variables,',10,0)');
        avgVariables    = strcat(data.variables,'_mavg');
        avgExpressions  = strcat('mavg(', data.variables,',9,0)');
        variables       = [stdVariables,avgVariables];
        expressions     = [stdExpressions,avgExpressions];
        data            = data.createVariable(variables,expressions);
        lowVariables    = strcat(origVars,'_low');
        lowExpressions  = strcat(origVars ,'_mavg-', origVars,'_mstd');
        highVariables   = strcat(origVars,'_high');
        highExpressions = strcat(origVars ,'_mavg+', origVars,'_mstd');
        variables       = [lowVariables,highVariables];
        expressions     = [lowExpressions,highExpressions];
        data            = data.createVariable(variables,expressions);
        dataLow         = data;
        return
        
    end
        
    dataMAVG = mavg(data,9,0);
    dataMSTD = mstd(data,10,0);
    
    dataLow  = dataMAVG - dataMSTD;
    dataHigh = dataMAVG + dataMSTD;
    
    dataLow  = addPostfix(dataLow,'_low');
    dataHigh = addPostfix(dataHigh,'_high');
    
    if nargout == 3
        dataMAVG = addPostfix(dataMAVG,'_mavg');
    end
    
    if nargout == 4
        dataMSTD = addPostfix(dataMSTD,'_mstd');
    end
    
end
