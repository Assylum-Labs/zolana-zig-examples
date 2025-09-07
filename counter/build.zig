const std = @import("std");
const solana = @import("solana_program_sdk");

pub fn build(b: *std.Build) !void {
    const target = b.resolveTargetQuery(solana.sbf_target);
    const optimize = .ReleaseFast;
    const program = b.AddSharedLibrary(.{ .name = "counter_program", .root_source_file = "main.zig", .target = target, .optimize = optimize });

    _ = solana.buildProgram(b, program, target, optimize);
    b.installArtifact(program);
}
