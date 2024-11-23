function date = toString(obj,format,first) 
% Syntax:
% 
% date = toString(obj,format,first)
%
% Description:
%   
% Transform the nb_day object to a string representing the date. 
% 
% Input:
% 
% - obj    : An object of class nb_day
% 
% - format : 
%
%   > 'xls'                        : 'dd.mm.yyyy'
%   > 'pprnorsk' or 'mprnorwegian' : 'Uke w(w) yyyy'
%   > 'pprengelsk' or 'mprenglish' : 'Week w(w) yyyy'
%   > 'default' (otherwise)        : 'yyyyWw(w)'
%   > 'vintage'                    : 'yyyymmdd'
% 
% - extra  :
%
%        > 'xls': 
%
%        Give 1 if you want the date string to represent the 
%        first day of the week, otherwise last day of the week
%        will be given. Only when format is given as 'xls'. Default
%        is 0 when 'xls'.
% 
%        > 'pprnorsk', 'mprnorwegian', 'pprengelsk', 'mprenglish' :
% 
%        Give 0 if you want the week text in lowercase only. 
%        Default is 1, i.e. that the week text starts with an uppercase. 
%
% Output:
% 
% - date   : A string with the date on the wanted format
% 
% Examples:
%
% obj  = nb_week(1,2012);
% date = obj.toString();               % Will give '2012W1'
% date = obj.toString('xls');          % Will give '08.01.2012'
% date = obj.toString('xls',1);        % Will give '02.01.2012'
% date = obj.toString('nbnorsk');      % Will give '2012W1'
% date = obj.toString('nbengelsk');    % Will give '2012W1'
% date = obj.toString('pprnorsk');     % Will give 'Uke 1 2012'
% date = obj.toString('pprnorsk',0);   % Will give 'uke 1 2012'
% date = obj.toString('pprengelsk');   % Will give 'Week 1 2012'
% date = obj.toString('pprengelsk',0); % Will give 'week 1 2012'
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if nargin < 3
        first = [];
        if nargin < 2
            format = 'default';
        end
    end
    
    if length(obj) == 0  %#ok<ISMT>
        date = '';
        return
    end
    
    if numel(obj) > 1
        [s1,s2,s3] = size(obj);
        obj        = obj(:);
        date       = cell(s1*s2*s3,1);
        for ii = 1:s1*s2*s3
            date{ii} = toString(obj(ii),format,first);
        end
        date = reshape(date,[s1,s2,s3]);
        return
    end

    switch lower(format)

        case 'xls'

            if isempty(first)
                first = 0;
            end
            
            date = nb_week.getXLSDate(obj.week,obj.dayOfWeek,obj.year,first);
            date = date{1};
            
        case 'vintage'

            if isempty(first)
                first = 0;
            end
            
            date = nb_week.getXLSDate(obj.week,obj.dayOfWeek,obj.year,first);
            date = date{1}; 
            date = [date(7:10),date(4:5),date(1:2)];

        case {'pprnorsk','mprnorwegian'}  

            if isempty(first)
                first = 1;
            end
            
            if first
                date = ['Uke ' int2str(obj.week) ' ' int2str(obj.year)];
            else
                date = ['uke ' int2str(obj.week) ' ' int2str(obj.year)];
            end
            
        case {'pprengelsk','mprenglish'}    

            if isempty(first)
                first = 1;
            end
            
            if first
                date = ['Week ' int2str(obj.week) ' ' int2str(obj.year)];
            else
                date = ['week ' int2str(obj.week) ' ' int2str(obj.year)];
            end

        otherwise

            date = [int2str(obj.year) 'W' int2str(obj.week)];

    end

end
