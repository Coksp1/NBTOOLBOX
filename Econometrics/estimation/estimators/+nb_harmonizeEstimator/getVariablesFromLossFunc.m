function matches = getVariablesFromLossFunc(harmonizer)
% Syntax:
%
% matches = nb_harmonizeEstimator.getVariablesFromLossFunc(harmonizer)
%
% Description:
%
% Get the variables used in all the loss functions of the harmonizer.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2024, Kenneth Sæterhagen Paulsen

    if ~isa(harmonizer,'nb_SMARTHarmonizeLossFunc')
        error(['When the algorithm is set to ''lossFunc'' each element of ',...
            'the harmonizers option must contain one nb_SMARTHarmonizeLossFunc object'])
    end

    eqs     = harmonizer.lossFunc;
    matches = regexp(eqs,'[A-Za-z_]{1}[A-Za-z_0-9.]*','match');
    matches = unique(horzcat(matches{:}));
    func    = regexp(eqs,'[A-Za-z_]{1}[A-Za-z_0-9]*(?=\()','match');%(?!\()
    func    = unique(horzcat(func{:}));
    func    = strrep(func,'(','');
    indFunc = ismember(matches,func);
    matches = matches(~indFunc);
    
end
