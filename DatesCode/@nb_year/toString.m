function date = toString(obj,format,first)
% Syntax:
% 
% date = toString(obj,format,first)
%
% Description:
%   
% Transform the nb_year object to a string representing the date. 
% 
% Input:
% 
% - obj    : An object of class nb_year
%
% - format : > 'xls'     : 'dd.mm.yyyy'
%            > 'vintage' : 'yyyymmdd'
%            > otherwise : 'yyyy'
%
% - first  : Give 1 if you want the date string to represent the 
%            first day of the year ('01.01.yyyy'), otherwise last 
%            day of the year will be given ('31.12.yyyy'). Only 
%            when format is given as 'xls'
% 
% Output:
% 
% - date   : A string on the wanted format 
% 
% Examples:
%
% obj  = nb_year(2012);
% date = obj.toString();        % Will give '2012'
% date = obj.toString('xls');   % Will give '31.12.2012'
% date = obj.toString('xls',1); % Will give '01.01.2012'
% 
% Written by Kenneth S. Paulsen
        
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

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
                yearS = int2str(obj.year);
                date  = strcat('01.01.', yearS);
            else
                yearS = int2str(obj.year);
                date  = strcat('31.12.', yearS);
            end
            
        case 'vintage'

            if first == 1
                yearS = int2str(obj.year);
                date  = strcat(yearS,'0101');
            else
                yearS = int2str(obj.year);
                date  = strcat(yearS,'1231');
            end    

        otherwise

            date = int2str(obj.year);

    end

end
