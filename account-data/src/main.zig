const sol = @import("solana_program_sdk");
const sol_lib = @import("solana_program_library");
const std = @import("std");
const Rent = sol.Rent;

pub const ProgramError = error{ InvalidInstructionData, InvalidAccountData };

pub const AddressInfo = packed struct {
    name: [32]u8,
    house_number: u8,
    street: [64]u8,
    city: [32]u8,

    pub const SIZE = @sizeOf(AddressInfo);

    fn new(name: [32]u8, house_number: u8, street: [64]u8, city: [32]u8) AddressInfo {
        return AddressInfo{ .name = name, .house_number = house_number, .street = street, .city = city };
    }
};

export fn entrypoint(input: [*]u8) u64 {
    var context = sol.Context.load(input) catch return 1;
    processInstruction(context.program_id, context.accounts[0..context.num_accounts], context.data) catch |err| return @intFromError(err);
    return 0;
}

fn processInstruction(program_id: *sol.PublicKey, accounts: []sol.Account, data: []const u8) !ProgramError {
    _ = program_id;

    if (data.len < AddressInfo.SIZE) return ProgramError.InvalidInstructionData;
    if (accounts.len < 3) return ProgramError.InvalidAccountData;

    const address_info: AddressInfo = std.mem.bytesToValue(AddressInfo, data[0..AddressInfo.SIZE]) catch return ProgramError.InvalidInstructionData;

    const address_info_account = accounts[0];
    const payer = accounts[1];
    const system_program = accounts[2];

    if (address_info_account.data.len != 0) return ProgramError.InvalidAccountData;
    if (!payer.isSigner) return ProgramError.InvalidAccountData;
    if (system_program.id != sol_lib.system.id) return ProgramError.InvalidAccountData;

    const space = AddressInfo.SIZE;
    const lamports = (try Rent.get()).getMinimumBalance(space);

    sol_lib.system.createAccount(payer, address_info_account, lamports, space, system_program);

    if (address_info_account.data.len != space) return ProgramError.InvalidAccountData;

    std.mem.copy(u8, address_info_account.data, std.mem.asBytes(&address_info));
}
