classdef Player
    % PLAYER Represents the player's motorcycle in the game
    %   Manages position, speed, lives, and power-up state.

    properties (Access = public)
        XPos        (1,1) double = 0.5   % normalized 0-1 (lane position)
        YPos        (1,1) double = 0.15  % fixed vertical position on screen
        Speed       (1,1) double = 30    % current speed (km/h visual)
        BaseSpeed   (1,1) double = 30
        MaxSpeed    (1,1) double = 120
        Lives       (1,1) double = 3
        MaxLives    (1,1) double = 5
        ShieldTimer (1,1) double = 0     % seconds of shield remaining
        BoostTimer  (1,1) double = 0     % seconds of boost remaining
        Distance    (1,1) double = 0     % total distance traveled
        LaneWidth   (1,1) double = 0.15  % half-width of motorcycle hitbox
        IsAlive     (1,1) logical = true
    end

    methods
        function obj = Player()
        end

        function obj = moveLeft(obj, dt)
            obj.XPos = max(0.1, obj.XPos - 0.8 * dt);
        end

        function obj = moveRight(obj, dt)
            obj.XPos = min(0.9, obj.XPos + 0.8 * dt);
        end

        function obj = update(obj, dt)
            % UPDATE Advances player state by dt seconds
            if ~obj.IsAlive
                return;
            end

            % Update shield timer
            if obj.ShieldTimer > 0
                obj.ShieldTimer = max(0, obj.ShieldTimer - dt);
            end

            % Update boost timer and speed
            if obj.BoostTimer > 0
                obj.BoostTimer = max(0, obj.BoostTimer - dt);
                obj.Speed = min(obj.MaxSpeed, obj.BaseSpeed * 2);
            else
                obj.Speed = obj.BaseSpeed;
            end

            % Accumulate distance
            obj.Distance = obj.Distance + obj.Speed * dt;
        end

        function obj = applyBoost(obj, duration)
            obj.BoostTimer = duration;
        end

        function obj = applyShield(obj, duration)
            obj.ShieldTimer = duration;
        end

        function obj = takeDamage(obj)
            if obj.ShieldTimer > 0
                return;  % shield absorbs hit
            end
            obj.Lives = obj.Lives - 1;
            if obj.Lives <= 0
                obj.IsAlive = false;
            end
        end

        function obj = addLife(obj)
            obj.Lives = min(obj.MaxLives, obj.Lives + 1);
        end

        function obj = setBaseSpeed(obj, speed)
            obj.BaseSpeed = min(speed, obj.MaxSpeed);
        end

        function obj = slowDown(obj)
            obj.BaseSpeed = max(20, obj.BaseSpeed - 10);
        end

        function obj = speedUp(obj)
            obj.BaseSpeed = min(obj.MaxSpeed, obj.BaseSpeed + 5);
        end

        function hasShield = isShielded(obj)
            hasShield = obj.ShieldTimer > 0;
        end

        function boosted = isBoosted(obj)
            boosted = obj.BoostTimer > 0;
        end

        function hitbox = getHitbox(obj)
            % Returns [xMin, xMax, yMin, yMax]
            hitbox = [obj.XPos - obj.LaneWidth, obj.XPos + obj.LaneWidth, ...
                      obj.YPos - 0.05, obj.YPos + 0.05];
        end
    end
end
