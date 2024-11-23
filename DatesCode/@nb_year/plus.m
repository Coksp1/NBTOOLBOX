function out = plus(obj,aObj)
% Syntax:
% 
% out = plus(obj,aObj)
%
% Description:
%  
% Makes it possible to add a given number of years to an nb_year
% object and receive an nb_year object which represents the year 
% the given numbers of years ahead 
%         
% Input:
%         
% - obj  : An nx1 double or a nx1 nb_year object.
%  
% - aObj : An nx1 double or a nx1 nb_year object.
%         
%         
% Output:
%         
% - out : A nx1 nb_year object the given number of years ahead.
%         
% Examples:
%         
% obj = obj + 1;
%    
% same as
%
% obj = 1 + obj;
% 
% Written by Kenneth S. Paulsen
       
% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if numel(obj) > 1 || numel(aObj) > 1
        
        as   = size(aObj);
        s    = size(obj);
        aObj = aObj(:);
        obj  = obj(:);
        ast  = prod(as);
        st   = prod(s);
        if st == 1 || ast == 1
            
            if st == 1
                y    = obj;
                obj  = aObj;
                aObj = y;
                st   = ast;
                s    = as;
            end
            out(st,1) = nb_year;
            for ii = 1:st
                out(ii) = plus(obj(ii),aObj);
            end
            out = reshape(out,s);
            
        else
            
            if st ~= ast
                error([mfilename ':: Dimensions of the two inputs must agree.'])
            end
            out(st,1) = nb_year;
            for ii = 1:st
                out(ii) = plus(obj(ii),aObj(ii));
            end
            out = reshape(out,s);
            
        end
        return
    end

    if isnumeric(obj) && isa(aObj,'nb_year')
        y    = obj;
        obj  = aObj;
        aObj = y;
    end

    if ~isnumeric(aObj)
        error([mfilename ':: It is not possible to add an object of class ' class(aObj) ' with an object of class nb_year.'])
    end

    y             = obj.year + round(aObj);
    out           = nb_year(y);
    out.dayOfWeek = obj.dayOfWeek;

end
