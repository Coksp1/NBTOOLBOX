function [obj,x,outputfile,errorfile,model] = x12Census(obj,varargin)
% Syntax:
%
% obj = x12Census(obj)
% [obj,x,outputfile,errorfile,model] = x12Census(obj)
% [obj,x,outputfile,errorfile,model] = x12Census(obj,varargin)
%
% Description:
%
% Do x12 Census
%
% Input:
% 
% - obj   : An object of class nb_objectInExpr.
%
% Optional input (...,'propertyName',propertyValue,...):
% 
% Any.
%
% Output:
%
% - obj        : An object of class nb_objectInExpr.
%
% - x          : An object of class nb_objectInExpr.
%
% - outputfile : ''
% 
% - errorfile  : {}
%
% - mdl        : []
%
% Written by Kenneth Sæterhagen Paulsen
    
% Copyright (c) 2023, Kenneth Sæterhagen Paulsen

    x          = obj;
    outputfile = '';
    errorfile  = {};
    model      = [];
   
end
