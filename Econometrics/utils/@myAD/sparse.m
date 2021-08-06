function A = sparse(i,j,v,n,m)
% Syntax:
%
% A = sparse(i,j,v,n,m)
%
% Description:
%
% Make object sparse.
% 
% Written by SeHyoun Ahn, Oct 2017

    val = getvalues(v);
    der = getderivs(v);

    [id, jd, vd] = find(der);
    l            = size(der, 2);

    retval = sparse(i, j, val, n, m);
    retder = sparse(n*(j(id)-1) + i(id), jd, vd, n*m, l);
    A      = myAD(retval, retder);
    
end
