import {test; suite; expect} "mo:test";
import {escapeMarkdownV2; escapeMarkdown; escapeHTML} "../src";

suite("escapeMarkdownV2", func() {
	test("basic formatting characters", func() {
		expect.text(escapeMarkdownV2("*Hello* _world_!")).equal("\\\\*Hello\\\\* \\\\_world\\\\_\\\\!");
	});

	test("all special characters", func() {
		expect.text(escapeMarkdownV2("_*[]()~`>#+-=|{}.!")).equal("\\\\_\\\\*\\\\[\\\\]\\\\(\\\\)\\\\~\\\\`\\\\>\\\\#\\\\+\\\\-\\\\=\\\\|\\\\{\\\\}\\\\.\\\\!");
	});

	test("empty string", func() {
		expect.text(escapeMarkdownV2("")).equal("");
	});

	test("no special characters", func() {
		expect.text(escapeMarkdownV2("Hello world")).equal("Hello world");
	});

	test("consecutive special characters", func() {
		expect.text(escapeMarkdownV2("***___")).equal("\\\\*\\\\*\\\\*\\\\_\\\\_\\\\_");
	});

	test("mixed content", func() {
		expect.text(escapeMarkdownV2("Hello *bold* and _italic_ text!")).equal("Hello \\\\*bold\\\\* and \\\\_italic\\\\_ text\\\\!");
	});

	test("code blocks", func() {
		expect.text(escapeMarkdownV2("```code``` and `inline`")).equal("\\\\`\\\\`\\\\`code\\\\`\\\\`\\\\` and \\\\`inline\\\\`");
	});

	test("links and references", func() {
		expect.text(escapeMarkdownV2("[link](url) and >quote")).equal("\\\\[link\\\\]\\\\(url\\\\) and \\\\>quote");
	});

	test("mathematical expressions", func() {
		expect.text(escapeMarkdownV2("x + y = z, a - b, c * d")).equal("x \\\\+ y \\\\= z, a \\\\- b, c \\\\* d");
	});

	test("complex formatting", func() {
		expect.text(escapeMarkdownV2("~strikethrough~ |spoiler| {custom}")).equal("\\\\~strikethrough\\\\~ \\\\|spoiler\\\\| \\\\{custom\\\\}");
	});

	test("unicode characters", func() {
		expect.text(escapeMarkdownV2("Héllo 世界 *bold*")).equal("Héllo 世界 \\\\*bold\\\\*");
	});

	test("numbers and special chars", func() {
		expect.text(escapeMarkdownV2("1 + 2 = 3, x > y")).equal("1 \\\\+ 2 \\\\= 3, x \\\\> y");
	});

	test("long string with repeating pattern", func() {
		let input = "*_*_*_*_";
		expect.text(escapeMarkdownV2(input)).equal("\\\\*\\\\_\\\\*\\\\_\\\\*\\\\_\\\\*\\\\_");
	});

	test("mixed language content", func() {
		expect.text(escapeMarkdownV2("English *text* and русский _текст_!")).equal("English \\\\*text\\\\* and русский \\\\_текст\\\\_\\\\!");
	});

	test("should not escape @ $ % ^ & : ; quotes", func() {
		expect.text(escapeMarkdownV2("Email: user@domain.com, $100, 50%, x^2, A&B, time:now; \"quoted\"")).equal("Email: user@domain\\\\.com, $100, 50%, x^2, A&B, time:now; \"quoted\"");
	});

	test("should not escape slashes and punctuation", func() {
		expect.text(escapeMarkdownV2("Path: /home/user, question?, comma,")).equal("Path: /home/user, question?, comma,");
	});

	test("should not escape whitespace and line breaks", func() {
		expect.text(escapeMarkdownV2("Line 1\nLine 2\tTabbed")).equal("Line 1\nLine 2\tTabbed");
	});

	test("mixed escaped and non-escaped", func() {
		expect.text(escapeMarkdownV2("Email *user@domain.com* costs $50! Use code 'SAVE20'")).equal("Email \\\\*user@domain\\\\.com\\\\* costs $50\\\\! Use code 'SAVE20'");
	});
});

suite("escapeMarkdown", func() {
	test("basic formatting characters", func() {
		expect.text(escapeMarkdown("*Hello* _world_!")).equal("\\\\*Hello\\\\* \\\\_world\\\\_!");
	});

	test("all special characters", func() {
		expect.text(escapeMarkdown("_*[]()")).equal("\\\\_\\\\*\\\\[\\\\]\\\\(\\\\)");
	});

	test("empty string", func() {
		expect.text(escapeMarkdown("")).equal("");
	});

	test("no special characters", func() {
		expect.text(escapeMarkdown("Hello world 123")).equal("Hello world 123");
	});

	test("consecutive brackets", func() {
		expect.text(escapeMarkdown("[[nested]] ((parentheses))")).equal("\\\\[\\\\[nested\\\\]\\\\] \\\\(\\\\(parentheses\\\\)\\\\)");
	});

	test("mixed with non-special chars", func() {
		expect.text(escapeMarkdown("Check this *important* [link](url)")).equal("Check this \\\\*important\\\\* \\\\[link\\\\]\\\\(url\\\\)");
	});

	test("real world example", func() {
		expect.text(escapeMarkdown("Visit [Google](https://google.com) for *search*")).equal("Visit \\\\[Google\\\\]\\\\(https://google.com\\\\) for \\\\*search\\\\*");
	});

	test("should not escape MarkdownV2 specific chars", func() {
		expect.text(escapeMarkdown("~strikethrough~ `code` >quote #header +list -item =spoiler |table| {custom} .dot !exclamation")).equal("~strikethrough~ `code` >quote #header +list -item =spoiler |table| {custom} .dot !exclamation");
	});

	test("should not escape HTML chars", func() {
		expect.text(escapeMarkdown("HTML: <tag> & entities")).equal("HTML: <tag> & entities");
	});

	test("should not escape symbols and punctuation", func() {
		expect.text(escapeMarkdown("Symbols: @ # $ % ^ & + = | \\ / ? . , ; : \" '")).equal("Symbols: @ # $ % ^ & + = | \\ / ? . , ; : \" '");
	});

	test("mixed escaped and non-escaped", func() {
		expect.text(escapeMarkdown("Price: $100 for *premium* & ~basic~ versions")).equal("Price: $100 for \\\\*premium\\\\* & ~basic~ versions");
	});
});

suite("escapeHTML", func() {
	test("basic HTML characters", func() {
		expect.text(escapeHTML("<tag>content</tag>")).equal("\\\\<tag\\\\>content\\\\</tag\\\\>");
	});

	test("all special characters", func() {
		expect.text(escapeHTML("<>&")).equal("\\\\<\\\\>\\\\&");
	});

	test("empty string", func() {
		expect.text(escapeHTML("")).equal("");
	});

	test("no special characters", func() {
		expect.text(escapeHTML("Hello world 123")).equal("Hello world 123");
	});

	test("HTML entities", func() {
		expect.text(escapeHTML("&lt; &gt; &amp;")).equal("\\\\&lt; \\\\&gt; \\\\&amp;");
	});

	test("complex HTML", func() {
		expect.text(escapeHTML("<div class=\"test\">Content & more</div>")).equal("\\\\<div class=\"test\"\\\\>Content \\\\& more\\\\</div\\\\>");
	});

	test("consecutive special chars", func() {
		expect.text(escapeHTML("<<<>>>")).equal("\\\\<\\\\<\\\\<\\\\>\\\\>\\\\>");
	});

	test("with quotes and attributes", func() {
		expect.text(escapeHTML("<img src=\"image.jpg\" alt=\"A & B\">")).equal("\\\\<img src=\"image.jpg\" alt=\"A \\\\& B\"\\\\>");
	});

	test("should not escape Markdown chars", func() {
		expect.text(escapeHTML("Markdown: *bold* _italic_ [link](url) `code` ~strike~")).equal("Markdown: *bold* _italic_ [link](url) `code` ~strike~");
	});

	test("should not escape special symbols", func() {
		expect.text(escapeHTML("Symbols: @ # $ % ^ * + = | \\ / ? . , ; : \" ' ! -")).equal("Symbols: @ # $ % ^ * + = | \\ / ? . , ; : \" ' ! -");
	});

	test("should not escape parentheses and brackets", func() {
		expect.text(escapeHTML("Brackets: [array] {object} (group)")).equal("Brackets: [array] {object} (group)");
	});

	test("mixed escaped and non-escaped", func() {
		expect.text(escapeHTML("Code: *bold* <important> text & more")).equal("Code: *bold* \\\\<important\\\\> text \\\\& more");
	});
});