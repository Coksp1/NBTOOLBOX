function displayCallback(gui,~,~)
% Syntax:
%
% displayCallback(gui,hObject,event)
%
% Description:
%
% Part of DAG. Display loaded distribution in nb_distributionGUI.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    nb_distributionGUI([],gui.loaded,'editable',false);

end
