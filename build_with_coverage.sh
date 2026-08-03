#!/bin/bash

# Swift Code Coverage Build Script for govsim
# This script builds the govsim project with code coverage enabled and updates README.md

set -e  # Exit on any error

# Configuration
PROJECT_DIR="${PWD}"
PROJECT_NAME="govsim"
DERIVED_DATA_PATH="${PROJECT_DIR}/.build"
COVERAGE_REPORT_PATH="${PROJECT_DIR}/coverage_report"
COVERAGE_SUMMARY_FILE="${COVERAGE_REPORT_PATH}/coverage_summary.txt"
README_FILE="${PROJECT_DIR}/README.md"
PROF_DATA_PATH="${DERIVED_DATA_PATH}/coverage"

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

# Generate coverage report
generate_coverage_report() {
    print_message "Generating coverage report..."
    
    # Find the coverage.profdata file
    PROF_DATA=$(find "${DERIVED_DATA_PATH}" -name "*.profdata" | head -n 1)
    
    if [ -z "${PROF_DATA}" ]; then
        print_error "No .profdata file found!"
        print_message "Looking for profdata in: ${DERIVED_DATA_PATH}"
        find "${DERIVED_DATA_PATH}" -name "*.profdata" -type f
        exit 1
    fi
    
    print_message "Found profdata: ${PROF_DATA}"
    
    # Find the test binary
    TEST_BINARY=$(find "${DERIVED_DATA_PATH}" -name "${PROJECT_NAME}PackageTests" -type f -perm +111 | head -n 1)
    
    if [ -z "${TEST_BINARY}" ]; then
        print_warning "Could not find test binary, using llvm-cov with the executable"
        # Try to find the executable
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
    
    # Generate HTML coverage report
    print_message "Generating HTML coverage report..."
    xcrun llvm-cov show \
        --instr-profile="${PROF_DATA}" \
        "${BINARY_TO_USE}" \
        --format=html \
        --output-dir="${COVERAGE_REPORT_PATH}" \
        --ignore-filename-regex=".build|Tests|Caches"
    
    # Generate coverage summary
    print_message "Generating coverage summary..."
    xcrun llvm-cov report \
        --instr-profile="${PROF_DATA}" \
        "${BINARY_TO_USE}" \
        --ignore-filename-regex=".build|Tests|Caches" > "${COVERAGE_SUMMARY_FILE}"
    
    # Also generate a simpler summary for the README
    COVERAGE_SUMMARY_SHORT="${COVERAGE_REPORT_PATH}/coverage_short.txt"
    xcrun llvm-cov report \
        --instr-profile="${PROF_DATA}" \
        "${BINARY_TO_USE}" \
        --ignore-filename-regex=".build|Tests|Caches" \
        | head -20 > "${COVERAGE_SUMMARY_SHORT}"
    
    # Extract overall coverage percentage
    COVERAGE_PERCENTAGE=$(grep -E "^TOTAL" "${COVERAGE_SUMMARY_FILE}" | awk '{print $4}' | sed 's/%//g')
    
    if [ -z "${COVERAGE_PERCENTAGE}" ]; then
        # Try alternative extraction method
        COVERAGE_PERCENTAGE=$(grep -oE '[0-9]+\.[0-9]+%' "${COVERAGE_SUMMARY_FILE}" | head -n 1 | sed 's/%//g')
    fi
    
    if [ -z "${COVERAGE_PERCENTAGE}" ]; then
        COVERAGE_PERCENTAGE="0.0"
        print_warning "Could not extract coverage percentage, defaulting to 0.0"
    else
        print_message "Overall coverage: ${COVERAGE_PERCENTAGE}%"
    fi
    
    # Save coverage percentage for later use
    echo "${COVERAGE_PERCENTAGE}" > "${COVERAGE_REPORT_PATH}/coverage_percentage.txt"
}

# Update README.md with coverage badge
update_readme() {
    print_message "Updating README.md with coverage information..."
    
    # Read coverage percentage
    if [ -f "${COVERAGE_REPORT_PATH}/coverage_percentage.txt" ]; then
        COVERAGE_NUM=$(cat "${COVERAGE_REPORT_PATH}/coverage_percentage.txt" | tr -d ' ')
    else
        COVERAGE_NUM="0.0"
    fi
    
    # Determine color based on coverage percentage
    if (( $(echo "${COVERAGE_NUM} >= 80" | bc -l 2>/dev/null || echo "0") )); then
        COLOR="brightgreen"
    elif (( $(echo "${COVERAGE_NUM} >= 60" | bc -l 2>/dev/null || echo "0") )); then
        COLOR="yellow"
    else
        COLOR="red"
    fi
    
    COVERAGE_BADGE="![Code Coverage](https://img.shields.io/badge/Coverage-${COVERAGE_NUM}%25-${COLOR}.svg)"
    
    # Check if README.md exists
    if [ ! -f "${README_FILE}" ]; then
        print_warning "README.md not found. Creating a new one..."
        echo "# ${PROJECT_NAME}" > "${README_FILE}"
        echo "" >> "${README_FILE}"
        echo "## Code Coverage" >> "${README_FILE}"
        echo "" >> "${README_FILE}"
        echo "${COVERAGE_BADGE}" >> "${README_FILE}"
        echo "" >> "${README_FILE}"
        echo "Coverage report generated on $(date)" >> "${README_FILE}"
    else
        # Check if coverage section exists in README
        if grep -q "## Code Coverage" "${README_FILE}"; then
            # Update existing coverage section using markers
            if grep -q "<!-- COVERAGE_START -->" "${README_FILE}" && grep -q "<!-- COVERAGE_END -->" "${README_FILE}"; then
                # Replace content between markers
                sed -i.bak "/<!-- COVERAGE_START -->/,/<!-- COVERAGE_END -->/c\\
<!-- COVERAGE_START -->\\
${COVERAGE_BADGE}\\
\\
**Overall Coverage: ${COVERAGE_NUM}%**\\
\\
*Last updated: $(date)*\\
<!-- COVERAGE_END -->" "${README_FILE}"
                rm -f "${README_FILE}.bak"
            else
                # Add markers and content
                echo "" >> "${README_FILE}"
                echo "## Code Coverage" >> "${README_FILE}"
                echo "" >> "${README_FILE}"
                echo "<!-- COVERAGE_START -->" >> "${README_FILE}"
                echo "${COVERAGE_BADGE}" >> "${README_FILE}"
                echo "" >> "${README_FILE}"
                echo "**Overall Coverage: ${COVERAGE_NUM}%**" >> "${README_FILE}"
                echo "" >> "${README_FILE}"
                echo "*Last updated: $(date)*" >> "${README_FILE}"
                echo "<!-- COVERAGE_END -->" >> "${README_FILE}"
            fi
        else
            # Append coverage section with markers
            echo "" >> "${README_FILE}"
            echo "## Code Coverage" >> "${README_FILE}"
            echo "" >> "${README_FILE}"
            echo "<!-- COVERAGE_START -->" >> "${README_FILE}"
            echo "${COVERAGE_BADGE}" >> "${README_FILE}"
            echo "" >> "${README_FILE}"
            echo "**Overall Coverage: ${COVERAGE_NUM}%**" >> "${README_FILE}"
            echo "" >> "${README_FILE}"
            echo "*Last updated: $(date)*" >> "${README_FILE}"
            echo "<!-- COVERAGE_END -->" >> "${README_FILE}"
        fi
    fi
    
    print_message "README.md updated with coverage badge: ${COVERAGE_BADGE}"
}

# Display coverage report location
show_coverage_info() {
    print_message "Coverage report generated successfully!"
    echo ""
    echo "Coverage Summary:"
    echo "─────────────────────────────────────"
    cat "${COVERAGE_SUMMARY_FILE}"
    echo "─────────────────────────────────────"
    echo ""
    echo "HTML Coverage Report: ${COVERAGE_REPORT_PATH}/index.html"
    echo "Coverage Summary: ${COVERAGE_SUMMARY_FILE}"
    echo "README.md updated with coverage badge"
    echo ""
    
    # Open coverage report in browser if possible
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_message "Opening coverage report in browser..."
        open "${COVERAGE_REPORT_PATH}/index.html" 2>/dev/null || true
    fi
}

# Main execution
main() {
    print_message "Starting govsim code coverage build process..."
    print_message "Project: ${PROJECT_NAME}"
    print_message "Swift version: $(swift --version | head -n 1)"
    
    clean_build
    build_with_coverage
    generate_coverage_report
    update_readme
    show_coverage_info
    
    print_message "Coverage build completed successfully!"
}

# Run main function with error handling
main
exit 0
