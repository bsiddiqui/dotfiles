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
    ./scripts/macos-defaults.sh --check

personal-check:
    ./scripts/personal-check.sh

secrets:
    ./scripts/secret-scan.sh
