function out = plus(obj,aObj)
% Syntax:
% 
% out = plus(obj,aObj)
%
% Description:
%  
% Makes it possible to add a given number of days to an nb_day
% and receive a nb_day object which represents the day the given
% numbers of days ahead 
%         
% Input:
%         
% - obj  : A nx1 double or a nx1 nb_day object
%  
% - aObj : A nx1 double or a nx1 nb_day object
%               
% Output:
%         
% - out : A nx1 nb_day object with the given number of years ahead
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
            out(st,1) = nb_day;
            for ii = 1:st
                out(ii) = plus(obj(ii),aObj);
            end
            out = reshape(out,s);
            
        else
            
            if st ~= ast
                error([mfilename ':: Dimensions of the two inputs must agree.'])
            end
            out(st,1) = nb_day;
            for ii = 1:st
                out(ii) = plus(obj(ii),aObj(ii));
            end
            out = reshape(out,s);
            
        end
        return
    end

    if isnumeric(obj) && isa(aObj,'nb_day')
        y    = obj;
        obj  = aObj;
        aObj = y;
    end

    if ~isnumeric(aObj)
        error([mfilename ':: It is not possible to add an object of class ' class(aObj) ' with an object of class nb_day.'])
    end
    aObj = round(aObj);
    
    daysAhead = aObj;
    m         = obj.month;
    y         = obj.year;
    d         = obj.day;

    if daysAhead > 0

        for ii = 1:daysAhead

            d = d + 1;
            switch m
                case {1,3,5,7,8,10}
                    if d == 32
                        d = 1;
                        m = m + 1;
                    end
                case {4,6,9,11}
                    if d == 31
                        d = 1;
                        m = m + 1;
                    end
                case 2
                    switch nb_year(y).leapYear
                        case 1
                            if d == 30 
                                d = 1;
                                m = 3;
                            end
                        case 0
                            if d == 29 
                                d = 1;
                                m = 3;
                            end
                    end
                case 12
                    if d == 32
                        d = 1;
                        m = 1;
                        y = y  + 1;
                    end
            end
        end

        out = nb_day(d,m,y);

    elseif daysAhead < 0

        for ii = 1:abs(daysAhead)

            d = d - 1;
            if d == 0
                switch m
                    case {2,4,6,8,9,11}
                        d = 31;
                        m = m - 1;
                    case {5,7,10,12}
                        d = 30;
                        m = m - 1;
                    case 3
                        switch nb_year(y).leapYear
                            case 1
                                d = 29;
                                m = 2;
                            case 0
                                d = 28;
                                m = 2;
                        end
                    case 1
                        d = 31;
                        m = 12;
                        y = y  - 1;
                end
            end
        end

        out = nb_day(d,m,y);
        
    else
        out = obj;
    end
    out.dayOfWeek = obj.dayOfWeek;

end

