function [s,c] = getMethodCalls(obj)
% Syntax:
%
% [s,c] = getMethodCalls(obj)
%
% Description:
%
% Get all method calls as a cell matrix. The object needs to be updatable
% to get a list of methods called on the object.
% 
% Input:
% 
% - obj : An object of class nb_ts, nb_cs or nb_data
% 
% Output:
%
% - s   : List of sources, as a cellstr. Will return {''} if the object is 
%         not updatable.
% 
% - c   : A cell matrix with a table of the method called on the object 
%         and its input. Will return {''} if the object is not updatable.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~obj.updateable 
        s = {''};
        c = {''};
        return
    end

    % Get the stored links of the object
    links       = obj.links;
    
    % Get the information for the different sources
    nSources    = size(links.subLinks,2);
    s           = cell(1,nSources);
    nOperations = zeros(1,nSources);
    nInputs     = zeros(1,nSources);
    nInputsAll  = cell(1,nSources);
    operations  = cell(1,nSources);
    for ii = 1:nSources
       
        subL = links.subLinks(1,ii);
        if ischar(subL.source)
            s{ii} = subL.source;
        elseif iscell(subL.source) && numel(subL.source)
            s{ii} = subL.source{1,1};
        else
            s{ii} = ['private' int2str(ii)]; 
        end
        op              = subL.operations;
        nOperations(ii) = size(op,2);
        nInputsTemp     = zeros(1,nOperations(ii));
        for jj = 1:nOperations(ii)
            nInputsTemp(jj) = size(op{jj}{2},2);
        end
        if isempty(nInputsTemp)
            nInputs(ii) = 0;
        else
            nInputs(ii) = max(nInputsTemp);
        end
        nInputsAll{ii} = nInputsTemp;
        operations{ii} = op;
        
    end
    
    % Create the final output as a table
    columns = max(nInputs) + 1;
    rows    = max(nOperations);
    c       = repmat({'Not editable'},[rows,columns,nSources]);
    for ii = 1:nSources
        
        for jj = 1:nOperations(ii)
            
            op = operations{ii}{jj};
            if ~ischar(op{1})
                op{1} = func2str(op{1});
            end
            c{jj,1,ii} = op{1}; % Name of method
            nInp       = nInputsAll{ii}(jj);
            if nInp ~= 0
                c(jj,2:1+nInp,ii) = cellfun(@nb_input2String,op{2},'UniformOutput',false); % Inputs to the method
            end
            
        end
        
    end
    
end
