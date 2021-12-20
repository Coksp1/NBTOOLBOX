function obj = squeeze(obj)
% Syntax:
%
% obj = squeeze(obj)
%
% Description:
% 
% Squeezes the different datasets (pages) of the given nb_data 
% object. It will append the variables in each dataset with the 
% given data name
%
% Input:
% 
% - obj : An nb_data object. If the object has only one dataset 
%         (page) this method has nothing to do.
%
% Output:
%
% - obj : An nb_data object, where all the pages are squeezed 
%         together. I.e. all data will be stored in one dataset, 
%         and all variable names will get the dataset name 
%         appended.
%
% Example:
%
% obj = nb_data(ones(1,1,2),{'b','c'},2,{'Var1'})
% 
% obj = 
% 
% (:,:,1) = 
% 
%     'Time'    'Var1'
%     '2012'    [   1]
% 
% (:,:,2) = 
% 
%     'Time'    'Var1'
%     '2012'    [   1]
% 
% sObj = squeeze(obj)
% 
% sObj = 
% 
%     'Time'    'Var1_b'    'Var1_c'
%     '2012'    [     1]    [     1]    
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    oldObj = obj;
    if obj.numberOfDatasets > 1

        temp = nb_data([],'',[],{},obj.sorted);
        var  = obj.variables;
        for ii = 1:obj.numberOfDatasets
            tData = obj.data(:,:,ii);
            tObj  = nb_data(tData,'',obj.startObs,var,obj.sorted);
            tObj  = tObj.addPostfix(['_',obj.dataNames{ii}]);
            temp  = temp.merge(tObj);
        end
        obj = temp;

    end
    
    if oldObj.isUpdateable()
        
        oldObj = oldObj.addOperation(@squeeze);
        links  = oldObj.links;
        obj    = obj.setLinks(links);
              
    end
        
end
