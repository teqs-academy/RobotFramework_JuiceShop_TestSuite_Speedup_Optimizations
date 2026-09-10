# Robot Framework Webshop Demo

This repository contains UI and API webshop testing demo using `Python + Robot Framework + Browser` against `OWASP Juice Shop` in a Docker container. The Robot test suites run locally and in GitHub Actions.

## What It Covers

- Homepage, product search, product details, basket, and UI-login flows
- API registration/authentication coverage and API-backed authentication for the authenticated basket, account settings, and checkout flows
- Language switching, saved-address, and payment-card management
- End-to-end checkout: address/delivery/payment selection, order review, and order confirmation
- CSV and Excel test-data examples
- Native Robot reports, screenshots on failure, and GitHub Pages publishing for `main`
- Robot Framework Style Guide checks through Robocop

## Prerequisites

Make sure you have:
- Python 3.11+
- Docker Desktop running, or another Docker installation with `docker` available on PATH
- Node.js
- Git

Clone and install the project

```bash
git clone https://github.com/teqs-academy/RobotFramework_JuiceShop_TestSuite_Speedup_Optimizations
cd RobotFramework_JuiceShop_TestSuite_Speedup_Optimizations
python -m pip install -e .
rfbrowser init
```

`python -m pip install -e .` installs the Python dependencies.
`rfbrowser init` sets up the Node and Playwright dependencies for the Browser Library.

For development, static analysis and for formatting checks, you can optionally use the following:
```bash
python -m pip install -e ".[dev]"
python -m robocop check tests
python -m robocop format --check tests
```

Start the webshop container:

```bash
docker compose -f webshop_app/docker-compose.yml up -d
```

The webshop should now be available on: `http://127.0.0.1:3000`

## Project Structure

- `.github/workflows/ui-tests.yml` contains the GitHub Actions pipeline.
- `scripts/` contains helper scripts grouped by purpose.
    - `wait_for_url.py` performs the shared readiness polling used by CI and local runs.
    - `reporting/build_pages_site.py` copies the latest native Robot outputs into a static site folder and writes a landing page for GitHub Pages.
    - `test_support/search_cases.py` contains Python-backed helper file, to read CSV files.

- `tests/`
    - `api/` contains pure API suites, currently registration and authentication coverage.
    - `data/` contains CSV- and Excel-based scenario input for search coverage.
    - `robot/` contains business-readable Robot suites.
    - `resources/` contains reusable centralized keywords, API authentication, and UI locators.
    - `variables/` contains environment and browser settings.

- `webshop_app/docker-compose.yml` Docker Compose configuration for `OWASP Juice Shop` container.
- `pyproject.toml` defines the Python project metadata and dependencies, including `robotframework-browser`, `robotframework-requests`, `robotframework-datadriver`, and `rpaframework`.

## Starting A Test

You can start tests with:

```bash
# Run the introductory Homepage Smoke test
python -m robot --outputdir results --test "Homepage Smoke" tests/robot/shop_journeys.robot

# Run all API and UI suites (the full-regression scope CI runs on pushes to main)
python -m robot --outputdir results tests

# Run the pull-request baseline: API coverage plus all smoke tests
python -m robot --outputdir results --include api --include smoke tests

# Run API suites only
python -m robot --outputdir results --include api tests

# Run only checkout coverage
python -m robot --outputdir results --include checkout tests

# Run a focused component, for example basket or language coverage
python -m robot --outputdir results --include basket tests
python -m robot --outputdir results --include language tests

# Run UI suites only
python -m robot --outputdir results tests/robot

# Run one suite
python -m robot --outputdir results tests/robot/basket.robot

# Record a video of the UI suites
python -m robot --outputdir results --variable RECORD_VIDEO:True --variable HEADLESS:False tests/robot

# Check Robot formatting and style
python -m robocop format --check tests

# Automatically fix Robot formatting and style
python -m robocop format
```

When a test is finished, you can open `results/report.html` for the summary and `results/log.html` for keyword-level details.

When you are done testing, you can stop the running webshop container:

```bash
docker compose -f webshop_app/docker-compose.yml down --remove-orphans
```

## Test Data Examples

Search coverage demonstrates three data-reading approaches:

- `search_method_1_DataDriver.robot`: DataDriver reads `search_keywords_datadriver.csv` and reports one test per row.
- `search_method_2_Python_Reader.robot`: Python `csv.DictReader` validates and exposes rows from `search_keywords.csv`.
- `search_method_3_RPA_Excel_Files.robot`: `RPA.Excel.Files` reads `search_keywords.xlsx`.

API coverage is in `tests/api/authentication.robot`. It verifies successful and rejected authentication and provides reusable authentication setup for relevant UI flows.

## Tags and Focused Execution

Tags make it possible to select useful test slices without coupling a command to file names. Multiple `--include` options are additive, so `--include api --include smoke` runs both selections together.

- Execution level: `api`, `ui`, `smoke`, `regression`
- UI components: `journeys`, `search`, `language`, `account`, `basket`, `checkout`
- State: `authenticated`

## GitHub Actions Workflow

The workflow runs Robocop checks for every event. Pull requests run the
API-and-smoke baseline (`--include api --include smoke`). Pushes to `main`
and manually dispatched runs execute the full regression suite.

The workflow:

- runs on pull requests
- runs on pushes to `main`
- can be started manually from the GitHub Actions page
- keeps reporting native to Robot

The pipeline:

1. checks out the repository
2. sets up Python
3. installs the project dependencies
4. validates the code with the Robot Style Guide
5. initializes the Browser library and Playwright side
6. starts Juice Shop with Docker Compose
7. waits until the app is reachable
8. runs the API-and-smoke baseline on pull requests, or the full suite on pushes to `main` and manually dispatched runs
9. uploads `results/` as the raw build artifact
10. builds a static site from the same Robot outputs
11. deploys that site to GitHub Pages on pushes to `main`
12. stops the webshop container

To use GitHub Pages for seeing the test results, make sure you have Pages enabled. Set Pages to build from `GitHub Actions` in the repository settings.

## Troubleshooting

When testing locally for many runs, it can happen that the shop will run out of stock. The cleanest way to keep on testing, is to start with a new Docker container:

```bash
docker compose -f webshop_app/docker-compose.yml down --remove-orphans
docker compose -f webshop_app/docker-compose.yml up -d
```

## Conventions

- [Robot Framework User Guide](https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html)
- [Robot Framework Browser Library](https://docs.robotframework.org/docs/different_libraries/browser)
- [Robot Framework Style Guide](https://docs.robotframework.org/docs/style_guide)
