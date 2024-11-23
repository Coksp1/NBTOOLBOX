function obj = squeeze(obj)
% Syntax:
%
% obj = squeeze(obj)
%
% Description:
% 
% Squeezes the different datasets (pages) of the given nb_cs 
% object. It will append the variables in each dataset with the 
% given data name
%
% Input:
% 
% - obj : An nb_cs object. If the object has only one dataset 
%         (page) this method has nothing to do.
%
% Output:
%
% - obj : An nb_cs object, where all the pages are squeezed 
%         together. I.e. all data will be stored in one dataset, 
%         and all variable names will get the dataset name 
%         appended.
%
% Example:
%
% obj = nb_cs(ones(1,1,2),{'b','c'},{'Type'},{'Var1'})
% 
% obj = 
% 
% 
% (:,:,1) = 
% 
%     'Types'    'Var1'
%     'Type'     [   1]
% 
% 
% (:,:,2) = 
% 
%     'Types'    'Var1'
%     'Type'     [   1]
% 
% sObj = squeeze(obj)
% 
% sObj = 
% 
%     'Time'    'Var1_b'    'Var1_c'
%     '2012'    [     1]    [     1]    
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    oldObj = obj;
    if obj.numberOfDatasets > 1

        temp = nb_cs([],'',{},{},obj.sorted);
        var  = obj.variables;
        type = obj.types;
        for ii = 1:obj.numberOfDatasets
            tData = obj.data(:,:,ii);
            tObj  = nb_cs(tData,'',type,var,obj.sorted);
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
