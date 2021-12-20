function obj = mtimes(obj,b)
% Syntax:
%
% obj = mtimes(obj,Num)
%
% Description:
%
% Matrix multiplication (*) Defined for multplication with a
% constant, a string which either represent a variable or obs.
% 
% Input:
% 
% - obj       : An object of class nb_data or scalar
% 
% - b         : An object of class nb_data or a scalar or a string.
% 
% Output:
% 
% - obj       : An nb_data object where the number (date or variable
%               as a vector) is multiplied with all the elements of  
%               the input objects data
% 
% Examples:
% 
% obj = 2*obj;
% obj = obj*2;
% obj = obj*'1'
% obj = obj*'Var1'
%
% See also:
% nb_data.times
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if isnumeric(obj) && isa(b,'nb_data')

        % Make expression like 2*obj work
        if isscalar(obj)
            temp      = b;
            temp.data = b.data*obj;
            obj       = temp;
        else
            error([mfilename ':: Undefined function ''mtimes'' for input arguments of type ''' class(obj) ''' (vector)  and ''' class(b) '''.'])
        end
        
    elseif isnumeric(b) && isa(obj,'nb_data')
        
        if isscalar(b)
            obj.data = obj.data*b;
        else
            error([mfilename ':: Undefined function ''mtimes'' for input arguments of type ''' class(b) ''' (vector)  and ''' class(obj) '''.'])
        end
        
    elseif isa(obj,'nb_data') && ischar(b) 
        
        if size(b,1) == 1
            
            indVar = find(strcmp(b,obj.variables),1);
            if ~isempty(indVar)
                
                b      = repmat(obj.data(:,indVar,:),[1,obj.numberOfVariables,1]);
                obj.data = obj.data.*b;
                
            else
                
                obss = observations(obj,'cellstr');
                indD = find(strcmp(b,obss),1);
                if ~isempty(indD)
                   
                    b        = repmat(obj.data(indD,:,:),[obj.numberOfObservations,1,1]);
                    obj.data = obj.data.*b;
                    
                else
                    error([mfilename ':: The string provided (''' b ''') is neither a obs or a variable of the object'])
                end
                
            end
            
        else
            error([mfilename ':: Undefined function ''mtimes'' for input arguments of type ''' class(a) '''  and multi-row ''' class(b) '''.'])
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
