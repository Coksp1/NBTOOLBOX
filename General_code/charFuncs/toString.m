function string = toString(anyObject,varargin)
% Syntax:
%
% string = toString(anyObject)
%
% Description:
%
% Converts object into a string.
% 
% Input:
% 
% - anyObject : A double, logical, nb_ts, nb_cs, nb_data or cell.
% 
% Optional inputs;
%
% - 'limit'   : Limit used for when to convert double array to short hand 
%               notation. Default is numel(x) == 20.
%
% Output:
% 
% - string    : A string
%
% See also:
% num2str, int2str, nb_cellstr2String, nb_any2String
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if iscellstr(anyObject) 
        string = nb_cellstr2String(anyObject,', ',' and ');
    elseif isnumeric(anyObject) && isscalar(anyObject)
        string = num2str(anyObject); 
    elseif isnumeric(anyObject)
        
        limit = 20;
        if nargin > 1
            limit = nb_parseOneOptional('limit',limit,varargin{:});
        end
            
        [s1,s2,s3] = size(anyObject);
        if s3 > 1 || numel(anyObject) > limit
            string = ['double<' int2str(s1) 'x' int2str(s2) 'x' int2str(s3) '>'];
            return
        end
        string = '';
        for jj = 1:s1 
            if jj == 1
                string = [string,'[', num2str(anyObject(jj,1))]; %#ok<AGROW>
            else
                string = [string,';', num2str(anyObject(jj,1))]; %#ok<AGROW>
            end
            for mm = 2:s2
                string = [string,',', num2str(anyObject(jj,mm))]; %#ok<AGROW>
            end
        end
        if ~isempty(string)
            string = [string ']'];
        end
        
    elseif islogical(anyObject) && isscalar(anyObject)
        string = log2str(anyObject);
    elseif islogical(anyObject)
        
        [s1,s2,s3] = size(anyObject);
        if s3 > 1 || numel(anyObject) > 20
            string = ['logical<' int2str(s1) 'x' int2str(s2) 'x' int2str(s3) '>'];
            return
        end
        string = '';
        for jj = 1:s1 
            if jj == 1
                string = [string,'[', log2str(anyObject(jj,1))]; %#ok<AGROW>
            else
                string = [string,';', log2str(anyObject(jj,1))]; %#ok<AGROW>
            end
            for mm = 2:s2
                string = [string,',', log2str(anyObject(jj,mm))]; %#ok<AGROW>
            end
        end
        if ~isempty(string)
            string = [string ']'];
        end
        
    elseif iscell(anyObject) && size(anyObject,1) == 1 && size(anyObject,3) == 1
        string = nb_cell2String(anyObject);
    elseif ischar(anyObject)
        string = anyObject;
    elseif isa(anyObject,'nb_ts')
        string = 'nb_ts';
    elseif isa(anyObject,'nb_cs')
        string = 'nb_cs';
    elseif isa(anyObject,'nb_data')
        string = 'nb_data';    
    else
        error([mfilename ':: Cannot convert an object of class ' class(anyObject) ' with size '...
            int2str(size(anyObject,1)) 'x' int2str(size(anyObject,2)) 'x' int2str(size(anyObject,3)) ' to a string.'])
    end

end

%==========================================================================
function str = log2str(anyObject)
    if anyObject
        str = 'true';
    else
        str = 'false';
    end
end
