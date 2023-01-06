function obj = merge(obj,DB,type)
% Syntax:
%
% obj = merge(obj,DB,'horzcat')
% obj = merge(obj,DB,'vertcat')
%
% Description:
%
% Merge another nb_cell object with the current one
% 
% Input:
% 
% - obj  : An object of class nb_cell
% 
% - DB   : An object of class nb_cell
% 
% - type : Either 'horzcat' or 'vertcat'. Dimensions must agree!
%
% Output:
% 
% - obj : An object of class nb_cell.
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isa(obj,'nb_cell') || ~isa(DB,'nb_cell')
        error([mfilename ':: The two merged objects must both be of class nb_cell.'])
    end

    % Start the merging
    %--------------------------------------------------------------
    if isempty(obj)
        obj = DB;
    elseif isempty(DB)
        % Do nothing
    else

        if ~obj.isBeingUpdated 
            
            % If the objects are updatable we need merge things also
            % for the property links 
            if ~isUpdateable(obj)
                dataObj = obj.cdata;
            end

            if ~isUpdateable(DB)
                dataDB = DB.cdata;
            end
            
            if ~obj.isUpdateable() && DB.isUpdateable()

                obj.links              = struct();
                tempSubLink            = nb_createDefaultLink;
                tempSubLink.source     = dataObj;
                tempSubLink.sourceType = 'private(nb_cell)';
                obj.links.subLinks     = tempSubLink;
                obj.updateable         = 1;  

            elseif obj.isUpdateable() && ~DB.isUpdateable()

                DB.links               = struct();
                tempSubLink            = nb_createDefaultLink;
                tempSubLink.source     = dataDB;
                tempSubLink.sourceType = 'private(nb_cell)';
                DB.links.subLinks      = tempSubLink;
                DB.updateable          = 1;

            end
            
        end
            
        % Test if the databases has the same number of datasets. If one
        % of the datasets has more then one page and the other has only
        % one this function makes copies of the one dataset and make
        % the database have the same number of datasets as the other
        % one. (Same number of pages)
        if obj.numberOfDatasets ~= DB.numberOfDatasets
           error([mfilename ':: The objects concatenated must have the same number of pages'])
        end
        
        % Merge the data
        switch type
            
            case 'horzcat'
                
                if size(obj.data,1) ~= size(DB.data,1)
                    error([mfilename ':: The objects concatenated must have the same number of rows.'])
                end   
                obj.data = [obj.data,DB.data];
                obj.c    = [obj.c,DB.c];
                
            case 'vertcat'
                
                if size(obj.data,2) ~= size(DB.data,2)
                    error([mfilename ':: The objects concatenated must have the same number of columns.'])
                end    
                obj.data = [obj.data;DB.data];
                obj.c    = [obj.c;DB.c];
                
            otherwise
                error([mfilename ':: Unsupported type ' type])
        end
        
        % Merge links
        if obj.isUpdateable() && DB.isUpdateable()
            obj = mergeLinks(obj,DB);
        end

    end

end

function obj = mergeLinks(obj,DB,type)
% Merge updatable links of the merged objects    

    tempLinksObj               = obj.links.subLinks;
    tempLinksObj(1).operations = [tempLinksObj(1).operations, {{'merge',{type}}}]; % Add a merge indicator to the operation tree.
    tempLinksDB                = DB.links.subLinks;
    mergedLinks                = nb_structdepcat(tempLinksObj,tempLinksDB);
    obj.links.subLinks         = mergedLinks;

end
