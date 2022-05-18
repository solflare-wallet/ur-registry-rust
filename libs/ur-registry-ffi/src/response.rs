use crate::types::{PtrString, PtrVoid};
use crate::utils::str_to_ptr_c_char;
use std::ffi::{CString};
use std::ptr::null_mut;

#[repr(C)]
pub struct Response {
    pub status_code: u32,
    pub error_message: PtrString,
    pub data: Value,
}

#[repr(C)]
pub union Value {
    _object: PtrVoid,
    _boolean: bool,
    _uint32: u32,
    _string: PtrString,
    _null: PtrVoid,
}

impl Value {
    pub fn object(o: PtrVoid) -> Self {
        Value { _object: o }
    }
    pub fn boolean(b: bool) -> Self {
        Value { _boolean: b }
    }
    pub fn uint32(u: u32) -> Self {
        Value { _uint32: u }
    }
    pub fn string(s: String) -> Self {
        Value {
            _string: str_to_ptr_c_char(s),
        }
    }
    pub fn null() -> Self {
        Value { _null: null_mut() }
    }
}

pub type PtrResponse = *mut Response;

impl Response {
    pub fn c_ptr(self) -> PtrResponse {
        Box::into_raw(Box::new(self))
    }

    pub fn success(data: Value) -> Self {
        Response {
            status_code: SUCCESS,
            error_message: null_mut(),
            data,
        }
    }

    pub fn error(error_message: String) -> Self {
        Response {
            status_code: ERROR,
            error_message: CString::new(error_message).unwrap().into_raw(),
            data: Value::null(),
        }
    }
}

pub const SUCCESS: u32 = 0;
pub const ERROR: u32 = 1;
