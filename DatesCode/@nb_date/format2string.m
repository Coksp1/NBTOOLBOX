function date = format2string(obj,format,language,first)
% Syntax:
%
% date = nb_date.format2string(obj,format)
% date = nb_date.format2string(obj,format,language,first)
%
% Description:
%
% Get date at a given format.
% 
% Input:
% 
% - obj      : An object of a subclass of nb_date.
%
% - format   : A string with the format. A combination of the following 
%              patterns:
%
%              - d : Day of the date. Examples:
%                    > 'dd'  : '01', '10'
%                    > 'd'   : '1' , '0'
%                    > 'd(d)': '1' , '10'
%              - w : Week of date. Same options as for d.
%              - m : Month of date. Same options as for d.
%              - q : Quarter of date. Examples:
%                    > 'q'   : '1' , '4'
%              - h : Half year of date. Same options as for h.
%              - y : Year of date.
%                    > 'yyyy' : '2016'
%                    > 'yyy'  : '016'
%                    > 'yy'   : '16'
%                    < 'y'    : '6'
%
%               Caution: To use the actual letter of the patterns use \
%                        in front of the letter. E.g. '\y'.
%
%               Extra (see also the language option):
%
%               - 'Monthtext'   : Month of date as full text. Starting with
%                                 upper case.
%               - 'monthtext'   : Month of date as full text. Starting with
%                                 upper case.
%
%               - 'Quartertext' : > 'norwegian' : '. kv.'
%                                 > 'english'   : 'Q'
%
%               - 'Weektext'    : > 'norwegian' : 'Uke'
%                                 > 'english'   : 'Week'
%
% - language : 'norwegian' or 'english' (default). Only important for the
%              'monthtext' or 'Monthtext' patterns.
%
% - first    : Give false to return the latest period when converted to a 
%              higher frequency. Default is true, i.e. first period.
%
% Output:
% 
% - date   : A string of the date on the wanted format.
%
% Examples:
%
% d    = nb_day.today();
% date = nb_date.format2string(d,'dd.mm.yyyy');
% date = nb_date.format2string(d,'d(d).m(m).yyyy');
% date = nb_date.format2string(d,'d(d) Monthtext yyyy');  
% date = nb_date.format2string(d,'d(d). monthtext yyyy','norwegian');
%
% m    = nb_month.today();
% date = nb_date.format2string(m,'dd.mm.yyyy');
% date = nb_date.format2string(m,'Monthtext yyyy');            
% date = nb_date.format2string(m,'Monthtext yyyy','norwegian');
%
% q    = nb_quarter.today();
% date = nb_date.format2string(m,'dd.mm.yyyy');
% date = nb_date.format2string(m,'qQ yyyy');  
% date = nb_date.format2string(m,'q. kv. yyyy');    
%
% y    = nb_year.today();
% date = nb_date.format2string(y,'dd.mm.yyyy');
% date = nb_date.format2string(y,'yyyy');
% date = nb_date.format2string(y,'\year yyyy');
%
% See also:
% toString
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 4
        first = true;
        if nargin < 3
            language = 'english';
        end
    end

    if ~isprop(obj,'day')
        dObj = getDay(obj,first);
        day  = dObj.day;
    else
        day = obj.day;
    end 
    d  = int2str(day);
    if size(d,2) == 2
        d1 = d(1);
        d2 = d(2);
    else
        d1 = '0';
        d2 = d(1);
    end

    if ~isprop(obj,'week')
        if obj.frequency > 52
            wObj = getWeek(obj);
        else
            wObj = getWeek(obj,first);
        end
        week = wObj.week;
    else
        week = obj.week;
    end
    w = int2str(week);
    if size(w,2) == 2
        w1 = w(1);
        w2 = w(2);
    else
        w1 = '0';
        w2 = w(1);
    end

    if ~isprop(obj,'month')
        if obj.frequency > 12
            mObj = getMonth(obj);
        else
            mObj = getMonth(obj,first);
        end
        month = mObj.month;
    else
        month = obj.month;
    end
    m = int2str(month);
    if size(m,2) == 2
        m1 = m(1);
        m2 = m(2);
    else
        m1 = '0';
        m2 = m(1);
    end
    
    if isprop(obj,'quarter')
        q = int2str(obj.quarter);
    else
        if obj.frequency > 4
            qObj = getQuarter(obj);
        else
            qObj = getQuarter(obj,first);
        end
        q = int2str(qObj.quarter);
    end

    if isprop(obj,'halfYear')
        h = int2str(obj.halfYear);
    else
        if obj.frequency > 2
            hObj = getHalfYear(obj);
        else
            hObj = getHalfYear(obj,first);
        end
        h = int2str(hObj.halfYear);
    end

    if ~isprop(obj,'year')
        yObj = getYear(obj);
        year = yObj.year;
    else
        year = obj.year;
    end
    
    y  = int2str(year);
    if size(y,2) == 2
        y1 = '0';
        y2 = '0';
        y3 = y(1);
        y4 = y(2);
    elseif size(y,2) == 3
        y1 = '0';
        y2 = y(1);
        y3 = y(2);
        y4 = y(3);
    elseif size(y,2) == 4
        y1 = y(1);
        y2 = y(2);
        y3 = y(3);
        y4 = y(4); 
    else
        y1 = '0';
        y2 = '0';
        y3 = '0';
        y4 = y(1);
    end

    % Substitute
    date = format;
    date = strrep(date,'Monthtext',getMonthText(obj,'Monthtext',language));
    date = strrep(date,'monthtext',getMonthText(obj,'monthtext',language));
    date = strrep(date,'Quartertext',getQuarterText(language));
    date = strrep(date,'Weektext',getWeekText(language));
    date = substForDate(date,'(?<!\\)d+\({0,1}d+\){0,1}','d',d1,d2);
    date = substForDate(date,'(?<!\\)w+\({0,1}w+\){0,1}','w',w1,w2);
    date = substForDate(date,'(?<!\\)m+\({0,1}m+\){0,1}','m',m1,m2);
    date = substForDate(date,'(?<!\\)q+','q',q);
    date = substForDate(date,'(?<!\\)h+','h',h);
    date = substForDate(date,'(?<!\\)y+','y',y1,y2,y3,y4);
    date = strrep(date,'\d','d');
    date = strrep(date,'\w','w');
    date = strrep(date,'\m','m');
    date = strrep(date,'\q','q');
    date = strrep(date,'\h','h');
    date = strrep(date,'\y','y');
    
end

% SUB
%==========================================================================
function monthString = getMonthText(obj,type,language)

    if ~isprop(obj,'month')
        mObj  = getMonth(obj);
        month = mObj.month;
    else
        month = obj.month;
    end

    switch language
        case {'norwegian','norsk'}
            
            switch month
                case 1
                    monthString = 'januar';
                case 2
                    monthString = 'februar';
                case 3
                    monthString = '\mars';
                case 4
                    monthString = 'april';
                case 5
                    monthString = 'mai';
                case 6
                    monthString = 'juni';
                case 7
                    monthString = 'juli';
                case 8
                    monthString = 'august';
                case 9
                    monthString = 'septe\mber';
                case 10
                    monthString = 'oktober';
                case 11
                    monthString = 'nove\mber';
                case 12
                    monthString = '\dese\mber';
            end
            
            if strcmp(type,'Monthtext')
                switch month
                    case {3,12}
                        monthString = monthString(2:end);    
                end
                monthString(1,1) = upper(monthString(1,1));
            end
            
        otherwise
            
            switch month
                case 1
                    monthString = 'Januar\y';
                case 2
                    monthString = 'Februar\y';
                case 3
                    monthString = 'March';
                case 4
                    monthString = 'April';
                case 5
                    monthString = 'May';
                case 6
                    monthString = 'June';
                case 7
                    monthString = 'July';
                case 8
                    monthString = 'August';
                case 9
                    monthString = 'Septe\mber';
                case 10
                    monthString = 'October';
                case 11
                    monthString = 'Nove\mber';
                case 12
                    monthString = 'Dece\mber';
            end
            
            if strcmp(type,'monthtext')
                monthString(1,1) = lower(monthString(1,1));
                switch month
                    case {3,12}
                        monthString = ['\' monthString];    
                end
            end
            
    end

end

function wString = getQuarterText(language)

    switch language
        case {'norwegian','norsk'}
            wString = '. kv.';
        otherwise
            wString = 'Q';
    end

end

function qString = getWeekText(language)

    switch language
        case {'norwegian','norsk'}
            qString = 'Uke';
        otherwise
            qString = 'Week';
    end

end

function date = substForDate(date,pattern,type,varargin)

    switch nargin
        
        case 5
            
            [matchC,startC] = regexp(date,pattern,'match','start');
            for ii = 1:length(matchC)

                matchT = matchC{ii};
                lenT   = length(matchT);
                ps     = strfind(matchT,'(');
                pe     = strfind(matchT,')');
                if ~isempty(ps) && ~isempty(pe)

                    startT = startC(ii);
                    if lenT == 4
                        if strcmpi(varargin{1},'0') 
                            date   = [date(1:startT-1),varargin{2},date(startT+lenT:end)];
                            startC = startC - 3;
                        else
                            date   = [date(1:startT-1),varargin{1},varargin{2},date(startT+lenT:end)];
                            startC = startC - 2;
                        end
                    else
                        error([mfilename ':: Wrong format. To many consecutive d''s in combination with (d).'])
                    end

                elseif isempty(ps) && isempty(pe)

                    startT = startC(ii);
                    if lenT == 2
                        date = [date(1:startT-1),varargin{1},varargin{2},date(startT+lenT:end)];
                    elseif lenT == 1
                        date = [date(1:startT-1),varargin{2},date(startT+lenT:end)];
                    else
                        error([mfilename ':: Wrong format. To many consecutive ' type '''s.'])
                    end

                end

            end
            
        case 4
            
            [matchC,startC] = regexp(date,pattern,'match','start');
            for ii = 1:length(matchC)

                matchT = matchC{ii};
                lenT   = length(matchT);
                startT = startC(ii);
                if lenT == 1
                    date = [date(1:startT-1),varargin{1},date(startT+lenT:end)];
                else
                    error([mfilename ':: Wrong format. To many consecutive ' type '''s.'])
                end

            end
            
        case 7
            
            [matchC,startC] = regexp(date,pattern,'match','start');
            for ii = 1:length(matchC)

                matchT = matchC{ii};
                lenT   = length(matchT);
                startT = startC(ii);
                if lenT == 1
                    date = [date(1:startT-1),varargin{4},date(startT+lenT:end)];
                elseif lenT == 2
                    date = [date(1:startT-1),varargin{3},varargin{4},date(startT+lenT:end)];
                elseif lenT == 3
                    date = [date(1:startT-1),varargin{2},varargin{3},varargin{4},date(startT+lenT:end)];
                elseif lenT == 4
                    date = [date(1:startT-1),varargin{1},varargin{2},varargin{3},varargin{4},date(startT+lenT:end)];    
                else
                    error([mfilename ':: Wrong format. To many consecutive ' type '''s.'])
                end

            end
            
    end

    

end

