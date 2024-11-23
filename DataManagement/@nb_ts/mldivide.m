function obj = mldivide(a,b)
% Syntax:
%
% obj = mldivide(a,b)
%
% Description:
%
% Matrix left division (\). See examples.
% 
% Input:
% 
% - a   : An object of class nb_ts
% 
% - b   : A scalar, a string or an nb_date object.
% 
% Output:
% 
% - obj : An nb_ts object.  
% 
% Examples:
%
% obj = nb_ts.rand('2012Q1',10,2)
% obj = obj\1              % 1/obj
% obj = obj\'2012Q1'       % '2012Q1'/obj
% obj = obj\'Var1'         % 'Var1'/obj
% obj = obj\obj.startDate  % obj.startDate/obj
%
% See also:
% nb_ts.mrdivide, nb_ts.rdivide
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isa(a,'nb_ts') && isnumeric(b)

        if isscalar(b)
            obj      = a;
            obj.data = b./obj.data;
        else
            error([mfilename ':: Undefined function ''mldivide'' for input arguments of type ''' class(a) '''  and ''' class(b) ' vector''.'])
        end
        
    elseif isa(a,'nb_ts') && ischar(b) 
        
        if size(b,1) == 1
            
            obj    = a;
            indVar = find(strcmp(b,a.variables),1);
            if ~isempty(indVar)
                num      = repmat(a.data(:,indVar,:),[1,a.numberOfVariables,1]);
                obj.data = num./a.data;
            else
                
                dat  = dates(a);
                indD = find(strcmp(b,dat),1);
                if ~isempty(indD)
                    num      = repmat(a.data(indD,:,:),[a.numberOfObservations,1,1]);
                    obj.data = num./a.data;
                else
                    error([mfilename ':: The string provided (''' b ''') is neither a date or a variable of the object'])
                end
                
            end
            
        else
            error([mfilename ':: Undefined function ''mldivide'' for input arguments of type ''' class(a) '''  and multi-row ''' class(b) '''.'])
        end
        
    elseif isa(a,'nb_ts') && isa(b,'nb_date')
        
        obj = a;
        if a.frequency == b.frequency
            
            indD = b - a.startDate + 1;
            if indD <= 0
                error([mfilename ':: The date provided is before the startDate of the object.'])
            elseif indD > a.numberOfObservations
                error([mfilename ':: The date provided is after the endDate of the object.'])
            else
                num      = repmat(a.data(indD,:,:),[a.numberOfObservations,1,1]);
                obj.data = num./a.data;
            end
            
        else
            error([mfilename ':: The nb_date object provided (''' b.toString() ''') is of wrong frequency.'])
        end    

    else
        error([mfilename ':: Undefined function ''mldivide'' for input arguments of type ''' class(a) ''' and ''' class(b) '''.'])
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@mldivide,{b});
        
    end

end
