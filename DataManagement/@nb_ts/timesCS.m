function obj = timesCS(obj,DB)
% Syntax:
%
% obj = timesCS(obj,DB)
%
% Description:
% 
% Element-wise multiplication (.*) between a nb_ts and nb_cs object.
% 
% Caution : Will multiply the data of variables in obj that match does one
%           variable in DB. The variable that does not match are not 
%           changed. The variables found in DB, but not in obj are ignored.
%           No warning will be given if no matches are found. 
%
% Two cases:
% > obj has as many pages as DB, and the number of pages are > 1, then
%   the multiplication will be done page by page. DB can only have one type
%   (row) in this case.
%
% > DB has only one page, but has more than one type (row). Then obj must
%   either have one page or as many pages as there are types of DB. If obj
%   has one page th multiplication will be done for each type (row) of DB.
%   The output will have as many pages as there are types of the DB input.
%   If obj has the same number of types as DB, then each page of obj will 
%   be multiplied with the matching type of DB, i.e. page one is multiplied
%   by type one and so on.
%   
% Input:
% 
% - obj : An object of class nb_ts.
% 
% - DB  : An object of class nb_cs, can only have one type.
% 
% Output:
% 
% - obj : A nb_ts object the data results from element-wise 
%         multiplication of the data of the input objects.
% 
% Examples:
%
% obj = obj.*DB;
% 
% See also:
% nb_ts.times
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isa(obj,'nb_ts') || ~isa(DB,'nb_cs')
        error([mfilename,':: You can only multiply element-wise a object of class with another object of class nb_ts'])
    end

    if isempty(obj) || isempty(DB)
        erro([mfilename ':: You cannot multiply a object with another if one of them is (or both are) empty.'])
    end
    
    if DB.numberOfDatasets > 1
        
        if DB.numberOfTypes > 1
            error([mfilename ':: Cannot multiply a nb_ts object with more pages with a nb_cs object with more pages and more than one type (row).'])
        end
        
        % Force the datasets to have the same variables.
        % The result will be NAN values for all the missing
        % observations in the two datasets. Must have the same
        % number of datasets (pages)
        if obj.numberOfDatasets ~= DB.numberOfDatasets
            nb_ts.errorConformity(4);
        end
        [ind,loc]         = ismember(DB.variables,obj.variables);
        loc               = loc(ind); 
        ind               = ismember(obj.variables,DB.variables);
        obj.data(:,ind,:) = bsxfun(@times,obj.data(:,ind,:),DB.data(:,loc,:));
        
    else
        
        if obj.numberOfDatasets > 1 
           
            if obj.numberOfPages ~= DB.numberOfTypes
                error([mfilename ':: Cannot multiply a nb_ts object with more pages with a nb_cs object ',...
                                 'which does not have the same number of types.'])
            end
            [ind,loc]         = ismember(DB.variables,obj.variables);
            loc               = loc(ind); 
            ind               = ismember(obj.variables,DB.variables);
            obj.data(:,ind,:) = bsxfun(@times,obj.data(:,ind,:),permute(DB.data(:,loc,:),[3,2,1]));
             
        else
            
            dataTS          = obj.data(:,:,ones(1,DB.numberOfTypes));
            [ind,loc]       = ismember(DB.variables,obj.variables);
            loc             = loc(ind); 
            ind             = ismember(obj.variables,DB.variables);
            dataTS(:,ind,:) = bsxfun(@times,obj.data(:,ind,:),permute(DB.data(:,loc,:),[3,2,1]));
            obj.data        = dataTS;
            
        end
        obj.dataNames = DB.types;
        
    end
    
    if obj.isUpdateable() 
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@timesCS,{DB});
        
    end

end
