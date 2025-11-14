const std = @import("std");
const solana = @import("solana_program_sdk");
const base58 = @import("base58");

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(solana.sbf_target);
    const optimze = .ReleaseFast;

    const dep_opts = .{ .target = target, .optimize = optimze };

    const solana_lib_dep = b.dependency("solana_program_library", dep_opts);
    const solana_lib_mod = solana_lib_dep.module("solana_program_library");

    const program = b.addSharedLibrary(.{ .name = "escrow_program", .root_source_file = b.path("src/main.zig"), .target = target, .optimize = optimze });

    program.root_module.addImport("solana_program_library", solana_lib_mod);

    _ = solana.buildProgram(b, program, target, optimze);
    b.installArtifact(program);

    const install_step = b.addInstallArtifact(program, .{ .dest_dir = .{ .override = .{ .custom = "../program-test/tests/fixtures" } } });
    b.getInstallStep().dependOn(&install_step.step);

    base58.generateProgramKeypair(b, program);
}
