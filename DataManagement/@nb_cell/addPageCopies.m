function obj = addPageCopies(obj,num)
% Syntax:
%
%
% Description:
%
% Add copies of the data of an object of class nb_cell and append it 
% as new datasets of the object. Only possible if an object 
% has only one page.
%
% Input:
% 
% - obj : An object of class nb_cell
% 
% - num : Number of copies to be appended
% 
% Output:
% 
% - obj : An object of class nb_cell with the added copies of the 
%         first dataset in the object.
%         
% Examples:
% 
% obj = nb_cs([2,2],'test',{'First'},{'Var1','Var2'});
% obj = addPageCopies(obj,2);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if obj.numberOfDatasets > 1
        error([mfilename ':: Only possible to append copies of the data of an object if it consist of only one dataset.'])
    end
    
    % Append the copies
    obj.data = repmat(obj.data,[1,1,1 + num]);
    obj.c    = repmat(obj.c,[1,1,1 + num]);

    % Add database names
    if strcmp(obj.dataNames{1},'Database1')
        NameOfDataset = 'Database';
        obj.dataNames = cell(1,obj.numberOfDatasets);
        for kk = 1:obj.numberOfDatasets
            obj.dataNames{kk} =  [NameOfDataset int2str(kk)];
        end
    else
        NameOfDataset = obj.dataNames{1}; 
        obj.dataNames = cell(1,obj.numberOfDatasets);
        for kk = 1:obj.numberOfDatasets
            obj.dataNames{kk} =  [NameOfDataset '(' int2str(kk) ')'];
        end
    end
    
    % If the object is updateable we need to update the links and
    % operations properties
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@addPageCopies,{num});
        
    end

end
