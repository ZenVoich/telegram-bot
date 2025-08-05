// import TelegramBot "../src";
// import IC "mo:ic";
// import Debug "mo:base/Debug";

// persistent actor {
// 	public query func transformTelegramRequest(arg : IC.TransformArg) : async IC.HttpRequestResult {
// 		TelegramBot.transformRequest(arg);
// 	};

// 	public func runTests() : async () {
// 		let bot = TelegramBot.TelegramBot("<bot_token>", transformTelegramRequest);

// 		let res = await bot.sendMessage("@mops_feed", "Hello, world!", null);

// 		switch (res) {
// 			case (#ok) {
// 				Debug.print("Message sent successfully");
// 			};
// 			case (#err(err)) {
// 				Debug.trap("Error sending message: " # err);
// 			};
// 		};
// 	};
// };