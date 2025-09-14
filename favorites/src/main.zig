const sol = @import("solana_program_sdk");
const sol_lib = @import("solana_program_library");
const std = @import("std");
const Rent = sol.Rent;

export fn entrypoint(input: [*]u8) u64 {
    var context = sol.Context.load(input) catch return 1;

    processInstruction(context.program_id, context.accounts[0..context.num_accounts], context.data) catch |err| return @intFromError(err);

    return 0;
}

pub const ProgramError = error{ InvalidIxData, InvalidAcctData, Unexpected };

pub const Favorites = struct { number: u64, color: [32]u8, hobbies: [4][32]u8 };

pub const InstructionType = enum(u8) { create, get };

pub fn processInstruction(program_id: *sol.PublicKey, accounts: []sol.Account, data: []const u8) ProgramError!void {
    const instruction_type: *const InstructionType = @ptrCast(data);

    switch (instruction_type.*) {
        InstructionType.create => {
            const create_data: *align(1) const Favorites = @ptrCast(data[1..]);

            try create_pda_ix(program_id, accounts, create_data.*);
        },
        InstructionType.get => {
            try get_pda_ix(program_id, accounts);
        },
    }
}

pub fn create_pda_ix(program_id: *sol.PublicKey, accounts: []sol.Account, data: Favorites) ProgramError!void {
    if (!(accounts.len == 3)) return ProgramError.InvalidAcctData;

    const user = accounts[0];
    const favtorites_account = accounts[1];
    const system_program = accounts[2];

    if (!user.isSigner()) return ProgramError.InvalidAcctData;
    if (favtorites_account.dataLen() != 0) return ProgramError.InvalidAcctData;
    if (!sol.PublicKey.equals(system_program.id(), sol_lib.system.id)) return ProgramError.InvalidAcctData;

    const seeds = &[_][]const u8{ "favorites", &user.id().bytes };

    const pda_result = try sol.PublicKey.findProgramAddress(seeds, program_id.*);
    const favorites_pda = pda_result.address;
    const favorites_bump = pda_result.bump_seed[0];

    const signer_seeds = [_][]const []const u8{
        &[_][]const u8{
            "favorites",
            &user.id().bytes,
            &[_]u8{favorites_bump},
        },
    };

    if (!sol.PublicKey.equals(favorites_pda, favtorites_account.id())) return ProgramError.InvalidAcctData;

    if (favtorites_account.dataLen() == 0) {
        const space = @sizeOf(Favorites);
        const rent = try Rent.get();
        const lamports = rent.getMinimumBalance(space);

        sol_lib.system.createAccount(.{ .from = user.info(), .to = favtorites_account.info(), .lamports = lamports, .space = space, .owner_id = program_id.*, .seeds = signer_seeds[0..] }) catch |e| return switch (e) {
            error.InvalidIxData => error.InvalidIxData,
            error.InvalidAcctData => error.InvalidAcctData,
            else => error.Unexpected,
        };

        const bytes = std.mem.asBytes(&data);
        @memcpy(favtorites_account.data()[0..bytes.len], bytes);
    } else return ProgramError.InvalidAcctData;
}

pub fn get_pda_ix(program_id: *sol.PublicKey, accounts: []sol.Account) ProgramError!void {
    if (!(accounts.len == 2)) return ProgramError.InvalidAcctData;

    const user = accounts[0];
    const favtorites_account = accounts[1];

    if (!user.isSigner()) return ProgramError.InvalidAcctData;

    if (favtorites_account.dataLen() == 0) return ProgramError.InvalidAcctData;

    const seeds = &[_][]const u8{ "favorites", &user.id().bytes };
    const pda_result = try sol.PublicKey.findProgramAddress(seeds, program_id.*);
    const favorites_pda = pda_result.address;

    if (!sol.PublicKey.equals(favorites_pda, favtorites_account.id())) return ProgramError.InvalidAcctData;

    const favorites = std.mem.bytesToValue(Favorites, favtorites_account.data());

    const color_str = std.mem.sliceTo(favorites.color[0..], 0);
    var hobby_strs: [4][]const u8 = undefined;
    for (favorites.hobbies, 0..) |hobby, i| {
        hobby_strs[i] = std.mem.sliceTo(&hobby, 0);
    }

    sol.print("User {}'s favorite number is {}, favorite color is: {s}, and their hobbies are {s}, {s}, {s}, {s}", .{ user.id(), favorites.number, color_str, hobby_strs[0], hobby_strs[1], hobby_strs[2], hobby_strs[3] });
}
