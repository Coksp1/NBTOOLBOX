function date = toString(obj,format,extra)
% Syntax:
%
% date = toString(obj,format,extra)
%
% Description:
%
% Transform the nb_month object to a string representing the date.
% It will be given in the format: 'yyyyMm(m)'.
% 
% Input:
% 
% - obj : The object itself
% 
% Optional input:
% 
% - format : > 'xls'                        : 'dd.mm.yyyy'
%            > 'nbnorsk' or 'nbnorwegian'   : 'mmm. yy'
%            > 'nbengelsk' or 'nbenglish'   : 'Mmm-yy'
%            > 'pprnorsk' or 'mprnorwegian' : 'monthtext yyyy'
%            > 'pprengelsk' or 'mprenglish' : 'Monthtext yyyy'
%            > 'default'                    : 'yyyyMm(m)'
%            > 'vintage'                    : 'yyyymmdd'
% 
% - extra  :
%
%        > 'xls': 
%
%        Give 1 if you want the date string to represent the 
%        first day of the month ('01.01.yyyy'), otherwise last 
%        day of the month will be given ('31.01.yyyy'). Only 
%        when format is given as 'xls'
% 
%        > 'pprnorsk', 'mprnorwegian', 'pprengelsk', 'mprenglish' :
% 
%        Give 0 if you want the month text in lowercase only. 
%        Default is that the month text starts with an uppercase. 
% 
% Output:
% 
% - date : A string with the date on the wanted format 
% 
% Examples:
%
% obj  = nb_month(1,2012);
% date = obj.toString();             % Will give '2012M1'
% date = obj.toString('xls');        % Will give '01.01.2012'
% date = obj.toString('xls',0);      % Will give '31.01.2012'
% date = obj.toString('nbnorsk');    % Will give 'jan. 12'
% date = obj.toString('nbengelsk');  % Will give 'Jan-12'
% date = obj.toString('pprnorsk');   % Will give 'Januar 2012'
% date = obj.toString('pprnorsk',0); % Will give 'januar 2012'
% date = obj.toString('pprengelsk'); % Will give 'January 2012'
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        extra = 1;
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
            date{ii} = toString(obj(ii),format,extra);
        end
        date = reshape(date,[s1,s2,s3]);
        return
    end

    switch lower(format)

        case 'xls'

            if extra == 1

                monthS = obj.month;
                yearS  = int2str(obj.year);
                if monthS < 10
                    date = strcat('01.0', int2str(monthS), '.', yearS);
                else
                    date = strcat('01.', int2str(monthS), '.', yearS);
                end

            else

                monthS = obj.month;
                switch monthS
                    case {1,3,5,8,10,12}
                        day = '31';
                    case {4,6,7,9,11}
                        day = '30';
                    case 2
                        if obj.leapYear
                            day = '29';
                        else
                            day = '28';
                        end
                end
                yearS = int2str(obj.year);
                if monthS < 10
                    date = strcat(day, '.0', int2str(monthS), '.', yearS);
                else
                    date = strcat(day, '.' , int2str(monthS), '.', yearS);
                end

            end
            
        case 'vintage'

            if extra == 1

                monthS = obj.month;
                yearS  = int2str(obj.year);
                if monthS < 10
                    date = strcat(yearS,'0', int2str(monthS),'01');
                else
                    date = strcat(yearS, int2str(monthS),'01');
                end

            else

                monthS = obj.month;
                switch monthS
                    case {1,3,5,8,10,12}
                        day = '31';
                    case {4,6,7,9,11}
                        day = '30';
                    case 2
                        if obj.leapYear
                            day = '29';
                        else
                            day = '28';
                        end
                end
                yearS = int2str(obj.year);
                if monthS < 10
                    date = strcat(yearS,'0', int2str(monthS),day);
                else
                    date = strcat(yearS, int2str(monthS),day);
                end

            end    

        case {'nbengelsk','nbenglish'}

            switch obj.month
                case 1
                    monthS = 'Jan-';
                case 2
                    monthS = 'Feb-';
                case 3
                    monthS = 'Mar-';
                case 4
                    monthS = 'Apr-';
                case 5
                    monthS = 'May-';
                case 6
                    monthS = 'Jun-';
                case 7
                    monthS = 'Jul-';
                case 8
                    monthS = 'Aug-';
                case 9
                    monthS = 'Sep-';
                case 10
                    monthS = 'Oct-';
                case 11
                    monthS = 'Nov-';
                case 12
                    monthS = 'Dec-';
            end

            yearS  = int2str(obj.year);
            yearS  = yearS(:,3:4);       
            date   = strcat(monthS,yearS);

        case {'nbnorsk','nbnorwegian'}

            switch obj.month
                case 1
                    monthS = 'jan. ';
                case 2
                    monthS = 'feb. ';
                case 3
                    monthS = 'mar. ';
                case 4
                    monthS = 'apr. ';
                case 5
                    monthS = 'mai. ';
                case 6
                    monthS = 'jun. ';
                case 7
                    monthS = 'jul. ';
                case 8
                    monthS = 'aug. ';
                case 9
                    monthS = 'sep. ';
                case 10
                    monthS = 'okt. ';
                case 11
                    monthS = 'nov. ';
                case 12
                    monthS = 'des. ';
            end

            yearS  = int2str(obj.year);
            yearS  = yearS(:,3:4);
            date   = strcat(monthS,yearS); 

        case {'pprnorsk','mprnorwegian'}

            switch obj.month
                case 1
                    monthS = 'Januar ';
                case 2
                    monthS = 'Februar ';
                case 3
                    monthS = 'Mars ';
                case 4
                    monthS = 'April ';
                case 5
                    monthS = 'Mai ';
                case 6
                    monthS = 'Juni ';
                case 7
                    monthS = 'Juli ';
                case 8
                    monthS = 'August ';
                case 9
                    monthS = 'September ';
                case 10
                    monthS = 'Oktober ';
                case 11
                    monthS = 'November ';
                case 12
                    monthS = 'Desember ';
            end

            if extra == 0

                monthS = lower(monthS);

            end

            yearS  = int2str(obj.year);     
            date   = [monthS,yearS];

        case {'pprengelsk','mprenglish'}

            switch obj.month
                case 1
                    monthS = 'January ';
                case 2
                    monthS = 'February ';
                case 3
                    monthS = 'March ';
                case 4
                    monthS = 'April ';
                case 5
                    monthS = 'May ';
                case 6
                    monthS = 'June ';
                case 7
                    monthS = 'July ';
                case 8
                    monthS = 'August ';
                case 9
                    monthS = 'September ';
                case 10
                    monthS = 'October ';
                case 11
                    monthS = 'November ';
                case 12
                    monthS = 'December ';
            end

            if extra == 0

                monthS = lower(monthS);

            end

            yearS  = int2str(obj.year);      
            date   = [monthS,yearS];   

        otherwise

            date = [int2str(obj.year) 'M' int2str(obj.month)];

    end

end
