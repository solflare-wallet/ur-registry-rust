use ur_registry::{crypto_psbt::CryptoPSBT, traits::{From, UR}};

use crate::{
    response::{PtrResponse, Response},
    types::{PtrString, PtrVoid},
    utils::parse_ptr_string_to_bytes,
};

pub fn resolve(data: Vec<u8>) -> PtrResponse {
    match ur_registry::crypto_psbt::CryptoPSBT::from_bytes(data) {
        Ok(result) => Response::success_object(Box::into_raw(Box::new(result)) as PtrVoid).c_ptr(),
        Err(error) => Response::error(error.to_string()).c_ptr(),
    }
}

#[no_mangle]
pub extern "C" fn crypto_psbt_get_data(crypto_psbt: &mut CryptoPSBT) -> PtrResponse {
    Response::success_string(hex::encode(crypto_psbt.get_psbt())).c_ptr()
}

#[no_mangle]
pub extern "C" fn crypto_psbt_construct(data: PtrString) -> PtrResponse {
    let psbt = match parse_ptr_string_to_bytes(data).map_err(|e| Response::error(e)) {
        Ok(v) => v,
        Err(e) => return e.c_ptr(),
    };
    let crypto_psbt = CryptoPSBT::new(psbt);
    Response::success_object(Box::into_raw(Box::new(crypto_psbt)) as PtrVoid).c_ptr()
}

#[no_mangle]
pub extern "C" fn crypto_psbt_get_ur_encoder(crypto_psbt: &mut CryptoPSBT) -> PtrResponse {
    let ur_encoder = crypto_psbt.to_ur_encoder(400);
    Response::success_object(Box::into_raw(Box::new(ur_encoder)) as PtrVoid).c_ptr()
}
