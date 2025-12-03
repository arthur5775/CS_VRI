clear variables
close all
clc

function circle(c,r)
  %x and y are the coordinates of the center of the circle
  %r is the radius of the circle
  %0.01 is the angle step, bigger values will draw the circle faster but
  %you might notice imperfections (not very smooth)
  ang=0:0.01:2*pi;
  xp=r*cos(ang);
  yp=r*sin(ang);
  plot(c(1)+xp,c(2)+yp);
endfunction



pos = [1 1];
c = [0 0];
r = 20;

S.fh = figure( 'units','pixels','position',[500 500 500 500],'name','TP Haptic course','numbertitle','off');

figure(1)
circle(c,r); hold on;
xlim([-40 40]); ylim([-40 40]);
hold off;
guidata(S.fh,S)

while(1)

  [pos(1), pos(2), ~] = ginput (1);

  circle(c, r); hold on;
  plot(pos(1), pos(2),'r.', "markersize", 20)
  fprintf('pos: [%f, %f] m\n', pos(1), pos(2));
  % here calculate the proxy position and force to be rendered

  xlim([-40 40]); ylim([-40 40]);
  hold off;

  figure(1)


endwhile



