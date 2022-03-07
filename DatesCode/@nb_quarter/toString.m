function date = toString(obj,format,first)
% Syntax:
% 
% date = toString(obj,format,first)
%
% Description:
%   
% Transforms the nb_quarter object to a string representing the 
% date. It will be given in the format: 'yyyyQq'.
% 
% Input:
% 
% - obj    : An object of class nb_quarter
%
% - format : > 'xls'                        : 'dd.mm.yyyy'
%            > 'nbnorsk' or 'nbnorwegian'   : 'q.kv.yy'
%            > 'nbengelsk' or 'nbenglish'   : 'yyyyQq'
%            > 'pprnorsk' or 'mprnorwegian' : 'q.kv. yyyy'
%            > 'pprengelsk' or 'mprenglish' : 'yyyy Qq'
%            > 'default'                    : 'yyyyQq'
%            > 'vintage'                    : 'yyyymmdd'
% 
% - first  : If you want the 'xls' type date string to begin with 
%            first or last day of the month. Will only have an 
%            effect when format is set to 'xls'. Default is 1 
%            (first day). Give any other number to get the last 
%            day. 
% 
% Output:
% 
% - date : A string with the date on the wanted format
% 
% Examples:
%
% obj  = nb_quarter(1,2012);
% date = obj.toString();             % Will give '2012Q1'
% date = obj.toString('xls');        % Will give '01.01.2012'
% date = obj.toString('xls',0);      % Will give '31.03.2012'
% date = obj.toString('nbnorsk');    % Will give '1.kv.12'
% date = obj.toString('nbengelsk');  % Will give '2012Q1'
% date = obj.toString('pprnorsk');   % Will give '1.kv. 2012'
% date = obj.toString('pprengelsk'); % Will give '2012 Q1' 
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        first = 1;
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

                month = obj.quarter*3 - 2;
                yearS = int2str(obj.year);
                if month < 10
                    date = strcat('01.0', int2str(month), '.', yearS);
                else
                    date = strcat('01.', int2str(month), '.', yearS);
                end

            else

                month = obj.quarter*3;
                switch month
                    case {3,12}
                        day = '31';
                    case {6,9}
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
            
            if first == 1

                month = obj.quarter*3 - 2;
                yearS = int2str(obj.year);
                if month < 10
                    date = strcat(yearS,'0', int2str(month), '01');
                else
                    date = strcat(yearS, int2str(month), '01');
                end

            else

                month = obj.quarter*3;
                switch month
                    case {3,12}
                        day = '31';
                    case {6,9}
                        day = '30';
                end
                yearS = int2str(obj.year);
                if month < 10
                    date = strcat(yearS,'0',int2str(month),day);
                else
                    date = strcat(yearS,int2str(month),day);
                end

            end

        case {'nbnorsk','nbnorwegian'}

            freqSign = '.kv.';
            yearS    = int2str(obj.year);
            date     = strcat(int2str(obj.quarter),freqSign,yearS(:,3:4)); 

        case {'pprnorsk','mprnorwegian'}

            freqSign = '. kv. ';
            yearS    = int2str(obj.year);
            date     = [int2str(obj.quarter),freqSign,yearS]; 

        case {'pprengelsk','mprenglish'}

            freqSign = ' Q';
            yearS    = int2str(obj.year);
            date     = strcat(yearS, freqSign, int2str(obj.quarter));

        otherwise

            date = [int2str(obj.year) 'Q' int2str(obj.quarter)];

    end


end
