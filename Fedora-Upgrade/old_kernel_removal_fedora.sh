#!/usr/bin/env bash
# Post-Upgrade Procedure fedora 42 -> 43
# 2025-11-01
# Dieses Skript soll alte Kernel, die nicht mehr in Gebrauch sind,
# vom fedora-System entfernen und somit Platz freigeben
# Quelle: https://docs.fedoraproject.org/en-US/quick-docs/upgrading-fedora-offline/#sect-clean-up-old-kernels

old_kernels=($(dnf repoquery --installonly --latest-limit=-1 -q))
if [ "${#old_kernels[@]}" -eq 0 ]; then
    echo "No old kernels found"
    exit 0
fi

if ! dnf remove "${old_kernels[@]}"; then
    echo "Failed to remove old kernels"
    exit 1
fi

echo "Removed old kernels"
exit 0
