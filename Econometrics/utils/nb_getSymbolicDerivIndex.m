function [I,J] = nb_getSymbolicDerivIndex(symDeriv,all,derivEqs)
% Syntax:
%
% [I,J] = nb_getSymbolicDerivIndex(symDeriv,all,derivEqs)
%
% Description:
%
% Find sparse indexes when utilizing the nb_mySD class and want to
% construct the full jacobian.
% 
% Input:
% 
% - symDeriv : A vector of nb_mySD objects.
%
% - all      : Either a cellstr with all bases of all equations or a one
%              line char with the generic name used when using nb_mySD.
%
% - derivEqs : The derivatives as a cellstr. If empty
%              [symDeriv.derivatives] will be used.
% 
% Output:
% 
% - I,J : Sparse indexes that can be used to initialize the sparse 
%         jacobian. 
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    if nargin < 3
        derivEqs = [symDeriv.derivatives];
    end

    nDEqs = size(derivEqs,2);
    J     = nan(nDEqs,1);
    I     = nan(nDEqs,1);
    kk    = 1;
    if iscellstr(all)
        
        for ii = 1:size(symDeriv,1)
            [~,JT] = ismember(symDeriv(ii).bases,all);
            ind    = kk:kk+size(JT,2)-1;
            J(ind) = JT;
            I(ind) = ii;
            kk     = kk + size(JT,2);
        end
        
    elseif ischar(all)
    
        for ii = 1:size(symDeriv,1)
            JTC    = strrep(strrep(symDeriv(ii).bases,[all,'('],''),')','');
            JT     = str2num(char(JTC')); %#ok<ST2NM>
            ind    = kk:kk+size(JT,1)-1;
            J(ind) = JT;
            I(ind) = ii;
            kk     = kk + size(JT,1);
        end
        
    else
        error([mfilename ':: The all input must be a one line char or a cellstr.'])
    end
