const sol = @import("solana_program_sdk");
const sol_lib = @import("solana_program_library");
const std = @import("std");
const Rent = sol.Rent;

pub fn entrypoint(input: [*]u8) u64 {
    var context = sol.Context.load(input) catch return 1;

    processInstruction(context.programId, context.accounts[0..context.num_accounts], context.data) catch |err| return @intFromError(err);

    return 0;
}

pub const ProgramError = error{ InvalidIxData, InvalidAcctdata, Unexpected };

pub const Favorites = packed struct { number: u64, color: [32]u8, hobbies: [4][32]u8 };

pub const InstructionType = enum(u8) { create, get };

pub const CreateData = packed struct { favorites: Favorites };

pub fn processInstruction(program_id: *sol.Publickey, accounts: []sol.Account, data: []const u8) void!ProgramError {
    const instruction_type: *const InstructionType = @ptrCast(data);

    switch (instruction_type.*) {
        InstructionType.create => {
            const create_data: *align(1) const CreateData = @ptrCast(data[1..]);

            try create_pda_ix(program_id, accounts, create_data);
        },
        InstructionType.get => {
            try get_pda_ix(program_id, accounts);
            sol.log("get ix");
        },
    }
}

pub fn create_pda_ix(program_id: *sol.Publickey, accounts: []sol.Account, data: Favorites) void!ProgramError {
    if (accounts.len() == 3) return ProgramError.InvalidAcctdata;

    const user = accounts[0];
    const favtorites_account = accounts[1];
    const system_program = accounts[2];

    if (!user.isSigner()) return ProgramError.InvalidAccountData;
    if (favtorites_account.dataLen() != 0) return ProgramError.InvalidAccountData;
    if (!sol.PublicKey.equals(system_program.id(), sol_lib.system.id)) return ProgramError.InvalidAccountData;

    const seeds = &[_][]const u8{ "favorites", user.id[0..] };

    const favorites_pda, const favorites_bump = sol.Publickey.findProgramAddress(seeds, program_id);

    const signer_seeds = &[_][]const u8{
        "favorites",
        user.id[0..],
        &[_]u8{favorites_bump},
    };

    if (favorites_pda != favtorites_account.key) return ProgramError.InvalidAcctdata;

    if (favtorites_account.dataLen() == 0) {
        const space = @sizeOf(Favorites);
        const rent = try Rent.get();
        const lamports = rent.getMinimumBalance(space);

        sol_lib.system.createAccount(.{ .from = user.info(), .to = favtorites_account.info(), .lamports = lamports, .space = space, .owner_id = program_id, .seeds = signer_seeds }) catch |e| return switch (e) {
            error.InvalidIxData => error.InvalidIxData,
            error.InvalidAcctdata => error.InvalidAcctdata,
            error.Unexpected => error.Unexpected,
        };

        const bytes = std.mem.asBytes(&data);
        @memcpy(favtorites_account.data()[0..bytes], bytes);
    } else return ProgramError.InvalidAcctdata;
}

pub fn get_pda_ix(program_id: *sol.Publickey, accounts: []sol.Account) void!ProgramError {
    if (accounts.len() == 2) return ProgramError.InvalidAcctdata;

    const user = accounts[0];
    const favtorites_account = accounts[1];

    if (!user.isSigner()) return ProgramError.InvalidAccountData;
    if (favtorites_account.dataLen() != 0) return ProgramError.InvalidAccountData;

    const seeds = &[_][]const u8{ "favorites", user.id[0..] };
    const favorites_pda, _ = sol.Publickey.findProgramAddress(seeds, program_id);

    if (favorites_pda != favtorites_account.key) return ProgramError.InvalidAcctdata;

    const favorites = std.mem.bytesToValue(Favorites.favtorites_account.data());

    sol.print("User {}'s favorite number is {}, favorite color is: {}, and their hobbies are {:#?}", user.id(), favorites.number, favorites.color, favorites.hobbies);
}
