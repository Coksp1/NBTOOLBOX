function [F,LAMBDA,R,varF,expl,c,sigma,e,Z] = pca(obj,~,~,varargin)
% Syntax:
%
% F                                  = pca(obj)
% [F,LAMBDA,R,varF,expl,c,sigma,e,Z] = pca(obj,r,method,varargin)
%
% Description:
%
% Principal Component Analysis.
% 
% Input:
%
% - obj     : An object of class nb_objectInExpr.
%
% - The rest not important
%
% Output:
% 
% - F       : A nb_objectInExpr object.
%
% - LAMBDA  : A empty nb_objectInExpr object.
%
% - R       : A empty nb_objectInExpr object.
%
% - varF    : A empty nb_objectInExpr object.
%
% - expl    : A empty nb_objectInExpr object.
%
% - c       : A empty nb_objectInExpr object.
%
% - sigma   : A empty nb_objectInExpr object.
%
% - e       : A nb_objectInExpr object.
%
% - Z       : A nb_objectInExpr object.
%
% See also:
% nb_pca
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    empt   = emptyObject(obj);
    F      = obj;
    LAMBDA = empt;
    R      = empt;
    varF   = empt;
    expl   = empt;
    c      = empt;
    sigma  = empt;
    e      = obj;  
    Z      = obj;
     
end
