function obj = summary(obj)
% Syntax:
% 
% obj = summary(obj)
%
% Description:
%
% Summary of the timesseries of the nb_ts object
% 
% Input:
% 
% - obj : An object of class nb_ts
% 
% Output:
% 
% - obj : The summary statistics - min, max, std, var, skewness and 
%         kurtosis, as a nb_cs object
%               
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Caluculate the summary statistics
    minD    = obj.min('double');
    maxD    = obj.max('double');
    meanD   = obj.mean('double');
    medianD = obj.median('double');
    %modeD   = obj.mode('double');
    stdD    = obj.std(0,'double');
    varD    = obj.var('double');
    skeD    = obj.skewness(0,'double');
    kurD    = obj.kurtosis(0,'double');

    % Merge them together
    dataOut  = [minD;maxD;meanD;medianD;stdD;varD;skeD;kurD];%;modeD
    types    = {'min','max','mean','median','std','var','skewness','kurtosis'};%,'mode'
    nb_cs_DB = nb_cs(dataOut,'',types,obj.variables,obj.sorted);
    
    if obj.isUpdateable()
        
        obj      = obj.addOperation(@summary);
        links    = obj.links;
        nb_cs_DB = nb_cs_DB.setLinks(links);
        
    end
    
    obj = nb_cs_DB;
    
end
