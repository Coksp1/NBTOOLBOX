function obj = cleanRealTime(obj)
% Syntax:
%
% obj = cleanRealTime(obj)
%
% Description:
%
% Secure that the real time data has new observations for each 
% period. You have to options 'delete' or 'fill'.
% 
% Input:
% 
% - obj    : An nb_ts object returend by the 
%            nb_fetchRealTimeFromFame function.
%
% Output:
% 
% - obj    : An object of class nb_ts.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isUpdateable(obj)
        error([mfilename ':: The object does not represent real-time data.'])
    end
    sublinks = obj.links.subLinks;

    if numel(sublinks) > 1
        error([mfilename ':: The object does not represent a single real-time data source.'])
    end
    
    if ~strcmpi(sublinks.sourceType,'realdb')
        error([mfilename ':: The object does not represent real-time data.'])
    end
    
    if length(obj.variables) > 1 
        error([mfilename ':: This method only handle a nb_ts object with one variable.'])
    end
    
    d   = obj.data;
    ind = nan(obj.numberOfDatasets,obj.numberOfVariables);
    n   = isnan(d);
    for ii = 1:obj.numberOfVariables
        for jj = 1:obj.numberOfDatasets
            test = find(n(:,ii,jj),1,'first');
            if isempty(test)
                ind(jj,ii) = obj.numberOfObservations;
            else
                ind(jj,ii) = test - 1;
            end
        end
    end
    
    diffD = diff(ind);
    dind  = and(diffD == 1,2);
    start = find(~dind,1,'last') + 1;
    if ~isempty(start)
        obj.data             = obj.data(:,:,start:end);
        obj.dataNames        = obj.dataNames(start:end);
    end
    
    if obj.isUpdateable() 
        
        % Add operation to the link property, so when the object 
        % is updated the operation will be done on the updated 
        % object
        obj = obj.addOperation(@cleanRealTime);
        
    end
    
end

% diffD = diff(ind);
% dind  = and(diffD == 2,2);
% start = nan(1,size(d,2));
% for ii = 1:size(d,2)
%     fIndex = find(dind(:,ii),1,'last');
%     if isempty(fIndex)
%         error([mfilename ':: The variable ' obj.variables{:} ' does not have any vintages that only provide one (and only) one observation.'])
%     end
%     start(ii) = fIndex + 1;
% end
% comMin = max(start);
% check  = sum(diffD(comMin:end,:));
% if check
% 
% for ii = 1:obj.numberOfVariables
%     notFinished = true;
%     diffDVar    = diffD(:,ii);
%     kk          = comMin;
%     while notFinished
%         if diffDVar(kk) == 0
% 
%         else
% 
%         end
%     end
% end
% 
% diffD = diff(ind);
% dind  = and(diffD == 1,2);
% start = nan(1,size(d,2));
% for ii = 1:size(d,2)
%     start(ii) = find(~dind(:,ii),1,'last') + 1;
% end
% start = max(start);
% if ~isempty(start)
%     obj.data             = obj.data(:,:,start:end);
%     obj.dataNames        = obj.dataNames(start:end);
%     obj.numberOfDatasets = size(obj.data,3);
% end
