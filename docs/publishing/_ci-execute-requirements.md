
- You need to reconstitute all of the dependencies (R, Python, or Julia plus the correct versions of required packages) in the CI environment.

- If your code requires any special permissions (e.g. database or network access) those permissions also need to be present on the CI server.

- Your project may contain documents that can no longer be easily executed (e.g. blog posts from several years ago that use older versions of packages). These documents may need to have `freeze` individually enabled for them to prevent execution on CI.



