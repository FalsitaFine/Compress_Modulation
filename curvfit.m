function [para,least] = curvfit(dat,error,order)
para = zeros(1,3);
act = [1500;10;10];
yt = zeros(size(dat,1),1);
m = size(dat,1);
n = size(act,1);
iterations = 1;
J = zeros(m,n);
er = zeros(100,1);
lambda = 0;

while(true)
    %compute Jacobin Matrix
    for i = 1:m
        J(i,(1:3)) = jacobin(i,act(1),act(2),act(3),order);
    end
    %compute residuals
    for x = 1:(size(dat,1))
        yt(x) = act(1) * (((x+act(2))/act(3))^order) * exp(-(x+act(2))/act(3));
    end
    E = dat-yt;
    e = sum(E.^2);
    er(iterations+1) = e;
    if(abs(e)<=error)
        para(1) = act(1);
        para(2) = act(2);
        para(3) = act(3);
        %para(4) = actn(4);
        least = error;
        break;
    elseif(abs(er(iterations+1) - er(iterations))<=0.001)
        para(1) = act(1);
        para(2) = act(2); 
        para(3) = act(3);
        %para(4) = act(4);
        least = er(iterations);
        break;
    else
        act = act + (J.'*J+lambda*eye(3))\J.'*E;
    end
    iterations = iterations+1;
end
end                