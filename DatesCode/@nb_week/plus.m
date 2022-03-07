function out = plus(obj,aObj)
% Syntax:
% 
% out = plus(obj,aObj)
%
% Description:
%  
% Makes it possible to add a given number of weeks to an nb_week
% and receive a nb_week object which represents the week the given
% numbers of weeks ahead 
%         
% Input:
%         
% - obj  : A nx1 double or a nx1 nb_week object.
%  
% - aObj : A nx1 double or a nx1 nb_week object.
%               
% Output:
%         
% - out : A nx1 nb_week object with the given number of years ahead
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

    if isnumeric(obj) && isa(aObj,'nb_week')
        y    = obj;
        obj  = aObj;
        aObj = y;
    end
    
    if ~isnumeric(aObj)
        error([mfilename ':: It is not possible to add an object of class ' class(aObj) ' with an object of class nb_week.'])
    end

    if numel(obj) > 1

        s    = size(obj);
        aObj = aObj(:);
        obj  = obj(:);
        st   = prod(s);
        if numel(aObj) == 1
            
            out(st,1) = nb_week;
            for ii = 1:st
                out(ii) = plus(obj(ii),aObj);
            end
            out = reshape(out,s);
            
        else
            
            if st ~= ast
                error([mfilename ':: Dimensions of the two inputs must agree.'])
            end
            out(st,1) = nb_week;
            for ii = 1:st
                out(ii) = plus(obj(ii),aObj(ii));
            end
            out = reshape(out,s);
            
        end
        return
    end

    periods         = round(aObj);
    s               = size(periods);
    periods         = periods(:);
    periodsNotS     = periods;
    periods         = sort(periods);
    nPer            = length(periods);
    out(nPer,1)     = nb_week;
    last            = 0;
    week            = obj.week;
    year            = obj.year;
    for ii = 1:nPer
        [week,year] = nb_week.localplus(week,year,periods(ii) - last);
        out(ii,1)   = nb_week(week,year,obj.dayOfWeek);
        last        = periods(ii);
    end
    [~,loc] = ismember(periods,periodsNotS);
    out     = reshape(out(loc),s);
    
end

