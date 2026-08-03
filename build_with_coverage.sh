#!/bin/bash

# Swift Code Coverage Build Script for govsim with Detailed Markdown Reports
# This script builds the govsim project with code coverage enabled and updates README.md
# with per-file coverage details and missed branch snippets

set -e  # Exit on any error

# Configuration
PROJECT_DIR="${PWD}"
PROJECT_NAME="govsim"
DERIVED_DATA_PATH="${PROJECT_DIR}/.build"
COVERAGE_REPORT_PATH="${PROJECT_DIR}/coverage_report"
COVERAGE_SUMMARY_FILE="${COVERAGE_REPORT_PATH}/coverage_summary.txt"
README_FILE="${PROJECT_DIR}/README.md"
PROF_DATA_PATH="${DERIVED_DATA_PATH}/coverage"
DETAILED_README_SECTION="${COVERAGE_REPORT_PATH}/detailed_coverage.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Clean previous builds and coverage data
clean_build() {
    print_message "Cleaning previous build data..."
    rm -rf "${DERIVED_DATA_PATH}"
    rm -rf "${COVERAGE_REPORT_PATH}"
    mkdir -p "${COVERAGE_REPORT_PATH}"
    mkdir -p "${PROF_DATA_PATH}"
}

# Build and test with coverage
build_with_coverage() {
    print_message "Building and testing govsim with code coverage enabled..."
    
    # Build the project
    swift build
    
    # Run tests with code coverage
    swift test --enable-code-coverage --build-path "${DERIVED_DATA_PATH}"
    
    if [ $? -ne 0 ]; then
        print_error "Tests failed!"
        exit 1
    fi
    
    print_message "Tests completed successfully"
}

# Generate detailed coverage data
generate_coverage_data() {
    print_message "Generating coverage data..."
    
    # Find the coverage.profdata file
    PROF_DATA=$(find "${DERIVED_DATA_PATH}" -name "*.profdata" | head -n 1)
    
    if [ -z "${PROF_DATA}" ]; then
        print_error "No .profdata file found!"
        exit 1
    fi
    
    print_message "Found profdata: ${PROF_DATA}"
    
    # Find the test binary
    TEST_BINARY=$(find "${DERIVED_DATA_PATH}" -name "${PROJECT_NAME}PackageTests" -type f -perm +111 | head -n 1)
    
    if [ -z "${TEST_BINARY}" ]; then
        EXEC_BINARY=$(find "${DERIVED_DATA_PATH}" -name "${PROJECT_NAME}" -type f -perm +111 | head -n 1)
        if [ -z "${EXEC_BINARY}" ]; then
            print_error "Could not find any binary to analyze coverage on"
            exit 1
        fi
        BINARY_TO_USE="${EXEC_BINARY}"
    else
        BINARY_TO_USE="${TEST_BINARY}"
    fi
    
    print_message "Using binary: ${BINARY_TO_USE}"
    
    # Generate HTML coverage report with branch information
    print_message "Generating HTML coverage report with branch details..."
    xcrun llvm-cov show \
        --instr-profile="${PROF_DATA}" \
        "${BINARY_TO_USE}" \
        --format=html \
        --output-dir="${COVERAGE_REPORT_PATH}" \
        --ignore-filename-regex=".build|Tests|Caches" \
        --show-branches=count \
        --show-expansions
    
    # Generate detailed per-file summary with branch information
    print_message "Generating per-file coverage summary..."
    xcrun llvm-cov report \
        --instr-profile="${PROF_DATA}" \
        "${BINARY_TO_USE}" \
        --ignore-filename-regex=".build|Tests|Caches" \
        --show-branch-summary > "${COVERAGE_SUMMARY_FILE}"
    
    # Extract overall coverage percentage
    COVERAGE_PERCENTAGE=$(grep -E "^TOTAL" "${COVERAGE_SUMMARY_FILE}" | awk '{print $4}' | sed 's/%//g')
    
    if [ -z "${COVERAGE_PERCENTAGE}" ]; then
        COVERAGE_PERCENTAGE=$(grep -oE '[0-9]+\.[0-9]+%' "${COVERAGE_SUMMARY_FILE}" | head -n 1 | sed 's/%//g')
    fi
    
    if [ -z "${COVERAGE_PERCENTAGE}" ]; then
        COVERAGE_PERCENTAGE="0.0"
    fi
    
    echo "${COVERAGE_PERCENTAGE}" > "${COVERAGE_REPORT_PATH}/coverage_percentage.txt"
    print_message "Overall coverage: ${COVERAGE_PERCENTAGE}%"
}

# Generate detailed markdown report with per-file coverage and missed branches
generate_detailed_markdown() {
    print_message "Generating detailed markdown coverage report..."
    
    cat > "${DETAILED_README_SECTION}" << 'EOF'
## Detailed Code Coverage Report

### Overall Coverage
EOF
    
    # Add overall coverage badge
    COVERAGE_NUM=$(cat "${COVERAGE_REPORT_PATH}/coverage_percentage.txt" | tr -d ' ')
    if (( $(echo "${COVERAGE_NUM} >= 80" | bc -l 2>/dev/null || echo "0") )); then
        COLOR="brightgreen"
    elif (( $(echo "${COVERAGE_NUM} >= 60" | bc -l 2>/dev/null || echo "0") )); then
        COLOR="yellow"
    else
        COLOR="red"
    fi
    echo "![Coverage](https://img.shields.io/badge/Coverage-${COVERAGE_NUM}%25-${COLOR}.svg)" >> "${DETAILED_README_SECTION}"
    echo "" >> "${DETAILED_README_SECTION}"
    
    # Extract per-file coverage data
    echo "### Per-File Coverage Summary" >> "${DETAILED_README_SECTION}"
    echo "" >> "${DETAILED_README_SECTION}"
    echo "| File | Line Coverage | Function Coverage | Branch Coverage |" >> "${DETAILED_README_SECTION}"
    echo "|------|--------------|------------------|----------------|" >> "${DETAILED_README_SECTION}"
    
    # Parse the coverage summary for per-file data
    # Skip the header lines and TOTAL line, extract each file's data
    tail -n +4 "${COVERAGE_SUMMARY_FILE}" | head -n -1 | while read -r line; do
        if [[ -n "$line" ]]; then
            # Extract filename (remove path if present)
            FILENAME=$(echo "$line" | awk '{print $NF}' | xargs basename 2>/dev/null || echo "unknown")
            LINE_COV=$(echo "$line" | awk '{print $4}' 2>/dev/null || echo "N/A")
            FUNC_COV=$(echo "$line" | awk '{print $5}' 2>/dev/null || echo "N/A")
            BRANCH_COV=$(echo "$line" | awk '{print $6}' 2>/dev/null || echo "N/A")
            
            # Clean up the values
            LINE_COV=$(echo "$LINE_COV" | sed 's/%//g')
            FUNC_COV=$(echo "$FUNC_COV" | sed 's/%//g')
            BRANCH_COV=$(echo "$BRANCH_COV" | sed 's/%//g')
            
            echo "| \`$FILENAME\` | ${LINE_COV}% | ${FUNC_COV}% | ${BRANCH_COV}% |" >> "${DETAILED_README_SECTION}"
        fi
    done
    
    echo "" >> "${DETAILED_README_SECTION}"
    
    # Generate missed branches section
    echo "### Missed Branches and Untested Code" >> "${DETAILED_README_SECTION}"
    echo "" >> "${DETAILED_README_SECTION}"
    echo "Below are code snippets showing branches that were not fully covered by tests:" >> "${DETAILED_README_SECTION}"
    echo "" >> "${DETAILED_README_SECTION}"
    
    # Extract missed branches from coverage data
    # This uses llvm-cov show with text output to find uncovered branches
    print_message "Analyzing missed branches..."
    
    # Create a temporary file for uncovered code
    UNCOVERED_FILE="${COVERAGE_REPORT_PATH}/uncovered_code.txt"
    
    # Generate detailed coverage with branch counts
    xcrun llvm-cov show \
        --instr-profile="${PROF_DATA}" \
        "${BINARY_TO_USE}" \
        --ignore-filename-regex=".build|Tests|Caches" \
        --show-branches=count \
        --show-expansions > "${UNCOVERED_FILE}" 2>/dev/null || true
    
    # Parse the uncovered code for branches that weren't fully covered
    # This is a simplified parser - you may need to adjust based on actual output format
    current_file=""
    line_num=0
    
    # Look for uncovered branches (regions that are highlighted as uncovered)
    while IFS= read -r line; do
        # Check for file markers (adjust pattern based on actual output)
        if [[ "$line" =~ ^.*\.swift$ ]]; then
            current_file=$(basename "$line")
            continue
        fi
        
        # Look for lines with branch counts showing uncovered branches
        # Patterns like: "|  0|" or "| 0 |" indicating uncovered code
        if [[ "$line" =~ ^[[:space:]]*\|[[:space:]]*[0-9]+[[:space:]]*\| ]]; then
            line_num=$(echo "$line" | awk -F'|' '{print $2}' | tr -d ' ')
            
            # Check if this line has any branch markers indicating missed branches
            if [[ "$line" =~ "Branch" ]] || [[ "$line" =~ "True" ]] || [[ "$line" =~ "False" ]]; then
                # Extract the code
                code_snippet=$(echo "$line" | sed 's/^.*|.*|//' | sed 's/^[[:space:]]*//')
                
                # If it has branch markers showing missed branches
                if [[ "$line" =~ "False" ]] || [[ "$line" =~ "0" ]]; then
                    echo "#### \`$current_file\` (Line $line_num)" >> "${DETAILED_README_SECTION}"
                    echo '```swift' >> "${DETAILED_README_SECTION}"
                    echo "$code_snippet" >> "${DETAILED_README_SECTION}"
                    echo '```' >> "${DETAILED_README_SECTION}"
                    echo "" >> "${DETAILED_README_SECTION}"
                    
                    # Add a note about which branch was missed
                    if [[ "$line" =~ "True: 0" ]]; then
                        echo "⚠️ True branch not executed" >> "${DETAILED_README_SECTION}"
                    elif [[ "$line" =~ "False: 0" ]]; then
                        echo "⚠️ False branch not executed" >> "${DETAILED_README_SECTION}"
                    fi
                    echo "" >> "${DETAILED_README_SECTION}"
                fi
            fi
        fi
    done < "${UNCOVERED_FILE}"
    
    # If no missed branches were found, add a note
    if ! grep -q "#### \`" "${DETAILED_README_SECTION}"; then
        echo "No missed branches detected! All branches are covered by tests." >> "${DETAILED_README_SECTION}"
        echo "" >> "${DETAILED_README_SECTION}"
    fi
    
    # Add timestamp
    echo "---" >> "${DETAILED_README_SECTION}"
    echo "*Coverage report generated on $(date)*" >> "${DETAILED_README_SECTION}"
    
    print_message "Detailed markdown report generated at ${DETAILED_README_SECTION}"
}

# Update README.md with coverage information
update_readme() {
    print_message "Updating README.md with coverage information..."
    
    # Check if README.md exists
    if [ ! -f "${README_FILE}" ]; then
        print_warning "README.md not found. Creating a new one..."
        echo "# ${PROJECT_NAME}" > "${README_FILE}"
        echo "" >> "${README_FILE}"
    fi
    
    # Check if coverage section exists with markers
    if grep -q "<!-- COVERAGE_DETAIL_START -->" "${README_FILE}" && grep -q "<!-- COVERAGE_DETAIL_END -->" "${README_FILE}"; then
        # Replace content between markers with the detailed report
        sed -i.bak "/<!-- COVERAGE_DETAIL_START -->/,/<!-- COVERAGE_DETAIL_END -->/c\\
<!-- COVERAGE_DETAIL_START -->\\
$(cat ${DETAILED_README_SECTION})\\
<!-- COVERAGE_DETAIL_END -->" "${README_FILE}"
        rm -f "${README_FILE}.bak"
    else
        # Append the detailed coverage section
        echo "" >> "${README_FILE}"
        echo "## Code Coverage" >> "${README_FILE}"
        echo "" >> "${README_FILE}"
        echo "<!-- COVERAGE_DETAIL_START -->" >> "${README_FILE}"
        cat "${DETAILED_README_SECTION}" >> "${README_FILE}"
        echo "<!-- COVERAGE_DETAIL_END -->" >> "${README_FILE}"
    fi
    
    print_message "README.md updated with detailed coverage report"
}

# Display coverage report location
show_coverage_info() {
    print_message "Coverage report generated successfully!"
    echo ""
    echo "Coverage Summary:"
    echo "─────────────────────────────────────"
    head -20 "${COVERAGE_SUMMARY_FILE}"
    echo "─────────────────────────────────────"
    echo ""
    echo "HTML Coverage Report: ${COVERAGE_REPORT_PATH}/index.html"
    echo "Detailed Coverage Summary: ${COVERAGE_SUMMARY_FILE}"
    echo "README.md updated with detailed coverage report"
    echo ""
    
    # Open coverage report in browser if possible
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_message "Opening coverage report in browser..."
        open "${COVERAGE_REPORT_PATH}/index.html" 2>/dev/null || true
    fi
}

# Main execution
main() {
    print_message "Starting govsim detailed code coverage build process..."
    print_message "Project: ${PROJECT_NAME}"
    print_message "Swift version: $(swift --version | head -n 1)"
    
    clean_build
    build_with_coverage
    generate_coverage_data
    generate_detailed_markdown
    update_readme
    show_coverage_info
    
    print_message "Coverage build completed successfully!"
}

# Run main function with error handling
main
exit 0
