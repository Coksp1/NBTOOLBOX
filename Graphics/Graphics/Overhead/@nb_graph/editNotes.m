function editNotes(obj,~,~)
% Syntax:
%
% editNotes(obj,~,~)
%
% Description:
% 
% Edit notes callback function. Used by DAG
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if isempty(obj.DB)
        nb_errorWindow('Cannot edit notes, because the data of the graph is empty.')
        return
    end

    nb_editNotes(obj);

end
