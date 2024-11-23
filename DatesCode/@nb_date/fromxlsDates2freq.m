function frequency = fromxlsDates2freq(dates) 
% Syntax:
%
% frequency = nb_date.fromxlsDates2freq(dates)
%
% Description:
% 
% A static method of the nb_date class.
%
% Try to find out the date frequency of the excel dates. I.e. dates 
% on the format 'dd.mm.yyyy'.
% 
% Input:
% 
% - Dates     : A cellstr with at least two dates on the date 
%               format 'dd.mm.yyyy'.
% 
% Output:
% 
% - frequency : The frequency of the input dates given as an 
%               integer. 
%
%               > Daily         : 365
%
%               > Weekly        : 52
%
%               > Monthly       : 12
%
%               > Quarterly     : 4
%
%               > Semiannually  : 2
%
%               > Yearly        : 1  
% 
% Examples:
%
% dates     = {'01.01.2012';'02.01.2012','03.01.2012'};
% frequency = nb_date.fromxlsDates2freq(dates)
% 
% The output will in this example be:
%
% - frequency : 1
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    % Find out if the date is on the format 'dd.mm.yyyy'
    exp = regexp(strtrim(dates{1}),'[0-9]{2,2}\.[0-9]{2,2}\.[0-9]{4,4}','match');
    if isempty(exp)
        error([mfilename ':: The given date format is not supported by this function (''' dates{1} ''').'])
    else
        % Find the frequency of the date format
        diff  = str2double(dates{2}(4:5)) - str2double(dates{1}(4:5));
        diff2 = str2double(dates{2}(1:2)) - str2double(dates{1}(1:2));

        switch diff

            case 3
                
                frequency = 4;

            case -9

                frequency = 4;

            case 1

                if diff2 >= -3
                    frequency = 12;
                elseif diff2 > - 27 
                    frequency = 52;
                else
                    frequency = 365;
                end

            case 0

                if diff2 == 0
                    frequency = 1;
                elseif diff2 == 7
                    frequency = 52;
                else
                    frequency = 365;
                end

            case -11

                if diff2 >= 0
                    frequency = 12;
                elseif diff2 > -27
                    frequency = 52;
                else
                    frequency = 365;
                end

            case 6

                frequency = 2;    

            case - 6

                frequency = 2;

            otherwise

                error([mfilename ':: The given date format is not supported by this function (''' dates{1} ':' dates{2} ''').'])

        end

    end

end
