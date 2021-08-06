function obj = strip(obj,startDate,endDate,variables)
% Syntax: 
%
% obj = strip(obj,startDate,endDate,variables)
%
% Description:
%
% Sets all values of the given variables of a nb_ts object, between two 
% given dates, to nan.
% 
% Input: 
%
% - obj       : A nb_ts object
% 
% - startDate : The starting point of the strip, must be either an  
%               nb_date object or a valid input to the toDate  
%               method of the nb_date class
%
% - endDate   : The starting point of the strip, must be either an  
%               nb_date object or a valid input to the toDate  
%               method of the nb_date class
%
% - variables : A cellstring with the variables to perform the 
%               method on. Can be empty, in which case the method  
%               will be performed on all variables in the object.
% 
% Output: 
%
% - obj       : A nb_ts object
% 
% Examples: 
%
% strippedObj = strip(obj,'2011Q1','2012Q3',{'Var1','Var2'})
% strippedObj = strip(obj,'2011Q1','2012Q3')
%
% See also:
% nb_ts.setToNaN
% 
% Written by Eyo Herstad

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        variables = {}; 
    end

    % Check input
    %---------------------------------------
    if isempty(obj)
        
        warning('nb_ts:EmptyObject',[mfilename ':: The object you are trying to strip observatiosns of is empty. Returning a empty object.']);
        return
        
    end
  
    % Check dates
    startDateT = interpretDateInput(obj,startDate);
    endDateT   = interpretDateInput(obj,endDate);
    
    % Get the selected window
    [~,~,~,startInd,endInd,variablesInd,~] = getWindow(obj,startDateT,endDateT,variables,1:obj.numberOfDatasets);
    
    % Perform the strip
    obj.data(startInd:endInd,variablesInd,:) = nan;
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object. (Cannot give pages, because the links are already
        % removed)
        obj = obj.addOperation(@strip,{startDate,endDate,variables});
        
    end
    
end

