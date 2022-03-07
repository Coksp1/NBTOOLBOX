function date = toString(obj,format,extra)
% Syntax:
%
% date = toString(obj,format,extra)
%
% Description:
%
% Transform the nb_semiAnnual object to a string representing the 
% date. It will be given in the format: 'yyyyQq'.
% 
% Input:
% 
% - obj : AN object of class nb_semiAnnual
% 
% Optional input:
% 
% - format : > 'xls'                        : 'dd.mm.yyyy'
%            > 'nbnorsk' or 'nbnorwegian'   : 'mmm. yy'
%            > 'nbengelsk' or 'nbenglish'   : 'Mmm. yy'
%            > 'pprnorsk' or 'mprnorwegian' : 'Monthtext yyyy'
%            > 'pprengelsk' or 'mprenglish' : 'Monthtext yyyy'
%            > 'default'                    : 'yyyySs'
%            > 'vintage'                    : 'yyyymmdd'
% 
% - extra  : 
%
%        > 'xls': 
%
%        Give 1 if you want the date string to represent the 
%        first day of the half year ('01.01.yyyy'), otherwise last 
%        day of the half year will be given ('31.06.yyyy'). Only 
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
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

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

                month = obj.halfYear*6 - 5;
                yearS = int2str(obj.year);
                date  = strcat('01.0', int2str(month), '.', yearS);

            else

                month = obj.halfYear*6;
                switch month
                    case 6
                        day = '31';
                    case 12
                        day = '30';
                end
                yearS = int2str(obj.year);
                if month < 10
                    date = strcat(day, '.0', int2str(month), '.', yearS);
                else
                    date = strcat(day, '.' , int2str(month), '.', yearS);
                end

            end
            
        case 'vintage'

            if extra == 1

                month = obj.halfYear*6 - 5;
                yearS = int2str(obj.year);
                date  = strcat(yearS,'0', int2str(month), '01');

            else

                month = obj.halfYear*6;
                switch month
                    case 6
                        day = '31';
                    case 12
                        day = '30';
                end
                yearS = int2str(obj.year);
                if month < 10
                    date = strcat(yearS,'0', int2str(month), day);
                else
                    date = strcat(yearS, int2str(month), day);
                end
                
            end    

        case {'nbengelsk','nbenglish'}

            switch obj.halfYear
                case 1
                    monthS = 'Jan-';
                case 2
                    monthS = 'Jul-';
            end

            yearS  = int2str(obj.year);
            yearS  = yearS(:,3:4);       
            date   = strcat(monthS,yearS);

        case {'nbnorsk','nbnorwegian'}

            switch obj.halfYear
                case 1
                    monthS = 'jan. ';
                case 2
                    monthS = 'jul. ';
            end

            yearS  = int2str(obj.year);
            yearS  = yearS(:,3:4);
            date   = strcat(monthS,yearS); 

        case {'pprnorsk','mprnorwegian'}

            switch obj.halfYear
                case 1
                    monthS = 'Januar ';
                case 2
                    monthS = 'July ';
            end

            if extra == 0

                monthS = lower(monthS);

            end

            yearS  = int2str(obj.year);     
            date   = [monthS,yearS];

        case {'pprengelsk','mprenglish'}

            switch obj.halfYear
                case 1
                    monthS = 'January ';
                case 2
                    monthS = 'July ';
            end

            if extra == 0

                monthS = lower(monthS);

            end

            yearS  = int2str(obj.year);      
            date   = [monthS,yearS];    

        otherwise

            date = [int2str(obj.year) 'S' int2str(obj.halfYear)];

    end

end
