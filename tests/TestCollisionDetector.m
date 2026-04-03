classdef TestCollisionDetector < matlab.unittest.TestCase
    % TESTCOLLISIONDETECTOR Unit tests for CollisionDetector

    methods (Test)
        %% Basic AABB tests
        function testOverlappingBoxes(testCase)
            a = [0, 1, 0, 1];
            b = [0.5, 1.5, 0.5, 1.5];
            testCase.verifyTrue(CollisionDetector.checkCollision(a, b));
        end

        function testNonOverlappingBoxes(testCase)
            a = [0, 1, 0, 1];
            b = [2, 3, 2, 3];
            testCase.verifyFalse(CollisionDetector.checkCollision(a, b));
        end

        function testTouchingEdges(testCase)
            a = [0, 1, 0, 1];
            b = [1, 2, 0, 1];
            testCase.verifyFalse(CollisionDetector.checkCollision(a, b));
        end

        function testContainedBox(testCase)
            a = [0, 4, 0, 4];
            b = [1, 2, 1, 2];
            testCase.verifyTrue(CollisionDetector.checkCollision(a, b));
        end

        function testEmptyHitbox(testCase)
            testCase.verifyFalse(CollisionDetector.checkCollision([], [0,1,0,1]));
            testCase.verifyFalse(CollisionDetector.checkCollision([0,1,0,1], []));
        end

        function testIdenticalBoxes(testCase)
            a = [0.3, 0.7, 0.1, 0.5];
            testCase.verifyTrue(CollisionDetector.checkCollision(a, a));
        end

        %% Player-Opponent collision
        function testPlayerOpponentCollision(testCase)
            p = Player();
            p.XPos = 0.5;
            p.YPos = 0.15;

            opp = Opponent(0.5, 40);
            opp.YPos = 0.15;  % same position
            opp.Active = true;

            testCase.verifyTrue(CollisionDetector.checkPlayerOpponentCollision(p, opp));
        end

        function testPlayerOpponentNoCollisionWhenFarApart(testCase)
            p = Player();
            p.XPos = 0.1;

            opp = Opponent(0.9, 40);
            opp.YPos = 0.9;
            opp.Active = true;

            testCase.verifyFalse(CollisionDetector.checkPlayerOpponentCollision(p, opp));
        end

        function testInactiveOpponentNoCollision(testCase)
            p = Player();
            opp = Opponent(0.5, 40);
            opp.YPos = 0.15;
            opp.Active = false;

            testCase.verifyFalse(CollisionDetector.checkPlayerOpponentCollision(p, opp));
        end

        %% Player-Gate collision
        function testPlayerGateCollision(testCase)
            p = Player();
            p.XPos = 0.5;
            p.YPos = 0.15;

            gate = MathGate(0.5, 0.15, '1+1=?', 2, [1 2 3 4]);
            testCase.verifyTrue(CollisionDetector.checkPlayerGateCollision(p, gate));
        end

        function testInactiveGateNoCollision(testCase)
            p = Player();
            gate = MathGate(0.5, 0.15, '1+1=?', 2, [1 2 3 4]);
            gate.Active = false;
            testCase.verifyFalse(CollisionDetector.checkPlayerGateCollision(p, gate));
        end

        %% Multiple opponents
        function testCheckAllOpponents(testCase)
            p = Player();
            p.XPos = 0.5;
            p.YPos = 0.15;

            opp1 = Opponent(0.5, 40);
            opp1.YPos = 0.15;  % colliding
            opp1.Active = true;

            opp2 = Opponent(0.9, 40);
            opp2.YPos = 0.9;   % not colliding
            opp2.Active = true;

            opp3 = Opponent(0.5, 40);
            opp3.YPos = 0.15;  % colliding
            opp3.Active = true;

            opponents = [opp1, opp2, opp3];
            idx = CollisionDetector.checkAllOpponents(p, opponents);
            testCase.verifyEqual(sort(idx), [1, 3]);
        end

        function testCheckAllOpponentsNoneColliding(testCase)
            p = Player();
            p.XPos = 0.1;

            opp1 = Opponent(0.9, 40);
            opp1.YPos = 0.9;
            opp1.Active = true;

            idx = CollisionDetector.checkAllOpponents(p, opp1);
            testCase.verifyEmpty(idx);
        end
    end
end
