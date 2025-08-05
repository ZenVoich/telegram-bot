# telegram-bot

A simple Telegram Bot library for Motoko.

Currently implemented bot API methods:
- `sendMessage`

## Install
```
mops add telegram-bot
```

## Usage
```motoko
import TelegramBot "mo:telegram-bot";
import IC "mo:ic";

actor {
  public query func transformTelegramRequest(arg : IC.TransformArg) : async IC.HttpRequestResult {
    TelegramBot.transformRequest(arg);
  };

  public func send() : async () {
    // Get bot token from https://t.me/BotFather
    let bot = TelegramBot.TelegramBot("<bot_token>", transformTelegramRequest);

    // Send a message to Telegram chat or channel
    let res = await bot.sendMessage("<chat_id>", "Hello, world!", null);

    switch (res) {
      case (#ok) {
        // ...
      };
      case (#err(err)) {
        // ...
      };
    };
  };
};
```
