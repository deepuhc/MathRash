classdef UIManager
    % UIMANAGER Handles all UI rendering: menus, HUD, dialogs, game over

    properties (Access = public)
        HUDTexts     struct  % handles for HUD text objects
    end

    methods
        function obj = UIManager()
            obj.HUDTexts = struct();
        end

        function renderStartMenu(~, ax)
            % RENDERSTARTMENU Draws the main menu screen
            cla(ax);
            set(ax, 'Color', [0.1 0.1 0.3]);
            hold(ax, 'on');

            % Title
            text(ax, 0.5, 0.8, 'MATH RASH', ...
                'Color', [1 0.9 0], 'FontSize', 36, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', 'FontName', 'Arial');

            % Subtitle
            text(ax, 0.5, 0.68, 'Race & Learn Math!', ...
                'Color', [1 1 1], 'FontSize', 16, ...
                'HorizontalAlignment', 'center', 'FontName', 'Arial');

            % Motorcycle ASCII art
            text(ax, 0.5, 0.52, '___( )___/', ...
                'Color', [1 0.5 0], 'FontSize', 20, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', 'FontName', 'Courier');

            % Instructions
            text(ax, 0.5, 0.35, 'Arrow Keys: Steer  |  1-4: Answer Math', ...
                'Color', [0.8 0.8 0.8], 'FontSize', 12, ...
                'HorizontalAlignment', 'center');

            text(ax, 0.5, 0.28, 'Solve math problems to get SPEED BOOSTS!', ...
                'Color', [0 1 0.5], 'FontSize', 12, ...
                'HorizontalAlignment', 'center');

            % Level selection
            text(ax, 0.5, 0.15, 'Press 1-4 to select starting level:', ...
                'Color', [0.8 0.8 1], 'FontSize', 11, ...
                'HorizontalAlignment', 'center');
            text(ax, 0.5, 0.08, '1: Addition  2: Subtraction  3: Multiplication  4: Division', ...
                'Color', [0.6 0.8 1], 'FontSize', 10, ...
                'HorizontalAlignment', 'center');

            text(ax, 0.5, 0.02, 'Press SPACE to start  |  Q to quit', ...
                'Color', [1 1 0], 'FontSize', 12, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center');

            hold(ax, 'off');
        end

        function renderHUD(~, ax, player, scoreManager, mathChallenge, levelProgress)
            % RENDERHUD Draws the heads-up display overlay
            % Lives
            livesStr = repmat('*', 1, player.Lives);
            text(ax, 0.02, 0.97, ['Lives: ' livesStr], ...
                'Color', [1 0 0], 'FontSize', 10, 'FontWeight', 'bold');

            % Score
            text(ax, 0.02, 0.93, sprintf('Score: %d', scoreManager.TotalScore), ...
                'Color', [1 1 0], 'FontSize', 10, 'FontWeight', 'bold');

            % Speed
            spdColor = [1 1 1];
            if player.isBoosted()
                spdColor = [0 1 1];
            end
            text(ax, 0.02, 0.89, sprintf('Speed: %d km/h', round(player.Speed)), ...
                'Color', spdColor, 'FontSize', 10);

            % Level & Operation
            [op, ~] = mathChallenge.getOperationAndRange();
            opNames = struct('+', 'Addition', '-', 'Subtraction', '*', 'Multiplication', '/', 'Division');
            if isfield(opNames, op)
                opName = opNames.(op);
            else
                opName = 'Mixed';
            end
            text(ax, 0.55, 0.97, sprintf('Level %d: %s', mathChallenge.Level, opName), ...
                'Color', [0.5 1 0.5], 'FontSize', 10, 'FontWeight', 'bold');

            % Streak
            if mathChallenge.Streak > 0
                text(ax, 0.55, 0.93, sprintf('Streak: %d / %d', ...
                    mathChallenge.Streak, mathChallenge.STREAK_TO_LEVEL_UP), ...
                    'Color', [1 0.5 0], 'FontSize', 9);
            end

            % Level progress bar
            barX = 0.55;
            barY = 0.89;
            barW = 0.4;
            barH = 0.02;
            fill(ax, [barX barX+barW barX+barW barX], ...
                     [barY barY barY+barH barY+barH], [0.3 0.3 0.3], 'EdgeColor', 'w');
            fillW = barW * levelProgress / 100;
            if fillW > 0
                fill(ax, [barX barX+fillW barX+fillW barX], ...
                         [barY barY barY+barH barY+barH], [0 0.8 0], 'EdgeColor', 'none');
            end

            % Shield indicator
            if player.isShielded()
                text(ax, 0.35, 0.97, 'SHIELD', ...
                    'Color', [0 1 1], 'FontSize', 10, 'FontWeight', 'bold', ...
                    'HorizontalAlignment', 'center');
            end
        end

        function renderMathPopup(~, ax, question, choices)
            % RENDERMATHPOPUP Shows the math question overlay
            % Semi-transparent background
            fill(ax, [0.1 0.9 0.9 0.1], [0.3 0.3 0.75 0.75], ...
                     [0 0 0.4], 'FaceAlpha', 0.9, 'EdgeColor', [0 1 1], 'LineWidth', 2);

            text(ax, 0.5, 0.65, question, ...
                'Color', [1 1 1], 'FontSize', 20, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center');

            labels = {'1:', '2:', '3:', '4:'};
            colors = {[0.5 1 0.5], [0.5 0.8 1], [1 1 0.5], [1 0.5 0.5]};
            for i = 1:4
                yPos = 0.55 - (i-1) * 0.07;
                text(ax, 0.35, yPos, sprintf('%s  %d', labels{i}, choices(i)), ...
                    'Color', colors{i}, 'FontSize', 14, 'FontWeight', 'bold');
            end
        end

        function renderGameOver(~, ax, scoreManager, mathChallenge)
            % RENDERGAMEOVER Shows the game over / results screen
            cla(ax);
            set(ax, 'Color', [0.1 0.05 0.15]);
            hold(ax, 'on');

            if scoreManager.GameComplete
                titleStr = 'CONGRATULATIONS!';
                titleColor = [0 1 0.5];
            else
                titleStr = 'GAME OVER';
                titleColor = [1 0.3 0.3];
            end

            text(ax, 0.5, 0.85, titleStr, ...
                'Color', titleColor, 'FontSize', 30, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center');

            report = scoreManager.getReport();
            y = 0.7;
            gap = 0.08;

            items = {
                sprintf('Total Score: %d', report.TotalScore), [1 1 0];
                sprintf('Math Score: %d', report.MathScore), [0.5 1 0.5];
                sprintf('Distance Score: %d', report.DistanceScore), [0.5 0.8 1];
                sprintf('Opponents Passed: %d', report.OpponentsPassed), [1 0.5 0];
                sprintf('Level Reached: %d', report.Level), [0.8 0.5 1];
                sprintf('Math Accuracy: %.0f%%', mathChallenge.getAccuracy()), [0 1 1];
                sprintf('Problems Solved: %d / %d', mathChallenge.ProblemsCorrect, mathChallenge.ProblemsAttempted), [1 1 1];
            };

            for i = 1:size(items, 1)
                text(ax, 0.5, y - (i-1)*gap, items{i,1}, ...
                    'Color', items{i,2}, 'FontSize', 13, ...
                    'HorizontalAlignment', 'center');
            end

            text(ax, 0.5, 0.05, 'Press R to restart  |  Q to quit', ...
                'Color', [1 1 0], 'FontSize', 12, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center');

            hold(ax, 'off');
        end

        function renderPlayer(~, ax, player)
            % Draw the player motorcycle
            x = player.XPos;
            y = player.YPos;

            % Body
            bodyColor = [0 0.5 1];
            if player.isShielded()
                bodyColor = [0 1 1];
            elseif player.isBoosted()
                bodyColor = [1 0.5 0];
            end

            % Motorcycle shape
            fill(ax, [x-0.03 x+0.03 x+0.02 x-0.02], ...
                     [y-0.04 y-0.04 y+0.04 y+0.04], bodyColor, 'EdgeColor', 'k');
            % Wheels
            fill(ax, [x-0.02 x+0.02 x+0.02 x-0.02], ...
                     [y-0.05 y-0.05 y-0.04 y-0.04], [0.2 0.2 0.2], 'EdgeColor', 'none');
            fill(ax, [x-0.015 x+0.015 x+0.015 x-0.015], ...
                     [y+0.04 y+0.04 y+0.05 y+0.05], [0.2 0.2 0.2], 'EdgeColor', 'none');

            % Shield glow
            if player.isShielded()
                rectangle(ax, 'Position', [x-0.05, y-0.06, 0.1, 0.12], ...
                    'Curvature', [1 1], 'EdgeColor', [0 1 1], 'LineWidth', 2);
            end
        end

        function renderOpponents(~, ax, opponents)
            for i = 1:length(opponents)
                if ~opponents(i).Active
                    continue;
                end
                opp = opponents(i);
                x = opp.XPos;
                y = opp.YPos;
                c = opp.Color;

                fill(ax, [x-0.025 x+0.025 x+0.018 x-0.018], ...
                         [y-0.035 y-0.035 y+0.035 y+0.035], c, 'EdgeColor', 'k');
                fill(ax, [x-0.018 x+0.018 x+0.018 x-0.018], ...
                         [y-0.045 y-0.045 y-0.035 y-0.035], [0.2 0.2 0.2], 'EdgeColor', 'none');
            end
        end

        function renderGates(~, ax, gates)
            for i = 1:length(gates)
                if ~gates(i).Active
                    continue;
                end
                g = gates(i);
                x = g.XPos;
                y = g.YPos;

                % Glowing gate
                fill(ax, [x-0.06 x+0.06 x+0.06 x-0.06], ...
                         [y-0.025 y-0.025 y+0.025 y+0.025], ...
                         [0.2 0 0.5], 'FaceAlpha', 0.7, 'EdgeColor', [1 0 1], 'LineWidth', 2);
                text(ax, x, y, '?', 'Color', [1 1 0], 'FontSize', 14, ...
                    'FontWeight', 'bold', 'HorizontalAlignment', 'center');
            end
        end
    end
end
