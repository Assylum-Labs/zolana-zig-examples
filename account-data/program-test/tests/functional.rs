use borsh::{BorshDeserialize, BorshSerialize};

#[derive(BorshDeserialize, BorshSerialize, Debug)]
pub struct AddressInfo {
    pub name: String,
    pub house_number: u8,
    pub street: String,
    pub city: String,
}

impl AddressInfo {
    pub fn new(name: String, house_number: u8, street: String, city: String) -> Self {
        AddressInfo {
            name,
            house_number,
            street,
            city,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    use {
        mollusk_svm::{program::keyed_account_for_system_program, Mollusk},
        solana_sdk::{
            account::Account,
            instruction::{AccountMeta, Instruction},
            pubkey,
            pubkey::Pubkey,
        },
    };

    #[test]
    fn test() {
        let program_id = pubkey!("27daoinP2eKLdRkrpYGzBVvHATdFPpPq2b17Ewukb1op");
        let (system_program, system_program_data) = keyed_account_for_system_program();
        let address_info_account = Pubkey::new_unique();
        let payer = Pubkey::new_unique();

        let accounts = vec![
            AccountMeta::new(address_info_account, false),
            AccountMeta::new(payer, true),
            AccountMeta::new(system_program, false),
        ];

        let mut data = vec![0];
        let address_info_data = AddressInfo {
            name: String::from("perelyn"),
            house_number: 0,
            street: String::from("solana"),
            city: String::from("solana"),
        };
        let address_info_data_serialized = borsh::to_vec(&address_info_data).unwrap();
        data.extend(address_info_data_serialized);

        let instruction = Instruction::new_with_bytes(program_id, &data, accounts);

        let base_lamports = 100_000_000u64;

        let accounts = vec![
            (
                address_info_account,
                Account::new(base_lamports, 0, &Pubkey::default()),
            ),
            (payer, Account::new(0, 0, &Pubkey::default())),
            (system_program, system_program_data),
        ];

        let mollusk = Mollusk::new(&program_id, "account_data_program");

        // Execute the instruction and get the result.
        let result = mollusk.process_instruction(&instruction, &accounts);
        dbg!(result.compute_units_consumed);
    }
}
