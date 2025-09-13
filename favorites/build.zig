const std = @import("std");
const solana = @import("solana_program_sdk");
const base58 = @import("base58");

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(solana.sbf_target);
    const optimize = .releaseFast;
    const program = b.addSharedLibrary(.{ .name = "favorites_program", .root_source_file = "src/main.zig", .target = target, .optimize = optimize });

    _ = solana.buildProgram(b, program, target, optimize);
    b.installArtifact(program);

    const install_step = b.addInstallArtifact(program, .{ .dest_dir = .{ .override = .{ .custom = "..program-test/tests/fixtures" } } });
    b.getInstallStep(install_step.step);

    base58.generateProgramKeypair(b, program);
}
