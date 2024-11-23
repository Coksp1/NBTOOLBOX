function resize(gui)
% Syntax:
%
% resize(gui)
%
% Description:
%
% Part of DAG.
% 
% Written by Henrik Halvorsen Hortemo and Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

   position = nb_getInUnits(gui.figureHandle, 'Position', 'points');
   
   width = position(3);
   height = position(4);
   
   % In points units
   margin       = 7.5;
   momentsWidth = 150;
   footerHeight = 90;
   heigth_2     = (height - 3*margin - footerHeight)/2;
   
   % Panel sizes and positions
   graph        = [margin, 1*margin + footerHeight, width - 3*margin - momentsWidth, height - 2*margin - footerHeight];
   moments      = [width - margin - momentsWidth, margin*2 + footerHeight + heigth_2, momentsWidth, heigth_2];
   domain       = [width - margin - momentsWidth, margin + footerHeight, momentsWidth, heigth_2];
   distribution = [margin, margin, width - 3*margin - momentsWidth, footerHeight];
   %domain       = [2*margin + distribution(3), margin, distribution(3), footerHeight];
   button       = [width - 2*margin - momentsWidth, 0, momentsWidth + 2*margin, footerHeight + margin];
   
   % Sizes must be positive
   graph(graph <= 0) = 0.1;
   moments(moments <= 0) = 0.1;
   distribution(distribution <= 0) = 0.1;
   domain(domain <= 0) = 0.1;
   button(button <= 0) = 0.1;
   
   nb_setInUnits(gui.graphPanel, 'Position', graph, 'points');   
   nb_setInUnits(gui.momentsPanel, 'Position', moments, 'points');   
   nb_setInUnits(gui.distributionPanel, 'Position', distribution, 'points');
   nb_setInUnits(gui.domainPanel, 'Position', domain, 'points');   
   nb_setInUnits(gui.buttonPanel, 'Position', button, 'points');
   
   % Update legend!
   leg = get(gui.plotter,'legendObject');
   if ~isempty(leg)
        update(leg);
   end
   
end
