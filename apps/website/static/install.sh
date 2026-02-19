#!/bin/bash
#
# Repolore Skill Installer
# Usage: curl -fsSL repolore.com/install | bash
#        curl -fsSL repolore.com/install | bash -s -- blog x linkedin
#        curl -fsSL repolore.com/install | bash -s -- --dir ~/.config/agents/skills
#

set -e

# Default skills directory (Claude Code)
DEFAULT_SKILLS_DIR="${HOME}/.claude/skills"
SKILLS_DIR="${DEFAULT_SKILLS_DIR}"
REPOLORE_URL="https://repolore.com"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# BEGIN ALL_SKILLS
ALL_SKILLS=(
    "repolore-blog"
    "repolore-changelog"
    "repolore-devto"
    "repolore-init"
    "repolore-linkedin"
    "repolore-newsletter"
    "repolore-reddit"
    "repolore-x"
    "using-repolore"
)
# END ALL_SKILLS

print_banner() {
    echo -e "${BLUE}"
    echo "  _____                _       _"
    echo " |  __ \\              | |     | |"
    echo " | |__) |___  ___ ___ | | ___ | |"
    echo " |  _  // _ \\/ __/ _ \\| |/ _ \\| |"
    echo " | | \\ \\  __/ (_| (_) | | (_) | |"
    echo " |_|  \\_\\___|\\___\\___/|_|\\___/|_|"
    echo ""
    echo -e "  Git Commits to Content${NC}"
    echo ""
}

print_usage() {
    echo "Usage:"
    echo "  curl -fsSL repolore.com/install | bash                              # Install all skills to ~/.claude/skills"
    echo "  curl -fsSL repolore.com/install | bash -s -- blog x                  # Install specific skills"
    echo "  curl -fsSL repolore.com/install | bash -s -- --dir ~/.config/agents/skills  # Custom directory"
    echo ""
    echo "Options:"
    echo "  -d, --dir <path>    Install skills to custom directory"
    echo ""
    echo "Available skills:"
    for skill in "${ALL_SKILLS[@]}"; do
        echo "  - ${skill}"
    done
}

install_skill() {
    local skill=$1
    local skill_dir="${SKILLS_DIR}/${skill}"
    local skill_url="${REPOLORE_URL}/skills/${skill}/SKILL.md"

    echo -e "${BLUE}Installing ${skill}...${NC}"

    # Delete existing repolore skill directory for clean reinstall
    rm -rf "${skill_dir}"

    # Create skill directory
    mkdir -p "${skill_dir}"

    # Download skill file
    if curl -fsSL "${skill_url}" -o "${skill_dir}/SKILL.md" 2>/dev/null; then
        echo -e "${GREEN}✓ ${skill} installed${NC}"
    else
        echo -e "${RED}✗ Failed to install ${skill}${NC}"
        return 1
    fi
}

main() {
    print_banner

    # Determine which skills to install
    local skills_to_install=()

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--dir)
                if [[ -n "$2" ]]; then
                    SKILLS_DIR="$2"
                    shift 2
                else
                    echo -e "${RED}Error: --dir requires a path argument${NC}"
                    print_usage
                    exit 1
                fi
                ;;
            *)
                # It's a skill name
                skills_to_install+=("$1")
                shift
                ;;
        esac
    done

    # Create skills directory
    mkdir -p "${SKILLS_DIR}"

    # If no skills specified, install all
    if [ ${#skills_to_install[@]} -eq 0 ]; then
        # Install all skills
        skills_to_install=("${ALL_SKILLS[@]}")
        echo -e "${YELLOW}Installing all Repolore skills...${NC}"
    else
        # Install specific skills
        local valid_skills=()
        for arg in "${skills_to_install[@]}"; do
            # Normalize skill name (add repolore- prefix if not present)
            if [[ "${arg}" != repolore-* ]]; then
                arg="repolore-${arg}"
            fi

            # Check if skill exists
            local found=false
            for skill in "${ALL_SKILLS[@]}"; do
                if [ "${skill}" = "${arg}" ]; then
                    found=true
                    break
                fi
            done

            if [ "${found}" = true ]; then
                valid_skills+=("${arg}")
            else
                echo -e "${YELLOW}Warning: Unknown skill '${arg}' - skipping${NC}"
            fi
        done
        skills_to_install=("${valid_skills[@]}")
    fi

    if [ ${#skills_to_install[@]} -eq 0 ]; then
        echo -e "${RED}No valid skills to install${NC}"
        print_usage
        exit 1
    fi

    echo ""
    if [ "${SKILLS_DIR}" = "${DEFAULT_SKILLS_DIR}" ]; then
        echo "Installing ${#skills_to_install[@]} skill(s) to ${SKILLS_DIR}"
    else
        echo -e "${YELLOW}Installing ${#skills_to_install[@]} skill(s) to custom directory:${NC}"
        echo "  ${SKILLS_DIR}"
    fi
    echo ""

    # Install each skill
    local installed=0
    for skill in "${skills_to_install[@]}"; do
        if install_skill "${skill}"; then
            ((installed++)) || true
        fi
    done

    echo ""
    echo -e "${GREEN}✓ Installed ${installed} skill(s) to ${SKILLS_DIR}${NC}"
    echo ""
    if [ "${SKILLS_DIR}" = "${DEFAULT_SKILLS_DIR}" ]; then
        echo "Usage (Claude Code):"
        echo "  /repolore-blog"
    else
        echo -e "${YELLOW}Note: Skills installed to custom directory${NC}"
        echo "Make sure your agent system is configured to read from:"
        echo "  ${SKILLS_DIR}"
    fi
    echo ""
}

main "$@"
