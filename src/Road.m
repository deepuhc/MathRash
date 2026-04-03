classdef Road
    % ROAD Handles road rendering with scrolling effect and scenery

    properties (Access = public)
        ScrollOffset (1,1) double = 0
        RoadColor    (1,3) double = [0.3, 0.3, 0.3]
        LineColor    (1,3) double = [1, 1, 1]
        GrassColor   (1,3) double = [0.2, 0.7, 0.2]
        SkyColor     (1,3) double = [0.4, 0.7, 1.0]
        RoadLeft     (1,1) double = 0.2
        RoadRight    (1,1) double = 0.8
        NumDashes    (1,1) double = 8
    end

    methods
        function obj = Road()
        end

        function obj = update(obj, dt, speed)
            obj.ScrollOffset = obj.ScrollOffset + speed * dt * 0.01;
            if obj.ScrollOffset > 1
                obj.ScrollOffset = obj.ScrollOffset - 1;
            end
        end

        function render(obj, ax)
            % Clear and draw the road scene
            cla(ax);
            hold(ax, 'on');

            % Sky background
            fill(ax, [0 1 1 0], [0.5 0.5 1 1], obj.SkyColor, 'EdgeColor', 'none');

            % Grass
            fill(ax, [0 obj.RoadLeft obj.RoadLeft 0], [0 0 1 1], obj.GrassColor, 'EdgeColor', 'none');
            fill(ax, [obj.RoadRight 1 1 obj.RoadRight], [0 0 1 1], obj.GrassColor, 'EdgeColor', 'none');

            % Road surface
            fill(ax, [obj.RoadLeft obj.RoadRight obj.RoadRight obj.RoadLeft], ...
                     [0 0 1 1], obj.RoadColor, 'EdgeColor', 'none');

            % Road edge lines
            plot(ax, [obj.RoadLeft obj.RoadLeft], [0 1], 'w-', 'LineWidth', 2);
            plot(ax, [obj.RoadRight obj.RoadRight], [0 1], 'w-', 'LineWidth', 2);

            % Center dashed line (scrolling)
            centerX = (obj.RoadLeft + obj.RoadRight) / 2;
            dashLen = 1 / obj.NumDashes;
            for i = 0:obj.NumDashes
                yBase = i * dashLen * 2 - mod(obj.ScrollOffset, dashLen * 2);
                yTop = yBase + dashLen;
                if yBase < 1 && yTop > 0
                    yBase = max(0, yBase);
                    yTop = min(1, yTop);
                    plot(ax, [centerX centerX], [yBase yTop], 'w-', 'LineWidth', 1.5);
                end
            end

            % Scenery - trees on the sides
            obj.drawTrees(ax);

            hold(ax, 'off');
        end

        function drawTrees(obj, ax)
            treePositions = [0.05, 0.12, 0.88, 0.95];
            for i = 1:length(treePositions)
                tx = treePositions(i);
                ty = 0.4 + mod(obj.ScrollOffset * 0.3 + i * 0.2, 0.5);
                if ty < 1
                    % Tree trunk
                    fill(ax, [tx-0.01 tx+0.01 tx+0.01 tx-0.01], ...
                             [ty ty ty+0.05 ty+0.05], [0.5 0.3 0.1], 'EdgeColor', 'none');
                    % Tree crown
                    fill(ax, [tx-0.03 tx+0.03 tx], ...
                             [ty+0.05 ty+0.05 ty+0.1], [0 0.5 0], 'EdgeColor', 'none');
                end
            end
        end
    end
end
