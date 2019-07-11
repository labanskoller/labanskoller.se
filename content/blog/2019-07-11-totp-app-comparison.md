---
title: "Many Common Mobile Authenticator Apps Accept QR Codes for Modes They Don't Support"
date: 2019-07-11T22:00:00+02:00
featured_image: blog/images/totp_unsupported_barcode.png
images:
  - blog/images/totp_unsupported_barcode.png
toc: true
tags:
  - TOTP
  - Authentication
---

You probably use an "authenticator app" such as Google Authenticator to enable two-step verification (sometimes called two-factor authentication, 2FA, or multi-factor authentication, MFA) for an online account. The method is called Time-Based One-Time Password Algorithm (TOTP) and is standardized in [<nobr>RFC 6238</nobr>](https://tools.ietf.org/html/rfc6238). In October 2017 when I evaluated [<nobr>HashiCorp Vault</nobr> for generating and storing TOTP secrets](https://www.vaultproject.io/docs/secrets/totp/index.html#as-a-provider) for a system at work I realized that the Android version and iOS version of Google Authenticator differed a lot when it comes to which modes are supported. I got the idea for this blog post and now I've finally executed it and compared eight different TOTP apps for the two mobile platforms:

* Authy 2-Factor Authentication
* Duo Mobile
* Google Authenticator
* LastPass Authenticator
* Microsoft Authenticator
* Sophos Authenticator
* Symantec VIP Access
* Yubico Authenticator

My investigations show that many common mobile authenticator apps accept QR codes for hash algorithms, periods and number of digits they don't support. Instead they assume the standard settings and generate tokens based on that, giving **wrong tokens**, **no error messages** and a **bad user experience**. Sites providing TOTP as a two-step verification method usually require the user to provide one token to prove that it has saved the TOTP parameters, the device has correct time and so on so there is no risk that these shortcomings would lock out users from their accounts, but there is a risk that a user would skip two-step verification if the setup process fails.

# Recommendation to App Developers

I recommend authenticator app developers to validate the data from the QR code, check if the app supports the mode encoded in it and give the user a descriptive error message if it detects a setting which the app does not support. Even better would be to add support for all three SHA hash algorithms mentioned in the TOTP RFC (HMAC-SHA-1, HMAC-SHA-256 and HMAC-SHA-512), 6 and 8 digit tokens plus 30 and 60 second periods.

# Recommendation to Site Owners

For sites choosing to let users protect their accounts with two-step verification via TOTP I recommend sticking to the HMAC-SHA-1 algorithm, 6 digits and a period of 30 seconds, at least as a default value, since this is currently the only mode all tested apps support. Choosing another mode is begging for problems for the users unless a list of compatible apps is presented to the user.

# Tested Apps

The following table shows which apps I've tested on the two platforms, the versions and the dates they were updated. Note that the test was conducted in end of April 2019 and that several apps have gotten updates since then when this post is published. Links go to Google Play and Apple App Store.

|                                                                            | Legend                                                     |
|----------------------------------------------------------------------------|:-----------------------------------------------------------|
| <img src="/blog/images/star.svg"    style="height: 25px" alt="Full"      > | All tested modes supported                                 |
| <img src="/blog/images/success.svg" style="height: 25px" alt="Good"      > | Only some modes supported but error messages on the others |
| <img src="/blog/images/error.svg"   style="height: 25px" alt="Misleading"> | Wrong tokens displayed for unsupported modes               |

|                                                                                               | App                                                                                                               | Platform | Version    | Last Updated |
|-----------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------|:---------|:-----------|-------------:|
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | [Authy 2-Factor Authentication](https://play.google.com/store/apps/details?id=com.authy.authy)                    | Android  | 23.7.0     | 15 APR 2019  |
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | [Authy](https://itunes.apple.com/us/app/authy/id494168017#?platform=iphone)                                       | iOS      | 22.4.1     | 24 APR 2019  |
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | [Duo Mobile](https://play.google.com/store/apps/details?id=com.duosecurity.duomobile)                             | Android  | 3.27.0     | 25 APR 2019  |
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | [Duo Mobile](https://itunes.apple.com/us/app/duo-mobile/id422663827#?platform=iphone)                             | iOS      | 3.25.0     | 03 APR 2019  |
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | [Google Authenticator](https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2)      | Android  | 5.00       | 27 SEP 2017  |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [Google Authenticator](https://itunes.apple.com/us/app/google-authenticator/id388497605#?platform=iphone)         | iOS      | 3.0.1      | 13 SEP 2018  |
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | [LastPass Authenticator](https://play.google.com/store/apps/details?id=com.lastpass.authenticator)                | Android  | 1.2.0.1179 | 12 APR 2019  |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [LastPass Authenticator](https://itunes.apple.com/us/app/lastpass-authenticator/id1079110004#?platform=iphone)    | iOS      | 1.5.6      | 15 NOV 2018  |
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | [Microsoft Authenticator](https://play.google.com/store/apps/details?id=com.azure.authenticator)                  | Android  | 6.4.7      | 01 APR 2019  |
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | [Microsoft Authenticator](https://itunes.apple.com/us/app/microsoft-authenticator/id983156458#?platform=iphone)   | iOS      | 6.2.8      | 12 MAR 2019  |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [Sophos Authenticator](https://play.google.com/store/apps/details?id=com.sophos.sophtoken)                        | Android  | 3.1        | 25 MAR 2017  |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [Sophos Authenticator](https://itunes.apple.com/us/app/sophos-authenticator/id864224575#?platform=iphone)         | iOS      | 1.4.0      | 03 MAY 2017  |
| <img src="/blog/images/success.svg" style="height: 30px" alt="Good"       title="Good"      > | [Symantec VIP Access](https://play.google.com/store/apps/details?id=com.verisign.mvip.main)                       | Android  | 4.1.6      | 06 MAR 2019  |
| <img src="/blog/images/success.svg" style="height: 30px" alt="Good"       title="Good"      > | [Symantec VIP Access](https://itunes.apple.com/us/app/vip-access-for-iphone/id307658513#?platform=iphone)         | iOS      | 4.2.4      | 27 SEP 2018  |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | [Yubico Authenticator](https://play.google.com/store/apps/details?id=com.yubico.yubioath) *                       | Android  | 2.1.0      | 24 SEP 2018  |

\*) Yubico doesn't have an authenticator app for iOS, but that might change when [YubiKey 5Ci](https://www.yubico.com/press-releases/yubico-announces-yubikey-for-lightning-partner-preview/) is released.

# Generation of Test QR Codes

In order to test the different apps I chose to generate a set of QR codes with different modes, scan them with all tested apps and then set the phone's clock to a given test time (2019-04-28 13:37:00 CEST).
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

The correct tokens to check against for the chosen test time were produced with [`oathtool`](https://www.nongnu.org/oath-toolkit/) 2.6.2 ([man page](https://www.nongnu.org/oath-toolkit/man-oathtool.html)):
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
>         --now "2019-04-28 13:37:00 CEST" \
>         --digits "${digits}" \
>         AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
>     done
>   done
> done
AA_SHA1_6dig_30s  : 365290
AA_SHA1_6dig_60s  : 205069
AA_SHA1_8dig_30s  : 22365290
AA_SHA1_8dig_60s  : 45205069
AA_SHA256_6dig_30s: 986416
AA_SHA256_6dig_60s: 727026
AA_SHA256_8dig_30s: 65986416
AA_SHA256_8dig_60s: 94727026
AA_SHA512_6dig_30s: 573802
AA_SHA512_6dig_60s: 759363
AA_SHA512_8dig_30s: 75573802
AA_SHA512_8dig_60s: 15759363
```

# Findings
Below the findings for every app are listed. The support for the different hash algorithms, number of digits and the periods are always included but some other interesting findings are also added. Any noteworthy differences between Android and iOS are covered.

## Authy 2-Factor Authentication

|                                                                                               |          |                                                            |
|-----------------------------------------------------------------------------------------------|---------:|------------------------------------------------------------|
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | Android: | Wrong tokens displayed for unsupported modes               |
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | iOS:     | Wrong tokens displayed for unsupported modes               |

<figure>
  <img src="/blog/images/authy_ios_aa_sha512_8_30s.png" style="width:45%; display:inline" title="Authy HMAC-SHA-512 8 digits 30 seconds iOS" alt="AA_SHA512_8dig_30s@... token is: 223 65 290">
  <img src="/blog/images/authy_ios_aa_sha512_8_60s.png" style="width:45%; display:inline" title="Authy HMAC-SHA-512 8 digits 60 seconds iOS" alt="AA_SHA512_8dig_60s@... token is: 223 65 290">
  <figcaption><i>Supports 8 digits but HMAC-SHA-1 and 30 second period is always used. Screenshots from iOS.</i></figcaption>
</figure>

* Only supports HMAC-SHA-1 but accepts the other two algorithms as well without error messages and generates erroneous tokens
* Only supports 30 second periods but accepts 60 second periods as well without error messages and generates erroneous tokens
* Correctly supports 8 digits however
* Is fetching the current time from some kind of backend to correct for wrong time on mobile device but this feature can't be turned off without entering flight mode (and then the offset still applies so the offset must be zero before enabling flight mode in order to accept the phone's time)
* Android: Blocks ability to take screenshots

## Duo Mobile

|                                                                                               |          |                                                            |
|-----------------------------------------------------------------------------------------------|---------:|------------------------------------------------------------|
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | Android: | Wrong tokens displayed for unsupported modes               |
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | iOS:     | Wrong tokens displayed for unsupported modes               |

<figure>
  <img src="/blog/images/duo_mobile_android_aa_sha1_6_30s.png" style="width:45%; display:inline" title="Duo Mobile HMAC-SHA-1 6 digits 30 seconds Android" alt="THIRD-PARTY AA_SHA1_6dig_30s@labanskolle... 365 290">
  <img src="/blog/images/duo_mobile_android_aa_sha1_8_30s_failed_barcode.png" style="width:45%; display:inline" title="Duo Mobile HMAC-SHA-1 8 digits 30 seconds Android" alt="Failed to Add Account - Could not add an account using this barcode.">
  <figcaption><i>Left: The only mode showing the correct token.<br/>Right: Error message (without details) when scanning any QR code for 8 digits. Screenshots from Android.</i></figcaption>
</figure>

* Android: Blocks ability to take screenshots (but it can be temporarily unlocked for 10 minutes!)
* Only 6 digit modes are supported
* 8 digit modes are correctly rejected
* Only 30 second periods are supported
* 60 second periods are accepted without error messages and generate erroneous tokens
* The only supported algorithm is HMAC-SHA-1 (6 digits and a 30 second period)
* The app accepts any other of the tested modes with 6 digits without error messages and generates erroneous tokens
* The token generated when an entry is clicked is always shown for 30 seconds even if the token is just valid for e.g. one second according to the clock. This is not a huge problem as long as the **recommendation** (not a requirement) about accepting the client being a few time steps out of sync is honored (see [section 6 *Resynchronization*](https://tools.ietf.org/html/rfc6238#section-6) in the TOTP RFC). It makes the period the token is valid for unnecessary short though.

## Google Authenticator

|                                                                                               |          |                                                            |
|-----------------------------------------------------------------------------------------------|---------:|------------------------------------------------------------|
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | Android: | Wrong tokens displayed for unsupported modes               |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | iOS:     | All tested modes supported                                 |

<figure>
  <img src="/blog/images/google_authenticator_android_sha1.png" style="width:45%; display:inline" title="Google Authenticator HMAC-SHA-1 Android" alt="Google Authenticator showing token 365 290 for all HMAC-SHA-1 modes">
  <img src="/blog/images/google_authenticator_ios_aa_sha1_8_60s__aa_sha256_6_animation_error.png" style="width:45%; display:inline" title="Google Authenticator iOS" alt="AA_SHA1_8dig_60s@labanskoller.se: 4520 5069, AA_SHA256_6dig_30s@labanskoll...: 986 416, AA_SHA256_6dig_60s@labanskoll...: 727 026">
  <figcaption><i>Left: The same token is displayed for all modes. It's only correct for mode HMAC-SHA-1 6 digits 30 seconds. Screenshot from Android.<br/>Right: All tokens correct but the clock symbol always shows the same remaining time for 30 and 60 second periods. The red color correctly shows which token is about to expire however. Screenshot from iOS.</i></figcaption>
</figure>

* Android: The only supported mode is the HMAC-SHA-1 algorithm, 6 digits and a 30 second period
* Android: The app accepts any other of the tested modes without error messages and generates erroneous tokens
* iOS: Supports all tested modes
* iOS: The circle counting down to the next token always take 30 seconds for one round even if the period is 60 seconds

It's funny that Google has broader support in their iOS app than in the app for their own OS.

## LastPass Authenticator

|                                                                                               |          |                                                            |
|-----------------------------------------------------------------------------------------------|---------:|------------------------------------------------------------|
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | Android: | Wrong tokens displayed for unsupported modes               |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | iOS:     | All tested modes supported                                 |

<figure>
  <img src="/blog/images/lastpass_authenticator_ios_aa_sha512.png" style="width:45%; display:inline" title="LastPass Authenticator HMAC-SHA-1 iOS" alt="AA_SHA512_6dig_30s@labanskoll...: 573 802, AA_SHA512_6dig_60s@labanskoll...: 759 363, AA_SHA512_8dig_30s@labanskoll...: 755 738 02, AA_SHA512_8dig_60s@labanskoll...: 157 593 63">
  <img src="/blog/images/lastpass_authenticator_android_aa_sha512.png" style="width:45%; display:inline" title="LastPass Authenticator HMAC-SHA-512 Android" alt="AA_SHA512_6dig_30s@labanskoller.se: 365 290, AA_SHA512_6dig_60s@labanskoller.se: 205 069, AA_SHA512_8dig_30s@labanskoller.se: 223 652 90, AA_SHA512_8dig_60s@labanskoller.se: 452 050 69">
  <figcaption><i>Left: All modes are supported. Screenshot from iOS.<br/>Right: Tokens for HMAC-SHA-1 instead of HMAC-SHA-512. Picture taken on Android from another phone, transformed and cut.</i></figcaption>
</figure>

* Android: The only supported algorithm is HMAC-SHA-1 but the other two are accepted without error messages and generates erroneous tokens
* Android: Blocks ability to take screenshots
* iOS: Supports all tested modes

## Microsoft Authenticator

|                                                                                               |          |                                                            |
|-----------------------------------------------------------------------------------------------|---------:|------------------------------------------------------------|
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | Android: | Wrong tokens displayed for unsupported modes               |
| <img src="/blog/images/error.svg"   style="height: 30px" alt="Misleading" title="Misleading"> | iOS:     | Wrong tokens displayed for unsupported modes               |

<figure>
  <img src="/blog/images/microsoft_authenticator_android_aa_sha1.png" style="width:45%; display:inline" title="Microsoft Authenticator HMAC-SHA-1 Android" alt="AA_SHA1_6dig_30s@labanskoller.se: 365 290, AA_SHA1_6dig_60s@labanskoller.se: 365 290, AA_SHA1_8dig_30s@labanskoller.se: 365 290, AA_SHA1_8dig_60s@labanskoller.se: 365 290, AA_SHA256_6dig_30s@labanskoller.se: 365 290">
  <img src="/blog/images/microsoft_authenticator_ios_aa_sha1.png" style="width:45%; display:inline" title="Microsoft Authenticator HMAC-SHA-1 iOS" alt="AA_SHA1_6dig_30s...: 365 290, AA_SHA1_6dig_60s...: 365 290, AA_SHA1_8dig_30s...: 365 290, AA_SHA1_8dig_60s...: 365 290">
  <figcaption><i>Only one mode supported.<br/>Left: Screenshot from Android. Right: Screenshot from iOS.</i></figcaption>
</figure>

* The only supported mode is the HMAC-SHA-1 algorithm, 6 digits and a 30 second period
* The app accepts any other of the tested modes without error messages and generates erroneous tokens on both platforms

## Sophos Authenticator

|                                                                                               |          |                                                            |
|-----------------------------------------------------------------------------------------------|---------:|------------------------------------------------------------|
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | Android: | All tested modes supported                                 |
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | iOS:     | All tested modes supported                                 |

<figure>
  <img src="/blog/images/sophos_authenticator_android_aa_sha256.png" style="width:45%; display:inline" title="Sophos Authenticator HMAC-SHA-256 Android" alt="labanskoller.se:AA_SHA256_6dig_30s@labanskoller.se: 986416, labanskoller.se:AA_SHA256_6dig_60s@labanskoller.se: 727026, labanskoller.se:AA_SHA256_8dig_30s@labanskoller.se: 65986416, labanskoller.se:AA_SHA256_8dig_60s@labanskoller.se: 94727026, labanskoller.se:AA_SHA512_6dig_30s@labanskoller.se: 573802">
  <img src="/blog/images/sophos_authenticator_ios__aa_sha256.png" style="width:45%; display:inline" title="Sophos Authenticator HMAC-SHA-256 iOS" alt="labanskoller.se:AA_SHA256_6dig_30s@laba...: 986416, labanskoller.se:AA_SHA256_6dig_60s@laba...: 727026, labanskoller.se:AA_SHA256_8dig_30s@laba...: 65986416, labanskoller.se:AA_SHA256_8dig_60s@laba...: 94727026, labanskoller.se:AA_SHA512_6dig_30s@laba...: 573802">
  <figcaption><i>All modes supported.<br/>Left: Screenshot from Android. Right: Screenshot from iOS.</i></figcaption>
</figure>

* Supports all tested modes
* Android: 8 digit entries can't be entered manually (only added by scanning QR code)
* iOS: When adding entries manually only the secret and period can be entered (not algorithm or number of digits), but once added also algorithm and number of digits can be modified
* Android: Entries added can't be modified but renamed

## Symantec VIP Access

|                                                                                               |          |                                                            |
|-----------------------------------------------------------------------------------------------|---------:|------------------------------------------------------------|
| <img src="/blog/images/success.svg" style="height: 30px" alt="Good"       title="Good"      > | Android: | Only some modes supported but error messages on the others |
| <img src="/blog/images/success.svg" style="height: 30px" alt="Good"       title="Good"      > | iOS:     | Only some modes supported but error messages on the others |

<figure>
  <img src="/blog/images/symantec_vip_access_android_aa_sha1_6_30s.png" style="width:45%; display:inline" title="Symantec VIP Access HMAC-SHA-1 6 digits 30 seconds Android" alt="365290 AA_SHA1_6dig_30s@labanskoller.se">
  <img src="/blog/images/symantec_vip_access_android_aa_sha1_6_60s_unsupported.png" style="width:45%; display:inline" title="Symantec VIP Access HMAC-SHA-1 6 digits 60 seconds Android" alt="VIP Access does not support this QR Code <otpauth://totp/labanskoller.se:AA_SHA1_6dig_60s@labanskoller.se?algorithm=SHA1&digits=6&issuer=labanskoller.se&period=60&secret=AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA>. Scan a different QR Code. CANCEL RETRY">
  <figcaption><i>Only one mode supported.<br/>Left: Only the supported mode can be added. Screenshot from Android. Right: Error message when an unsupported mode is scanned. Screenshot from Android.</i></figcaption>
</figure>

* The only supported mode is the HMAC-SHA-1 algorithm, 6 digits and a 30 second period
* The user is presented with proper error messages for unsupported modes on both platforms

## Yubico Authenticator

|                                                                                               |          |                                                            |
|-----------------------------------------------------------------------------------------------|---------:|------------------------------------------------------------|
| <img src="/blog/images/star.svg"    style="height: 30px" alt="Full"       title="Full"      > | Android: | All tested modes supported                                 |
|                                                                                               | iOS:     | No app                                                     |

<figure>
  <img src="/blog/images/yubico_authenticator_android_aa_sha1__aa_sha256_6.png" style="width:45%; display:inline" title="Yubico Authenticator HMAC-SHA-1 and some HMAC-SHA-256 Android" alt="365 290 AA_SHA1_6dig_30s@labanskoller.se, 205 069 AA_SHA1_6dig_60s@labanskoller.se, 2236 5290 AA_SHA1_8dig_30s@labanskoller.se, 4520 5069 AA_SHA1_8dig_60s@labanskoller.se, 986 416 AA_SHA256_6dig_30s@labanskoller.se, 727 026 AA_SHA256_6dig_60s@labanskoller.se">
  <figcaption><i>All modes supported. Picture taken on Android from another phone, transformed and cut (there is no iOS version).</i></figcaption>
</figure>

* Android: Supports all tested modes
* Android: Warns when there is already a TOTP secret with the same issuer and name present on the YubiKey when adding a new entry
* Android: Blocks ability to take screenshots
* No iOS app yet

# Summary

Many common mobile authenticator apps accept QR codes for hash algorithms, periods and number of digits they don’t support. They give **wrong tokens**, **no error messages** and therefore a **bad user experience**. I urge TOTP app developers to validate the data that comes from the scanned QR codes and present the user with a descriptive error message if they choose to not support all possible modes. I recommend site owners who support two-step verification using TOTP to give users guidelines on which apps to use if they choose a mode other than the most common HMAC-SHA1 algorithm, 6 digits and a period of 30 seconds.

The best app out of the tested ones is in my opinion **Sophos Authenticator** which supports all modes on both platforms. **Symantec VIP Access** is the second best since it doesn't support all modes but it tells the user when a mode is not supported.

# Comments?

Do you have comments? Interact with this tweet:

{{< tweet 1149417515505897472 >}}

# Credit
Icons made by <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a> licensed by <a href="https://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a>.

Thanks to Alexander Kjäll for reviewing halfway through the progress.
