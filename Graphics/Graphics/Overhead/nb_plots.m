function plotter = nb_plots(structure,varargin)
% Syntax:
% 
% nb_plots(structure,varargin)
% plotter = nb_plots(structure,varargin)
% 
% Description:
% 
% Plots a structure of nb_ts objects.
% 
% This function plots each variable of each nb_ts objects in 
% seperate plots. If the nb_ts objects have more datasets (pages) 
% it will plot these against eachother.
% 
% This function can be utitlized to plot impulse response functions 
% returned by the nb_irf function.
% 
% Input:
% 
% - structure : A structure of nb_ts objects.
% 
% Optional input (...,'propertyName',propertyValue,...):
% 
% - varargin : - See the optional input to the set method of the 
%                nb_graph_ts class.
%
%              - 'gui'          : Give 1 if the one figure with
%                                 menu to select the graphs is 
%                                 wanted, else 0. Default is 0.
%                                
%                                 Caution: The saveName property
%                                         will be disabled.
%
%              - 'translate'    :
%
%                   A cellstr array with how to translate the given
%                   variables. I.e. {{'modelName1','translation1'},...}
%
%              - 'parent'       : Parent given to the 
%                                 nb_graphInfoStructGUI class when
%                                 'gui' is set to 1. Default is []. 
% 
% Output:
%
% - plotter : A nb_graph_ts object. Use the graphInfoStruct method to
%             produce graphs.
% 
% - If nargout is 0:
%
%   Graphs of each variable of each nb_ts objects in seperate plots 
%   on the screen. If the nb_ts objects have more datasets (pages) it 
%   will plot these against eachother.
% 
% Examples:
% 
% If you provide the 'saveName' and the 'pdfBook' options all 
% the plotted variables will be saved in one pdf file.
%  
% nb_plots(structure,'saveName','test','pdfBook',1);
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    [translate,varargin]       = nb_parseOneOptional('translate',{},varargin{:});
    [parent,varargin]          = nb_parseOneOptional('parent',[],varargin{:});
    [gui,varargin]             = nb_parseOneOptional('gui',0,varargin{:});
    [variablesToPlot,varargin] = nb_parseOneOptional('variablesToPlot',0,varargin{:});
    
    % Collect all of the fields of the input structure to an nb_ts
    % object with as many pages as the nb_ts objects stored as the
    % different fields.
    %--------------------------------------------------------------
    fields = fieldnames(structure);
    data   = nb_ts();
    for ii = 1:length(fields)
        
        % We append the variables names with the fieldname to make
        % it possible to merge the dataset with the others
        temp           = structure.(fields{ii});
        temp.variables = strcat(temp.variables,'_',fields{ii});
        data           = data.merge(temp);
        
    end

    % Translate variables
    %--------------------------------------------------------------
    if isempty(variablesToPlot)
        vars = structure.(fields{1}).variables;
    else
        vars = variablesToPlot;
    end
    vars           = vars(:);
    translatedVars = vars;
    for ii = 1:length(translate)
        trans = translate{ii};
        if ~iscell(trans)
            error([mfilename ':: The input given to the ''translate'' input must be a nested cell. I.e. {{''modelName1'',''translation1''},...}'])
        end
        translatedVars = strrep(translatedVars,trans{1},trans{2});
    end
    
    % Get the subPlotSize
    %--------------------------------------------------------------
    subPlotSize = [2,2];
    loc         = find(strcmpi('subPlotSize',varargin),1,'last');
    if ~isempty(loc)
        subPlotSize = varargin{loc + 1};
    end
    
    % Create the GraphStruct input
    %--------------------------------------------------------------
    numPerStruct = subPlotSize(1)*subPlotSize(2);
    numStruct    = ceil(size(vars,1)/numPerStruct);
    
    GraphStruct = struct();
    for ii = 1:size(fields,1)
        
        varsTemp = strcat(vars,'_',fields{ii});
        start    = 1;
        for jj = 1:numStruct
            
            % Construct the cell
            try
                tempVars   = varsTemp(start:numPerStruct*jj);
                tempTitles = translatedVars(start:numPerStruct*jj);
            catch %#ok<CTCH>
                tempVars   = varsTemp(start:end);
                tempTitles = translatedVars(start:end);
                tempSize   = size(tempVars,1);
                extra      = numPerStruct - tempSize;
                extra      = repmat({''},extra,1);
                tempVars   = [tempVars;extra]; %#ok
                tempTitles = [tempTitles;extra]; %#ok
            end
            
            % Add the title option
            inputs = cell(numPerStruct,1);
            for ll = 1:numPerStruct
                inputs{ll}   = ['title', tempTitles(ll)];
            end
            
            % Construct the field
            info = [tempVars,inputs];
            GraphStruct.([fields{ii},int2str(jj)]) = info;
            
            start = numPerStruct*jj + 1;
            
        end
         
    end
    
    % Graph 
    %--------------------------------------------------------------
    plotter = nb_graph_ts(data);
    if ~isempty(varargin)
        plotter.set(varargin{:});
    end
    plotter.set('GraphStruct',GraphStruct);
    
    if nargout < 1
        if gui
            nb_graphInfoStructGUI(plotter,parent);
        else
            graphInfoStruct(plotter);
        end
    end

end
