classdef TestPlayer < matlab.unittest.TestCase
    % TESTPLAYER Unit tests for Player class

    properties
        P
    end

    methods (TestMethodSetup)
        function setup(testCase)
            testCase.P = Player();
        end
    end

    methods (Test)
        %% Initialization
        function testDefaultValues(testCase)
            p = testCase.P;
            testCase.verifyEqual(p.Lives, 3);
            testCase.verifyEqual(p.XPos, 0.5);
            testCase.verifyTrue(p.IsAlive);
            testCase.verifyEqual(p.Distance, 0);
        end

        %% Movement
        function testMoveLeftDecreasesX(testCase)
            p = testCase.P;
            original = p.XPos;
            p = p.moveLeft(0.1);
            testCase.verifyLessThan(p.XPos, original);
        end

        function testMoveRightIncreasesX(testCase)
            p = testCase.P;
            original = p.XPos;
            p = p.moveRight(0.1);
            testCase.verifyGreaterThan(p.XPos, original);
        end

        function testMoveLeftBoundary(testCase)
            p = testCase.P;
            for i = 1:100
                p = p.moveLeft(0.1);
            end
            testCase.verifyGreaterThanOrEqual(p.XPos, 0.1);
        end

        function testMoveRightBoundary(testCase)
            p = testCase.P;
            for i = 1:100
                p = p.moveRight(0.1);
            end
            testCase.verifyLessThanOrEqual(p.XPos, 0.9);
        end

        %% Update
        function testUpdateAccumulatesDistance(testCase)
            p = testCase.P;
            p = p.update(1.0);
            testCase.verifyGreaterThan(p.Distance, 0);
        end

        function testUpdateDecrementsShieldTimer(testCase)
            p = testCase.P;
            p = p.applyShield(5);
            p = p.update(2);
            testCase.verifyEqual(p.ShieldTimer, 3);
        end

        function testUpdateDecrementsBoostTimer(testCase)
            p = testCase.P;
            p = p.applyBoost(5);
            p = p.update(2);
            testCase.verifyEqual(p.BoostTimer, 3);
        end

        function testShieldTimerNeverNegative(testCase)
            p = testCase.P;
            p = p.applyShield(1);
            p = p.update(5);
            testCase.verifyEqual(p.ShieldTimer, 0);
        end

        function testBoostIncreasesSpeed(testCase)
            p = testCase.P;
            baseSpeed = p.Speed;
            p = p.applyBoost(5);
            p = p.update(0.1);
            testCase.verifyGreaterThan(p.Speed, baseSpeed);
        end

        function testNoUpdateWhenDead(testCase)
            p = testCase.P;
            p.IsAlive = false;
            dist = p.Distance;
            p = p.update(1);
            testCase.verifyEqual(p.Distance, dist);
        end

        %% Damage
        function testTakeDamageReducesLives(testCase)
            p = testCase.P;
            p = p.takeDamage();
            testCase.verifyEqual(p.Lives, 2);
        end

        function testDiesAtZeroLives(testCase)
            p = testCase.P;
            p = p.takeDamage();
            p = p.takeDamage();
            p = p.takeDamage();
            testCase.verifyFalse(p.IsAlive);
        end

        function testShieldBlocksDamage(testCase)
            p = testCase.P;
            p = p.applyShield(5);
            p = p.takeDamage();
            testCase.verifyEqual(p.Lives, 3);
        end

        %% Lives
        function testAddLife(testCase)
            p = testCase.P;
            p = p.takeDamage();
            p = p.addLife();
            testCase.verifyEqual(p.Lives, 3);
        end

        function testAddLifeCappedAtMax(testCase)
            p = testCase.P;
            for i = 1:10
                p = p.addLife();
            end
            testCase.verifyEqual(p.Lives, p.MaxLives);
        end

        %% Speed
        function testSpeedUp(testCase)
            p = testCase.P;
            original = p.BaseSpeed;
            p = p.speedUp();
            testCase.verifyGreaterThan(p.BaseSpeed, original);
        end

        function testSlowDown(testCase)
            p = testCase.P;
            original = p.BaseSpeed;
            p = p.slowDown();
            testCase.verifyLessThan(p.BaseSpeed, original);
        end

        function testSpeedNeverExceedsMax(testCase)
            p = testCase.P;
            for i = 1:100
                p = p.speedUp();
            end
            testCase.verifyLessThanOrEqual(p.BaseSpeed, p.MaxSpeed);
        end

        function testSlowDownMinimumSpeed(testCase)
            p = testCase.P;
            for i = 1:100
                p = p.slowDown();
            end
            testCase.verifyGreaterThanOrEqual(p.BaseSpeed, 20);
        end

        %% Hitbox
        function testHitboxFormat(testCase)
            hb = testCase.P.getHitbox();
            testCase.verifySize(hb, [1, 4]);
            testCase.verifyLessThan(hb(1), hb(2));  % xMin < xMax
            testCase.verifyLessThan(hb(3), hb(4));  % yMin < yMax
        end

        %% Status queries
        function testIsShielded(testCase)
            p = testCase.P;
            testCase.verifyFalse(p.isShielded());
            p = p.applyShield(5);
            testCase.verifyTrue(p.isShielded());
        end

        function testIsBoosted(testCase)
            p = testCase.P;
            testCase.verifyFalse(p.isBoosted());
            p = p.applyBoost(5);
            testCase.verifyTrue(p.isBoosted());
        end
    end
end
