function [phi,J,iterations,s1,s2,phi_hist,J_hist,dJ_hist] = optimize_viewpoints(matching,precision,initialization,learning_rate)

%------------------------------------------------------
% Gradient Descent
%------------------------------------------------------
if(exist('learning_rate','var'))
    alpha = learning_rate;
else
    alpha = .1;
end

delta = .1 *pi/180;

J_hist = [];
dJ_hist = [];
phi_hist = [];

matching = wrapTo2Pi(matching);

n = size(matching,1);

if(exist('initialization','var'))
    phi = initialization;
else
    phi = matching(:,1); %Initialization
end

A = exp(1i*matching); %precompute the constants

iterations = 0;
while(1)
    iterations = iterations + 1;
    
    [J,s1,s2] = cost_function(phi,A);
    
    %compute the approximation of the derivative
    batch_size = n;
    b = [];
    while(nnz(b) < batch_size)
        b(randi(n)) = 1;
    end
    fb = find(b);
    dJ = zeros(n,1);
    for ik = 1 : length(fb)
        J_ = zeros(n,1);
        k = fb(ik);
        
        d = zeros(n,1);
        d(k) = delta;
        phi_ = phi+d;
        J_(k) = cost_function(phi_,A);
        
        dJ(k) = J_(k) - J;
    end
    
    % update phi
    phi = phi - alpha*dJ;
    
    J_hist(end+1) = J;
    phi_hist(:,end+1) = phi;
    dJ_hist(:,end+1) = dJ;
    
    fprintf('%d \n',var(dJ)); 
    if(var(dJ) < precision)
        break;
    end
    
%     if(numel(J_hist) > 5000)
%         break
%     end
end

function [J,s1,s2] = cost_function(phi,A)
[p1,p2] = meshgrid(phi,phi);
ephi2 = exp(1i*p1).*exp(-1i*p2);
d = abs(ephi2 .* A' - 1).^2;
s1 = sum(d);
s2 = sum(d,2);
J = sum(s1);

n = size(d,1);
s1 = s1./n;
s2 = s2./n;
