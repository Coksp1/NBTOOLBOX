function data = nb_cell2obj(cellMatrix,excel,sorted)
% Syntax:
%
% data = nb_cell2obj(cellMatrix)
% 
% Description:
%
% This is a function tries to transform an cell matrix to an 
% nb_data, nb_ts or nb_cs object.
%
% Input:
%
% - cellMatrix : A cell matrix. Must have size(1) > 1 and 
%                size(2) > 1
%
% - excel      : true or false. Default is false.
%
% - sorted     : true or false. Default is false.
%
% Formats:
% 
% - Timeseries : 
% 
%    {'dates',       'Var1', 'Var2';
%    '30.06.2012',     3,    4;
%    '30.09.2012',     5,   6}
% 
% - Cross sectional data :
%
%    {'types', 'Var1',  'Var2';
%    'var',      1,     4;
%    'std',      1,     2}
%
% - Dimensionless (Indicated by having 'obs'/'observations' in the the  
%   element {1,1} of the cell matrix)
%
%    {'obs',    'Var1',  'Var2';
%    1,         1,     4;
%    2,         1,     2}
%
%
% - Business days / timeseries with missing observations (Indicated by 
%   having 'bd'/'businessdays'/'md'/'missingdates' in the the element 
%   {1,1} of the cell matrix)
%
%    {'md',    'Var1',  'Var2';
%    1,         1,     4;
%    2,         1,     2}
%
% - excel : If the cell comes from a excel spreadsheet, sometimes the data
%           needs to be stripped.
%
% Output:
%
% - data    : An object of class nb_data, nb_ts or nb_cs
%
% See also:
% nb_ts, nb_cs, nb_data
%
% Written by Kenneth S. Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if nargin < 3
        sorted = true;
        if nargin < 2
            excel = 0;
        end
    end

    if isempty(cellMatrix)
        data = nb_ts;
        return
    end
    
    if size(cellMatrix,1) < 2
        error([mfilename ':: The cellMatrix input must have more than 1 row.'])
    end
    
    if size(cellMatrix,2) < 2
        error([mfilename ':: The cellMatrix input must have more than 1 column.'])
    end
       
    % Remove rows storing comments
    firstColumn        = cellMatrix(1:end,1);
    isNum              = cellfun(@(x)isnumeric(x),firstColumn);
    firstColumn(isNum) = {''};
    ind1               = cellfun(@(x)nb_contains(x,'comment','ignoreCase',true),firstColumn);
    ind2               = cellfun(@(x)nb_contains(x,'Class[size]','ignoreCase',true),firstColumn);
    cellMatrix         = cellMatrix(~(ind1|ind2),:);
    
    % Get types/dates/obs
    %--------------------------------------------------------------
    firstCol           = cellMatrix(2:end,1);
    numDates           = cellfun(@isnumeric,firstCol);
    firstCol(numDates) = cellfun(@num2str,firstCol(numDates),'UniformOutput',false);
    
    % Get the data 
    %--------------------------------------------------------------
    data = cellMatrix(2:end,2:end);
    try
       data = cell2mat(data);
    catch %#ok<CTCH>
        try
            [dim1,dim2] = size(data);
            data        = data(:);
            ind         = cellfun('isclass',data,'double');
            data(~ind)  = {nan};
            data        = reshape(data,dim1,dim2);
            data        = cell2mat(data);
        catch %#ok<CTCH>
            error('The provided matrix cannot be converted to a nb_data, nb_bd, nb_ts or nb_cs object. The cell is not on the correct format.')
        end
    end
    
    % Get the variables
    %--------------------------------------------------------------
    variablesTemp = cellMatrix(1,2:end);
    if excel % Correct for a excel bug
        isNaN         = isnan(data);
        ind2          = all(isNaN,1);
        data          = data(:,~ind2);
        variablesTemp = variablesTemp(~ind2);
    end
    ind                = cellfun(@isnumeric,variablesTemp);
    variablesTemp(ind) = cellfun(@num2str,variablesTemp(ind),'UniformOutput',false);
    emptyVariables     = ~(strcmp('',variablesTemp) | strcmp('NaN',variablesTemp));
    variables          = variablesTemp(emptyVariables); % Remove the '' variable names. I.e. variables without names.  
    indicies           = find(emptyVariables);
    
    % Remove the data of the empty variables
    data = data(:,indicies); %#ok<FNDSB>
    
    % Find out if it is dimensionless data, timeseries data, businessday data
    % or crossSectional data
    %==============================================================
    A1 = cellMatrix{1,1};
    if strcmpi(A1,'observations') || strcmpi(A1,'observation') || strcmpi(A1,'obs')
        [data, variables, startObs] = nb_data.interpretXlsOutput(data,variables,firstCol);
        type = 'dimensionless';
    elseif any(strcmpi(A1,{'bd','businessdays','md','missingdates'}))
        [data,variables,startDate,locations,indicator] = nb_bd.interpretXlsOutput(data,variables,firstCol);
        type  = 'businessdays'; 
    else
        type = '';
    end
    
    if isempty(type)
        try
            [data,variables,startDate] = nb_ts.interpretXlsOutput(data,variables,firstCol);
            type = 'timeseries';
        catch  %#ok<CTCH>
            [data, variables, types] = nb_cs.interpretXlsOutput(data,variables,firstCol');
            type  = 'cross_sectional';
        end
    end

    %==========================================================================
    % Initialize data objects
    %==========================================================================
    switch type

        case 'timeseries'
            try
                data = nb_ts(data,'',startDate,variables,sorted);  
            catch Err
                error([mfilename ':: Unsupported cell format. MATLAB error :: ' Err.message])
            end
            
        case 'cross_sectional'
            try
                data = nb_cs(data,'',types,variables,sorted);
            catch Err
                error([mfilename ':: Unsupported cell format. MATLAB error :: ' Err.message])
            end
            
        case 'dimensionless'
            try
                data = nb_data(data,'',startObs,variables,sorted);  
            catch Err
                error([mfilename ':: Unsupported cell format. MATLAB error :: ' Err.message])
            end
            
        case 'businessdays'
            try
                data = nb_bd(data,'',startDate,variables,locations,indicator,sorted);  
            catch Err
                error([mfilename ':: Unsupported cell format. MATLAB error :: ' Err.message])
            end            

    end

end

