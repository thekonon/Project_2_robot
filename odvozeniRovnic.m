function [F_m, J_m] = odvozeniRovnic(L)

l1 = L(1);
l2 = L(2);
l3 = L(3);

syms t
syms('q', [1 2])
syms('qt(t)', [1 2])
syms('qd', [1 2])
syms('z', [1 4])
syms('zt(t)', [1 4])
syms('zd', [1 4])

q = [q1; q2]; %x y
qt = [qt1; qt2]; %jejich derivace
qdt = diff(qt,t);
z = [z1; z2; z3; z4];
zt = [zt1; zt2; zt3; zt4];
zdt = diff(zt,t);
qd = [qd1; qd2];
zd = [zd1; zd2; zd3; zd4];

b = [l2 l3 l3 l2 l1];
bet = [z1 z3 z4 (z2+pi) pi];

clear F
F = [b*cos(bet).';
    b*sin(bet).';
    b(1:2)*cos(bet(1:2)).'+0*cos(bet(2)+pi/4-pi/180*0)-q1;
    b(1:2)*sin(bet(1:2)).'+0*sin(bet(2)+pi/4-pi/180*0)-q2];

F_m = matlabFunction(F,'Vars', {[q1 q2 z1 z2 z3 z4]});
J = jacobian(F,[q; z]);
J_m = matlabFunction(J,'Vars', {[q1 q2 z1 z2 z3 z4]});

% clear jqz
% jqz = subs(diff(subs(Jz, [q;z],[qt;zt]))*zd+...
%     diff(subs(Jq, [q;z],[qt;zt]))*qd, [zdt; zt],[zd; z]);
% jqz_m = matlabFunction(jqz);
end
