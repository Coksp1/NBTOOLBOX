function [ p, e ] = qsimvn( m, r, a, b )
% Syntax:
%
% [p,e] = qsimvn(m,r,a,b)
%
% Description:
%
% This function uses a randomized quasi-random rule with m points to 
% estimate an MVN probability for positive definite covariance matrix r,
% with lower integration limits a and upper integration limits b. 
% Probability p is output with error estimate e.
%
% This function uses an algorithm given in the paper
% 	"Numerical Computation of Multivariate Normal Probabilities", in
% 	J. of Computational and Graphical Stat., 1(1992), pp. 141-149, by
% 	Alan Genz, WSU Math, PO Box 643113, Pullman, WA 99164-3113
% 	Email : AlanGenz@wsu.edu
%
% The primary references for the numerical integration are 
% 	"On a Number-Theoretical Integration Method"
%   H. Niederreiter, Aequationes Mathematicae, 8(1972), pp. 304-11, and
%   "Randomization of Number Theoretic Methods for Multiple Integration"
%   R. Cranley and T.N.L. Patterson, SIAM J Numer Anal, 13(1976), pp. 
%   904-14.
%
% Examples:
%
% r      = [4 3 2 1;3 5 -1 1;2 -1 4 2;1 1 2 5];
% a      = -inf*[1 1 1 1 ]'; b = [ 1 2 3 4 ]';
% [p, e] = qsimvn( 5000, r, a, b ); disp([ p e ])
% 
% Copyright (C) 2013, Alan Genz,  All rights reserved.

% Copyright (C) 2013, Alan Genz,  All rights reserved.               
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided the following conditions are met:
%   1. Redistributions of source code must retain the above copyright
%      notice, this list of conditions and the following disclaimer.
%   2. Redistributions in binary form must reproduce the above copyright
%      notice, this list of conditions and the following disclaimer in 
%      the documentation and/or other materials provided with the 
%      distribution.
%   3. The contributor name(s) may not be used to endorse or promote 
%      products derived from this software without specific prior 
%      written permission.
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
% FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
% COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
% INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
% BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS 
% OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND 
% ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR 
% TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%
%   Alan Genz is the author of this function and following Matlab functions.

    % Initialization
    [~, n]       = size(r); 
    [ch, as, bs] = chlrdr( r, a, b );
    ct = ch(1,1); ai = as(1); bi = bs(1);  
    if abs(ai) < 9*ct, c = phi(ai/ct); else c = ( 1 + sign(ai) )/2; end
    if abs(bi) < 9*ct, d = phi(bi/ct); else d = ( 1 + sign(bi) )/2; end
    ci = c; dci = d - ci; p = 0; e = 0;
    ns = 12; nv = max( [ m/ns 1 ] ); 
    %q = 2.^( [1:n-1]'/n) ; % Niederreiter point set generators
    ps = sqrt(primes(5*n*log(n+1)/4)); q = ps(1:n-1)'; % Richtmyer generators
    %
    % Randomization loop for ns samples
    %
    for i = 1 : ns
      vi = 0; xr = rand( n-1, 1 ); 
      %
      % Loop for nv quasirandom points
      %
      for  j = 1 : nv
        x = abs( 2*mod( j*q + xr, 1 ) - 1 ); % periodizing transformation
        vp =   mvndns( n, ch, ci, dci,  x, as, bs ); 
        vi = vi + ( vp - vi )/j; 
      end   
      d = ( vi - p )/i; p = p + d; 
      if abs(d) > 0 
        e = abs(d)*sqrt( 1 + ( e/d )^2*( i - 2 )/i );
      else
        if i > 1, e = e*sqrt( ( i - 2 )/i ); end
      end
    end
    e = 3*e; % error estimate is 3 x standard error with ns samples.

end

function p = mvndns( n, ch, ci, dci, x, a, b )
%
%  Transformed integrand for computation of MVN probabilities. 
%
    y = zeros(n-1,1); s = 0; c = ci; dc = dci; p = dc; 
    for i = 2 : n
      y(i-1) = phinv( c + x(i-1)*dc ); s = ch(i,1:i-1)*y(1:i-1); 
      ct = ch(i,i); ai = a(i) - s; bi = b(i) - s;
      if abs(ai) < 9*ct, c = phi(ai/ct); else c = ( 1 + sign(ai) )/2; end
      if abs(bi) < 9*ct, d = phi(bi/ct); else d = ( 1 + sign(bi) )/2; end
      dc = d - c; p = p*dc; 
    end 

end

function [ c, ap, bp ] = chlrdr( R, a, b )
%
%  Computes permuted lower Cholesky factor c for R which may be singular, 
%   also permuting integration limit vectors a and b.
%
    ep = 1e-10; % singularity tolerance;
    [~,n] = size(R); c = R; ap = a; bp = b; d = sqrt(max(diag(c),0));
    for i = 1 :  n
      if d(i) > 0
        c(:,i) = c(:,i)/d(i); c(i,:) = c(i,:)/d(i); 
        ap(i) = ap(i)/d(i); bp(i) = bp(i)/d(i);
      end
    end
    y = zeros(n,1); sqtp = sqrt(2*pi);
    for k = 1 : n
       im = k; ckk = 0; dem = 1; s = 0; 
       for i = k : n 
           if c(i,i) > eps
              cii = sqrt( max( [c(i,i) 0] ) ); 
              if i > 1, s = c(i,1:k-1)*y(1:k-1); end
              ai = ( ap(i)-s )/cii; bi = ( bp(i)-s )/cii; de = phi(bi) - phi(ai);
              if de <= dem, ckk = cii; dem = de; am = ai; bm = bi; im = i; end
           end
       end
       if im > k
          tv = ap(im); ap(im) = ap(k); ap(k) = tv;
          tv = bp(im); bp(im) = bp(k); bp(k) = tv;
          c(im,im) = c(k,k); 
          t = c(im,1:k-1); c(im,1:k-1) = c(k,1:k-1); c(k,1:k-1) = t; 
          t = c(im+1:n,im); c(im+1:n,im) = c(im+1:n,k); c(im+1:n,k) = t; 
          t = c(k+1:im-1,k); c(k+1:im-1,k) = c(im,k+1:im-1)'; c(im,k+1:im-1) = t'; 
       end
       if ckk > ep*k
          c(k,k) = ckk; c(k,k+1:n) = 0;
          for i = k+1 : n
             c(i,k) = c(i,k)/ckk; c(i,k+1:i) = c(i,k+1:i) - c(i,k)*c(k+1:i,k)';
          end
          if abs(dem) > ep 
        y(k) = ( exp( -am^2/2 ) - exp( -bm^2/2 ) )/( sqtp*dem ); 
          else
        if am < -10
          y(k) = bm;
        elseif bm > 10
          y(k) = am;
        else
          y(k) = ( am + bm )/2;
        end
          end
       else
          c(k:n,k) = 0; y(k) = 0;
       end
    end

end
%  Standard statistical normal distribution functions
%
function p =   phi(z) 
    p =  erfc( -z/sqrt(2) )/2;
end
function z = phinv(p) 
    z = norminv( p );
end
% function z = phinv(p), z = -sqrt(2)*erfcinv( 2*p ); % use if no norminv
%
