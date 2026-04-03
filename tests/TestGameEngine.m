classdef TestGameEngine < matlab.unittest.TestCase
    % TESTGAMEENGINE Integration tests for GameEngine
    %   Tests game flow, state transitions, and math answer handling.
    %   Uses headless approach - tests engine logic without rendering.

    properties
        Engine
    end

    methods (TestMethodSetup)
        function setup(testCase)
            testCase.Engine = GameEngine();
        end
    end

    methods (TestMethodTeardown)
        function teardown(testCase)
            testCase.Engine.cleanup();
        end
    end

    methods (Test)
        %% Initialization
        function testEngineCreation(testCase)
            testCase.verifyEqual(testCase.Engine.State, "menu");
            testCase.verifyTrue(isa(testCase.Engine.Player, 'Player'));
            testCase.verifyTrue(isa(testCase.Engine.MathChal, 'MathChallenge'));
        end

        %% State transitions
        function testStartGameChangesState(testCase)
            ge = testCase.Engine;
            ge.createWindow();
            ge.startGame(1);
            testCase.verifyEqual(ge.State, "playing");
            testCase.verifyTrue(ge.Player.IsAlive);
            ge.stopTimer();
        end

        function testStartGameWithDifferentLevels(testCase)
            ge = testCase.Engine;
            ge.createWindow();

            % Level 1 -> Addition (MathChallenge level 1)
            ge.startGame(1);
            testCase.verifyEqual(ge.MathChal.Level, 1);
            ge.stopTimer();

            % Level 3 -> Multiplication (MathChallenge level 5)
            ge.startGame(3);
            testCase.verifyEqual(ge.MathChal.Level, 5);
            ge.stopTimer();
        end

        function testGameOverChangesState(testCase)
            ge = testCase.Engine;
            ge.createWindow();
            ge.startGame(1);
            ge.stopTimer();
            ge.gameOver();
            testCase.verifyEqual(ge.State, "gameover");
        end

        function testPauseToggle(testCase)
            ge = testCase.Engine;
            ge.createWindow();
            ge.startGame(1);
            ge.stopTimer();
            ge.State = "playing";
            ge.togglePause();
            testCase.verifyEqual(ge.State, "paused");
            ge.togglePause();
            testCase.verifyEqual(ge.State, "playing");
            ge.stopTimer();
        end

        %% Math answer handling
        function testCorrectMathAnswer(testCase)
            ge = testCase.Engine;
            ge.createWindow();
            ge.startGame(1);
            ge.stopTimer();

            % Create a gate with known answer
            gate = MathGate(0.5, 0.15, '2 + 3 = ?', 5, [3 5 7 8]);
            ge.ActiveGate = gate;
            ge.State = "mathpopup";

            % Answer correctly (choice 2 = answer 5)
            ge.handleMathAnswer(2);
            testCase.verifyEqual(ge.State, "playing");
            testCase.verifyTrue(ge.Player.isBoosted());
            ge.stopTimer();
        end

        function testWrongMathAnswer(testCase)
            ge = testCase.Engine;
            ge.createWindow();
            ge.startGame(1);
            ge.stopTimer();

            gate = MathGate(0.5, 0.15, '2 + 3 = ?', 5, [3 5 7 8]);
            ge.ActiveGate = gate;
            ge.State = "mathpopup";

            originalSpeed = ge.Player.BaseSpeed;
            % Answer wrong (choice 1 = 3, not 5)
            ge.handleMathAnswer(1);
            testCase.verifyEqual(ge.State, "playing");
            testCase.verifyLessThan(ge.Player.BaseSpeed, originalSpeed);
            ge.stopTimer();
        end

        %% Key handling
        function testKeyPressMenu(testCase)
            ge = testCase.Engine;
            ge.createWindow();
            ge.State = "menu";

            event = struct('Key', 'space');
            ge.onKeyPress(event);
            testCase.verifyEqual(ge.State, "playing");
            ge.stopTimer();
        end

        function testKeyPressMovement(testCase)
            ge = testCase.Engine;
            ge.createWindow();
            ge.startGame(1);
            ge.stopTimer();

            event = struct('Key', 'leftarrow');
            ge.onKeyPress(event);
            testCase.verifyTrue(ge.KeysDown.left);

            ge.onKeyRelease(event);
            testCase.verifyFalse(ge.KeysDown.left);
        end

        %% Timer management
        function testTimerCleanup(testCase)
            ge = testCase.Engine;
            ge.createWindow();
            ge.startGame(1);
            testCase.verifyFalse(isempty(ge.GameTimer));
            ge.stopTimer();
            testCase.verifyTrue(isempty(ge.GameTimer));
        end

        function testDoubleStopTimerSafe(testCase)
            ge = testCase.Engine;
            ge.stopTimer();  % should not error
            ge.stopTimer();  % should not error
        end

        %% Cleanup
        function testCleanupClosesFigure(testCase)
            ge = testCase.Engine;
            ge.createWindow();
            fig = ge.Fig;
            ge.cleanup();
            testCase.verifyFalse(isvalid(fig));
        end
    end
end
