default:
    @just --list

bootstrap:
    ./bootstrap.sh

link:
    ./link.sh

doctor:
    ./doctor.sh

doctor-personal:
    ./doctor.sh --personal

audit-machine:
    ./scripts/audit-machine.sh

macos-check:
    ./scripts/macos-settings.sh --check
    @if [ -f docs/machine-candidates.md ]; then ./scripts/macos-defaults.sh --check; else echo "ok: no machine candidate macOS rows"; fi

macos-apply:
    ./scripts/macos-settings.sh --apply

personal-check:
    ./scripts/personal-check.sh

secrets:
    ./scripts/secret-scan.sh
