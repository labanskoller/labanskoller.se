---
title: Email Conversation With Yubico Support
author: Laban Sköllermark ([@LabanSkoller](https://twitter.com/LabanSkoller))
date: 2019-12-30T15:00:00+01:00
featured_image: blog/images/broken_chains.png
images:
  - blog/images/brokan_chains.png
toc: true
---
This is an attachment to the blog post about [the broken attestation certificate chain in YubiKey
4.3 and YubiKey NEO]({{< ref "../blog/2019-12-30-yubico-attestation-pki.md" >}}).

Headers are mine and not part of the original conversation. Long commands have been split to
multiple lines using `\ ` to fit the blog. All indications of time are given in two time zones:
[CEST](https://www.timeanddate.com/time/zones/cest) where I was sitting and
[PDT](https://www.timeanddate.com/time/zones/pdt) where Yubico Support was sitting.

# Initial Report on Wrong Commands in Documentation
From me to Yubico Support:
***
**Date:** Sat 2018-JUL-14 01:33 CEST (2018-JUL-13 4:33 PM PDT)<br/>
**Subject:** Wrong commands in documentation about key attestation

Hi!<br/>
I tried to follow your guideline on how to verify attestation as documented on <https://developers.yubico.com/yubico-piv-tool/Attestation.html#\_verifying>.<br/>
I found that the described way of verifying with OpenSSL does not work.<br/>
Preparations:<br/>
1. Download https://developers.yubico.com/PIV/Introduction/piv-attestation-ca.pem as piv-attestation-ca.pem<br/>
2. Get the attestion certificate from the YubiKey:<br/>
$ yubico-piv-tool \-\-action=read-certificate \-\-slot=f9 > my\_f9\_cert.pem<br/>
3. Attest the key in slot 9a:<br/>
$ yubico-piv-tool \-\-action=attest \-\-slot=9a > attestation.pem

Now I have three files:<br/>
$ ls<br/>
attestation.pem  my\_f9\_cert.pem  piv-attestation-ca.pem

Your documentation says that I should create a certificate chain file with the attestation root CA first and then append it with the attestion certificate from my YubiKey (using action "read-certificate"). If I do that and then use your suggested "openssl verify" command I get the following error:<br/>
$ cat piv-attestation-ca.pem my\_f9\_cert.pem > certs.pem<br/>
$ openssl verify -CAfile certs.pem attestation.pem<br/>
CN = Yubico PIV Attestation<br/>
error 24 at 1 depth lookup: invalid CA certificate<br/>
error attestation.pem: verification failed

My interpretation of the OpenSSL documentation (man verify) is that there is an error because the certificate in my\_f9\_cert.pem is not a CA because it's not self-signed.

However if I have only your root CA in the file supplied with "-CAfile" and my YubiKey's attestation certificate (my\_f9\_cert.pem) and the attest (attestation.pem) in the file being verified, it works:<br/>
$ cat my\_f9\_cert.pem attestation.pem > f9\_and\_attestation.pem<br/>
$ openssl verify -CAfile piv-attestation-ca.pem f9\_and\_attestation.pem<br/>
f9\_and\_attestation.pem: OK

My OpenSSL version:<br/>
$ openssl version<br/>
OpenSSL 1.1.0g  2 Nov 2017

Best regards<br/>
Laban Sköllermark

# Yubico's Initial Response
**Date:** Mon 2018-JUL-16 17:35 CEST (8:35 AM PDT)

Hi Laban,

Thank you for contacting Yubico Support. I am not able to reproduce your issue when following the guide. See my terminal output below. I have the piv-attestation-ca.pem file saved as certs.pem ahead of time, as demonstrated by the last command. Your openssl verify command should fail if you don't concatenate the f9 cert, as it is the intermediate/issuing CA in this case and the certificate chain cannot be completed without it.

$ yubico-piv-tool \-\-action=read-certificate \-\-slot=f9 >> certs.pem

$ yubico-piv-tool \-\-action=attest \-\-slot=9a > attest.pem

$ openssl verify -CAfile certs.pem attest.pem<br/>
attest.pem: OK

$ cat certs.pem<br/>
\-\-\-\-\-BEGIN CERTIFICATE\-\-\-\-\-<br/>
MIIDFzCCAf+gAwIBAgIDBAZHMA0GCSqGSIb3DQEBCwUAMCsxKTAnBgNVBAMMIFl1<br/>
YmljbyBQSVYgUm9vdCBDQSBTZXJpYWwgMjYzNzUxMCAXDTE2MDMxNDAwMDAwMFoY<br/>
DzIwNTIwNDE3MDAwMDAwWjArMSkwJwYDVQQDDCBZdWJpY28gUElWIFJvb3QgQ0Eg<br/>
U2VyaWFsIDI2Mzc1MTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMN2<br/>
cMTNR6YCdcTFRxuPy31PabRn5m6pJ+nSE0HRWpoaM8fc8wHC+Tmb98jmNvhWNE2E<br/>
ilU85uYKfEFP9d6Q2GmytqBnxZsAa3KqZiCCx2LwQ4iYEOb1llgotVr/whEpdVOq<br/>
joU0P5e1j1y7OfwOvky/+AXIN/9Xp0VFlYRk2tQ9GcdYKDmqU+db9iKwpAzid4oH<br/>
BVLIhmD3pvkWaRA2H3DA9t7H/HNq5v3OiO1jyLZeKqZoMbPObrxqDg+9fOdShzgf<br/>
wCqgT3XVmTeiwvBSTctyi9mHQfYd2DwkaqxRnLbNVyK9zl+DzjSGp9IhVPiVtGet<br/>
X02dxhQnGS7K6BO0Qe8CAwEAAaNCMEAwHQYDVR0OBBYEFMpfyvLEojGc6SJf8ez0<br/>
1d8Cv4O/MA8GA1UdEwQIMAYBAf8CAQAwDgYDVR0PAQH/BAQDAgEGMA0GCSqGSIb3<br/>
DQEBCwUAA4IBAQA8bRnIMVi+xLco6rHFKdZvPgXx4Rb8PiaQnIZtfuDgJk36n/ID<br/>
bBrSw5DX5Gn8JwWz0In5afTpyb4ICylnsu4Z4rJG9AcYQzVLqHkQlpSQ4mtPfDU7<br/>
SZ37nEOwxyTpY4r81eSb1hkNWfAcv0V1Upwmo5gTqqddL2eMxYUw/IPzp8x2bB+z<br/>
mRVw7OIq0VIVg3vWI3yqh8lDNdy8vN9i1gXtDUQjWkA0Xwl3l9cw4G1La2J/VSoA<br/>
OW0UjTJvprEvG7wSvfziAmkDds9afPk2etXn0hyDmzcpj07jS31/JJJ2UpKIjX/W<br/>
G5cNAbH/oWi5OXS53bl7Zuuo4RLgxktTdrd+<br/>
\-\-\-\-\-END CERTIFICATE\-\-\-\-\-<br/>
\-\-\-\-\-BEGIN CERTIFICATE\-\-\-\-\-<br/>
MIIC5jCCAc6gAwIBAgIJAIDJ0Mz+WTdUMA0GCSqGSIb3DQEBCwUAMCsxKTAnBgNV<br/>
BAMMIFl1YmljbyBQSVYgUm9vdCBDQSBTZXJpYWwgMjYzNzUxMCAXDTE2MDMxNDAw<br/>
MDAwMFoYDzIwNTIwNDE3MDAwMDAwWjAhMR8wHQYDVQQDDBZZdWJpY28gUElWIEF0<br/>
dGVzdGF0aW9uMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwbtblxQC<br/>
Xlyh/2yI/e/4MAWboIXhQDDhsT2GBoE/wCF3Yan1dQ5VfFMxa4aIaJIVfxvjw574<br/>
q/7MbS9oVFqqrqc5f7hS/kW0fCYuzgpCEcod3hOcJOIPjplDmBHhOaR3punP57Je<br/>
n8MKS6iU/qwa1aKLpYvBcV1Q2Ep9pQMtSqJ1GXXwSNe0V8LNTRh9gJlolHJdp9OS<br/>
9YTYlvB3O0TSd2QLAxOnUkfEwXdsi33n3usgcCEqMsPRnz6ULeOMeWPEnW/rZr7E<br/>
mbNcf/VFDwxytbWm/rHva02EQvJ7scVRcnA8hPWY9S5iiOplM69FJ7Y2u8nCoz/3<br/>
PwyKPwluYkWL4QIDAQABoxUwEzARBgorBgEEAYLECgMDBAMEAwQwDQYJKoZIhvcN<br/>
AQELBQADggEBAGYtvFFppUdbMuEvcQoI/1NmSi0YSjoNq2Yxv6HlIOWOrtmU1CNU<br/>
NyE1rmb8jWIDQJp7iDbxUjTpRiGTqZUx1I6DOA2Jl1UJFIV40G3WZno8s8VEc+S7<br/>
3U/f5jbuSYrn27uOw7a10jl7eGhZO4I2Kp0sIcmPzT8Y/GoRlPVj6V+g8yOOlvUA<br/>
lSnC/SnEdd7eN4+nLZ19v3HfpP6XK14YGApdHl4M1Qq1ucngpG2K4VEVl5V/OrmI<br/>
IbgcOpOvXvLmyhy8yoGCP27LS0qO9AT7tJiLcGJXnG3sN2D7ewsRHj1Sszfi6QKt<br/>
LL62+racaCSKom8Ty1yBgNiZmcho8+buAfU=<br/>
\-\-\-\-\-END CERTIFICATE\-\-\-\-\-

Sincerely,<br/>
\<REDACTED\><br/>
Yubico Support

# Suspicion That Intermediate Certificate Is Not Allowed to Sign Certificates
From me to Yubico Support:
***
**Date:** Wed 2018-JUL-18 13:05 CEST (4:05 AM PDT)

Hi \<REDACTED\>!

First I would like to point out that my suggested command doesn't do what I want. It turns out openssl reads just one certificate from the file given as last argument, so when trying to verify my suggested "f9\_attestation.pem", all it does is to verify that the Yubico intermediate cert with CN "Yubico PIV Attestation" is signed by the Yubico root cert with CN "Yubico PIV Root CA Serial 263751". That can be seen when adding "-show\_chain" available in newer versions of OpenSSL.

However, your command doesn't work either when using OpenSSL 1.1.0g which comes with Ubuntu 18.04.

What version of OpenSSL are you using? When I copy the files to another computer running OpenSSL 1.0.2k-fips, your verify command works perfectly well!

I suspect that the problem is that your intermediate cert embedded on the YubiKeys doesn't have the "X509v3 Key Usage" extension set to "Certificate Sign", so it's not allowed to create any attestation certs. I think that's why it doesn't work on newer OpenSSL versions. What do you think?

Best regards<br/>
Laban Sköllermark

# Bug in OpenSSL?
From Yubico Support to me:
***
**Date:** Wed 2018-JUL-18 18:18 CEST (9:18 AM PDT)

Hi Laban,

The PIV Attestation (intermediate) certificate has the key usage of "Any". I have confirmed that the verification fails on Ubuntu 1804 (OpenSSL 1.1.0g) and succeeds on macOS 10.13.6 (LibreSSL 2.2.7) and Ubuntu 1604 (OpenSSL 1.0.2g). This is an issue with OpenSSL, and you should file a bug report with them.

Sincerely,<br/>
\<REDACTED\><br/>
Yubico Support

# No, Stricter Certificate Chain Verification in OpenSSL 1.1
From me to Yubico Support:
***
**Date:** Tue 2018-JUL-24 12:36 CEST (3:36 AM PDT)

On Wed, Jul 18, 2018 at 6:18 PM, Yubico Support <support@yubico.com> wrote:<br/>

> Hi Laban,

Hi \<REDACTED\>!

> I have confirmed that the verification fails on Ubuntu 1804 (OpenSSL 1.1.0g) and succeeds on macOS 10.13.6 (LibreSSL 2.2.7) and Ubuntu 1604 (OpenSSL 1.0.2g). This is an issue with OpenSSL, and you should file a bug report with them.

I've done some research which I would like your feedback on before contacting the OpenSSL community, because I don't think OpenSSL does anything wrong here.

After cloning the OpenSSL GitHub Git repo, I looked at the source code and found that the code for the "verify" command mainly resides in `crypto/x509/x509_vfy.c`. After looking at changes in that file and building different commits myself, my conclusion is that the behavior changed in OpenSSL 1.1.0, specifically with this particular commit:

```
commit 0daccd4dc1f1ac62181738a91714f35472e50f3c
Author: Viktor Dukhovni <openssl-users@dukhovni.org>
Date:   Thu Jan 28 03:01:45 2016 -0500

    Check chain extensions also for trusted certificates

    This includes basic constraints, key usages, issuer EKUs and auxiliary
    trust OIDs (given a trust suitably related to the intended purpose).

    Added tests and updated documentation.

    Reviewed-by: Dr. Stephen Henson <steve@openssl.org>
```

My tests on the commit before and then with that commit:

```
$ #1b4cf96f9b82ec3b06e7902bb21620a09cadd94e
$ #OpenSSL 1.1.0-pre3-dev  xx XXX xxxx
$ LD_LIBRARY_PATH=../git/openssl/ ../git/openssl/apps/openssl \
    verify -verbose -CAfile certs.pem attestation.pem
attestation.pem: OK
```

```
$ #0daccd4dc1f1ac62181738a91714f35472e50f3c
$ #OpenSSL 1.1.0-pre3-dev  xx XXX xxxx
$ LD_LIBRARY_PATH=../git/openssl/ ../git/openssl/apps/openssl \
    verify -verbose -CAfile certs.pem attestation.pem
CN = Yubico PIV Attestation
error 24 at 1 depth lookup: invalid CA certificate
error attestation.pem: verification failed
```

I think that OpenSSL has made their validation of certificate chains **stricter** in recent versions (1.1.0 and newer), but believe that they have correct behavior.

Do you mind sharing how you draw the following conclusion?

> The PIV Attestation (intermediate) certificate has the key usage of "Any".

When I check with the `x509` command of OpenSSL, the intermediate certificate (the one I extract from slot f9 which is the same certificate you have in your `certs.pem` in a previous email) does **not** have neither the X509v3 Basic Constraint "CA:TRUE" nor the X509v3 Key Usage "Certificate Sign". Do you mean that the lack of those extensions mean that the certificate has a key usage of "Any", or do you have any other motivation?

Please compare the text versions of your root CA and your intermediate certificate below (I used latest version on master branch of OpenSSL, but I get the same output with older versions as well):

```
$ #master (0efa0ba4e664d6d3dab1ec2b9bce3b39696f4ac7)
$ #OpenSSL 1.1.1-pre9-dev  xx XXX xxxx
$ LD_LIBRARY_PATH=../git/openssl/ ../git/openssl/apps/openssl \
    x509 -noout -text -certopt ext\_dump -in piv-attestation-ca.pem
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 263751 (0x40647)
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN = Yubico PIV Root CA Serial 263751
        Validity
            Not Before: Mar 14 00:00:00 2016 GMT
            Not After : Apr 17 00:00:00 2052 GMT
        Subject: CN = Yubico PIV Root CA Serial 263751
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus:
                    00:c3:76:70:c4:cd:47:a6:02:75:c4:c5:47:1b:8f:
                    cb:7d:4f:69:b4:67:e6:6e:a9:27:e9:d2:13:41:d1:
                    5a:9a:1a:33:c7:dc:f3:01:c2:f9:39:9b:f7:c8:e6:
                    36:f8:56:34:4d:84:8a:55:3c:e6:e6:0a:7c:41:4f:
                    f5:de:90:d8:69:b2:b6:a0:67:c5:9b:00:6b:72:aa:
                    66:20:82:c7:62:f0:43:88:98:10:e6:f5:96:58:28:
                    b5:5a:ff:c2:11:29:75:53:aa:8e:85:34:3f:97:b5:
                    8f:5c:bb:39:fc:0e:be:4c:bf:f8:05:c8:37:ff:57:
                    a7:45:45:95:84:64:da:d4:3d:19:c7:58:28:39:aa:
                    53:e7:5b:f6:22:b0:a4:0c:e2:77:8a:07:05:52:c8:
                    86:60:f7:a6:f9:16:69:10:36:1f:70:c0:f6:de:c7:
                    fc:73:6a:e6:fd:ce:88:ed:63:c8:b6:5e:2a:a6:68:
                    31:b3:ce:6e:bc:6a:0e:0f:bd:7c:e7:52:87:38:1f:
                    c0:2a:a0:4f:75:d5:99:37:a2:c2:f0:52:4d:cb:72:
                    8b:d9:87:41:f6:1d:d8:3c:24:6a:ac:51:9c:b6:cd:
                    57:22:bd:ce:5f:83:ce:34:86:a7:d2:21:54:f8:95:
                    b4:67:ad:5f:4d:9d:c6:14:27:19:2e:ca:e8:13:b4:
                    41:ef
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Subject Key Identifier:
                CA:5F:CA:F2:C4:A2:31:9C:E9:22:5F:F1:EC:F4:D5:DF:02:BF:83:BF
            X509v3 Basic Constraints:
                CA:TRUE, pathlen:0
            X509v3 Key Usage: critical
                Certificate Sign, CRL Sign
    Signature Algorithm: sha256WithRSAEncryption
         3c:6d:19:c8:31:58:be:c4:b7:28:ea:b1:c5:29:d6:6f:3e:05:
         f1:e1:16:fc:3e:26:90:9c:86:6d:7e:e0:e0:26:4d:fa:9f:f2:
         03:6c:1a:d2:c3:90:d7:e4:69:fc:27:05:b3:d0:89:f9:69:f4:
         e9:c9:be:08:0b:29:67:b2:ee:19:e2:b2:46:f4:07:18:43:35:
         4b:a8:79:10:96:94:90:e2:6b:4f:7c:35:3b:49:9d:fb:9c:43:
         b0:c7:24:e9:63:8a:fc:d5:e4:9b:d6:19:0d:59:f0:1c:bf:45:
         75:52:9c:26:a3:98:13:aa:a7:5d:2f:67:8c:c5:85:30:fc:83:
         f3:a7:cc:76:6c:1f:b3:99:15:70:ec:e2:2a:d1:52:15:83:7b:
         d6:23:7c:aa:87:c9:43:35:dc:bc:bc:df:62:d6:05:ed:0d:44:
         23:5a:40:34:5f:09:77:97:d7:30:e0:6d:4b:6b:62:7f:55:2a:
         00:39:6d:14:8d:32:6f:a6:b1:2f:1b:bc:12:bd:fc:e2:02:69:
         03:76:cf:5a:7c:f9:36:7a:d5:e7:d2:1c:83:9b:37:29:8f:4e:
         e3:4b:7d:7f:24:92:76:52:92:88:8d:7f:d6:1b:97:0d:01:b1:
         ff:a1:68:b9:39:74:b9:dd:b9:7b:66:eb:a8:e1:12:e0:c6:4b:
         53:76:b7:7e
$ LD_LIBRARY_PATH=../git/openssl/ ../git/openssl/apps/openssl \
    x509 -noout -text -certopt ext\_dump -in my\_f9\_cert.pem
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            80:c9:d0:cc:fe:59:37:54
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN = Yubico PIV Root CA Serial 263751
        Validity
            Not Before: Mar 14 00:00:00 2016 GMT
            Not After : Apr 17 00:00:00 2052 GMT
        Subject: CN = Yubico PIV Attestation
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus:
                    00:c1:bb:5b:97:14:02:5e:5c:a1:ff:6c:88:fd:ef:
                    f8:30:05:9b:a0:85:e1:40:30:e1:b1:3d:86:06:81:
                    3f:c0:21:77:61:a9:f5:75:0e:55:7c:53:31:6b:86:
                    88:68:92:15:7f:1b:e3:c3:9e:f8:ab:fe:cc:6d:2f:
                    68:54:5a:aa:ae:a7:39:7f:b8:52:fe:45:b4:7c:26:
                    2e:ce:0a:42:11:ca:1d:de:13:9c:24:e2:0f:8e:99:
                    43:98:11:e1:39:a4:77:a6:e9:cf:e7:b2:5e:9f:c3:
                    0a:4b:a8:94:fe:ac:1a:d5:a2:8b:a5:8b:c1:71:5d:
                    50:d8:4a:7d:a5:03:2d:4a:a2:75:19:75:f0:48:d7:
                    b4:57:c2:cd:4d:18:7d:80:99:68:94:72:5d:a7:d3:
                    92:f5:84:d8:96:f0:77:3b:44:d2:77:64:0b:03:13:
                    a7:52:47:c4:c1:77:6c:8b:7d:e7:de:eb:20:70:21:
                    2a:32:c3:d1:9f:3e:94:2d:e3:8c:79:63:c4:9d:6f:
                    eb:66:be:c4:99:b3:5c:7f:f5:45:0f:0c:72:b5:b5:
                    a6:fe:b1:ef:6b:4d:84:42:f2:7b:b1:c5:51:72:70:
                    3c:84:f5:98:f5:2e:62:88:ea:65:33:af:45:27:b6:
                    36:bb:c9:c2:a3:3f:f7:3f:0c:8a:3f:09:6e:62:45:
                    8b:e1
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            1.3.6.1.4.1.41482.3.3:
                0000 - 04 03 04                                 ...

    Signature Algorithm: sha256WithRSAEncryption
         66:2d:bc:51:69:a5:47:5b:32:e1:2f:71:0a:08:ff:53:66:4a:
         2d:18:4a:3a:0d:ab:66:31:bf:a1:e5:20:e5:8e:ae:d9:94:d4:
         23:54:37:21:35:ae:66:fc:8d:62:03:40:9a:7b:88:36:f1:52:
         34:e9:46:21:93:a9:95:31:d4:8e:83:38:0d:89:97:55:09:14:
         85:78:d0:6d:d6:66:7a:3c:b3:c5:44:73:e4:bb:dd:4f:df:e6:
         36:ee:49:8a:e7:db:bb:8e:c3:b6:b5:d2:39:7b:78:68:59:3b:
         82:36:2a:9d:2c:21:c9:8f:cd:3f:18:fc:6a:11:94:f5:63:e9:
         5f:a0:f3:23:8e:96:f5:00:95:29:c2:fd:29:c4:75:de:de:37:
         8f:a7:2d:9d:7d:bf:71:df:a4:fe:97:2b:5e:18:18:0a:5d:1e:
         5e:0c:d5:0a:b5:b9:c9:e0:a4:6d:8a:e1:51:15:97:95:7f:3a:
         b9:88:21:b8:1c:3a:93:af:5e:f2:e6:ca:1c:bc:ca:81:82:3f:
         6e:cb:4b:4a:8e:f4:04:fb:b4:98:8b:70:62:57:9c:6d:ec:37:
         60:fb:7b:0b:11:1e:3d:52:b3:37:e2:e9:02:ad:2c:be:b6:fa:
         b6:9c:68:24:8a:a2:6f:13:cb:5c:81:80:d8:99:99:c8:68:f3:
         e6:ee:01:f5
```

Do you still think that OpenSSL is wrong? If so I will write on their mailing list and hope I can quote your answers. I will write "Yubico Support" and not name you.

Best regards<br/>
Laban Sköllermark

-----
**Date:** Wed 2018-JUL-25 18:45 CEST (9:45 AM PDT)

Hi Laban,

Thank you for the extremely detailed update. We will review this and follow up with you.

Sincerely,<br/>
\<REDACTED\><br/>
Yubico Support

# Issue With Certificate Properties Will Be Fixed in Next Hardware Release Cycle
**Date:** Wed 2018-AUG-22 00:13 CEST (Tue 2018-AUG-21 3:13 PM PDT)

Hi Laban,

Thank you for your patience while we investigated this. There was an issue with the certificate properties that will be fixed in the next hardware release cycle. We do not have a timeline for the next release at this time.

Sincerely,<br/>
\<REDACTED\><br/>
Yubico Support

# Documentation Improvements
**Date:** Wed 2018-AUG-22 00:43 CEST (Tue 2018-AUG-21 3:43 PM PDT)

Hi \<REDACTED\>!

Thank you for investigating this! It means that it was worth it for me to do the digging...

So, waiting for the next hardware version, maybe you could write a note on which versions of OpenSSL (incorrectly) support the current verification commands on \<[https://developers.yubico.com/yubico-piv-tool/Attestation.html](https://developers.yubico.com/yubico-piv-tool/Attestation.html)\>?

Best regards<br/>
Laban

-----
**Date:** Wed 2018-AUG-22 18:05 CEST (9:05 AM PDT)

Laban,

We plan on adding a note along those lines once we have the new YubiKey released with the updated certificate.

Sincerely,<br/>
\<REDACTED\><br/>
Yubico Support

-----
**Date:** Mon 2018-AUG-27 23:33 CEST (2:33 PM PDT)

Hi \<REDACTED\>!

I'm sad to hear that other users of your products might run into the same issues as I have in the meantime. Do you think you would accept a pull request if I suggest improvements in this area of the documentation?

My impression is that the problem I've found does not have security implications (other than that the attestation feature using the factory f9 certificate won't work as intended). I'm all for responsible disclosure around sensitive security bugs, but I don't see this "bug" as such and would like to write publicly about my findings. Please tell me if you disagree.

Best regards<br/>
Laban

-----
**Date:** Tue 2018-SEP-04 20:07 CEST (11:07 AM PDT)

Hi Laban,

Feel free to submit a PR if you'd like, it will be reviewed and considered.

Sincerely,<br/>
\<REDACTED\><br/>
Yubico Support

-----
