use serde::Deserialize;

#[derive(Deserialize)]
pub struct Cat {
    pub url: String
}

pub async fn fetch_cats() -> Result<Vec<Cat>, reqwest::Error> {
    Ok(reqwest::get("https://api.thecatapi.com/v1/images/search")
        .await?
        .json::<Vec<Cat>>()
        .await?)
}
