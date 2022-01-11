---
title: "Man-in-The-Middle Session Fixation in Securitas Direct My Pages"
author: Laban Sköllermark ([@LabanSkoller](https://twitter.com/LabanSkoller))
date: 2022-02-22T22:55:00+01:00
toc: true
tags:
  - Web Vulnerabilities
  - Coordinated Disclosure
featured_image: blog/images/mypages-pro_featured.png
images:
  - blog/images/mypages-pro_featured.png
---
During 2021 I had access to a facility equipped with an alarm system from [Securitas Direct](https://www.securitasdirect.se/en). I had access as a regular user to Securitas Direct's My Pages at [mypages-pro.securitas-direct.com](https://mypages-pro.securitas-direct.com/), which is used to administer some aspects of one's security alarm installation. That web application suffered a [CWE-384](https://cwe.mitre.org/data/definitions/384.html) _Session Fixation_ vulnerability which can be used by an attacker in a so-called Man-In-The-Middle (MiTM) position.

<figure>
  <img src="../../../../images/mypages-pro_home.png"
style="display:inline" title="Home page of Securitas Direct My Pages">
  <figcaption><i>Home page of Securitas Direct My Pages</i></figcaption>
</figure>

In summary, if an attacker is on the same network as the victim or somewhere else between the victim and Securitas Direct's server, and if the attacker can make the victim's browser make an unencrypted HTTP request to a subdomain of `securitas-direct.com`, the attacker can impersonate the victim when they log in, even if that happens a long time afterwards. A requirement is that the attacker makes an HTTP request themself every half an hour to keep a session alive.

The session fixation problem is now allegedly fixed and it is important to note that as a regular user of the system, who does not have permissions to administer the alarm's users, even if one became victim of this attack, it was not possible to disarm the alarm system with the hijacked session since that action requires a PIN as well. What a session hijacker could do with an administrative account has not been tested as I did not have such privileges.

Session Fixation is described by MITRE as:

> Authenticating a user, or otherwise establishing a new user session, without invalidating any existing session identifier gives an attacker the opportunity to steal authenticated sessions.
>
> Such a scenario is commonly observed when:
>
> 1. A web application authenticates a user without first invalidating the
existing session, thereby continuing to use the session already associated with
the user.
> 1. An attacker is able to force a known session identifier on a user so that,
once the user authenticates, the attacker has access to the authenticated
session.
> 1. The application or container uses predictable session identifiers. In the
generic exploit of session fixation vulnerabilities, an attacker creates a new
session on a web application and records the associated session identifier. The
attacker then causes the victim to associate, and possibly authenticate,
against the server using that session identifier, giving the attacker access to
the user's account through the active session.

## Technical Description

### Session Handling

The first time a user visits a dynamic page, such as the root page [`/`](https://mypages-pro.securitas-direct.com/) served by [index.php](https://mypages-pro.securitas-direct.com/index.php), the user's browser does not have any cookies to present in that HTTP GET request. The server generates a session identifier which is set in a cookie named `bwp_session`. The cookie has the [attributes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#restrict_access_to_cookies) `Secure` and `HttpOnly`, is valid for all pages on the `mypages-pro.securitas-direct.com` domain and expires in 30 minutes using both `Max-Age` and `Expires` attributes. So far, so good.

When logging in, however, the session identifier remains unchanged. This is the first problem.

Login HTTP POST request:

```
POST /login HTTP/1.1
Host: mypages-pro.securitas-direct.com
Cookie: _ga=GA1.2.1010388372.1637676224; _gid=GA1.2.42687429.1637676224; bwp_inst_id=<REDACTED>; bwp_session=beandraclf7gu8ubfak196d3f1; _gat_gtag_UA_105598027_3=1
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:94.0) Gecko/20100101 Firefox/94.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Content-Type: application/x-www-form-urlencoded
Content-Length: <REDACTED>
Origin: https://mypages-pro.securitas-direct.com
Dnt: 1
Referer: https://mypages-pro.securitas-direct.com/
Upgrade-Insecure-Requests: 1
Sec-Fetch-Dest: document
Sec-Fetch-Mode: navigate
Sec-Fetch-Site: same-origin
Sec-Fetch-User: ?1
Te: trailers
Connection: close

username=laban%40<REDACTED>&password=<REDACTED>
```

Login HTTP response:

```
HTTP/1.1 302 Found
Date: Wed, 24 Nov 2021 13:43:30 GMT
Server: Apache
Expires: Thu, 19 Nov 1981 08:52:00 GMT
Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0
Pragma: no-cache
Set-Cookie: bwp_session=beandraclf7gu8ubfak196d3f1; expires=Wed, 24-Nov-2021 14:13:30 GMT; Max-Age=1800; path=/; secure; HttpOnly
Set-Cookie: bwp_session=beandraclf7gu8ubfak196d3f1; expires=Wed, 24-Nov-2021 14:13:30 GMT; Max-Age=1800; path=/; secure; HttpOnly
Set-Cookie: bwp_session=beandraclf7gu8ubfak196d3f1; expires=Wed, 24-Nov-2021 14:13:31 GMT; Max-Age=1800; path=/; secure; HttpOnly
Set-Cookie: bwp_inst_id=<REDACTED>; expires=Tue, 19-Jan-2038 03:14:07 GMT; Max-Age=509722236; path=/; secure; httponly
Set-Cookie: bwp_session=beandraclf7gu8ubfak196d3f1; expires=Wed, 24-Nov-2021 14:13:31 GMT; Max-Age=1800; path=/; secure; HttpOnly
Set-Cookie: bwp_session=beandraclf7gu8ubfak196d3f1; expires=Wed, 24-Nov-2021 14:13:31 GMT; Max-Age=1800; path=/; secure; HttpOnly
Set-Cookie: bwp_session=beandraclf7gu8ubfak196d3f1; expires=Wed, 24-Nov-2021 14:13:31 GMT; Max-Age=1800; path=/; secure; HttpOnly
Set-Cookie: bwp_session=beandraclf7gu8ubfak196d3f1; expires=Wed, 24-Nov-2021 14:13:31 GMT; Max-Age=1800; path=/; secure; HttpOnly
Set-Cookie: bwp_session=beandraclf7gu8ubfak196d3f1; expires=Wed, 24-Nov-2021 14:13:31 GMT; Max-Age=1800; path=/; secure; HttpOnly
Set-Cookie: bwp_session=beandraclf7gu8ubfak196d3f1; expires=Wed, 24-Nov-2021 14:13:31 GMT; Max-Age=1800; path=/; secure; HttpOnly
Set-Cookie: bwp_session=beandraclf7gu8ubfak196d3f1; expires=Wed, 24-Nov-2021 14:13:31 GMT; Max-Age=1800; path=/; secure; HttpOnly
Location: https://mypages-pro.securitas-direct.com/home
Set-Cookie: bwp_session=beandraclf7gu8ubfak196d3f1; expires=Wed, 24-Nov-2021 14:13:31 GMT; Max-Age=1800; path=/; secure; HttpOnly
Content-Length: 0
Connection: close
Content-Type: text/html; charset=UTF-8


```

Yes, the `bwp_session` cookie does not change and the expiration is set to another 30 minutes. It seems like an innocent bug that the same `Set-Cookie: bwp_session=...` header is repeated ten extra times with the same value, but we will soon see that it becomes a security problem, too.

When the user explicitly logs out, it seems like the logout actually takes place server-side, which is good. It also seems like the developers tries to do the right thing &mdash; to delete the session cookie from the browser. But here the repeating header bug strikes again.

Logout HTTP request:

```
GET /logout HTTP/1.1
Host: mypages-pro.securitas-direct.com
Cookie: _ga=GA1.2.1010388372.1637676224; _gid=GA1.2.42687429.1637676224; bwp_inst_id=<REDACTED>; bwp_session=beandraclf7gu8ubfak196d3f1
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:94.0) Gecko/20100101 Firefox/94.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate
Dnt: 1
Referer: https://mypages-pro.securitas-direct.com/home
Upgrade-Insecure-Requests: 1
Sec-Fetch-Dest: document
Sec-Fetch-Mode: navigate
Sec-Fetch-Site: same-origin
Sec-Fetch-User: ?1
Te: trailers
Connection: close

```

Logout HTTP response:

```
HTTP/1.1 302 Found
Date: Wed, 24 Nov 2021 13:54:19 GMT
Server: Apache
Expires: Thu, 19 Nov 1981 08:52:00 GMT
Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0
Pragma: no-cache
Set-Cookie: bwp_session=beandraclf7gu8ubfak196d3f1; expires=Wed, 24-Nov-2021 14:24:19 GMT; Max-Age=1800; path=/; secure; HttpOnly
Set-Cookie: bwp_session=deleted; expires=Thu, 01-Jan-1970 00:00:01 GMT; Max-Age=0; path=/; secure; httponly
Set-Cookie: bwp_session=beandraclf7gu8ubfak196d3f1; expires=Wed, 24-Nov-2021 14:24:19 GMT; Max-Age=1800; path=/; secure; HttpOnly
Location: https://mypages-pro.securitas-direct.com/
Set-Cookie: bwp_session=beandraclf7gu8ubfak196d3f1; expires=Wed, 24-Nov-2021 14:24:19 GMT; Max-Age=1800; path=/; secure; HttpOnly
Content-Length: 0
Connection: close
Content-Type: text/html; charset=UTF-8

```

Note how one `Set-Cookie` header **in the middle** deletes the `bwp_session` cookie by changing its value and make it expire in the past:

```
Set-Cookie: bwp_session=deleted; expires=Thu, 01-Jan-1970 00:00:01 GMT; Max-Age=0; path=/; secure; httponly
```

That does not have any effect however since browsers process `Set-Cookie` headers in the order they are received (implicitly by sections [5.2](https://www.rfc-editor.org/rfc/rfc6265.html#section-5.2) and [5.3](https://www.rfc-editor.org/rfc/rfc6265.html#section-5.3) in [RFC 6265](https://www.rfc-editor.org/rfc/rfc6265.html) *HTTP State Management Mechanism*) and the cookie is created again with **the same value** as before:

```
Set-Cookie: bwp_session=beandraclf7gu8ubfak196d3f1; expires=Wed, 24-Nov-2021 14:24:19 GMT; Max-Age=1800; path=/; secure; HttpOnly
```

An attacker that gets hold of a session identifier for a logged-in user can use it to become that user and can keep the session alive by making new HTTP requests with that identifier at least once per 30 minutes. When the user explicitly logs out using a GET request to `/logout` however, the attacker is also logged out. But since the cookie is never deleted in the user's browser and a new session identifier is not set, the session will become alive again on the next login. But only if that second login happens within 30 minutes after the last request by the user, as the browser will automatically purge expired cookies from its cookie store and a `bwp_session` cookie properly set by an authentic Securitas Direct server has both the `Max-Age` and `Expires` cookie attributes set to accomplish that.

### Man-in-The-Middle Attack Using Plaintext HTTP

The cookie attribute `Secure` mentioned above specify when browsers shall *transmit* the cookie to the server, but the attributes themselves are never sent, so the server cannot know *how* the cookie was set in the first place (unless [cookie prefixes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies#cookie_prefixes) are used as part of the cookie name).

This means that the cookie `bwp_session` could be set somewhere else than the "Secure" (HTTPS) site [https://mypages-pro.securitas-direct.com](https://mypages-pro.securitas-direct.com/). For instance, the plaintext HTTP site [http://mypages-pro.securitas-direct.com](http://mypages-pro.securitas-direct.com/). Or over either HTTPS or HTTP on another subdomain of `securitas-direct.com`. Even a non-existing subdomain. From Mozilla's documentation on *cookie prefixes* already linked above:

> A vulnerable application on a subdomain can set a cookie with the `Domain` attribute, which gives access to that cookie on all other subdomains. This mechanism can be abused in a *session fixation* attack. See [session fixation](https://developer.mozilla.org/en-US/docs/Web/Security/Types_of_attacks#session_fixation) for primary mitigation methods.

So, a Man-in-The-Middle attacker who can make the victim's browser to send a request to for instance http://mypages-pro.securitas-direct.com/ can set a persistent cookie named `bwp_session` without expiration and which is valid for `securitas-direct.com` including all subdomains, such as `mypages-pro`.

That is not so hard once in the MiTM position. The attacker could inject some resource (an image for instance) on another plaintext HTTP page the victim is browsing to. The attacker could also trick the victim into visiting an attacker-controlled website (even over HTTPS) that will do the same. Or the attacker could send an innocent looking link that the victim might click.

If the attacker does not redirect the victim to the real My Pages site, the session identifier, which the attacker knows, will remain in the victim's browser indefinitely. Once the victim visits the real site, the browser will pick upp the changed properties of the cookie, such as the expiry time (30 minutes). The cookie value will remain however, and that is the big problem. The attacker will be able to hijack the victim's first login session, and any other subsequent login sessions as long as they are no longer than 30 minutes apart.

## List of Problems
* The session identifier is not changed when logging in
* The session identifier is not changed when logging out
* Cookie deletion ineffective
* Domain not protected with HTTP Strict Transport Security ([HSTS](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security))
* Unclear where to report security vulnerabilities: no Vulnerability Disclosure Policy ([VDP](https://www.hackerone.com/vulnerability-management/what-responsible-disclosure-policy-and-why-you-need-one)) or [`security.txt`](https://securitytxt.org/)

## Recommendations

My recommendations, in order of importance:

1. Change the session identifier when logging in and out (required to overcome the session fixation problem)
1. Make sure that the header `Set-Cookie: bwp_session=...` is present only once per HTTP response
1. Publish a Vulnerability Disclosure Policy. See [Internet.nl's policy](https://internet.nl/disclosure/) for a good example. Cybersecurity and Infrastructure Security Agency (CISA) within the Department of Homeland Security (DHS) in United States offer a [VDP template](https://cyber.dhs.gov/bod/20-01/vdp-template/).
1. Publish a [security.txt](https://securitytxt.org/) on preferably all Verisure domains but at least https://mypages-pro.securitas-direct.com/, referring to the VDP
1. Add the [`Strict-Transport-Security`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security) HTTP response header, at least on https://mypages-pro.securitas-direct.com/. Preferrably with a `max-age` attribute of at least one year.
1. Make sure all websites on subdomains of `securitas-direct.com` support HTTPS and [preload HSTS on the entire domain](https://hstspreload.org/?domain=securitas-direct.com). For that to work, first http://securitas-direct.com must redirect to https://securitas-direct.com instead of https://www.verisure.com/.
1. More user experience rather than security related: Make https://securitas-direct.com/ and https://www.securitas-direct.com redirect to https://www.securitasdirect.se/ rather than to https://www.verisure.com/. Also make https://securitasdirect.se/ work by presenting the proper TLS certificate instead of the one for `*.verisure.com`.

## Timeline

**2021-SEP-02** Session problems first sighted. *Session Fixation* described in a private Facebook Messenger chat with a former Verisure colleague who promised to investigate and create an internal ticket about the matter.

**2021-NOV-23** Contacted Securitas Direct customer support (kundtjanst\@securitasdirect.se) to ask where to report security problems.

**2021-NOV-24** Contacted some former Verisure colleagues to speed up the process to find the proper security contact person, which ended up being the Information Security Manager for the north part of Verisure. Sent the vulnerability report.

**2021-NOV-25** The Information Security Manager for the north part of Verisure confirmed the reception of the report.

**2021-DEC-23** An *IT-Dev Integration Analyst* at Verisure contacts me to thank me for reporting, apologizing for the troubles in reaching the proper contact person and inform me that several internal tickets have been created to address my findings.

**2022-JAN-11** I respond and inform about my intention to publish this blog post 90 days after the report was sent.

**2022-FEB-18** The IT-Dev Integration Analyst contacts me again to inform that "the teams have deployed fixes to production for the core aspects of the session fixation".

**2022-FEB-22** Publication of this blog post.

**2022-FEB-23** Redacted one piece of information which was forgotten.

**2022-MAR-15** Removed some unnecessary information.

## Deployed Fixes

I don't have access to a My Pages account anymore, so I have just been able to verify some changes with anonymous access. I can't know if the session identifier is changed on successful login. It's not on unsuccessful login and not when trying to logout without being logged in either:

```
$ curl --head --include https://mypages-pro.securitas-direct.com
HTTP/1.1 200 OK
Date: Tue, 22 Feb 2022 20:40:53 GMT
Server: Apache
Expires: Thu, 19 Nov 1981 08:52:00 GMT
Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0
Pragma: no-cache
Set-Cookie: bwp_session=snb21g98qec43arukcmgsjmka3; expires=Tue, 22-Feb-2022 21:10:53 GMT; Max-Age=1800; path=/; secure; HttpOnly
Strict-Transport-Security: max-age=31536000; includeSubDomains
Connection: close
Content-Type: text/html; charset=UTF-8

$ curl --head --include --header "Cookie: bwp_session=snb21g98qec43arukcmgsjmka3" https://mypages-pro.securitas-direct.com/logout
HTTP/1.1 302 Found
Date: Tue, 22 Feb 2022 20:41:41 GMT
Server: Apache
Expires: Thu, 19 Nov 1981 08:52:00 GMT
Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0
Pragma: no-cache
Location: https://mypages-pro.securitas-direct.com/
Set-Cookie: vs-access=deleted; expires=Thu, 01-Jan-1970 00:00:01 GMT; Max-Age=0; path=/; secure; httponly
Set-Cookie: bwp_session=snb21g98qec43arukcmgsjmka3; expires=Tue, 22-Feb-2022 21:11:41 GMT; Max-Age=1800; path=/; secure; HttpOnly
Strict-Transport-Security: max-age=31536000; includeSubDomains
Connection: close
Content-Type: text/html; charset=UTF-8

```

Verisure seems to have removed the duplicate `Set-Cookie` headers with identical cookie names, at least for the endpoints above.

I notice that there is now an HTTP Strict Transport Security (HSTS) header on the My Pages domain with a `max-age` of one year, as recommended. The whole top domain [securitas-direct.com](https://securitas-direct.com/) has HSTS as well (not preloaded), but probably nobody will visit it to pick up the policy.

## Disclosure
I have previously worked for Verisure Innovation AB which together with Securitas Sverige AB are part of Securitas Direct Verisure Group. I worked with IT operations and never with the physical alarm systems or the customers' interaction with the service. No inside knowledge was used to find the session fixation vulnerability. It was discovered when I received a My Pages account myself while having access to the facility in question.

## Comments?

Do you have questions, comments or corrections? Please interact with the [tweet](https://twitter.com/LabanSkoller/status/1496244176358420483),
[LinkedIn
post](https://www.linkedin.com/posts/labanskoller_man-in-the-middle-session-fixation-in-securitas-activity-6902008852179505152-hxrE)
or [make a pull
request](https://github.com/labanskoller/labanskoller.se/edit/main/content/blog/2022-02-22-securitas-direct-session-fixation.md).

## Credit

Thanks to:

* My former Verisure Innovation colleagues who helped me get in contact with the right person for reporting security vulnerabilities
* [Niklas Andersson](https://www.linkedin.com/in/niklas-andersson-21308a7/) for
  pointing out that I forgot to redact some information in one place, 2022-FEB-23. That warranted some commit squashing and force pushing...
