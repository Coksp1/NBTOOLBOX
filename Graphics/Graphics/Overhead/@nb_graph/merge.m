function out = merge(obj,varargin)
% Syntax:
%
% out = merge(obj,varargin)
%
% Description:
%
% Default: This tries to merge the data of plotter objects that uses the  
% graphSubPlots, or the graphInfoStruct.
%
% Caution: All objects must share the exact same variables!
% 
% 'graph' is given: In this case it will try to merge the data
% of all nb_graph objects, and concatenate the variableToPlot property. 
% If the property variableToPlot is empty for all objects, it will 
% also be returned as empty, i.e. plot all series in the data.
%
% Caution : Merging of any of the other properties then DB and 
%           variableToPlot is not done!
%
% Input:
% 
% - obj      : An object of class nb_graph, which includes the classes 
%              nb_graph_ts, nb_graph_cs and nb_graph_data.
%
% Optional input:
%
% - 'graph'  : Give this input to merge the graphs in the way that is
%              described in the description of this method.
%
% - varargin : Each input must be an object of class nb_graph. 
% 
% Output:
% 
% - out      : An object of class nb_graph.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    [isGraph,varargin] = nb_parseOneOptionalSingle('graph',false,true,varargin{:});
    if isGraph
        
        vars    = cell(1,1 + length(varargin));
        vars{1} = obj.variablesToPlot;
        DB      = obj.DB;
        cl      = class(obj);
        for ii = 1:length(varargin)
            if ~isa(varargin{ii},cl)
                error([mfilename ':: The optional input nr ' int2str(ii) ' must be of class ' cl '.'])
            end
            DB         = merge(DB,varargin{ii}.DB);
            vars{ii+1} = varargin{ii}.variablesToPlot;
        end
        
        ind = cellfun(@isempty,vars);
        if all(ind)
            vars = {};
        else
           loc = find(ind);
           for ii = loc
               vars{ii} = varargin{ii}.DB.variables;
           end
           vars = unique(nb_nestedCell2Cell(vars));
        end
        
    else
    
        DB      = obj.DB;
        legs    = cell(1,length(varargin)+1);
        legs{1} = obj.legends;
        lineS   = obj.lineStyles;
        marks   = obj.markers;
        colors  = obj.colors;
        cl      = class(obj);
        for ii = 1:length(varargin)
            if ~isa(varargin{ii},cl)
                error([mfilename ':: The optional input nr ' int2str(ii) ' must be of class ' cl '.'])
            end
            if DB.numberOfVariables ~= varargin{ii}.DB.numberOfVariables
                error([mfilename ':: The merged ' cl ' objects must have exactly the same variables!'])
            end
            ind = ismember(DB.variables,varargin{ii}.DB.variables);
            if any(~ind)
                error([mfilename ':: The merged ' cl ' objects must have exactly the same variables!'])
            end
            DB         = addPages(DB,varargin{ii}.DB);
            legs{ii+1} = varargin{ii}.legends;
            lineS      = [lineS, varargin{ii}.lineStyles]; %#ok<AGROW>
            marks      = [marks, varargin{ii}.markers]; %#ok<AGROW>
            colors     = [colors, varargin{ii}.colors]; %#ok<AGROW>
        end
        
    end
    
    % Make a copy of the object and set data
    out = copy(obj);
    setSpecial(out,'DB',DB);

    if isGraph
        set(out,'variablesToPlot',vars);
    else
        set(out,'colors',colors,'lineStyles',lineS,'markers',marks);
        ind = cellfun(@(x)isempty(x),legs);
        if ~any(ind)
            set(out,'legends',[legs{:}]);
        end  
    end
    
end
