function obj = addPageCopies(obj,num)
% Syntax:
%
% obj = addPageCopies(obj,num)
%
% Description:
%
% Add copies of the data of an object and append it as new datasets
% of the object. Only possible if an object has only one page.
% 
% Input:
% 
% - obj : An object of class nb_ts
% 
% - num : Number of copies to be appended, or a vector of nb_date objects
%         with the end date of each new page.
% 
% Output:
% 
% - obj : An object of class nb_ts with the added copies of the 
%         first dataset in the object.
% 
% Examples:
%
% data   = nb_ts(rand(20,2),'','2011Q1',{'Var1','Var2'});
% dataP  = data.addPageCopies(10);
% dates  = vec(nb_quarter('2015Q1'),nb_quarter('2015Q3'));
% dataP2 = data.addPageCopies(dates);
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if obj.numberOfDatasets > 1
        error([mfilename ':: Only possible to append copies of the data of an object if it consist of only one dataset.'])
    end
    
    if isa(num,'nb_date')
        dates = num;
        dates = dates(:);
        num   = size(dates,1);
    else
        dates = {};
    end

    % Append the copies
    obj.data = repmat(obj.data,[1,1,1 + num]);
    if isa(obj.data,'nb_distribution')
        obj.data(:,:,2:num) = copy(obj.data(:,:,2:num));
    end
    if ~isempty(dates)
        if isa(obj.data,'nb_distribution')
            element = nb_distribution('type','constant','parameters',{nan});
        else
            element = nan;
        end
        for ii = 1:num
            e                      = (dates(ii) - obj.startDate) + 1;
            obj.data(e+1:end,:,ii) = element;
        end
    end
    
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
