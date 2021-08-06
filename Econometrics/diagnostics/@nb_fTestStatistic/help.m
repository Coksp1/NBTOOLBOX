function help = help(~,option)
% Syntax:
%
% help = help(~,option)
%
% Description:
%
% A method to give some basic instructions regarding input to
% nb_fTestStatistic
% 
% Input:
% 
% - obj    : A nb_fTestStatistic object
%
% - option : A string with the property to look up.
% 
% Output:
% 
% - help : A string with the help text.
%
% Written by Kenneth Sæterhagen Paulsen

% Copyright (c) 2021, Kenneth Sæterhagen Paulsen

if nargin < 2
    option = 'all';
end

% Genereate help for the different options
aHelp = sprintf([...
    '-A: A is the a cell with the matrix A from the equation Ab = c. \n',...
    'which defines the f-test that will be made.  The cell must have the \n',...
    'dimensions nxm, where n is the amount of coefficients being tested, and \n',...
    'm is the amount of tests being made. For example, if we are performing \n',...
    'three tests, and we have three coefficients,A will look something like \n',...
    'A = [1,0,0;0,1,1;3,1,2]']);

cHelp = sprintf([...
    '-c: A is the a cell with the vector c from the equation Ab = c. \n',...
    'which defines the f-test that will be made.  The cell must have the \n',...
    'dimensions 1xm, where m is the amount of tests being made. for example, \n',...
    'if we are performing three tests, c will look something like c = [1,2,3]']);

dependentHelp = sprintf([...
    '-dependent: setting the dependent variable will decide which equation the f-test \n',...
    'will be performed on. This input must be a string with the name of the variable,\n',...
    'for example ''Var1''']);

switch lower(option)
    case 'all'
        help = [aHelp,char(10),char(10),cHelp,char(10),char(10),dependentHelp];
    case 'a'
        help = aHelp;
    case 'c'
        help = cHelp;
    case 'dependent'
        help = dependentHelp;
end
end

