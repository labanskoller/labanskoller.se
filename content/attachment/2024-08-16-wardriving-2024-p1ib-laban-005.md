---
title: "Vulnerability P1IB-LABAN-005: Plaintext Storage of a Password"
author: Laban Sköllermark ([@LabanSkoller](https://twitter.com/LabanSkoller))
date: 2024-08-16T01:00:00+02:00
toc: true
---
This is an attachment to the blog post [Wardriving 2024: Using Electricity Meter Readers to Get In]({{< ref "/blog/2024-08-16-wardriving-2024.md" >}}).

# Vulnerability Metadata

**Vulnerability identifier:** P1IB-LABAN-005

**Summary:** Password stored in plain text.

**CWE:** [CWE-256: Plaintext Storage of a Password](https://cwe.mitre.org/data/definitions/256.html)

**CVE:** None. A CVE was requested from the [MITRE CNA-LR](https://cveform.mitre.org/) without any response.

**CVSS:** 6.9 / Medium [CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:L/VI:N/VA:N/SC:N/SI:N/SA:N](https://www.first.org/cvss/calculator/4.0#CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:L/VI:N/VA:N/SC:N/SI:N/SA:N)

### MITRE Submission

The following information was [submitted](https://cveform.mitre.org/) to the MITRE CNA-LR in *CVE Request 1610270 for CVE ID Request* the 24th of February 2024. No response was given.

**Vulnerability type:** Other or Unknown

**Other vulnerability type:** [CWE-256: Plaintext Storage of a Password](https://cwe.mitre.org/data/definitions/256.html)

**Vendor of the product(s):** [Remne Technologies AB](https://remne.tech/)

**Product:** P1IB - P1 Interface Bridge - https://github.com/remne/p1ib

**Version:** Found in stable version 9c2ad9a (build date 2023-SEP-22). Not fixed.

**Has vendor confirmed or acknowledged the vulnerability?** Yes

**Attack type:** Remote

**Impact:** Information Disclosure

**Suggested description of the vulnerability for use in the CVE:**
The smart meter reader P1IB by Remne Technologies AB is storing the
administrator's password in clear text and retrievable via a "get
configuration" request. An attacker who has gained access to the device via the
authentication bypass vulnerability can get the administrator password, which
might be used on other devices or accounts.

**Discoverer(s)/Credits:** Laban Sköllermark

**Reference(s):**

* https://github.com/remne/p1ib

**Additional information:**

* Coordinated disclosure deadline: 2024-APR-23
