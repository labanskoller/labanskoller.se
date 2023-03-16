---
title: "Mobile Authenticator Apps Algorithm Support Review - 2023 Edition"
author: Laban Sköllermark ([@LabanSkoller](https://twitter.com/LabanSkoller))
date: 2023-03-16T02:30:00+01:00
featured_image: blog/images/authenticator_apps_2023.jpg
images:
  - blog/images/authenticator_apps_2023.jpg
toc: true
tags:
  - TOTP
  - Authentication
---

Last week my favorite IT security podcast *Bli säker* (*Become Secure* in English) published the episode [*The Epochalypse and the QR Code*](https://nikkasystems.com/2023/03/10/podd-188-epokalypsen-och-qr-koden/) (only in Swedish) where they explained the techonology behind mobile authenticator apps. I felt I needed to refresh my TOTP algorithm support investigation from 2019 before the recording of the next episode of the *Bli säker* podcast. :)

So this is an update to the blog post I published in July 2019 called [*Many Common Mobile Authenticator Apps Accept QR Codes for Modes They Don't Support*]({{<ref 2019-07-11-totp-app-comparison.md>}}). Most of the text, like an introduction to the concepts, is copied here so there is no need to revisit unless you are interested in the apps' support back then. If you've recently read it or you are just interested in the results in this 2023 edition, you might want to skip to the [*Tested Apps*]({{<ref "#tested-apps" >}}) section. This year I don't write comments on the individual apps and I don't include any screenshots. See the old blog post for such details. Not much has changed in the tested apps since then. This year I've included seven (7) new apps however.

You probably use an "authenticator app" such as Google Authenticator to enable two-step verification (sometimes called two-factor authentication, 2FA, or multi-factor authentication, MFA) for an online account. The method is called Time-Based One-Time Password Algorithm (TOTP) and is standardized in [<nobr>RFC 6238</nobr>](https://tools.ietf.org/html/rfc6238).

I have compared the following TOTP apps for the mobile platforms Android and iOS:

* Aegis (Android only)
* Bitwarden Password Manager (required premium account for TOTP support)
* Dashlane Authenticator
* Duo Mobile
* FortiToken Mobile
* Google Authenticator
* LastPass Authenticator
* Microsoft Authenticator
* Okta Verify
* Oracle Mobile Authenticator
* Raivo OTP (iOS only)
* Salesforce Authenticator
* Sophos Authenticator
* Symantec VIP Access
* Twilio Authy
* Yubico Authenticator

# Introduction and Conclusion

The de-facto standard is to transfer TOTP parameters including the secret (key) using a QR code. It seems Google invented this method. The QR code encodes text on the so called *Key URI* format as per a [Google Authenticator wiki article](https://github.com/google/google-authenticator/wiki/Key-Uri-Format):
```
otpauth://totp/ACME%20Co:john.doe@email.com?secret=HXDMVJECJJWSRB3HWIZR4IFUGFTMXBOZ&issuer=ACME%20Co&algorithm=SHA1&digits=6&period=30
```
The TOTP standard recommends a default time-step size of 30 seconds. Many apps support 60 seconds as well. The HMAC-SHA-1 hash function is the default but HMAC-SHA-256 and HMAC-SHA-512 are also allowed. The Key URI format says

> The digits parameter may have the values 6 or 8, and determines how long of a one-time passcode to display to the user. The default is 6.

Varying the number of digits is not mentioned in the TOTP standard apart from in the [Java reference implementation](https://tools.ietf.org/html/rfc6238#appendix-A), but it's mentioned as an extension in the underlying HMAC-Based One-Time Password Algorithm (HOTP) standard ([<nobr>RFC 4226</nobr>](https://tools.ietf.org/html/rfc4226)) in [Appendix E.1](https://tools.ietf.org/html/rfc4226#appendix-E.1):

> A simple enhancement in terms of security would be to extract more digits from the HMAC-SHA-1 value.
> For instance, calculating the HOTP value modulo 10^8 to build an 8-digit HOTP value would reduce the probability of success of the adversary from sv/10^6 to sv/10^8.

My investigations show that many common mobile authenticator apps accept QR codes for hash algorithms, periods and number of digits they don't support. Instead they assume the standard settings and generate tokens based on that, giving **wrong tokens**, **no error messages** and a **bad user experience**. Sites providing TOTP as a two-step verification method usually require the user to provide one token to prove that it has saved the TOTP parameters, the device has correct time and so on so there is no risk that these shortcomings would lock out users from their accounts, but there is a risk that a user would skip two-step verification if the setup process fails.

# Recommendation to App Developers

I recommend authenticator app developers to validate the data from the QR code, check if the app supports the mode encoded in it and give the user a descriptive error message if it detects a setting which the app does not support. Even better would be to add support for all three SHA hash algorithms mentioned in the TOTP RFC (HMAC-SHA-1, HMAC-SHA-256 and HMAC-SHA-512), 6 and 8 digit tokens plus 30 and 60 second periods.

# Recommendation to Site Owners

For sites choosing to let users protect their accounts with two-step verification via TOTP I recommend sticking to the HMAC-SHA-1 algorithm, 6 digits and a period of 30 seconds, at least as a default value, since this is currently the only mode all tested apps support. Choosing another mode is begging for problems for the users unless a list of compatible apps is presented to the user.

# Tested Apps

The following table shows which apps I've tested on the two platforms and the versions. Links go to Google Play and Apple App Store.

|                                                                            | Legend                                                     |
|----------------------------------------------------------------------------|:-----------------------------------------------------------|
| <img src="/blog/images/star.svg"    style="height: 25px" alt="Full"      > | All tested modes supported                                 |
| <img src="/blog/images/success.svg" style="height: 25px" alt="Good"      > | Only some modes supported but error messages on the others |
| <img src="/blog/images/error.svg"   style="height: 25px" alt="Misleading"> | Wrong tokens displayed for unsupported modes               |

|                                                                                               | App                                                                                                               | Platform | Version    |
|-----------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------|:---------|:-----------|
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [Aegis](https://play.google.com/store/apps/details?id=com.beemdevelopment.aegis)                                  | Android  | 2.1.3      |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [Bitwarden Password Manager](https://play.google.com/store/apps/details?id=com.x8bit.bitwarden)                   | Android  | 2023.2.0   |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [Bitwarden Password Manager](https://apps.apple.com/us/app/bitwarden-password-manager/id1137397744)               | iOS      | 2023.2.0   |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [Dashlane Authenticator](https://play.google.com/store/apps/details?id=com.dashlane.authenticator)                | Android  | 1.2304.0   |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [Dashlane Authenticator](https://apps.apple.com/us/app/dashlane-authenticator/id1582978196)                       | iOS      | 1.2310.0   |
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | [Duo Mobile](https://play.google.com/store/apps/details?id=com.duosecurity.duomobile)                             | Android  | 4.35.0     |
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | [Duo Mobile](https://apps.apple.com/us/app/duo-mobile/id422663827#?platform=iphone)                               | iOS      | 4.36.0.335.1 |
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | [FortiToken Mobile](https://play.google.com/store/apps/details?id=com.fortinet.android.ftm)                       | Android  | 5.3.2.0070 |
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | [FortiToken Mobile](https://apps.apple.com/us/app/fortitoken-mobile/id500007723)                                  | iOS      | 5.4.2.0117 |
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | [Google Authenticator](https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2)      | Android  | 5.20R4     |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [Google Authenticator](https://apps.apple.com/us/app/google-authenticator/id388497605#?platform=iphone)           | iOS      | 3.4.0      |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [LastPass Authenticator](https://play.google.com/store/apps/details?id=com.lastpass.authenticator)                | Android  | 2.13.1     |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [LastPass Authenticator](https://apps.apple.com/us/app/lastpass-authenticator/id1079110004#?platform=iphone)      | iOS      | 2.8.1      |
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | [Microsoft Authenticator](https://play.google.com/store/apps/details?id=com.azure.authenticator)                  | Android  | 6.2303.1482 |
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | [Microsoft Authenticator](https://apps.apple.com/us/app/microsoft-authenticator/id983156458#?platform=iphone)     | iOS      | 6.7.5      |
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | [Okta Verify](https://play.google.com/store/apps/details?id=com.okta.android.auth)                                | Android  | 7.13.0     |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [Okta Verify](https://apps.apple.com/us/app/okta-verify/id490179405)                                              | iOS      | 7.12.0     |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [Oracle Mobile Authenticator](https://play.google.com/store/apps/details?id=oracle.idm.mobile.authenticator)      | Android  | 9.5        |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [Oracle Mobile Authenticator](https://apps.apple.com/us/app/oracle-mobile-authenticator/id835904829)              | iOS      | 4.16       |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [Raivo OTP](https://apps.apple.com/us/app/raivo-otp/id1459042137)                                                 | iOS      | 1.4.8      |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [Salesforce Authenticator](https://play.google.com/store/apps/details?id=com.salesforce.authenticator)            | Android  | 3.11.3     |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [Salesforce Authenticator](https://apps.apple.com/us/app/salesforce-authenticator/id782057975)                    | iOS      | 3.11.1     |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [Sophos Authenticator](https://play.google.com/store/apps/details?id=com.sophos.sophtoken)                        | Android  | 3.4        |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [Sophos Authenticator](https://apps.apple.com/us/app/sophos-authenticator/id864224575#?platform=iphone)           | iOS      | 1.4.2      |
| <img src="/blog/images/success.svg" style="height: 30px" alt="Good"       title="Good"      > | [Symantec VIP Access](https://play.google.com/store/apps/details?id=com.verisign.mvip.main)                       | Android  | 4.1.9      |
| <img src="/blog/images/success.svg" style="height: 30px" alt="Good"       title="Good"      > | [Symantec VIP Access](https://apps.apple.com/us/app/vip-access-for-iphone/id307658513#?platform=iphone)           | iOS      | 4.2.9      |
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | [Twilio Authy Authentication](https://play.google.com/store/apps/details?id=com.authy.authy)                      | Android  | 24.11.1    |
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | [Twilio Authy](https://apps.apple.com/us/app/authy/id494168017#?platform=iphone)                                  | iOS      | 25.1.0     |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [Yubico Authenticator](https://play.google.com/store/apps/details?id=com.yubico.yubioath)                         | Android  | 6.1.1      |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [Yubico Authenticator](https://apps.apple.com/us/app/yubico-authenticator/id1476679808)                           | iOS      | 1.7.1      |

# Generation of Test QR Codes

In order to test the different apps I chose to generate a set of QR codes with different modes, scan them with all tested apps and then compare the generated TOTP codes with the output of `oathtool` below.
I know that the secrets below should be longer for HMAC-SHA-256 (32 bytes) and HMAC-SHA-512 (64 bytes) than for HMAC-SHA-1 (the HOTP RFC recommends 20 bytes), but it doesn't matter since the Keyed-Hashing for Message Authentication (HMAC) [<nobr>RFC 2104</nobr>](https://tools.ietf.org/html/rfc2104) states that too short keys shall be padded with zeroes until they are of desired length.

The following Bash `for` loop was used to produce the QR codes in PNG format using [`qrencode`](https://fukuchi.org/works/qrencode/) 3.4.4 ([man page](https://linux.die.net/man/1/qrencode)):

```
$ for algorithm in SHA1 SHA256 SHA512
> do
>   for digits in 6 8
>   do
>     for period in 30 60
>     do
>       qrencode -o "AA_${algorithm}_${digits}_${period}s.png" \
>         "otpauth://totp/labanskoller.se:AA_${algorithm}_${digits}dig_${period}s@labanskoller.se?algorithm=${algorithm}&digits=${digits}&issuer=labanskoller.se&period=${period}&secret=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
>     done
>   done
> done
```

Resulting 12 QR codes:

<figure>
  <img src="/blog/images/AA_SHA1_6_30s.png" style="width:159px; display:inline" title="otpauth://totp/labanskoller.se:AA_SHA1_6dig_30s@labanskoller.se?algorithm=SHA1&digits=6&issuer=labanskoller.se&period=60&secret=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">
  <img src="/blog/images/AA_SHA1_6_60s.png" style="width:159px; display:inline" title="otpauth://totp/labanskoller.se:AA_SHA1_6dig_60s@labanskoller.se?algorithm=SHA1&digits=6&issuer=labanskoller.se&period=60&secret=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">
  <figcaption><i>HMAC-SHA-1, 6 digits, 30 and 60 seconds</i></figcaption>
</figure>

<figure>
  <img src="/blog/images/AA_SHA1_8_30s.png" style="width:159px; display:inline" title="otpauth://totp/labanskoller.se:AA_SHA1_8dig_30s@labanskoller.se?algorithm=SHA1&digits=8&issuer=labanskoller.se&period=60&secret=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">
  <img src="/blog/images/AA_SHA1_8_60s.png" style="width:159px; display:inline" title="otpauth://totp/labanskoller.se:AA_SHA1_8dig_60s@labanskoller.se?algorithm=SHA1&digits=8&issuer=labanskoller.se&period=60&secret=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">
  <figcaption><i>HMAC-SHA-1, 8 digits, 30 and 60 seconds</i></figcaption>
</figure>

<figure>
  <img src="/blog/images/AA_SHA256_6_30s.png" style="width:171px; display:inline" title="otpauth://totp/labanskoller.se:AA_SHA256_6dig_30s@labanskoller.se?algorithm=SHA256&digits=6&issuer=labanskoller.se&period=60&secret=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">
  <img src="/blog/images/AA_SHA256_6_60s.png" style="width:171px; display:inline" title="otpauth://totp/labanskoller.se:AA_SHA256_6dig_60s@labanskoller.se?algorithm=SHA256&digits=6&issuer=labanskoller.se&period=60&secret=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">
  <figcaption><i>HMAC-SHA-256, 6 digits, 30 and 60 seconds</i></figcaption>
</figure>

<figure>
  <img src="/blog/images/AA_SHA256_8_30s.png" style="width:171px; display:inline" title="otpauth://totp/labanskoller.se:AA_SHA256_8dig_30s@labanskoller.se?algorithm=SHA256&digits=8&issuer=labanskoller.se&period=60&secret=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">
  <img src="/blog/images/AA_SHA256_8_60s.png" style="width:171px; display:inline" title="otpauth://totp/labanskoller.se:AA_SHA256_8dig_60s@labanskoller.se?algorithm=SHA256&digits=8&issuer=labanskoller.se&period=60&secret=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">
  <figcaption><i>HMAC-SHA-256, 8 digits, 30 and 60 seconds</i></figcaption>
</figure>

<figure>
  <img src="/blog/images/AA_SHA512_6_30s.png" style="width:171px; display:inline" title="otpauth://totp/labanskoller.se:AA_SHA512_6dig_30s@labanskoller.se?algorithm=SHA512&digits=6&issuer=labanskoller.se&period=60&secret=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">
  <img src="/blog/images/AA_SHA512_6_60s.png" style="width:171px; display:inline" title="otpauth://totp/labanskoller.se:AA_SHA512_6dig_60s@labanskoller.se?algorithm=SHA512&digits=6&issuer=labanskoller.se&period=60&secret=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">
  <figcaption><i>HMAC-SHA-512, 6 digits, 30 and 60 seconds</i></figcaption>
</figure>

<figure>
  <img src="/blog/images/AA_SHA512_8_30s.png" style="width:171px; display:inline" title="otpauth://totp/labanskoller.se:AA_SHA512_8dig_30s@labanskoller.se?algorithm=SHA512&digits=8&issuer=labanskoller.se&period=60&secret=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">
  <img src="/blog/images/AA_SHA512_8_60s.png" style="width:171px; display:inline" title="otpauth://totp/labanskoller.se:AA_SHA512_8dig_60s@labanskoller.se?algorithm=SHA512&digits=8&issuer=labanskoller.se&period=60&secret=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">
  <figcaption><i>HMAC-SHA-512, 8 digits, 30 and 60 seconds</i></figcaption>
</figure>

# Generation of Tokens to Compare With

The correct tokens to check against were produced with [`oathtool`](https://www.nongnu.org/oath-toolkit/) 2.6.7 ([man page](https://www.nongnu.org/oath-toolkit/man-oathtool.html)):
```
$ for algorithm in SHA1 SHA256 SHA512
> do
>   for digits in 6 8
>   do
>     for period in 30 60
>     do
>       printf "%-18s: " "AA_${algorithm}_${digits}dig_${period}s"
>       oathtool --base32 --totp="${algorithm,,}" \
>         --time-step-size "${period}" \
>         --digits "${digits}" \
>         AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
>     done
>   done
> done
AA_SHA1_6dig_30s  : 148285
AA_SHA1_6dig_60s  : 512776
AA_SHA1_8dig_30s  : 11148285
AA_SHA1_8dig_60s  : 21512776
AA_SHA256_6dig_30s: 155759
AA_SHA256_6dig_60s: 202695
AA_SHA256_8dig_30s: 28155759
AA_SHA256_8dig_60s: 69202695
AA_SHA512_6dig_30s: 389950
AA_SHA512_6dig_60s: 246498
AA_SHA512_8dig_30s: 22389950
AA_SHA512_8dig_60s: 86246498
```

# Summary

Many common mobile authenticator apps accept QR codes for hash algorithms, periods and number of digits they don’t support. They give **wrong tokens**, **no error messages** and therefore a **bad user experience**. I urge TOTP app developers to validate the data that comes from the scanned QR codes and present the user with a descriptive error message if they choose to not support all possible modes. I recommend site owners who support two-step verification using TOTP to give users guidelines on which apps to use if they choose a mode other than the most common HMAC-SHA1 algorithm, 6 digits and a period of 30 seconds.

This year when I've included many new apps there were several with full support for all tested TOTP variations, so I won't crown the best ones.

## Comments?

Do you have questions, comments or corrections? Please interact with the [toot](https://infosec.exchange/@LabanSkoller/110030440578631332), [tweet](https://twitter.com/LabanSkoller/status/1636179215002267648),
[LinkedIn
post](https://www.linkedin.com/posts/labanskoller_mobile-authenticator-apps-algorithm-support-activity-7041946003049979904-EdI1/)
or [make a pull
request](https://github.com/labanskoller/labanskoller.se/edit/main/content/blog/2023-03-16-totp-app-comparison-2023-edition.md).

# Credit
Icons made by <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a> licensed by <a href="https://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a>.

Thanks to [Karl Emil Nikka](https://www.linkedin.com/in/karlemilnikka/) for bringing up the TOTP subject is his podcast so I felt urged to refresh my old blog post.
