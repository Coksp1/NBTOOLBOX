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
%   > 'pprnorsk' or 'mprnorwegian' : 'd(d). monthtext yyyy'
%   > 'pprengelsk' or 'mprenglish' : 'd(d) Monthtext yyyy'
%   > 'default' (otherwise)        : 'yyyyMm(m)Dd(d)'
%   > 'vintage'                    : 'yyyymmdd'
% 
% - first  : 
%
%        'xls' :
% 
%        If 1 is given, the first day of the current month will be 
%        returned. Default is not. 
% 
% Output:
% 
% - date   : A string with the date on the wanted format
% 
% Examples:
%
% obj  = nb_day(1,1,2012);
% date = obj.toString();             % Will give '2012M1D1'
% date = obj.toString('xls');        % Will give '01.01.2012'
% date = obj.toString('xls',0);      % Will give '01.01.2012'
% date = obj.toString('nbnorsk');    % Will give '2012M1D1'
% date = obj.toString('nbengelsk');  % Will give '2012M1D1'
% date = obj.toString('pprnorsk');   % Will give '1. januar 2012'
% date = obj.toString('pprnorsk',0); % Will give '1. januar 2012'
% date = obj.toString('pprengelsk'); % Will give '1 January 2012'
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        first = 0;
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

            if first == 1

                monthS = obj.month;
                yearS  = int2str(obj.year);
                if monthS < 10
                    date = strcat('01.0', int2str(monthS), '.', yearS);
                else
                    date = strcat('01.', int2str(monthS), '.', yearS);
                end

            else

                yearS = int2str(obj.year);
                if obj.month < 10
                    if obj.day < 10
                        date = strcat('0', int2str(obj.day), '.0', int2str(obj.month), '.', yearS);
                    else
                        date = strcat(     int2str(obj.day), '.0', int2str(obj.month), '.', yearS);
                    end
                else
                    if obj.day < 10
                        date = strcat('0', int2str(obj.day), '.', int2str(obj.month), '.', yearS);
                    else
                        date = strcat(     int2str(obj.day), '.', int2str(obj.month), '.', yearS);
                    end
                end

            end
            
        case 'vintage'
            
            yearS = int2str(obj.year);
            if obj.month < 10
                if obj.day < 10
                    date = strcat(yearS, '0', int2str(obj.month), '0', int2str(obj.day));
                else
                    date = strcat(yearS, '0', int2str(obj.month), int2str(obj.day));
                end
            else
                if obj.day < 10
                    date = strcat(yearS, int2str(obj.month), '0', int2str(obj.day));
                else
                    date = strcat(yearS, int2str(obj.month),int2str(obj.day));
                end
            end

        case 'fame'

            switch obj.month
                case 1
                    monthString = 'jan';
                case 2
                    monthString = 'feb';
                case 3
                    monthString = 'mar';
                case 4
                    monthString = 'apr';
                case 5
                    monthString = 'may';
                case 6
                    monthString = 'jun';
                case 7
                    monthString = 'jul';
                case 8
                    monthString = 'aug';
                case 9
                    monthString = 'sep';
                case 10
                    monthString = 'oct';
                case 11
                    monthString = 'nov';
                case 12
                    monthString = 'dec';
            end

            date = [int2str(obj.day) monthString int2str(obj.year)];

        case {'pprnorsk','mprnorwegian'}  

            switch obj.month
                case 1
                    monthString = '. januar ';
                case 2
                    monthString = '. februar ';
                case 3
                    monthString = '. mars ';
                case 4
                    monthString = '. april ';
                case 5
                    monthString = '. mai ';
                case 6
                    monthString = '. juni ';
                case 7
                    monthString = '. juli ';
                case 8
                    monthString = '. august ';
                case 9
                    monthString = '. september ';
                case 10
                    monthString = '. oktober ';
                case 11
                    monthString = '. november ';
                case 12
                    monthString = '. desember ';
            end

            date = [int2str(obj.day) monthString int2str(obj.year)];

        case {'pprengelsk','mprenglish'}    

            switch obj.month
                case 1
                    monthString = ' January ';
                case 2
                    monthString = ' February ';
                case 3
                    monthString = ' March ';
                case 4
                    monthString = ' April ';
                case 5
                    monthString = ' May ';
                case 6
                    monthString = ' June ';
                case 7
                    monthString = ' July ';
                case 8
                    monthString = ' August ';
                case 9
                    monthString = ' September ';
                case 10
                    monthString = ' October ';
                case 11
                    monthString = ' November ';
                case 12
                    monthString = ' December ';
            end

            date = [int2str(obj.day) monthString int2str(obj.year)];

        otherwise

            date = [int2str(obj.year) 'M' int2str(obj.month) 'D' int2str(obj.day)];

    end

end
