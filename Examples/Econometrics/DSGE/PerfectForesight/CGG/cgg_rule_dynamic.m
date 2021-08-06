function [residual, g1, g2, g3] = cgg_rule_dynamic(y, x, params, steady_state, it_)
%
% Status : Computes dynamic model for Dynare
%
% Inputs :
%   y         [#dynamic variables by 1] double    vector of endogenous variables in the order stored
%                                                 in M_.lead_lag_incidence; see the Manual
%   x         [nperiods by M_.exo_nbr] double     matrix of exogenous variables (in declaration order)
%                                                 for all simulation periods
%   steady_state  [M_.endo_nbr by 1] double       vector of steady state values
%   params    [M_.param_nbr by 1] double          vector of parameter values in declaration order
%   it_       scalar double                       time period for exogenous variables for which to evaluate the model
%
% Outputs:
%   residual  [M_.endo_nbr by 1] double    vector of residuals of the dynamic model equations in order of 
%                                          declaration of the equations.
%                                          Dynare may prepend auxiliary equations, see M_.aux_vars
%   g1        [M_.endo_nbr by #dynamic variables] double    Jacobian matrix of the dynamic model equations;
%                                                           rows: equations in order of declaration
%                                                           columns: variables in order stored in M_.lead_lag_incidence followed by the ones in M_.exo_names
%   g2        [M_.endo_nbr by (#dynamic variables)^2] double   Hessian matrix of the dynamic model equations;
%                                                              rows: equations in order of declaration
%                                                              columns: variables in order stored in M_.lead_lag_incidence followed by the ones in M_.exo_names
%   g3        [M_.endo_nbr by (#dynamic variables)^3] double   Third order derivative matrix of the dynamic model equations;
%                                                              rows: equations in order of declaration
%                                                              columns: variables in order stored in M_.lead_lag_incidence followed by the ones in M_.exo_names
%
%
% Warning : this file is generated automatically by Dynare
%           from model file (.mod)

%
% Model equations
%

residual = zeros(7, 1);
lhs =y(8);
rhs =params(10)*y(1)+(1-params(10))*y(15)-params(11)*(y(10)-y(16))+y(13);
residual(1)= lhs-rhs;
lhs =y(13);
rhs =params(6)*y(6)+x(it_, 2);
residual(2)= lhs-rhs;
lhs =y(9);
rhs =params(9)*y(2)+y(16)*(1-params(9))*params(2)+y(8)*params(1)+y(12);
residual(3)= lhs-rhs;
lhs =y(12);
rhs =params(7)*y(5)+x(it_, 1);
residual(4)= lhs-rhs;
lhs =y(10);
rhs =max(params(3)*y(3)+(1-params(3))*(y(9)*params(4)+y(8)*params(5))+y(14),(-0.15));
residual(5)= lhs-rhs;
lhs =y(14);
rhs =params(8)*y(7)+x(it_, 3);
residual(6)= lhs-rhs;
lhs =y(11);
rhs =(1-params(3))*(y(9)*params(4)+y(8)*params(5))+params(3)*y(4);
residual(7)= lhs-rhs;
if nargout >= 2,
  g1 = zeros(7, 19);

  %
  % Jacobian matrix
  %

  g1(1,1)=(-params(10));
  g1(1,8)=1;
  g1(1,15)=(-(1-params(10)));
  g1(1,16)=(-params(11));
  g1(1,10)=params(11);
  g1(1,13)=(-1);
  g1(2,6)=(-params(6));
  g1(2,13)=1;
  g1(2,18)=(-1);
  g1(3,8)=(-params(1));
  g1(3,2)=(-params(9));
  g1(3,9)=1;
  g1(3,16)=(-((1-params(9))*params(2)));
  g1(3,12)=(-1);
  g1(4,5)=(-params(7));
  g1(4,12)=1;
  g1(4,17)=(-1);
  g1(5,8)=(-((1-params(3))*params(5)*(params(3)*y(3)+(1-params(3))*(y(9)*params(4)+y(8)*params(5))+y(14)>(-0.15))));
  g1(5,9)=(-((params(3)*y(3)+(1-params(3))*(y(9)*params(4)+y(8)*params(5))+y(14)>(-0.15))*(1-params(3))*params(4)));
  g1(5,3)=(-(params(3)*(params(3)*y(3)+(1-params(3))*(y(9)*params(4)+y(8)*params(5))+y(14)>(-0.15))));
  g1(5,10)=1;
  g1(5,14)=(-(params(3)*y(3)+(1-params(3))*(y(9)*params(4)+y(8)*params(5))+y(14)>(-0.15)));
  g1(6,7)=(-params(8));
  g1(6,14)=1;
  g1(6,19)=(-1);
  g1(7,8)=(-((1-params(3))*params(5)));
  g1(7,9)=(-((1-params(3))*params(4)));
  g1(7,4)=(-params(3));
  g1(7,11)=1;

if nargout >= 3,
  %
  % Hessian matrix
  %

  g2 = sparse([],[],[],7,361);
if nargout >= 4,
  %
  % Third order derivatives
  %

  g3 = sparse([],[],[],7,6859);
end
end
end
end
