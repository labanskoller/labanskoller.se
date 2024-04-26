---
title: "Vulnerability P1IB-LABAN-001: Missing Authorization"
author: Laban Sköllermark ([@LabanSkoller](https://twitter.com/LabanSkoller))
date: 2024-08-16T01:00:00+02:00
toc: true
---
This is an attachment to the blog post [Wardriving 2024: Using Electricity Meter Readers to Get In]({{< ref "/blog/2024-08-16-wardriving-2024.md" >}}).

# Vulnerability Metadata

**Vulnerability identifier:** P1IB-LABAN-001

**Summary:** A wireless or adjacent network attacker can completely compromise the device, including extracting Pre-Shared Key (PSK) for the Wi-Fi SSID the device is connected to.

**CWE:** [CWE-862: Missing Authorization](https://cwe.mitre.org/data/definitions/862.html)

**CVE:** None

**CVSS:** 9.9 / Critical [CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:N/AU:Y/R:U/V:C/RE:M](https://www.first.org/cvss/calculator/4.0#CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:N/AU:Y/R:U/V:C/RE:M)

### MITRE Submission

The following information was [submitted](https://cveform.mitre.org/) to the MITRE CNA-LR in *CVE Request 1610270 for CVE ID Request* the 24th of February 2024. No response was given.

**Vulnerability type:** Incorrect Access Control

**Vendor of the product(s):** [Remne Technologies AB](https://remne.tech/)

**Product:** P1IB - P1 Interface Bridge - https://github.com/remne/p1ib

**Version:** Found in stable version 9c2ad9a (build date 2023-SEP-22). Fixed in stable version aae1e85 (build date 2024-FEB-12).

**Has vendor confirmed or acknowledged the vulnerability?** Yes

**Attack type:** Remote

**Impact:** Code Execution, Denial of Service, Escalation of Privileges, Information Disclosure

**Suggested description of the vulnerability for use in the CVE:**
Authentication bypass in the web interface of smart meter reader P1IB by Remne
Technologies AB in stable versions built before 2024-FEB-12 allows a wireless
or adjacent network attacker to completely compromise the device, including
extracting Pre-Shared Key (PSK) for the Wi-Fi SSID the device is connected to.

**Discoverer(s)/Credits:** Laban Sköllermark

**Reference(s):**

* https://github.com/remne/p1ib

**Additional information:**

* Coordinated disclosure deadline: 2024-APR-23
* CWE-862: Missing Authorization
