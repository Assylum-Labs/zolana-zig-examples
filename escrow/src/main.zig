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

pub const MakeOffer = struct { id: u64, token_a_offered_amount: u64, token_b_wanted_amount: u64 };

pub const InstructionType = enum(u8) { make, take };

pub fn processInstruction(program_id: *sol.Publickey, accounts: []sol.Account, data: []const u8) ProgramError!void {
    const instruction_type: *const InstructionType = @ptrCast(data);

    switch (instruction_type.*) {
        InstructionType.make => {
            const make_data: *align(1) const MakeOffer = @ptrCast(data[1..]);

            try make_offer(program_id, accounts, make_data);
        },
        InstructionType.take => {
            try take_offer(program_id, accounts, data);
        },
    }
}

pub fn make_offer(program_id: *sol.Publickey, accounts: []sol.Account, data: MakeOffer) ProgramError!void {
    if (!(accounts.len == 10)) return ProgramError.InvalidAcctData;

    const offer = accounts[0];
    const token_mint_a = accounts[1];
    const token_mint_b = accounts[2];
    const maker_token_account_a = accounts[3];
    const vault = accounts[4];
    const maker = accounts[5];
    const payer = accounts[6];
    const token_program = accounts[7];
    const associated_token_program = accounts[8];
    const system_program = accounts[9];

    if (!maker.isSigner()) return ProgramError.InvalidAcctData;

    // something is wrong here
    const seeds = &[_][]const u8{ "offer", &maker.id().bytes, data.id.bytes };

    const offer_pda = try sol.PublicKey.findProgramAddres(seeds, program_id.*);
    const offer_id = offer_pda.address;
    const offer_bump = offer_pda.bump_seed[0];

    if (offer.key != offer_id) return ProgramError.InvalidAcctData;
}

pub fn take_offer(program_id: *sol.Publickey, accounts: []sol.Account, data: []const u8) ProgramError!void {}
