import IC "mo:ic";
import Call "mo:ic/Call";
import {JSON} "mo:serde";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Result "mo:base/Result";
import Blob "mo:base/Blob";

module {
	public type Formatting = {
		#Plain;
		#Markdown;
		#MarkdownV2;
		#HTML;
	};

	/// https://core.telegram.org/bots/api#linkpreviewoptions
	///
	/// `is_disabled`: True, if the link preview is disabled
	/// `url`: URL to use for the link preview. If empty, then the first URL found in the message text will be used
	/// `prefer_small_media`: True, if the media in the link preview is supposed to be shrunk; ignored if the URL isn't explicitly specified or media size change isn't supported for the preview
	/// `prefer_large_media`: True, if the media in the link preview is supposed to be enlarged; ignored if the URL isn't explicitly specified or media size change isn't supported for the preview
	/// `show_above_text`: True, if the link preview must be shown above the message text; otherwise
	public type LinkPreviewOptions = {
		is_disabled : Bool;
		url : ?Text;
		prefer_small_media : Bool;
		prefer_large_media : Bool;
		show_above_text : Bool;
	};

	/// `parse_mode`: Mode for parsing entities in the message text (default: `#MarkdownV2`)
	/// `link_preview_options`: Link preview generation options for the message (default: `null`)
	/// `disable_notification`: Sends the message silently. Users will receive a notification with no sound. (default: `null`)
	public type SendMessageOptions = {
		parse_mode : ?Formatting;
		link_preview_options : ?LinkPreviewOptions;
		disable_notification : ?Bool;
	};

	public class TelegramBot(token : Text, transformFunction : IC.TransformFunction) {
		func _method(method : Text) : Text {
			return "https://api.telegram.org/bot" # token # "/" # method;
		};

		/// Send a message to the chat
		public func sendMessage(chat_id : Text, text : Text, options : ?SendMessageOptions) : async Result.Result<(), Text> {
			let defaultOptions : SendMessageOptions = {
				parse_mode = null;
				disable_notification = null;
				link_preview_options = null;
			};

			let opts = Option.get(options, defaultOptions);

			var params = {
				chat_id = chat_id;
				text = text;
				parse_mode = _formattingToOptText(Option.get(opts.parse_mode, #Plain));
				disable_notification = opts.disable_notification;
				link_preview_options = Option.get(opts.link_preview_options, {});
			};

			let keys = [
				"chat_id",
				"text",
				"parse_mode",
				"disable_notification",
				"link_preview_options"
			];

			var jsonRes : Result.Result<Text, Text> = #ok("{}");

			// hack: if parse_mode is null, we need to remove it from the json
			if (Option.isNull(opts.parse_mode)) {
				jsonRes := JSON.toText(to_candid({
					chat_id = params.chat_id;
					text = params.text;
					disable_notification = params.disable_notification;
					link_preview_options = params.link_preview_options;
				}), keys, null);
			}
			else {
				jsonRes := JSON.toText(to_candid(params), keys, null);
			};

			let json = switch (jsonRes) {
				case (#ok(json)) json;
				case (#err(err)) {
					return #err(err);
				};
			};

			let res = await Call.httpRequest({
				url = _method("sendMessage");
				method = #post;
				max_response_bytes = ?(1024 * 200);
				body = ?Text.encodeUtf8(json);
				transform = ?{
					function = transformFunction;
					context = Blob.fromArray([]);
				};
				is_replicated = ?false;
				headers = [
					{
						name = "Content-Type";
						value = "application/json";
					}
				];
			});

			if (res.status != 200) {
				return #err("HTTP error: " # debug_show(res.status) # " " # debug_show(Option.get(Text.decodeUtf8(res.body), "")));
			};

			#ok;
		};
	};

	func _formattingToOptText(formatting : Formatting) : ?Text {
		switch (formatting) {
			case (#Plain) {
				return null;
			};
			case (#MarkdownV2) {
				return ?"MarkdownV2";
			};
			case (#HTML) {
				return ?"HTML";
			};
			case (#Markdown) {
				return ?"Markdown";
			};
		};
	};

	func _escapeChars(chars : Text, text : Text) : Text {
		var res = text;
		for (char in chars.chars()) {
			res := Text.replace(res, #char(char), "\\\\" # Text.fromChar(char));
		};
		res;
	};

	/// https://core.telegram.org/bots/api#markdown-style
	public func escapeMarkdown(text : Text) : Text {
		_escapeChars("_*[]()", text);
	};

	/// https://core.telegram.org/bots/api#markdownv2-style
	public func escapeMarkdownV2(text : Text) : Text {
		_escapeChars("_*[]()~`>#+-=|{}.!", text);
	};

	/// https://core.telegram.org/bots/api#html-style
	public func escapeHTML(text : Text) : Text {
		_escapeChars("<>&", text);
	};

	public func transformRequest(arg : IC.TransformArg) : IC.HttpRequestResult {
		{
			status = arg.response.status;
			body = arg.response.body;
			headers = [];
		};
	};
};