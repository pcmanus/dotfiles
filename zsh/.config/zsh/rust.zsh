# Full-debug escape hatch for the size-reduced dev profile in ~/.cargo/config.toml.
#
# That config strips debuginfo from dependencies and keeps only line tables for
# workspace crates, which is enough for backtraces but not for stepping in a
# debugger. `cargod` restores full DWARF everywhere for a single invocation.
#
# --config is used rather than CARGO_PROFILE_DEV_DEBUG because the environment
# variable cannot address the `package."*"` glob that strips dependencies.
#
# Note this builds into the same target/ as plain `cargo`, so switching back and
# forth rebuilds the affected crates.
cargod() {
  cargo \
    --config 'profile.dev.debug=2' \
    --config 'profile.dev.package."*".debug=2' \
    "$@"
}
