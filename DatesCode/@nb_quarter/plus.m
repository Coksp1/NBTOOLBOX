function out = plus(obj,aObj)
% Syntax:
% 
% out = plus(obj,aObj)
%
% Description:
%  
% Makes it possible to add a given number of quarters to an 
% nb_quarter and receive a nb_quarter object which represents the 
% quarter the given numbers of quarters ahead 
%         
% Input:
%         
% - obj  : A nx1 double or a nx1 nb_quarter object
%  
% - aObj : A nx1 double or a nx1 nb_quarter object
%         
%         
% Output:
%         
% - out : A nx1 nb_quarter object with the given number of years ahead
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

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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
            out(st,1) = nb_quarter;
            for ii = 1:st
                out(ii) = plus(obj(ii),aObj);
            end
            out = reshape(out,s);
            
        else
            
            if st ~= ast
                error([mfilename ':: Dimensions of the two inputs must agree.'])
            end
            out(st,1) = nb_quarter;
            for ii = 1:st
                out(ii) = plus(obj(ii),aObj(ii));
            end
            out = reshape(out,s);
            
        end
        return
    end

    if isnumeric(obj) && isa(aObj,'nb_quarter')
        y    = obj;
        obj  = aObj;
        aObj = y;
    end

    if ~isnumeric(aObj)
        error([mfilename ':: It is not possible to add an object of class ' class(aObj) ' with an object of class nb_quarter.'])
    end
    aObj = round(aObj);
    
    yearsdiff     = floor((aObj - 1 + obj.quarter)/4);
    obj.year      = obj.year + yearsdiff;
    obj.quarter   = obj.quarter + aObj - yearsdiff*4;
    obj.quarterNr = obj.quarterNr + aObj;

    yearNr = obj.year - obj.baseYear;
    if yearNr/4 - floor(yearNr/4) == 0
        obj.leapYear = 1;
    else
        obj.leapYear = 0;
    end
    out = obj;

end
