function update(obj,addWaitBar)
% Syntax:
% 
% obj = update(obj)
% 
% Description:
% 
% Update the data source of the nb_graph_package object. I.e update 
% the data source of the graphs property.
%
% See the update method of the nb_cs or nb_ts class for more on how 
% to make the data of the graphs updateable.
% 
% Input:
% 
% - obj        : An object of class nb_graph_package
% 
% - addWaitBar : Add wait bar if 1, otherwise no. Default is not.
%
% Output:
% 
% - obj      : An object of class nb_graph_package, where the data  
%              is updated. 
%     
% Examples:
%
% obj.update();
% 
% Written by Kenneth S. Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 2
        addWaitBar = 0;
    end
    
    if isempty(obj.graphs)
        return
    end

    notUpdated = {};
    messages   = {};
    if addWaitBar
        
        numberOfGraphs = size(obj.graphs,2);
        
        % Create waiting bar window
        h      = nb_waitbar([],'Update Graph Package',numberOfGraphs);
        h.text = ['Updating ' obj.identifiers{1} '...']; 
        for ii = 1:numberOfGraphs
            
            % Check for Cancel button press
            if h.canceling == 1
                break
            end
            
            try
                obj.graphs{ii} = update(obj.graphs{ii},'off');
            catch Err
                notUpdated = [notUpdated, obj.identifiers{ii}];  %#ok<AGROW>
                messages   = [messages,   Err.message];  %#ok<AGROW>
            end
            
            if ii == numberOfGraphs
                break
            end
            
            % Report current estimate in the waitbar's message field
            h.status = ii;
            h.text   = ['Updating ' obj.identifiers{ii + 1} '...'];
            
        end
        
        % Delete the waitbar.
        delete(h)       
        
    else
    
        for ii = 1:size(obj.graphs,2)

            try
                obj.graphs{ii} = update(obj.graphs{ii},'off');
            catch Err
                notUpdated = [notUpdated, obj.identifiers{ii}];  %#ok<AGROW>
                messages   = [messages,   Err.message];  %#ok<AGROW>
            end

        end
        
    end
    
    % Provide the user with information on which object wasn't 
    % updated
    if ~isempty(notUpdated)
        
        message = ['The following graphs could not be updated; ' notUpdated{1}  ' (' messages{1} ') '];
        for ii = 2:size(notUpdated,2) - 1 
            message = [message ', ' notUpdated{ii} ' (' messages{ii} ') '];  %#ok<AGROW>
        end
        if size(notUpdated,2) > 1
            message = [message ' and ' notUpdated{end} ' (' messages{end} ') ' '.'];
        else
            message = [message '.'];
        end
        
        try
            nb_errorWindow(message);
        catch %#ok<CTCH>
            errordlg(message,'Error'); 
        end
        
    end

end
