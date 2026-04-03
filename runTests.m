function results = runTests()
    % RUNTESTS Runs all MathRash tests and displays results
    %   Usage: results = runTests()

    % Add source and test directories to path
    rootDir = fileparts(mfilename('fullpath'));
    addpath(fullfile(rootDir, 'src'));
    addpath(fullfile(rootDir, 'tests'));

    fprintf('========================================\n');
    fprintf('  MathRash Test Suite\n');
    fprintf('========================================\n\n');

    % Create test suite from test folder
    suite = matlab.unittest.TestSuite.fromFolder(fullfile(rootDir, 'tests'));

    % Run with verbose output
    runner = matlab.unittest.TestRunner.withTextOutput('Verbosity', 3);

    results = runner.run(suite);

    % Summary
    fprintf('\n========================================\n');
    fprintf('  Test Summary\n');
    fprintf('========================================\n');
    fprintf('  Total:  %d\n', length(results));
    fprintf('  Passed: %d\n', sum([results.Passed]));
    fprintf('  Failed: %d\n', sum([results.Failed]));
    fprintf('  Errors: %d\n', sum([results.Incomplete]));
    fprintf('========================================\n');

    if all([results.Passed])
        fprintf('  ALL TESTS PASSED!\n');
    else
        fprintf('  SOME TESTS FAILED - check output above.\n');
    end
    fprintf('========================================\n');
end
