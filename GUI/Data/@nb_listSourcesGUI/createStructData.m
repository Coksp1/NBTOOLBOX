function sourceStruct = createStructData(obj,names)
% Syntax:
%
% sourceStruct = createStructData(obj,names)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    s = struct();
    
    % Dataset level
    for ii = 1:length(names)

        dataset     = names{ii};
        s.(dataset) = {};
        
        if ~isempty(obj.data.(dataset).links)
            subLinks = obj.data.(dataset).links.subLinks;
            
            % Keeping track of number of sources
            ctr = 0;
            
            % Struct array level
            for jj = 1:length(subLinks)

                singleStruct = subLinks(jj);
                sources      = singleStruct.source;

                if iscell(sources)
                    sourceCount = length(sources);
                else
                    % Char (Excel files)
                    sourceCount = 1;
                end

                % Individual struct level 
                for kk = 1:sourceCount
                    
                    ctr = ctr + 1;
                    
                    fieldName                          = ['Source_',num2str(ctr)];
                    s.(dataset).(fieldName)            = {};
                    sourceType                         = singleStruct.sourceType;
                    s.(dataset).(fieldName).sourceType = sourceType;

                    if strcmpi(sourceType,'xls')
                        s.(dataset).(fieldName).source    = singleStruct.source;
                        s.(dataset).(fieldName).sheet     = singleStruct.sheet;
                        s.(dataset).(fieldName).startDate = getStringDate(singleStruct.startDate);
                        s.(dataset).(fieldName).endDate   = getStringDate(singleStruct.endDate);
                        s.(dataset).(fieldName).variables = singleStruct.variables;
                    elseif strcmpi(sourceType,'db')
                        s.(dataset).(fieldName).source    = singleStruct.source{kk};
                        s.(dataset).(fieldName).vintage   = singleStruct.vintage;
                        s.(dataset).(fieldName).startDate = getStringDate(singleStruct.startDate);
                        s.(dataset).(fieldName).endDate   = getStringDate(singleStruct.endDate);
                        s.(dataset).(fieldName).variables = singleStruct.variables{kk};
                    elseif contains(sourceType,'private')
                        s.(dataset).(fieldName).variables = singleStruct.variables;
                    else
                        s.(dataset).(fieldName).source    = 'No information available';

                    end


                end
            end
            
        else % This can happen if the dataset is created generated in DAG
           s.(dataset).Source_1.source     = 'No information available';
           s.(dataset).Source_1.sourceType = 'nan';
        
        end
            
            
    end
    sourceStruct = s;

end

function sDate = getStringDate(date)
% Checks if date is a nb_date obect. If so convert to string. Return 
% string representation.

    if isa(date,'nb_date')
        if isempty(date)
            date = '';
        else
            date = toString(date);
        end
    end
    sDate = date;
    
end
