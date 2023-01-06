function obj = appendRecursive(obj,app,dat)
% Syntax:
%
% obj = appendRecursive(obj,app,dat)
%
% Description:
%
% Append data from app by adding new pages to obj.
% 
% Caution link to the data source will be broken.
%
% Input:
% 
% - obj : A single paged nb_ts object.
%
% - app : Ab object of class nb_data, nb_cs or double.
%
% - dat : The dates where the data from app should start. Must match the
%         number of pages of app. As a cellstr.
% 
% Output:
% 
% - obj : An object of class nb_ts.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if isnumeric(app)
        app = double(app);
        if size(app,2) ~= obj.numberOfDatasets
            error([mfilename ':: The second dimension of app does not match the number of variables of obj.'])
        end
    else
        [test,loc] = ismember(app.variables,obj.variables);
        if any(~test)
            error([mfilename ':: Some of the variables in app are not in obj; ' app.variables(~test)])
        end
        test2 = ismember(obj.variables,app.variables);
        if any(~test2)
            error([mfilename ':: Some of the variables in obj are not in app; ' obj.variables(~test2)])
        end
        app = app.data(:,loc,:);
    end
    pages = length(dat);
    if pages ~= size(app,3)
        error([mfilename ':: The dat input must have the same number of elements as app has pages.'])
    end
    
    dates = obj.dates();
    indD  = nan(1,pages);
    for ii = 1:pages
        indT = find(strcmpi(dat{ii},dates)); 
        if isempty(indT)
            indD(ii) = length(dates) + 1;
        else
            indD(ii) = indT;
        end
    end
    
    nSteps  = size(app,1);
    oldData = obj.data;
    nData   = nan(max(indD) + nSteps,obj.numberOfVariables,pages);
    for ii = 1:pages
       nData(1:indD(ii)-1,:,ii)                 = oldData(1:indD(ii)-1,:,1);  
       nData(indD(ii):indD(ii)+(nSteps-1),:,ii) = app(:,:,ii);
    end   
    obj = nb_ts(nData,dat(:)',obj.startDate,obj.variables);
    
end
