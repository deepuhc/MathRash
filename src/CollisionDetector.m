classdef CollisionDetector
    % COLLISIONDETECTOR Axis-aligned bounding box collision detection
    %   Checks for overlapping hitboxes between game objects.

    methods (Static)
        function hit = checkCollision(hitboxA, hitboxB)
            % CHECKCOLLISION Tests if two hitboxes overlap
            %   hitbox format: [xMin, xMax, yMin, yMax]
            %   Returns true if the boxes overlap.

            if isempty(hitboxA) || isempty(hitboxB)
                hit = false;
                return;
            end

            hit = hitboxA(1) < hitboxB(2) && hitboxA(2) > hitboxB(1) && ...
                  hitboxA(3) < hitboxB(4) && hitboxA(4) > hitboxB(3);
        end

        function hit = checkPlayerOpponentCollision(player, opponent)
            % CHECKPLAYEROPPONENTCOLLISION Checks collision between player and opponent
            if ~opponent.Active
                hit = false;
                return;
            end
            hit = CollisionDetector.checkCollision(player.getHitbox(), opponent.getHitbox());
        end

        function hit = checkPlayerGateCollision(player, gate)
            % CHECKPLAYERGATECOLLISION Checks if player rides through a math gate
            if ~gate.Active
                hit = false;
                return;
            end
            hit = CollisionDetector.checkCollision(player.getHitbox(), gate.getHitbox());
        end

        function [collidedIdx] = checkAllOpponents(player, opponents)
            % CHECKALLOPPONENTS Returns indices of opponents colliding with player
            collidedIdx = [];
            for i = 1:length(opponents)
                if CollisionDetector.checkPlayerOpponentCollision(player, opponents(i))
                    collidedIdx(end+1) = i; %#ok<AGROW>
                end
            end
        end
    end
end
