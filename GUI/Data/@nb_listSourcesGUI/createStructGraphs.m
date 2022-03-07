function sourceStruct = createStructGraphs(obj,names)
% Syntax:
%
% sourceStruct = createStructGraphs(obj,names)
%
% Description:
%
% Part of DAG.
% 
% Written by Per Bjarne Bye

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    s = struct();
    
    % Graph level
    for ii = 1:length(names)

        graph     = names{ii};
        s.(graph) = {};
        
        if isa(obj.graphs.(graph),'nb_graph_adv')
            numPlotters = size(obj.graphs.(graph).plotter,2);
            adv         = true;
        else
            numPlotters = 1;
            adv         = false;
        end
        
        for jj = 1:numPlotters
            
            if checkEmptyLinks(obj,adv,graph,jj)
                
                subLinks = getSubLinks(obj,adv,graph,jj);
                
                % Keeping track of number of sources
                ctr = 0;

                % Struct array level
                for kk = 1:length(subLinks)

                    singleStruct = subLinks(kk);
                    sources      = singleStruct.source;

                    if iscell(sources)
                        sourceCount = length(sources);
                    else
                        % Char (Excel files)
                        sourceCount = 1;
                    end

                    % Individual struct level 
                    for ll = 1:sourceCount

                        ctr = ctr + 1;

                        fieldName                        = ['Source_',num2str(ctr)];
                        s.(graph).(fieldName)            = {};
                        sourceType                       = singleStruct.sourceType;
                        s.(graph).(fieldName).sourceType = sourceType;

                        if strcmpi(sourceType,'xls')
                            s.(graph).(fieldName).source    = singleStruct.source;
                            s.(graph).(fieldName).sheet     = singleStruct.sheet;
                            s.(graph).(fieldName).startDate = getStringDate(singleStruct.startDate);
                            s.(graph).(fieldName).endDate   = getStringDate(singleStruct.endDate);
                            s.(graph).(fieldName).variables = singleStruct.variables;
                        elseif strcmpi(sourceType,'db')
                            s.(graph).(fieldName).source    = singleStruct.source{ll};
                            s.(graph).(fieldName).vintage   = singleStruct.vintage;
                            s.(graph).(fieldName).startDate = getStringDate(singleStruct.startDate);
                            s.(graph).(fieldName).endDate   = getStringDate(singleStruct.endDate);
                            s.(graph).(fieldName).variables = singleStruct.variables{ll};
                        elseif contains(sourceType,'private')
                            s.(graph).(fieldName).variables = singleStruct.variables;
                        else
                            s.(graph).(fieldName).source    = 'No information available';

                        end


                    end
                end

            else % This can happen if the dataset is created generated in DAG
               s.(graph).Source_1.source     = 'No information available';
               s.(graph).Source_1.sourceType = 'nan';

            end
            
        end
            
    end
    sourceStruct = s;

end

function bool = checkEmptyLinks(obj,adv,graph,jj)
% Check if links struct is empty. adv is needed to see if we need to check
% in plotter or not.

    if adv
        bool = isempty(obj.graphs.(graph).plotter(jj).DB.links);
    else
        bool = isempty(obj.graphs.(graph).DB.links);
    end
    bool = ~bool;
end

function SL = getSubLinks(obj,adv,graph,jj)
% Return subLinks struct. adv is needed to see if we need to go into
% plotter or not to retrieve information.

    if adv
        SL = obj.graphs.(graph).plotter(jj).DB.links.subLinks;
    else
        SL = obj.graphs.(graph).DB.links.subLinks;
    end
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
