function obj = summary(obj)
% Syntax:
% 
% obj = summary(obj)
%
% Description:
%
% Summary of the series of the nb_data object
% 
% Input:
% 
% - obj       : An object of class nb_data
% 
% Output:
% 
% - obj       : the summary statistics - min, max, std, var,  
%               skewness and kurtosis
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    % Caluculate the summary statistics
    minD    = obj.min('double');
    maxD    = obj.max('double');
    meanD   = obj.mean('double');
    medianD = obj.median('double');
    modeD   = obj.mode('double');
    stdD    = obj.std(0,'double');
    varD    = obj.var('double');
    skeD    = obj.skewness(0,'double');
    kurD    = obj.kurtosis(0,'double');

    % Merge them together
    dataOut  = [minD;maxD;meanD;medianD;modeD;stdD;varD;skeD;kurD];
    types    = {'min','max','mean','median','mode','std','var','skewness','kurtosis'};
    nb_cs_DB = nb_cs(dataOut,'',types,obj.variables,obj.sorted);
    
    if obj.isUpdateable()
        
        obj      = obj.addOperation(@summary);
        links    = obj.links;
        nb_cs_DB = nb_cs_DB.setLinks(links);
        
    end
    
    nb_cs_DB.localVariables = obj.localVaribles;
    
    obj = nb_cs_DB;
    
end
