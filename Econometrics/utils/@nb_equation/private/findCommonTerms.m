function [common,base1,base2] = findCommonTerms(base1,base2,pow1,pow2)
% Syntax:
%
% [common,base1,base2] = findCommonTerms(base1,base2,pow1,pow2)
%
% Description:
%
% Test for equality of two objects ignoring powers.
%
% Inputs:
%
% - base1 : A nb_equation object.
%
% - base2 : A nb_equation object.
%
% - pow1  : A nb_term object.
%
% - pow2  : A nb_term object.
%
% Output:
%
% - common : A nb_equation object representing the common terms.
%
% - base1  : A nb_equation object.
%
% - base2  : A nb_equation object.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

    % Get commond terms from base1
    commonTerms1 = getCommonTermsSub(base1,pow1);
    
    % Get commond terms from base2
    commonTerms2 = getCommonTermsSub(base2,pow2);
    
    % Get common terms for both terms
    common = intersect(commonTerms1,commonTerms2);    
    if ~isempty(common)
        
        % Remove common terms from base1
        base1 = removeCommonTerms(base1,common);
        
        % Remove common terms from base2
        base2 = removeCommonTerms(base2,common);
        
        % Create an equation out of the common terms
        if size(common,1) > 1
            common = nb_equation('*',common);
        end
        
    end
    
end

%==========================================================================
function commonTerms = getCommonTermsSub(obj,pow)

    if strcmp(obj.operator,'*') 
        commonTerms = obj.terms;
    elseif strcmp(obj.operator,'+')
        if isa(pow,'nb_num') && (pow == 1 || pow == -1)
            commonTerms = getCommonTermsPlus(obj);
        else
            commonTerms = obj;
        end
    else
        commonTerms = obj;
    end

end

%==========================================================================
function commonTerms = getCommonTermsPlus(obj)

    commonTerms = getCommonTermsSub(obj.terms(1));
    for ii = 2:obj.numberOfTerms
        commonTermsT = getCommonTermsSub(obj.terms(ii));
        commonTerms  = intersect(commonTerms,commonTermsT);
    end
    
end

%==========================================================================
function obj = removeCommonTerms(obj,common)

    if strcmp(obj.operator,'*') 
        ind = ismember(obj.terms,common);
        if all(ind)
            obj = nb_num(1);
        else
            obj.terms = obj.terms(~ind);
        end
        obj = clean(obj); 
    elseif strcmp(obj.operator,'+')
        terms = obj.terms;
        for ii = 1:obj.numberOfTerms
            terms(ii) = removeCommonTerms(terms(ii),common);
        end
        obj.terms = terms;
    else
        obj = nb_num(1);
    end

end
