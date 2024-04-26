---
title: "Vulnerability P1IB-LABAN-008: Insecure defaults"
author: Laban Sköllermark ([@LabanSkoller](https://twitter.com/LabanSkoller))
date: 2024-08-16T01:00:00+02:00
toc: true
---
This is an attachment to the blog post [Wardriving 2024: Using Electricity Meter Readers to Get In]({{< ref "/blog/2024-08-16-wardriving-2024.md" >}}).

# Vulnerability Metadata

**Vulnerability identifier:** P1IB-LABAN-008

**Summary:** Insecure defaults.

**CWE:** [CWE-1188: Initialization of a Resource with an Insecure Default](https://cwe.mitre.org/data/definitions/1188.html)

**CVE:** None. A CVE was requested from the [MITRE CNA-LR](https://cveform.mitre.org/) without any response.

**CVSS:** 8.7 / High [CVSS:4.0/AV:A/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N/R:U](https://www.first.org/cvss/calculator/4.0#CVSS:4.0/AV:A/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N/R:U)

# MITRE Submission

The following information was [submitted](https://cveform.mitre.org/) to the MITRE CNA-LR in *CVE Request 1610270 for CVE ID Request* the 24th of February 2024. No response was given.

**Vulnerability type:** Other or Unknown

**Other vulnerability type:** [CWE-1188: Initialization of a Resource with an Insecure Default](https://cwe.mitre.org/data/definitions/1188.html)

**Vendor of the product(s):** [Remne Technologies AB](https://remne.tech/)

**Product:** P1IB - P1 Interface Bridge - https://github.com/remne/p1ib

**Version:** Found in stable version 9c2ad9a (build date 2023-SEP-22). Not fixed.

**Has vendor confirmed or acknowledged the vulnerability?** No

**Attack type:** Remote

**Impact:** Information Disclosure

**Suggested description of the vulnerability for use in the CVE:**
The smart meter reader P1IB by Remne Technologies AB is using insecure
defaults. The factory setting is to start in Access Point (AP) mode with an
open and unencrypted web interface over plaintext HTTP with no password
protection. The setting of an administrator password is hidden under advanced
settings. The owner of the device is supposed to provision it by selecting a
wireless network to join to [sic!] device to and enter its Pre-Shared Key (PSK)
over this insecure interface. If the device at any time fails to join its
configured network or if an attacked [sic!] performs a deauthentication attack
to kick the device out from its network, it falls back to open/unencrypted AP
mode, and there is no possibility to set a PSK for the AP mode.

**Discoverer(s)/Credits:** Laban Sköllermark

**Reference(s):**

* https://github.com/remne/p1ib

**Additional information:**

* Coordinated disclosure deadline: 2024-APR-23
