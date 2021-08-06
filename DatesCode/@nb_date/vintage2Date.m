function date = vintage2Date(vintage,freq)
% Syntax:
%
% date = nb_date.vintage2Date(vintage,freq)
%
% Description:
% 
% This method converts a vintage date into a nb_date object with the wanted
% frequency. You can also convert a cellstring containing multiple vintage
% dates.
% 
% Input:
% 
% - vintage : Either the vintage date that you want to convert, or a
%             cellstring containing the vintage dates you want to convert. 
% - freq    : The wanted frequency. Your options are 1, 4, 12 or 365.
% 
% Output:
% 
% - date    : A 1xNumberOfVintages vector containing nb_date object(s).
%
% Examples:
%
% f = '20110622' 
% t = nb_date.vintage2Date(f,4)
%
% OR
%
% f = {'20110622','20111019','20120314'} |
% t = nb_date.vintage2Date(f,4) 
%
% Written by Tobias Ingebrigtsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if iscellstr(vintage)
        switch freq
            case 1
                func = @nb_year;
            case 2
                func = @nb_semiAnnual;
            case 4
                func = @nb_quarter;
            case 12
                func = @nb_month;
            case 52
                func = @nb_week;
            case 365 
                func = @nb_day;
            otherwise
                error('The frequency you have chosen is not supported. Your options are 1, 4, 12, 52 or 365')
        end
        date(size(vintage,1),size(vintage,2)) = func();
        for ii = 1:length(vintage)
            date(ii) = nb_date.vintage2Date(vintage{ii},freq);
        end
        return
    end

    vintaget = char(vintage);
    year     = str2double(vintaget(1:4));
    month    = str2double(vintaget(5:6));
    day      = str2double(vintaget(7:8));    
    datet    = nb_day(day,month,year);    
    date     = datet.convert(freq);
      
end
