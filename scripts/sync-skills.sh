#!/bin/bash
#
# Syncs canonical skills from _skills/ to apps/website/static/skills/
# and updates the ALL_SKILLS array in install.sh.
#
# Runs automatically before every build (see root package.json).
# You should never edit apps/website/static/skills/ directly.
#

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CANONICAL="${REPO_ROOT}/_skills"
STATIC="${REPO_ROOT}/apps/website/static/skills"
INSTALL_SH="${REPO_ROOT}/apps/website/static/install.sh"

# 1. Copy canonical skills to static/
rm -rf "${STATIC}"
mkdir -p "${STATIC}"

for skill_dir in "${CANONICAL}"/*/; do
    skill_name="$(basename "${skill_dir}")"
    mkdir -p "${STATIC}/${skill_name}"
    cp "${skill_dir}SKILL.md" "${STATIC}/${skill_name}/SKILL.md"
done

skill_count=$(ls -1d "${CANONICAL}"/*/ | wc -l | tr -d ' ')
echo "Synced ${skill_count} skills to static/skills/"

# 2. Update ALL_SKILLS array in install.sh
# Write the replacement block to a temp file
TMPFILE=$(mktemp)
echo "# BEGIN ALL_SKILLS" > "${TMPFILE}"
echo "ALL_SKILLS=(" >> "${TMPFILE}"
for skill_dir in "${CANONICAL}"/*/; do
    skill_name="$(basename "${skill_dir}")"
    echo "    \"${skill_name}\"" >> "${TMPFILE}"
done
echo ")" >> "${TMPFILE}"
echo "# END ALL_SKILLS" >> "${TMPFILE}"

# Replace everything between BEGIN and END markers (inclusive)
# using awk with file reading
awk '
    /^# BEGIN ALL_SKILLS/ { while ((getline line < "'"${TMPFILE}"'") > 0) print line; skip=1; next }
    /^# END ALL_SKILLS/ { skip=0; next }
    !skip { print }
' "${INSTALL_SH}" > "${INSTALL_SH}.tmp"
mv "${INSTALL_SH}.tmp" "${INSTALL_SH}"
chmod +x "${INSTALL_SH}"
rm -f "${TMPFILE}"

echo "Updated ALL_SKILLS in install.sh (${skill_count} skills)"
