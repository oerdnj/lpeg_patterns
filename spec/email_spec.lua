local lpeg = require "lpeg"

describe("email_nocfws Addresses", function()
	local email = require "lpeg_patterns.email".email * lpeg.P(-1)
	it("Pass valid addresses", function()
		assert.same({"localpart", "example.com"}, {email:match "localpart@example.com"})
	end)
	it("Deny invalid addresses", function()
		assert.falsy(email:match "not an address")
	end)
	it("Handle unusual localpart", function()
		assert.same({"foo.bar", "example.com"}, {email:match "foo.bar@example.com"})
		assert.same({"foo+", "example.com"}, {email:match "foo+@example.com"})
		assert.same({"foo+bar", "example.com"}, {email:match "foo+bar@example.com"})
		assert.same({"!#$%&'*+-/=?^_`{}|~", "example.com"}, {email:match "!#$%&'*+-/=?^_`{}|~@example.com"})
		assert.same({[[quoted]], "example.com"}, {email:match [["quoted"@example.com]]})
		assert.same({[[quoted string]], "example.com"}, {email:match [["quoted string"@example.com]]})
		assert.same({[[quoted@symbol]], "example.com"}, {email:match [["quoted@symbol"@example.com]]})
		assert.same({[=[very.(),:;<>[]".VERY."very@\ "very".unusual]=], "example.com"}, {email:match [=["very.(),:;<>[]\".VERY.\"very@\\ \"very\".unusual"@example.com]=]})
	end)
	it("Ignore invalid localpart", function()
		assert.falsy(email:match "@example.com")
		assert.falsy(email:match ".@example.com")
		assert.falsy(email:match "foobar.@example.com")
		assert.falsy(email:match "@foo@example.com")
		assert.falsy(email:match "foo@bar@example.com")
		assert.falsy(email:match [[just"not"right@example.com]] ) -- quoted strings must be dot separated, or the only element making up the local-pat
		assert.falsy(email:match( "\127@example.com" ))
	end)
	it("Handle unusual hosts", function()
		assert.same({"localpart", "host_name"}, {email:match "localpart@host_name"})
		assert.same({"localpart", "127.0.0.1"}, {email:match "localpart@[127.0.0.1]"})
		assert.same({"localpart", "IPv6:2001::d1"}, {email:match "localpart@[IPv6:2001::d1]"})
		assert.same({"localpart", "::1"}, {email:match "localpart@[::1]"})
	end)
	it("Handle comments", function()
		assert.same({"localpart", "example.com"}, {email:match "(comment)localpart@example.com"})
		assert.same({"localpart", "example.com"}, {email:match "localpart(comment)@example.com"})
		assert.same({"quoted", "example.com"}, {email:match "(comment)\"quoted\"@example.com"})
		assert.same({"quoted", "example.com"}, {email:match "\"quoted\"(comment)@example.com"})
		assert.same({"localpart", "example.com"}, {email:match "localpart@(comment)example.com"})
		assert.same({"localpart", "example.com"}, {email:match "localpart@example.com(comment)"})
	end)
	it("Handle escaped items in quotes", function()
		assert.same({"escape d", "example.com"}, {email:match [["escape\ d"(comment)@example.com]]})
		assert.same({"escape\"d", "example.com"}, {email:match [["escape\"d"(comment)@example.com]]})
	end)
end)
describe("email nocfws variants", function()
	local email_nocfws = require "lpeg_patterns.email".email_nocfws * lpeg.P(-1)
	it("Pass valid addresses", function()
		assert.same({"localpart", "example.com"}, {email_nocfws:match "localpart@example.com"})
	end)
	it("Deny invalid addresses", function()
		assert.falsy(email_nocfws:match "not an address")
	end)
	it("Handle unusual localpart", function()
		assert.same({"foo.bar", "example.com"}, {email_nocfws:match "foo.bar@example.com"})
		assert.same({"foo+", "example.com"}, {email_nocfws:match "foo+@example.com"})
		assert.same({"foo+bar", "example.com"}, {email_nocfws:match "foo+bar@example.com"})
		assert.same({"!#$%&'*+-/=?^_`{}|~", "example.com"}, {email_nocfws:match "!#$%&'*+-/=?^_`{}|~@example.com"})
		assert.same({[[quoted]], "example.com"}, {email_nocfws:match [["quoted"@example.com]]})
		assert.same({[[quoted string]], "example.com"}, {email_nocfws:match [["quoted string"@example.com]]})
		assert.same({[[quoted@symbol]], "example.com"}, {email_nocfws:match [["quoted@symbol"@example.com]]})
		assert.same({[=[very.(),:;<>[]".VERY."very@\ "very".unusual]=], "example.com"}, {email_nocfws:match [=["very.(),:;<>[]\".VERY.\"very@\\ \"very\".unusual"@example.com]=]})
	end)
	it("Ignore invalid localpart", function()
		assert.falsy(email_nocfws:match "@example.com")
		assert.falsy(email_nocfws:match ".@example.com")
		assert.falsy(email_nocfws:match "foobar.@example.com")
		assert.falsy(email_nocfws:match "@foo@example.com")
		assert.falsy(email_nocfws:match "foo@bar@example.com")
		assert.falsy(email_nocfws:match [[just"not"right@example.com]] ) -- quoted strings must be dot separated, or the only element making up the local-pat
		assert.falsy(email_nocfws:match( "\127@example.com" ))
	end)
	it("Handle unusual hosts", function()
		assert.same({"localpart", "host_name"}, {email_nocfws:match "localpart@host_name"})
		assert.same({"localpart", "127.0.0.1"}, {email_nocfws:match "localpart@[127.0.0.1]"})
		assert.same({"localpart", "IPv6:2001::d1"}, {email_nocfws:match "localpart@[IPv6:2001::d1]"})
		assert.same({"localpart", "::1"}, {email_nocfws:match "localpart@[::1]"})
	end)
	it("Doesn't allow comments", function()
		assert.falsy(email_nocfws:match "(comment)localpart@example.com")
		assert.falsy(email_nocfws:match "localpart(comment)@example.com")
		assert.falsy(email_nocfws:match "(comment)\"quoted\"@example.com")
		assert.falsy(email_nocfws:match "\"quoted\"(comment)@example.com")
		assert.falsy(email_nocfws:match "localpart@example.com(comment)")
		assert.falsy(email_nocfws:match "localpart@example.com(comment)")
	end)
end)
