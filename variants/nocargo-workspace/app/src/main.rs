use std::error::Error;
use cats;

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    let cats = cats::fetch_cats().await?;
    println!("There's a cat at {}", cats[0].url);
    Ok(())
}
