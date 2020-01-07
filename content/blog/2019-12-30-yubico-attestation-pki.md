---
title: "PKI Is Hard - How Yubico Trusted OpenSSL And Got It Wrong"
author: Laban Sköllermark ([@LabanSkoller](https://twitter.com/LabanSkoller))
date: 2019-12-30T15:00:00+01:00
toc: true
featured_image: blog/images/broken_chains.png
images:
  - blog/images/brokan_chains.png
tags:
  - PKI
  - Certificates
---

This is the story on how I discovered that Yubico used an invalid certificate chain in their
Personal Identity Verification (PIV) attestation feature on YubiKey 4.3 ~~and YubiKey NEO~~, which could
only be solved by a new hardware release. The impact for users and organizations is that the
certificate chain will be deemed invalid by tools that verifies the chain properly, such as OpenSSL
version 1.1.0 and later. Yubico has published a custom Python script that can be used to verify
their attestation certificate chains. Organizations can also deploy their own certificates onto the
affected YubiKeys instead of relying on Yubico's public key infrastructure (PKI).

**UPDATE 2020-JAN-08:** I've striked out YubiKey NEO above since that device never had the
attestation capability. YubiKey NEO was erroneously mentioned in [Yubico's support article about
this
problem](https://support.yubico.com/support/solutions/articles/15000013406-piv-attestation-verification-fails-with-openssl-1-1-0)
which has now been corrected. Thanks to Klas Lindfors at Yubico for pointing out this in my
[yubico-piv-tool pull request #216](https://github.com/Yubico/yubico-piv-tool/pull/216).

# What Is A YubiKey?
A YubiKey is a small device you use over USB or NFC with your computer or mobile phone. It can store
and protect different kinds of secrets used for OATH (TOTP, HOTP), U2F, WebAuthn and asymmetric
encryption like PGP etcetera. You can either import existing keys you have generated on your
computer or have the YubiKey generate them on board. The main advantage for that is that the private
key cannot be extracted from the device. That means that physical access to one particular YubiKey
is needed in order to sign something with the private key or decrypt anything encrypted with the
public key.

{{< tweet 1211400748053008390 >}}

# What Is Key Attestation?

Organizations might want to buy YubiKeys for their employees for use with GPG, SSH etcetera and
require that only asymmetric keys generated on the devices are used in their environment. In order
to prevent mistakes or "lazy" employees who want to cut corners they might want to require proof
that a key pair was actually generated on a YubiKey and not just generated on a laptop and stored
insecurely.

YubiKey 4.3 and later come with a feature called key attestation which means that the YubiKey comes
with a private key that can be used to produce a certificate that a particular key pair was actually
generated on board on the device.

If you want to read Yubico's own explanation, see [PIV
Attestation](https://developers.yubico.com/PIV/Introduction/PIV_attestation.html) and [Using
Attestation](https://developers.yubico.com/yubico-piv-tool/Attestation.html) for technical details
on how to do it.

# The Discovered Certificate Problem
I found that the attest certificate, the intermediate attestation certificate and Yubico's PIV root
CA didn't form a proper verifiable certificate chain following Yubico's documented example. First I
thought there was a problem with the `openssl` commands and the contents of individual `.pem` files
and contacted Yubico support via email (see below for full email conversation). Soon I discovered
that the OpenSSL version mattered and started dissecting the [OpenSSL source
code](https://github.com/openssl/openssl) and found that it was actually an **improvement** in the
verification code that made the YubiKey certificate to not verify.

I found that the attestation certificate embedded from factory on my YubiKey (with subject *CN =
Yubico PIV Attestation*) had neither the required Basic Constraint `CA:TRUE` nor the Key Usage
*Certificate Sign* so it wasn't trusted to issue any certificates but it did so anyway.

My conclusion is that Yubico used only old versions of OpenSSL to test the attestation feature and
thought the certificate chain was properly constructed since OpenSSL didn't complain.

# Maximum Path Length
After or at least outside of my conversation with the Yubico support I realized that there was a
problem with their PIV root CA as well. It was marked as a CA, but `pathlen` was set to 0:

```
       X509v3 extensions:
            X509v3 Subject Key Identifier:
                CA:5F:CA:F2:C4:A2:31:9C:E9:22:5F:F1:EC:F4:D5:DF:02:BF:83:BF
            X509v3 Basic Constraints:
                CA:TRUE, pathlen:0
            X509v3 Key Usage: critical
                Certificate Sign, CRL Sign
```

From the [*Basic Constraints* section of RFC 5280, Internet X.509 Public Key Infrastructure
Certificate and Certificate Revocation List (CRL)
Profile](https://tools.ietf.org/html/rfc5280#section-4.2.1.9) (my emphasis):

> The pathLenConstraint field is meaningful only if the cA boolean is
> asserted and the key usage extension, if present, asserts the
> keyCertSign bit (Section 4.2.1.3).  In this case, it gives the
> maximum number of non-self-issued intermediate certificates that may
> follow this certificate in a valid certification path.  (Note: The
> last certificate in the certification path is not an intermediate
> certificate, and is not included in this limit.  Usually, the last
> certificate is an end entity certificate, but it can be a CA
> certificate.)  **A pathLenConstraint of zero indicates that no non-self-issued
> intermediate CA certificates may follow in a valid
> certification path.**  Where it appears, the pathLenConstraint field
> MUST be greater than or equal to zero.  Where pathLenConstraint does
> not appear, no limit is imposed.

So their attestation intermediate certificate is not allowed to sign any end-entity certificates,
which it actually **is** used for.

# New Intermediate Certificate in YubiKey 5 and New Root CA

The 23rd of September 2018 Yubico announced YubiKey 5: [Introducing the YubiKey 5 Series with New
NFC and FIDO2 Passwordless
Features](https://www.yubico.com/2018/09/introducing-the-yubikey-5-series-with-new-nfc-and-fido2-passwordless-features/).
On the same day they published information about the problem I found and a workaround for old
devices in their support article [PIV Attestation Verification Fails with OpenSSL
1.1.0](https://support.yubico.com/support/solutions/articles/15000013406-piv-attestation-verification-fails-with-openssl-1-1-0)
and updated their [PIV attestation
introduction](https://developers.yubico.com/PIV/Introduction/PIV_attestation.html) with a link to a
new root CA ([.pem](https://developers.yubico.com/PIV/Introduction/piv-attestation-ca.pem),
[my copy](/blog/resources/piv-attestation-ca.pem), [text
format](/blog/resources/piv-attestation-ca.pem.txt)) and a note about the old root
CA ([.pem](https://developers.yubico.com/PIV/Introduction/piv-attestation-ca-old.pem),
[my copy](/blog/resources/piv-attestation-ca-old.pem), [text
format](/blog/resources/piv-attestation-ca-old.pem.txt)).

It seems Yubico also found out about the problem with the path length. The only difference in the
new root CA (apart from the obvious different signature) is that the `pathlen` field changed:
```
<                 CA:TRUE, pathlen:0
---
>                 CA:TRUE, pathlen:1
```

That's a bit unconventional. They chose to keep the same serial number on the new certificate even
though the fingerprint changed.

```
        Issuer: CN = Yubico PIV Root CA Serial 263751
...
        Subject: CN = Yubico PIV Root CA Serial 263751
```

The intermediate certificate stored on the YubiKey 5 has a new key pair but also the following added
property which allows it to sign certificates:

```
>             X509v3 Basic Constraints: critical
>                 CA:TRUE, pathlen:0
```

# Workaround: Using Yubico's Verification Python Script

In the announcement linked to above about the OpenSSL 1.1.0 problems Yubico included an interactive
Python script [`piv-attest.py`](https://support.yubico.com/helpdesk/attachments/15006846984) that
customers can use instead of OpenSSL to verify the certificate chain of an attestation produced on a
YubiKey 4.3.

# Workaround: Using Your Own CA

If you own an affected YubiKey 4.3 and want to use the attestation feature but don't want to buy a
YubiKey 5 you can instead use your own PKI. By using the `yubico-piv-tool` actions [`import-key` and
`import-certificate`](https://developers.yubico.com/yubico-piv-tool/Actions/key_import.html) to
import a key and a certificate to the special attestation key slot `f9`. By doing so you're not
affected by the problem since you will replace the factory attestation key and certificate your
YubiKey came with.

# Email Conversation With Yubico Support
For transparency, see the [full email conversation]({{< ref
"../attachment/2019-12-30-yubico-attestation-email-conversation.md" >}}) I had
with the Yubico support regarding attestation problems.

# Comments?

Do you have comments? Interact with this tweet:

{{< tweet 1211653256415461380 >}}

# Credit

Thanks to Alexander Kjäll for reviewing.

Broken chain image from [Clipart
Gallery](http://clipart-library.com/clip-art/365-3653229_transparent-background-broken-chains-png.htm).
