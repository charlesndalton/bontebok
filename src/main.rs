use std::env;
use anyhow::Result;

#[tokio::main]
async fn main() -> Result<()> {
    let telegram_token =
        env::var("BONTEBOK_TELEGRAM_TOKEN").expect("BONTEBOK_TELEGRAM_TOKEN not set");

    let msg = "This is a scheduled weekly reminder to check this Dune dashboard: https://dune.com/tokemak/Tokemak";

    telegram_client::send_message_to_committee(msg, &telegram_token).await?;

    Ok(())
}

mod telegram_client {
    use super::*;

    use urlencoding::encode;

    const TOKEMAK_COMMITTEE_TELEGRAM_CHAT_ID: i64 = -1001175962929;

    pub async fn send_message_to_committee(message: &str, token: &str) -> Result<()> {
        let url = format!(
            "https://api.telegram.org/bot{}/sendMessage?chat_id={}&text={}",
            token,
            TOKEMAK_COMMITTEE_TELEGRAM_CHAT_ID,
            encode(message)
        );

        reqwest::get(url).await?;

        Ok(())
    }
}
