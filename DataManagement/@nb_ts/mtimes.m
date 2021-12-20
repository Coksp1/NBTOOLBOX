function obj = mtimes(obj,b)
% Syntax:
%
% obj = mtimes(obj,Num)
%
% Description:
%
% Matrix multiplication (*) Defined for multplication with a
% constant, a string which either represent a variable or date or
% an nb_date object.
% 
% Input:
% 
% - obj       : An object of class nb_ts or scalar
% 
% - b         : An object of class nb_ts or a scalar, a string or
%               an nb_date object.
% 
% Output:
% 
% - obj       : An nb_ts object where the number (date or variable
%               as a vector) is multiplied with all the elements of  
%               the input objects data
% 
% Examples:
% 
% obj = 2*obj;
% obj = obj*2;
% obj = obj*'2012Q1'
% obj = obj*'Var1'
% obj = obj*obj.startDate
%
% See also:
% nb_ts.times
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isnumeric(obj) && isa(b,'nb_ts')

        % Make expression like 2*obj work
        if isscalar(obj)
            temp      = b;
            temp.data = b.data*obj;
            obj       = temp;
        else
            error([mfilename ':: Undefined function ''mtimes'' for input arguments of type ''' class(obj) ''' (vector)  and ''' class(b) '''.'])
        end
        
    elseif isnumeric(b) && isa(obj,'nb_ts')
        
        if isscalar(b)
            obj.data = obj.data*b;
        else
            error([mfilename ':: Undefined function ''mtimes'' for input arguments of type ''' class(b) ''' (vector)  and ''' class(obj) '''.'])
        end
        
    elseif isa(obj,'nb_ts') && ischar(b) 
        
        if size(b,1) == 1
            
            indVar = find(strcmp(b,obj.variables),1);
            if ~isempty(indVar)
                
                b      = repmat(obj.data(:,indVar,:),[1,obj.numberOfVariables,1]);
                obj.data = obj.data.*b;
                
            else
                
                dat  = dates(obj);
                indD = find(strcmp(b,dat),1);
                if ~isempty(indD)
                   
                    b      = repmat(obj.data(indD,:,:),[obj.numberOfObservations,1,1]);
                    obj.data = obj.data.*b;
                    
                else
                    error([mfilename ':: The string provided (''' b ''') is neither a date or a variable of the object'])
                end
                
            end
            
        else
            error([mfilename ':: Undefined function ''mtimes'' for input arguments of type ''' class(a) '''  and multi-row ''' class(b) '''.'])
        end 
        
    elseif isa(obj,'nb_ts') && isa(b,'nb_date')
        
        if obj.frequency == b.frequency
            
            indD = b - obj.startDate + 1;
            if indD <= 0
                error([mfilename ':: The date provided is before the startDate of the object.'])
            elseif indD > obj.numberOfObservations
                error([mfilename ':: The date provided is after the endDate of the object.'])
            else
                b      = repmat(obj.data(indD,:,:),[obj.numberOfObservations,1,1]);
                obj.data = obj.data.*b;
            end
            
        else
            error([mfilename ':: The nb_date object provided (''' b.toString() ''') is of wrong frequency.'])
        end    
        
    else
        error([mfilename ':: Matrix muliplication of two object of class ' class(obj) ' and ' class(b) ' is not supported.'])
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@mtimes,{b});
        
    end

end
