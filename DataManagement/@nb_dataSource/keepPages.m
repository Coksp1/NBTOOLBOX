function obj = keepPages(obj,pages)
% Syntax:
%
% obj = keepPages(obj,pages)
%
% Description:
% 
% Keep pages of the current nb_ts object
% 
% Input:
% 
% - obj   : An object of class nb_ts
% 
% - pages : A numerical index of the pages you want to keep. E.g. if 
%           you want to keep the first 3 datasets (pages of the data) 
%           of the object. And the number of datasets of the object is 
%           larger than 3. You can use; 1:3. If empty a empty nb_ts object
%           is returned.
%
%           Can also be a cellstr with the names to keep, or a logical
%           array with length equal to the number of pages (datasets).
% 
% Output: 
%
% - obj : An nb_ts object with the pages specified in the input are kept.
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isempty(pages)
        pagesInt = false(1,obj.numberOfDatasets);
    else
        if nb_iswholenumber(pages)
            pages = pages(:);
            m     = max(pages);
            if m > obj.numberOfDatasets
                error([mfilename ':: The object consist only of ' int2str(obj.numberOfDatasets) ' datasets. You are trying to reach the dataset ' int2str(m) ', which is not possible.'])
            end
            m = min(pages);
            if m < 1
                error([mfilename ':: The pages input cannot include negative indexes!'])
            end
            pagesInt = pages;
        elseif ischar(pages)
            pagesInt = strcmp(pages,obj.dataNames);
            if ~any(pagesInt)
                error([mfilename ':: The page ' pages ' is not a page (dataset) name of the object.'])
            end
        elseif iscellstr(pages)
            [test,pagesInt] = ismember(pages,obj.dataNames);
            if any(~test)
                error([mfilename ':: The following pages are not a page of the object; ' toString(pages(~test))])
            end
        elseif islogical(pages)
            pagesInt = pages(:);
            if ~nb_sizeEqual(pagesInt,[obj.numberOfDatasets,1])
                error([mfilename ':: If the pages input is given as a logical it must have length ',... 
                       int2str(obj.numberOfDatasets) '.'])
            end
            if ~any(pagesInt)
                
            end
        else
            error([mfilename ':: The pages input cannot be an object of class ' class(pages)])
        end
        
    end
    obj.data      = obj.data(:,:,pagesInt);
    obj.dataNames = obj.dataNames(pagesInt);
    if isempty(obj.data)
        obj = empty(obj);
    end
    
    if obj.isUpdateable()
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@keepPages,{pages});      
    end

end
