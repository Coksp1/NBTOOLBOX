function addAnnotation(obj)
% Syntax:
%
% addLegend(obj)
%
% Description:
% 
% Add annotation to the axes
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if ~isempty(obj.listeners)
        delete(obj.listeners);
        obj.listeners = [];
    end

    if ~isempty(obj.annotation)

        if isa(obj.annotation,'nb_annotation')
           ann = {obj.annotation};  
        else
           ann = obj.annotation;
        end

        ind = true(1,length(ann));
        for jj = 1:length(ann)

            temp = ann{jj};
            if isa(temp,'nb_annotation')

                if isvalid(temp)

                    % Assign parent to plot it
                    if isa(temp,'nb_strategyInterval')

                        % Set the fontUnits to be the same as for the
                        % object itself
                        set(temp,'fontUnits',     obj.fontUnits,...
                                 'fontName',      obj.fontName,...
                                 'normalized',    obj.normalized,...
                                 'grapher',       obj);

                    elseif isa(temp,'nb_barAnnotation')

                        % Set the fontUnits to be the same as for the
                        % object itself
                        set(temp,'fontUnits',     obj.fontUnits,...
                                 'fontName',      obj.fontName,...
                                 'normalized',    obj.normalized,...
                                 'language',      obj.language,...
                                 'parent',        obj.axesHandle);         

                    elseif isa(temp,'nb_textAnnotation')

                        if isa(temp,'nb_textArrow') || isa(temp,'nb_textBox')

                            % Interpret the string property
                            oldString = temp.string;
                            if ~isempty(obj.lookUpMatrix)
                                newString = nb_graph.findVariableName(obj,oldString);
                            else
                                newString = oldString;
                            end

                            % Interpret the local variables syntax
                            if ~isempty(obj.localVariables)
                                newString = nb_localVariables(obj.localVariables,newString);
                            end
                            newString = nb_localFunction(obj,newString);

                            % Set the fontUnits to be the same as for the
                            % object itself
                            set(temp,'fontUnits',     obj.fontUnits,...
                                     'fontName',      obj.fontName,...
                                     'normalized',    obj.normalized,...
                                     'parent',        obj.axesHandle,...
                                     'string',        newString,...
                                     'copyOption',    true);

                            % Reset to old string
                            temp.string = oldString;

                        elseif isa(temp,'nb_colorbar')
                            
                            % Set the fontSize and fontUnits to be the 
                            % same as for the axes
                            set(temp,'fontName',      obj.fontName,...
                                     'language',      obj.language,...
                                     'normalized',    obj.normalized,...
                                     'parent',        obj.axesHandle,...
                                     'copyOption',    true);
                            
                        else

                            % Set the fontUnits to be the same as for the
                            % object itself
                            set(temp,'fontUnits',     obj.fontUnits,...
                                     'fontName',      obj.fontName,...
                                     'normalized',    obj.normalized,...
                                     'parent',        obj.axesHandle,...
                                     'copyOption',    true);

                        end 

                    elseif isa(temp,'nb_plotLabels')

                        [formatCells,formatColumns,formatRows] = updateLabelIndices(obj,temp);

                        % Set the fontUnits to be the same as for the
                        % object itself
                        set(temp,'fontUnits',     obj.fontUnits,...
                                 'fontName',      obj.fontName,...
                                 'formatCells',   formatCells,...
                                 'formatColumns', formatColumns,...
                                 'formatRows',    formatRows,...
                                 'language',      obj.language,...
                                 'normalized',    obj.normalized,...
                                 'parent',        obj.axesHandle);

                    else
                        set(temp,'parent',        obj.axesHandle,...
                                 'copyOption',    true);
                    end
                    
                    if isa(temp,'nb_movableAnnotation')
                        listener      = addlistener(temp,'annotationMoved',@obj.notifyUpdatedGraph);
                        obj.listeners = [obj.listeners,listener];
                    end
                    listener      = addlistener(temp,'annotationEdited',@obj.notifyUpdatedGraph);
                    obj.listeners = [obj.listeners,listener];

                else
                    ind(jj) = false;
                end

            else
                error([mfilename ':: If the annotation property is set to a cell it should only contain nb_annotation objects. This is not the case for element ' int2str(jj) '.']);
            end

            % Remove the invalid annotation objects
            obj.annotation = ann(ind);

        end

    end

end
