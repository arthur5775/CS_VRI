clear variables
close all
clc

keystroke = '0';
pos = [1 1];
global c; c = [30 30];
global r; r = 20;

S.fh = figure( 'units','pixels',...
    'position',[500 500 500 500],...
    'name','TP Haptic course',...
    'numbertitle','off','resize','off',...
    'keypressfcn',@f_capturekeystroke);

figure(1)
circle(c,r); hold on;
xlim([1 60]); ylim([1 60]);
hold off;
guidata(S.fh,S)


%%%%%%%% FUNCTIONS
function f = haptic_rend(pos, c, r)

% this function should calculate the force provided given the position of
% the user and the object (i.e., the circle in this case)

end


% enabling the user to move its position in the screen
function update_pos(key)

global c; global r;

pos = evalin('base', 'pos');
clc;

switch key
    case 'uparrow'
        pos(2) = pos(2) + 1;
    case 'rightarrow'
        pos(1) = pos(1) + 1;
    case 'leftarrow'
        pos(1) = pos(1) - 1;
    case 'downarrow'
        pos(2) = pos(2) - 1;
end

circle(c, r); hold on;
plot(pos(1), pos(2),'r.')

haptic_rend(pos, c, r);

xlim([1 60]); ylim([1 60]);
hold off;

assignin('base','pos', pos);

figure(1)

end

% reading the keyboard strokes
function  f_capturekeystroke(H,E)
% capturing and logging keystrokes
S2 = guidata(H);
%P = get(S2.fh,'position');
%
%set(S2.tx,'string',E.Key)
assignin('base','keystroke',E.Key)    % passing 1 keystroke to workspace variable
update_pos(E.Key)
%
%evalin('base','b=[b a]')  % accumulating to catch combinations like ctrl+S
end

% designing the circle
function circle(c,r)
%x and y are the coordinates of the center of the circle
%r is the radius of the circle
%0.01 is the angle step, bigger values will draw the circle faster but
%you might notice imperfections (not very smooth)
ang=0:0.01:2*pi;
xp=r*cos(ang);
yp=r*sin(ang);
plot(c(1)+xp,c(2)+yp);
end