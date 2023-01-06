function inputs = getSolvedPrologue(obj,inputs,YT,proY,iter)
% Syntax:
%
% inputs = nb_perfectForesight.getSolvedPrologue(obj,inputs,YT,proY,iter)
%
% Description:
%
% Part of the perfect forseight solver package nb_perfectForesight.
% 
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    nPro = sum(obj.parser.block.proEndo);
    if nPro == 0
        inputs.prologueSolution = nan(inputs.periodsU(iter),0);
        return
    end
    YP  = YT(proY);
    pro = obj.parser.endogenous(obj.parser.block.proEndo);
    
    % Get inital values of prologue variables
    initVal = zeros(nPro,1);
    for ii = 1:length(pro)
        if isfield(inputs.initVal,pro{ii})
            initVal(ii) = inputs.initVal.(pro{ii});
        end
    end
    
    % Get end values of prologue variables
    endVal = zeros(nPro,1);
    for ii = 1:length(pro)
        if isfield(inputs.endVal,pro{ii})
            endVal(ii) = inputs.endVal.(pro{ii});
        end
    end
    YP = [initVal;YP;endVal];
    YP = reshape(YP',[nPro,size(YP,1)/nPro])';
    YP = [nb_mlag(YP,1),YP,nb_mlead(YP,1)];
    YP = YP(2:end-1,:);
    inputs.prologueSolution = YP;
    
end
