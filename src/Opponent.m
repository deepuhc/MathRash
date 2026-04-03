classdef Opponent
    % OPPONENT Represents an AI opponent motorcycle on the road
    %   Opponents move down the screen toward the player.

    properties (Access = public)
        XPos    (1,1) double = 0.5
        YPos    (1,1) double = 1.0   % starts at top of screen
        Speed   (1,1) double = 40
        Width   (1,1) double = 0.12  % half-width of hitbox
        Active  (1,1) logical = true
        Color   (1,3) double = [1, 0, 0]  % red by default
    end

    properties (Constant)
        COLORS = [1 0 0; 0 0 1; 0.5 0 0.5; 1 0.5 0; 0 0.5 0];
    end

    methods
        function obj = Opponent(xPos, speed)
            if nargin > 0
                obj.XPos = xPos;
            end
            if nargin > 1
                obj.Speed = speed;
            end
            colorIdx = randi(size(obj.COLORS, 1));
            obj.Color = obj.COLORS(colorIdx, :);
        end

        function obj = update(obj, dt, playerSpeed)
            % MOVE Move opponent relative to player speed
            if ~obj.Active
                return;
            end
            relativeSpeed = (playerSpeed - obj.Speed) * 0.005;
            obj.YPos = obj.YPos - relativeSpeed * dt;

            % Deactivate if off screen
            if obj.YPos < -0.1 || obj.YPos > 1.5
                obj.Active = false;
            end
        end

        function hitbox = getHitbox(obj)
            hitbox = [obj.XPos - obj.Width, obj.XPos + obj.Width, ...
                      obj.YPos - 0.04, obj.YPos + 0.04];
        end
    end

    methods (Static)
        function opponents = spawnWave(count, level)
            % SPAWNWAVE Creates a wave of opponents
            opponents = Opponent.empty(0);
            lanes = linspace(0.2, 0.8, max(count + 1, 3));
            lanes = lanes(2:end-1);
            if count > length(lanes)
                count = length(lanes);
            end
            selectedLanes = lanes(randperm(length(lanes), count));
            baseSpeed = 25 + level * 5;
            for i = 1:count
                spd = baseSpeed + randi([-5, 10]);
                opp = Opponent(selectedLanes(i), spd);
                opp.YPos = 0.9 + rand() * 0.3;  % stagger start positions
                opponents(end+1) = opp; %#ok<AGROW>
            end
        end
    end
end
