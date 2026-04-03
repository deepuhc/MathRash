classdef GameEngine < handle
    % GAMEENGINE Core game loop and state management for MathRash
    %   Inherits from handle to allow in-place state mutation during callbacks.

    properties (Access = public)
        Player          Player
        Road            Road
        MathChal        MathChallenge
        ScoreMgr        ScoreManager
        UIManager       UIManager
        Opponents       Opponent
        Gates           MathGate
        Fig             matlab.ui.Figure
        Ax              matlab.graphics.axis.Axes
        GameTimer       timer
        State           string = "menu"  % menu, playing, mathpopup, gameover, paused
        DeltaTime       (1,1) double = 0.05  % ~20 FPS
        SpawnTimer      (1,1) double = 0
        GateSpawnTimer  (1,1) double = 0
        ActiveGate      MathGate
        KeysDown        struct
    end

    properties (Constant)
        OPPONENT_SPAWN_INTERVAL = 3  % seconds
        GATE_SPAWN_INTERVAL = 8     % seconds
        FPS = 20
    end

    methods
        function obj = GameEngine()
            obj.Player = Player();
            obj.Road = Road();
            obj.MathChal = MathChallenge(1);
            obj.ScoreMgr = ScoreManager(10);
            obj.UIManager = UIManager();
            obj.Opponents = Opponent.empty(0);
            obj.Gates = MathGate.empty(0);
            obj.ActiveGate = MathGate.empty(0);
            obj.KeysDown = struct('left', false, 'right', false);
        end

        function start(obj)
            % START Initializes the game window and starts the main loop
            obj.createWindow();
            obj.showMenu();
        end

        function createWindow(obj)
            obj.Fig = figure('Name', 'MathRash - Race & Learn!', ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'ToolBar', 'none', ...
                'Color', [0 0 0], ...
                'Position', [100, 100, 600, 800], ...
                'KeyPressFcn', @(~,e) obj.onKeyPress(e), ...
                'KeyReleaseFcn', @(~,e) obj.onKeyRelease(e), ...
                'CloseRequestFcn', @(~,~) obj.cleanup(), ...
                'Resize', 'off');

            obj.Ax = axes(obj.Fig, 'Position', [0 0 1 1], ...
                'XLim', [0 1], 'YLim', [0 1], ...
                'XTick', [], 'YTick', [], ...
                'Box', 'off');
            axis(obj.Ax, 'off');
        end

        function showMenu(obj)
            obj.State = "menu";
            obj.UIManager.renderStartMenu(obj.Ax);
        end

        function startGame(obj, startLevel)
            if nargin < 2
                startLevel = 1;
            end

            % Map level selection: 1=add(L1), 2=sub(L3), 3=mul(L5), 4=div(L7)
            levelMap = [1, 3, 5, 7];
            if startLevel >= 1 && startLevel <= 4
                actualLevel = levelMap(startLevel);
            else
                actualLevel = 1;
            end

            obj.Player = Player();
            obj.Road = Road();
            obj.MathChal = MathChallenge(actualLevel);
            obj.ScoreMgr = ScoreManager(10);
            obj.Opponents = Opponent.empty(0);
            obj.Gates = MathGate.empty(0);
            obj.ActiveGate = MathGate.empty(0);
            obj.SpawnTimer = 0;
            obj.GateSpawnTimer = 0;
            obj.State = "playing";

            obj.startTimer();
        end

        function startTimer(obj)
            obj.stopTimer();
            obj.GameTimer = timer('ExecutionMode', 'fixedRate', ...
                'Period', round(1/obj.FPS, 3), ...
                'TimerFcn', @(~,~) obj.gameLoop(), ...
                'ErrorFcn', @(~,~) obj.stopTimer());
            start(obj.GameTimer);
        end

        function stopTimer(obj)
            if ~isempty(obj.GameTimer) && isvalid(obj.GameTimer)
                stop(obj.GameTimer);
                delete(obj.GameTimer);
            end
            obj.GameTimer = timer.empty;
        end

        function gameLoop(obj)
            if ~isvalid(obj.Fig)
                obj.stopTimer();
                return;
            end

            try
                dt = obj.DeltaTime;

                % Handle continuous movement
                if obj.KeysDown.left
                    obj.Player = obj.Player.moveLeft(dt);
                end
                if obj.KeysDown.right
                    obj.Player = obj.Player.moveRight(dt);
                end

                % Update game objects
                obj.Player = obj.Player.update(dt);
                obj.Road = obj.Road.update(dt, obj.Player.Speed);
                obj.ScoreMgr = obj.ScoreMgr.updateDistance(obj.Player.Distance);

                % Update opponents
                for i = 1:length(obj.Opponents)
                    obj.Opponents(i) = obj.Opponents(i).update(dt, obj.Player.Speed);
                end

                % Update gates
                for i = 1:length(obj.Gates)
                    obj.Gates(i) = obj.Gates(i).update(dt, obj.Player.Speed);
                end

                % Spawn opponents
                obj.SpawnTimer = obj.SpawnTimer + dt;
                if obj.SpawnTimer >= obj.OPPONENT_SPAWN_INTERVAL
                    obj.SpawnTimer = 0;
                    count = min(3, 1 + floor(obj.MathChal.Level / 3));
                    newOpps = Opponent.spawnWave(count, obj.MathChal.Level);
                    obj.Opponents = [obj.Opponents, newOpps];
                end

                % Spawn math gates
                obj.GateSpawnTimer = obj.GateSpawnTimer + dt;
                if obj.GateSpawnTimer >= obj.GATE_SPAWN_INTERVAL
                    obj.GateSpawnTimer = 0;
                    newGate = MathGate.createFromChallenge(obj.MathChal);
                    obj.Gates = [obj.Gates, newGate];
                end

                % Check collisions with opponents
                colIdx = CollisionDetector.checkAllOpponents(obj.Player, obj.Opponents);
                for i = length(colIdx):-1:1
                    obj.Player = obj.Player.takeDamage();
                    obj.Opponents(colIdx(i)).Active = false;
                    if ~obj.Player.IsAlive
                        obj.gameOver();
                        return;
                    end
                end

                % Check collisions with gates
                for i = 1:length(obj.Gates)
                    if obj.Gates(i).Active && ...
                       CollisionDetector.checkPlayerGateCollision(obj.Player, obj.Gates(i))
                        obj.Gates(i).Active = false;
                        obj.ActiveGate = obj.Gates(i);
                        obj.showMathPopup();
                        return;
                    end
                end

                % Clean up inactive objects
                obj.Opponents = obj.Opponents([obj.Opponents.Active]);
                obj.Gates = obj.Gates([obj.Gates.Active]);

                % Check level completion
                if obj.ScoreMgr.LevelComplete
                    obj.ScoreMgr = obj.ScoreMgr.advanceLevel();
                    obj.MathChal = obj.MathChal.levelUp();
                    obj.Player = obj.Player.speedUp();
                end

                % Check game completion
                if obj.ScoreMgr.GameComplete
                    obj.gameOver();
                    return;
                end

                % Render
                obj.renderFrame();

            catch ME
                fprintf('Game loop error: %s\n', ME.message);
            end
        end

        function renderFrame(obj)
            % Render all game elements
            obj.Road.render(obj.Ax);
            hold(obj.Ax, 'on');
            obj.UIManager.renderGates(obj.Ax, obj.Gates);
            obj.UIManager.renderOpponents(obj.Ax, obj.Opponents);
            obj.UIManager.renderPlayer(obj.Ax, obj.Player);

            levelProg = obj.ScoreMgr.getLevelProgress(obj.Player.Distance);
            obj.UIManager.renderHUD(obj.Ax, obj.Player, obj.ScoreMgr, obj.MathChal, levelProg);
            hold(obj.Ax, 'off');
            drawnow limitrate;
        end

        function showMathPopup(obj)
            obj.State = "mathpopup";
            obj.stopTimer();  % pause game while answering
        end

        function handleMathAnswer(obj, choice)
            if isempty(obj.ActiveGate)
                return;
            end

            selectedAnswer = obj.ActiveGate.Choices(choice);
            isCorrect = obj.ActiveGate.checkAnswer(selectedAnswer);
            obj.MathChal = obj.MathChal.recordAnswer(isCorrect);

            if isCorrect
                obj.ScoreMgr = obj.ScoreMgr.addMathScore(obj.MathChal.Level * 10);
                obj.Player = obj.Player.applyBoost(3);
                obj.Player = obj.Player.applyShield(2);
                obj.Player = obj.Player.speedUp();
            else
                obj.Player = obj.Player.slowDown();
            end

            obj.ActiveGate = MathGate.empty(0);
            obj.State = "playing";
            obj.startTimer();
        end

        function gameOver(obj)
            obj.stopTimer();
            obj.State = "gameover";
            obj.UIManager.renderGameOver(obj.Ax, obj.ScoreMgr, obj.MathChal);
        end

        function onKeyPress(obj, event)
            switch obj.State
                case "menu"
                    switch event.Key
                        case 'space'
                            obj.startGame(1);
                        case {'1','2','3','4'}
                            obj.startGame(str2double(event.Key));
                        case 'q'
                            obj.cleanup();
                    end

                case "playing"
                    switch event.Key
                        case 'leftarrow'
                            obj.KeysDown.left = true;
                        case 'rightarrow'
                            obj.KeysDown.right = true;
                        case 'p'
                            obj.togglePause();
                        case 'q'
                            obj.gameOver();
                    end

                case "mathpopup"
                    switch event.Key
                        case {'1','2','3','4'}
                            obj.handleMathAnswer(str2double(event.Key));
                    end

                case "gameover"
                    switch event.Key
                        case 'r'
                            obj.startGame(1);
                        case 'q'
                            obj.cleanup();
                    end

                case "paused"
                    if strcmp(event.Key, 'p')
                        obj.togglePause();
                    end
            end
        end

        function onKeyRelease(obj, event)
            switch event.Key
                case 'leftarrow'
                    obj.KeysDown.left = false;
                case 'rightarrow'
                    obj.KeysDown.right = false;
            end
        end

        function togglePause(obj)
            if obj.State == "playing"
                obj.State = "paused";
                obj.stopTimer();
                hold(obj.Ax, 'on');
                text(obj.Ax, 0.5, 0.5, 'PAUSED', ...
                    'Color', [1 1 0], 'FontSize', 30, 'FontWeight', 'bold', ...
                    'HorizontalAlignment', 'center');
                text(obj.Ax, 0.5, 0.42, 'Press P to resume', ...
                    'Color', [1 1 1], 'FontSize', 14, ...
                    'HorizontalAlignment', 'center');
                hold(obj.Ax, 'off');
            elseif obj.State == "paused"
                obj.State = "playing";
                obj.startTimer();
            end
        end

        function cleanup(obj)
            obj.stopTimer();
            if ~isempty(obj.Fig) && isvalid(obj.Fig)
                delete(obj.Fig);
            end
        end
    end
end
