// #[derive(Debug)]
// #[repr(C)]
// pub struct Favorites {
//     pub number: u64,
//     pub color: [u8; 32],
//     pub hobbies: [[u8; 32]; 4],
// }

// impl Favorites {
//     pub fn new(number: u64, color: &str, hobbies: Vec<&str>) -> Self {
//         let mut favaorites = Favorites {
//             number,
//             color: [0; 32],
//             hobbies: [[0; 32]; 4],
//         };

//         let color_bytes = color.as_bytes();
//         let copy_len = color_bytes.len().min(32);
//         favaorites.color[..copy_len].copy_from_slice(&color_bytes[..copy_len]);

//         for (i, e) in hobbies.iter().enumerate().take(4) {
//             let bytes = e.as_bytes();
//             let len = e.len().min(32);
//             favaorites.hobbies[i][..len].copy_from_slice(&bytes[..len]);
//         }

//         favaorites
//     }
// }
// #[cfg(test)]
// mod tests {
//     use super::*;

//     use {
//         mollusk_svm::{
//             account_store::AccountStore, program::keyed_account_for_system_program, Mollusk,
//         },
//         solana_sdk::{
//             account::Account,
//             instruction::{AccountMeta, Instruction},
//             pubkey,
//             pubkey::Pubkey,
//         },
//         std::collections::HashMap,
//     };

//     // Simple in-memory account store implementation
//     #[derive(Default)]
//     struct InMemoryAccountStore {
//         accounts: HashMap<Pubkey, Account>,
//     }

//     impl AccountStore for InMemoryAccountStore {
//         fn get_account(&self, pubkey: &Pubkey) -> Option<Account> {
//             self.accounts.get(pubkey).cloned()
//         }

//         fn store_account(&mut self, pubkey: Pubkey, account: Account) {
//             self.accounts.insert(pubkey, account);
//         }
//     }
//     #[ignore]
//     #[test]
//     fn test() {
//         let program_id = pubkey!("kxKpwU7ZKheCSCDqwHyQUBW86GDGxci4ceK1xgzsWUn");
//         let (system_program, system_program_data) = keyed_account_for_system_program();

//         let user = Pubkey::new_unique();
//         let (favourites_account, _) =
//             Pubkey::find_program_address(&[b"favorites", user.as_ref()], &program_id);

//         let accounts = vec![
//             AccountMeta::new(user, true),
//             AccountMeta::new(favourites_account, true),
//             AccountMeta::new_readonly(system_program, false),
//         ];

//         let mut data = vec![0];
//         let favorites_info_data = Favorites::new(200, "purple", vec!["tx", "ix", "mev", "bundle"]);

//         println!("{:?}", &favorites_info_data);

//         // Convert struct to bytes using unsafe transmute since we have #[repr(C)]
//         let favorites_info_bytes = unsafe {
//             std::slice::from_raw_parts(
//                 &favorites_info_data as *const Favorites as *const u8,
//                 std::mem::size_of::<Favorites>(),
//             )
//         };
//         println!("{:?}", &favorites_info_bytes);

//         data.extend_from_slice(favorites_info_bytes);

//         let instruction = Instruction::new_with_bytes(program_id, &data, accounts);

//         let base_lamports = 100_000_000u64;

//         let accounts = vec![
//             (favourites_account, Account::new(0, 0, &Pubkey::default())),
//             (user, Account::new(base_lamports, 0, &Pubkey::default())),
//             (system_program, system_program_data),
//         ];

//         let mollusk = Mollusk::new(&program_id, "favorites_program");
//         let context = mollusk.with_context(InMemoryAccountStore::default());

//         // Execute the instruction and get the result.
//         // let result = mollusk.process_instruction(&instruction, &accounts);
//         let result = context.process_instruction(&instruction);
//         dbg!(result.compute_units_consumed);

//         // test get_pda ix
//         let accounts = vec![
//             AccountMeta::new(user, true),
//             AccountMeta::new(favourites_account, false),
//         ];
//         let data = vec![1];
//         let instruction = Instruction::new_with_bytes(program_id, &data, accounts);
//         let accounts = vec![
//             (favourites_account, Account::new(0, 0, &Pubkey::default())),
//             (user, Account::new(base_lamports, 0, &Pubkey::default())),
//         ];
//         // let result = mollusk.process_instruction(&instruction, &accounts);
//         let result = context.process_instruction(&instruction);
//         dbg!(result.compute_units_consumed);
//     }
// }
