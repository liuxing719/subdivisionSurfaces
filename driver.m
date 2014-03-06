% driver!!!

%[vertices faces] = readSTL('chunk10.stl');
[vertices faces] = readSTL('chunk3.stl');

figure(120); clf
patch('Faces', faces, 'Vertices', vertices, 'FaceColor', 'r')
view(3)
axis image vis3d

%%

VV = fv2vv(faces(randperm(size(faces,1)),:), vertices);
%VV = fv2vv(faces, vertices);

%% Test selective splitting

splitFlags = vertices(:,3) < -50;
%splitFlags = vertices(:,3) < 250;
A = vv2adjacency(VV);
adjFlags = (A^1)*splitFlags > 0;

%%

[VV2, ~, vertices2] = loopRefine(VV, vertices, adjFlags);
f2 = vv2fv(VV2);


%%
figure(1); clf
plotVV(VV2, vertices2, 'b-')

%%
figure(120); clf
subplot(121)
plotVV(VV, vertices, 'b-')
hold on
plot3(vertices(adjFlags,1), vertices(adjFlags,2), vertices(adjFlags,3),...
    'ro', 'LineWidth', 3)
view(3); axis image vis3d

subplot(122)
plotVV(VV2, vertices2, 'b-')
hold on
plotVV(VV, vertices, '-', 'Color', [0.8 0.8 1])
view(3); axis image vis3d
%%

%%

figure(9); clf
plotVV(VV, vertices, 'b-', 'LineWidth', 2)
[VV2, ~, vertices2] = loopRefine(VV, vertices);
[VV2, ~, vertices2] = loopRefine(VV2, vertices2);
[VV2, ~, vertices2] = loopRefine(VV2, vertices2);

hold on
plotVV(VV2, vertices2, 'r--')

%%

faces2 = vv2fv(VV);

figure(20); clf
patch('Faces', faces2, 'Vertices', vertices, 'FaceColor', 'g')
view(3)
axis image vis3d

%% Loop subdivision!!!

[VV2 vertices2] = loopSubdivision(VV, vertices);
%%
for ii = 1:6
    %figure(ii); clf
    %plotVV(VV2, vertices2, 'b-');
    %axis image vis3d
    
    faces2 = vv2fv(VV2);
    figure(ii+10); clf
    flatPatch('Faces', faces2, 'Vertices', vertices2, 'FaceColor', 'r');
    hold on
    plotVV(VV, vertices, 'b--')
    view(3); axis image vis3d
    camlight right
    
    pause
    [VV2 vertices2] = loopSubdivision(VV2, vertices2);
end

%%
% As far as restricting certain regions to be divided or not divided:
% well... any edge that gets split can connect no matter what.  The
% splitting is a per-edge technique, that's all.  Mark edges to split that
% way!
%
% One approach then: mark a vertex as "split adjacent" or something?  Or
% split every edge next to a marked vertex?  I'm using a VV data structure
% so I gotta make this make sense for me.


%% Test mesh.

[vertices faces] = flatRegularMesh(5);
VV = fv2vv(faces, vertices);

vertices(:,3) = sin(2*(vertices(:,1) + vertices(:,2)));

%%

crease = [1:4, 5:5:20, 25:-1:22, 21:-5:1];

creaseB = [8 12 17];

%%
[VV2 vertices2 T creaseB2 crease2] = loopSubdivision(VV, vertices, creaseB, crease);
[VV2 vertices2 T2 creaseB2 crease2] = loopSubdivision(VV2, vertices2, creaseB2, crease2);
[VV2 vertices2 T3 creaseB2 crease2] = loopSubdivision(VV2, vertices2, creaseB2, crease2);
f2 = vv2fv(VV2);

figure(1); clf
whitebg k
plotVV(VV, vertices, 'b-');
hold on
patch('Faces', f2, 'Vertices', vertices2, 'FaceColor', 'r', ...
    'FaceAlpha', 1.0, 'EdgeAlpha', 0.1);
%plotVV(VV2, vertices2, 'r-');
plot3(vertices(crease,1), vertices(crease,2), vertices(crease,3), ...
    'b--', 'LineWidth', 3)
plot3(vertices2(crease2,1), vertices2(crease2,2), vertices2(crease2,3),...
    'g-', 'LineWidth', 4)
plot3(vertices2(creaseB2,1), vertices2(creaseB2,2), vertices2(creaseB2,3),...
    'g-', 'LineWidth', 4)
axis image vis3d
axis off
set(gcf, 'Color', 'k')
view(3);
camlight right; lighting phong
ax = axis;

%%

Ttot = T3*T2*T;
verts = vertices;

movObj = QTWriter('wiggle.mov');

for tt = 1:100
    
    %randVert = randi(25,1);
    %verts(randVert,:) = verts(randVert,:) + rand - 0.5;
    
    verts = verts + 0.1*rand(size(verts)) - 0.05;
    verts2 = Ttot*verts;
    
    figure(10); clf
    plotVV(VV, verts, 'b-');
    hold on
    patch('Faces', f2, 'Vertices', Ttot*verts, 'FaceColor', 'r', ...
        'EdgeAlpha', 0.1);
    plot3(verts(crease,1), verts(crease,2), verts(crease,3), ...
        'b--', 'LineWidth', 3)
    plot3(verts2(crease2,1), verts2(crease2,2), verts2(crease2,3),...
        'g-', 'LineWidth', 4)
    plot3(verts2(creaseB2,1), verts2(creaseB2,2), verts2(creaseB2,3),...
        'g-', 'LineWidth', 4)
    axis off
    axis(ax)
    view(az, el)
    set(gcf, 'Color', 'k')
    camlight right; lighting phong
    writeMovie(movObj, getframe);
    
    pause(0.01)
end
close(movObj);



%%
[VV2, ~, vertices2] = loopRefine(VV2, vertices2);
plotVV(VV2, vertices2);

