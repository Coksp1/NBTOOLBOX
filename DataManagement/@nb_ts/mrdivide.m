function obj = mrdivide(a,b)
% Syntax:
%
% obj = mrdivide(a,b)
%
% Description:
%
% Matrix right division (/). See examples.
% 
% Input:
% 
% - a   : An object of class nb_data, a scalar number, a string 
%         representing a variable name or a date, or a nb_date 
%         object.
% 
% - b   : An object of class nb_data, a scalar number, a string 
%         representing a variable name or a date, or a nb_date 
%         object.
% 
% Output:
% 
% - obj : An nb_ts object.   
% 
% Examples:
%
% obj  = nb_ts.rand('2012Q1',10,2)
% obj1 = obj/1
% obj2 = obj/'2012Q1'
% obj3 = obj/'Var1';
% obj4 = obj/obj.startDate
% obj5 = 1/obj
% obj6 = '2012Q1'/obj
% obj7 = 'Var1'/obj;
% obj8 = obj.startDate/obj
% 
% See also:
% nb_ts.mldivide, nb_ts.rdivide
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isa(a,'nb_ts')
        obj = mldivide(b,a);
        return
    end

    if (isa(a,'nb_ts') && isa(b,'double')) 

        if isscalar(b)

            obj      = a;
            obj.data = obj.data/b;

        else
            error([mfilename ':: Undefined function ''mrdivide'' for input arguments of type ''' class(a) '''  and ''' class(b) ' vector''. '...
                             '(Remeber that the / operator is the matrix division and not elementwise division (./))'])
        end
        
    elseif isa(a,'nb_ts') && ischar(b) 
        
        if size(b,1) == 1
            
            obj    = a;
            indVar = find(strcmp(b,a.variables),1);
            if ~isempty(indVar)
                
                num      = repmat(a.data(:,indVar,:),[1,a.numberOfVariables,1]);
                obj.data = a.data./num;
                
            else
                
                dat  = dates(a);
                indD = find(strcmp(b,dat),1);
                if ~isempty(indD)
                   
                    num      = repmat(a.data(indD,:,:),[a.numberOfObservations,1,1]);
                    obj.data = a.data./num;
                    
                else
                    error([mfilename ':: The string provided (''' b ''') is neither a date or a variable of the object'])
                end
                
            end
            
        else
            error([mfilename ':: Undefined function ''mrdivide'' for input arguments of type ''' class(a) '''  and multi-row ''' class(b) '''.'])
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
                obj.data = a.data./num;
            end
            
        else
            error([mfilename ':: The nb_date object provided (''' b.toString() ''') is of wrong frequency.'])
        end    

    else
        error([mfilename ':: Undefined function ''mrdivide'' for input arguments of type ''' class(a) ''' and ''' class(b) '''. '...
                             '(Remeber that the / operator is the matrix division and not elementwise division (./))'])
    end
    
    if obj.isUpdateable()
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@mrdivide,{b});
        
    end

end
