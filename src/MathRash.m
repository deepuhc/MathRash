function MathRash()
    % MATHRASH Main entry point for the MathRash game
    %   A Road Rash-inspired motorcycle game that teaches kids math!
    %
    %   Controls:
    %     Arrow Keys  - Steer left/right
    %     1-4         - Answer math questions (on menu: select starting level)
    %     SPACE       - Start game (from menu)
    %     P           - Pause/Resume
    %     R           - Restart (from game over screen)
    %     Q           - Quit
    %
    %   How to play:
    %     - Ride your motorcycle down the road
    %     - Avoid opponent motorcycles (they cost you a life!)
    %     - Ride through purple '?' gates to get math questions
    %     - Correct answers give you SPEED BOOST + SHIELD
    %     - Wrong answers slow you down
    %     - Get 5 correct in a row to level up!
    %     - Levels progress through: Addition -> Subtraction ->
    %       Multiplication -> Division -> Mixed operations
    %
    %   Usage:
    %     >> MathRash()

    % Add src to path if not already there
    srcDir = fileparts(mfilename('fullpath'));
    if ~contains(path, srcDir)
        addpath(srcDir);
    end

    % Create and start the game engine
    game = GameEngine();
    game.start();

    fprintf('MathRash started! Have fun learning math!\n');
    fprintf('Use Arrow Keys to steer, press 1-4 to answer questions.\n');
end
