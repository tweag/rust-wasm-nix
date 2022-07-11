//! Test suite for the Web and headless browsers.

#![cfg(target_arch = "wasm32")]

extern crate wasm_bindgen_test;
use wasm_bindgen_test::*;
use wasm::cat_url;

wasm_bindgen_test_configure!(run_in_browser);

#[wasm_bindgen_test]
async fn test_cat_url() {
    let url = cat_url().await;
    assert!(url.starts_with("https://cdn2.thecatapi.com/images/"));
}
