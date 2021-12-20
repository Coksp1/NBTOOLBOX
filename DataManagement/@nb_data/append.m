function obj = append(obj,DB)
% Syntax:
%
% obj = append(obj,DB,method)
%
% Description:
%
% Append a nb_data object to another nb_data object.
%
% Caution: 
% 
% - It is possible to merge datasets with the same variables as 
%   long as they represent the same data or have different 
%   observation ids.
% 
% - If the datsets has different number of datasets and one of the 
%   merged objects only consists of one, this object will add as
%   many datasets as needed (copies of the first dataset) so they
%   the one object can append the other.
%
% - In contrast to the vertcat method, this method will keep the
%   first inputs end obs and cut all the shared observations of the
%   appended object.
% 
% Input:
% 
% - obj : An object of class nb_data
% 
% - DB  : An object of class nb_data
%
% Output:
% 
% - obj : An nb_data object where the datasets from the two nb_data
%         objects are merged
% 
% Examples:
% 
% obj = append(obj,DB)
% obj = obj.append(DB)
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isa(obj,'nb_data') || ~isa(DB,'nb_data')
        error([mfilename ':: The appended objects must both be of class nb_data.'])
    end

    if isempty(obj)
        obj = DB; 
    elseif isempty(DB)
        % Do nothing
    else
        
        if ~obj.isBeingUpdated 
            % If the object is being updated, all this stuff are
            % already been taken care of
        
            % Test if the databases has the same number of datasets. If one
            % of the datasets has more then one page and the other has only
            % one this function makes copies of the one dataset and make
            % the database have the same number of datasets as the other
            % one. (Same number of pages)
            if obj.numberOfDatasets ~= DB.numberOfDatasets

               if obj.numberOfDatasets < DB.numberOfDatasets
                   obj = obj.addPageCopies(DB.numberOfDatasets - obj.numberOfDatasets);
               else
                   DB = DB.addPageCopies(obj.numberOfDatasets - DB.numberOfDatasets);
               end

            end
            
            % Set the startObs of the second database to endObs
            % + 1 
            DB = DB.window(obj.endObs + 1);

        end
            
        % Then we merge the datasets
        obj = merge(obj,DB); 

    end 

end
