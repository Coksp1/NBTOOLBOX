function obj = initialize(data,nameOfDatasets,dates,variables,sorted)
% Syntax:
%
% obj = nb_bd.initialize(data,nameOfDatasets,dates,variables,sorted)
%
% Description:
%
% Initialze a nb_db object with a stripped set of dates and its matching 
% data points.
% 
% Input:
% 
% - data : A r x c x p double, logical or nb_distribution array.
% 
% - nameOfDatasets : Either a one line char or a 1 x p cellstr.
%
% - dates          : A 1 x r or r x 1 nb_date array.
%
% - variables      : A 1 x c cellstr.
%
% - sorted         : true or false. Default is true.
%
% Output:
% 
% - obj            : A nb_bd object.
%
% See also:
% nb_bd
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 5
        sorted = true;
    end

    if ~isa(dates,'nb_date')
        error([mfilename ':: The dates input must be a vector of nb_date objets.'])
    end
    dates = dates(:);
    
    if not(isnumeric(data) || islogical(data) || isa(data,'nb_distribution'))
        error([mfilename ':: The data input cannot be of class ' class(data)])
    end
    [s1,s2,s3,s4] = size(data);
    if s4 > 1
        error([mfilename ' :: data must be three-dimensional at most'])
    end
    if size(dates,1) ~= s1
        error([mfilename ':: The dates input must match the the number of rows of the data input.'])
    end
    
    if isempty(nameOfDatasets)
        nameOfDatasets = nb_appendIndexes('Database',1:s3)';
    elseif nb_isOneLineChar(nameOfDatasets)
        nameOfDataset  = nameOfDatasets;
        nameOfDatasets = cell(1,s3);
        for kk = 1:s3
            nameOfDatasets{kk} =  [nameOfDataset '(' int2str(kk) ')'];
        end
        
    elseif ~iscellstr(nameOfDatasets)
        error([mfilename ':: The nameOfDatasets input must be a cellstr vector.'])
    end
    nameOfDatasets = nb_rowVector(nameOfDatasets);
    if size(nameOfDatasets,2) ~= s3
        error([mfilename ':: The nameOfDatasets input must match the number of pages of the data input.'])
    end
    
    if nb_isOneLineChar(variables)
        variables = cellstr(variables);
    elseif ~iscellstr(variables)
        error([mfilename ':: The variables input must be a cellstr vector.'])
    end
    variables = nb_rowVector(variables);
    if size(variables,2) ~= s2
        error([mfilename ':: The variables input must match the number of columns of the data input.'])
    end
    
    if sorted 
        [variables,order] = sort(variables);
        data              = data(:,order,:);
    end
    
    index    = nan(s1,1);
    index(1) = 1;
    for ii = 2:s1
        index(ii) = (dates(ii) - dates(1)) + 1;
    end
    data          = data(:);
    isNotNaN      = ~isnan(data);
    obj           = nb_bd;
    cInd          = 1:s2*s3;
    cInd          = cInd(ones(s1,1),:);
    cInd          = cInd(:);
    index         = index(:,ones(1,s2*s3));
    index         = index(:); 
    obj.locations = sparse(index,cInd,isNotNaN);
    obj.data      = data(isNotNaN);
    obj.startDate = dates(1);
    obj.endDate   = dates(end);
    obj.frequency = obj.startDate.frequency;
    obj.variables = variables;
    obj.indicator = 1;
    obj.sorted    = sorted;
    obj.dataNames = nameOfDatasets;
    
end
