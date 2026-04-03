classdef TestResourceLeaks < matlab.unittest.TestCase
    % TESTRESOURCELEAKS Verifies no figure or timer leaks in the game
    %   Checks that all graphics handles and timers are properly cleaned up.

    methods (Test)
        function testNoFigureLeakOnCleanup(testCase)
            % Record existing figures before test
            existingFigs = findall(0, 'Type', 'figure');

            ge = GameEngine();
            ge.createWindow();
            ge.cleanup();

            % Verify no new figures remain
            remainingFigs = findall(0, 'Type', 'figure');
            testCase.verifyEqual(length(remainingFigs), length(existingFigs), ...
                'Figure leak detected after cleanup');
        end

        function testNoTimerLeakOnCleanup(testCase)
            existingTimers = timerfindall();

            ge = GameEngine();
            ge.createWindow();
            ge.startGame(1);
            pause(0.2);  % let timer run briefly
            ge.cleanup();

            remainingTimers = timerfindall();
            testCase.verifyEqual(length(remainingTimers), length(existingTimers), ...
                'Timer leak detected after cleanup');
        end

        function testNoFigureLeakOnMultipleRestarts(testCase)
            existingFigs = findall(0, 'Type', 'figure');

            ge = GameEngine();
            ge.createWindow();
            ge.startGame(1);
            ge.stopTimer();
            ge.startGame(2);
            ge.stopTimer();
            ge.startGame(3);
            ge.stopTimer();
            ge.cleanup();

            remainingFigs = findall(0, 'Type', 'figure');
            testCase.verifyEqual(length(remainingFigs), length(existingFigs), ...
                'Figure leak on restart');
        end

        function testNoTimerLeakOnMultipleRestarts(testCase)
            existingTimers = timerfindall();

            ge = GameEngine();
            ge.createWindow();
            for i = 1:5
                ge.startGame(1);
                pause(0.1);
                ge.stopTimer();
            end
            ge.cleanup();

            remainingTimers = timerfindall();
            testCase.verifyEqual(length(remainingTimers), length(existingTimers), ...
                'Timer leak on multiple restarts');
        end

        function testNoTimerLeakOnPauseResume(testCase)
            existingTimers = timerfindall();

            ge = GameEngine();
            ge.createWindow();
            ge.startGame(1);
            pause(0.1);
            ge.togglePause();
            ge.togglePause();
            ge.stopTimer();
            ge.togglePause();
            ge.togglePause();
            ge.stopTimer();
            ge.cleanup();

            remainingTimers = timerfindall();
            testCase.verifyEqual(length(remainingTimers), length(existingTimers), ...
                'Timer leak during pause/resume');
        end

        function testNoLeakOnGameOver(testCase)
            existingFigs = findall(0, 'Type', 'figure');
            existingTimers = timerfindall();

            ge = GameEngine();
            ge.createWindow();
            ge.startGame(1);
            pause(0.1);
            ge.gameOver();
            ge.cleanup();

            remainingFigs = findall(0, 'Type', 'figure');
            remainingTimers = timerfindall();
            testCase.verifyEqual(length(remainingFigs), length(existingFigs), ...
                'Figure leak on game over');
            testCase.verifyEqual(length(remainingTimers), length(existingTimers), ...
                'Timer leak on game over');
        end

        function testMathChallengeNoResourceUsage(testCase)
            % MathChallenge is pure logic - verify it uses no graphics resources
            existingFigs = findall(0, 'Type', 'figure');

            mc = MathChallenge(1);
            for i = 1:100
                [~, ~, ~] = mc.generateProblem();
                mc = mc.recordAnswer(rand() > 0.5);
            end

            remainingFigs = findall(0, 'Type', 'figure');
            testCase.verifyEqual(length(remainingFigs), length(existingFigs), ...
                'MathChallenge unexpectedly created figures');
        end
    end
end
