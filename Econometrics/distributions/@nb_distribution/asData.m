function data = asData(obj,x,type)
% Syntax:
%
% data = asData(obj,x,type)
%
% Description:
%
% Create an nb_data object from either the PDF or CDF of the distribution
% 
% Input:
% 
% - obj  : A nb_distribution object.
%
% - x    : The values to evaluate the distribution. x must be a Nx1 double.
%
%          If not provided or empty the full domain of the distribution(s)
%          will be used
%
% - type : A string with either 'pdf' (default) or 'cdf'
% 
% Output:
% 
% - data : A nb_data object.
%
% Examples:
%
% obj = nb_distribution
% asData(obj)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        type = 'pdf';
        if nargin < 2
            x = [];
        end
    end

    obj = obj(:);
    if isempty(x)
        % The meanShift property will be corrected for in cdf and pdf 
        % methods
        start  = getStartOfDomain(obj); 
        finish = getEndOfDomain(obj);
        if finish - start > 1
            start  = floor(start);
            finish = ceil(finish);
        elseif finish - start > 0.1
            start  = floor(start*10)/10;
            finish = ceil(finish*10)/10;
        elseif finish - start > 0.01
            start  = floor(start*100)/100;
            finish = ceil(finish*100)/100;
        else
            start  = floor(start*1000)/1000;
            finish = ceil(finish*1000)/1000;
        end
        x = linspace(start, finish, 1000);
    else
        if ~isnumeric(x)
            error([mfilename ':: The x input must be numeric'])
        end
    end
  
    if size(x,2) ~= 1
        if size(x,1) ~=1
            error([mfilename ':: The x input must be a column vector.'])
        else
            x = x';
        end
    end

    switch lower(type)
        
        case 'cdf'
            
            f = cdf(obj,x);
            
        otherwise
            
            f = pdf(obj,x);
    end

    % Make a nb_data object
    vars = {obj.name};
    % nb_data requires unique variable names
    vars = enumerateDuplicates(vars);
    try
        data = nb_data([x,f],'',1,['domain',vars], false);
    catch %#ok<CTCH>
        error([mfilename ':: Cannot plot replicated distributions!'])
    end
end

function out = enumerateDuplicates(strArray)
    out = cell(0);
    for i = 1:length(strArray)
        str = strArray(i);
        count = sum(ismember(strArray(1:i), str));
        if (count > 1)
            str{1} = [str{1} '_' num2str(count)];
        end
        out = [out, str]; %#ok<AGROW>
    end
end
