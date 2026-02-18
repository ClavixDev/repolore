#!/bin/bash
#
# Repolore Skill Installer
# Usage: curl -fsSL repolore.com/install | bash
#        curl -fsSL repolore.com/install | bash -s -- blog x linkedin
#

set -e

SKILLS_DIR="${HOME}/.claude/skills"
REPOLORE_URL="https://repolore.com"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# All available skills
ALL_SKILLS=(
    "repolore-blog"
    "repolore-x"
    "repolore-linkedin"
    "repolore-reddit"
    "repolore-changelog"
    "repolore-devto"
    "repolore-newsletter"
)

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
    echo "  curl -fsSL repolore.com/install | bash           # Install all skills"
    echo "  curl -fsSL repolore.com/install | bash -s -- blog x    # Install specific skills"
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

    # Create skills directory
    mkdir -p "${SKILLS_DIR}"

    # Determine which skills to install
    local skills_to_install=()

    if [ $# -eq 0 ]; then
        # Install all skills
        skills_to_install=("${ALL_SKILLS[@]}")
        echo -e "${YELLOW}Installing all Repolore skills...${NC}"
    else
        # Install specific skills
        for arg in "$@"; do
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
                skills_to_install+=("${arg}")
            else
                echo -e "${YELLOW}Warning: Unknown skill '${arg}' - skipping${NC}"
            fi
        done
    fi

    if [ ${#skills_to_install[@]} -eq 0 ]; then
        echo -e "${RED}No valid skills to install${NC}"
        print_usage
        exit 1
    fi

    echo ""
    echo "Installing ${#skills_to_install[@]} skill(s)..."
    echo ""

    # Install each skill
    local installed=0
    for skill in "${skills_to_install[@]}"; do
        if install_skill "${skill}"; then
            ((installed++))
        fi
    done

    echo ""
    echo -e "${GREEN}✓ Installed ${installed} skill(s) to ${SKILLS_DIR}${NC}"
    echo ""
    echo "Usage:"
    echo "  /load skill repolore-blog"
    echo ""
    echo "Or install with template:"
    echo "  curl -fsSL repolore.com/install | bash -s -- --with-template"
}

main "$@"
