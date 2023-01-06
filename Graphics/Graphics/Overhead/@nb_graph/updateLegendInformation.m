function updateLegendInformation(obj)
% Syntax:
%
% enableUIComponents(obj,~,~)
%
% Description:
%
% Update the legend edit properties of object used when
% loaded to the nb_graphGUI class
%
% This function will update the properties:
%
% - legendText
% - legends (will be set to empty)
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    if ~isempty(obj.legendText)
        return
    end

    % Secure that legAuto is set to 'on'
    %--------------------------------------------------------------
    if strcmpi(obj.legAuto,'off')
        obj.legAuto = 'on';
    end

    % Initialize
    %--------------------------------------------------------------
    legVars = {};

    % Get the information on the patches plotted
    %--------------------------------------------------------------
    if ~isempty(obj.patch) && ~(strcmpi(obj.plotType,'radar') || strcmpi(obj.plotType,'pie'))
        patchNames = obj.patch(1:4:end);
        legVars    = [legVars,patchNames];
    end

    % Get the information on the variables plotted
    %--------------------------------------------------------------
    legVars = [legVars,getPlottedVariables(obj,true)];

    % Get the information on the fake legend plotted
    %--------------------------------------------------------------
    if ~isempty(obj.fakeLegend)
        fakeNames  = obj.fakeLegend(1:2:end);
        legVars    = [legVars,fakeNames];
    end 

    % Secure that the legends property of the  object is 
    % of correct length
    %--------------------------------------------------------------
    sizeLV = size(legVars,2);
    leg    = obj.legends;
    if isempty(leg)
        leg = legVars;
    else
        sizeL  = size(leg,2);
        if sizeL < sizeLV
            leg = [leg,repmat({''},1,sizeLV - sizeL)];
        end
    end

    % Assign the information to the GUI
    %--------------------------------------------------------------
    legEditT = cell(1,sizeLV*2);
    for ii = 1:sizeLV
        legEditT{ii*2 - 1} = legVars{ii};
        legEditT{ii*2}     = leg{ii};
    end

    % The GUI uses the legendText property instead of the legends
    % property
    obj.legendText = legEditT;
    obj.legends    = {};

end
