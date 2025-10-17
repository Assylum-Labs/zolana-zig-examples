const std = @import("std");
const solana = @import("solana_program_sdk");
const base58 = @import("base58");

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(solana.sbf_target);
    const optimze = .ReleaseFast;

    const program = b.addSharedLibrary(.{ .name = "escrow_program", .root_source_file = "src/main.zig", .target = target, .optimize = optimze });

    _ = solana.buildProgram(b, program, target, optimze);
    b.installArtifact(program);
}
