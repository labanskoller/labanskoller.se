---
title: "Vulnerability P1IB-LABAN-002: Cross-Site Request Forgery"
author: Laban Sköllermark ([@LabanSkoller](https://twitter.com/LabanSkoller))
date: 2024-08-16T01:00:00+02:00
toc: true
---
This is an attachment to the blog post [Wardriving 2024: Using Electricity Meter Readers to Get In]({{< ref "/blog/2024-08-16-wardriving-2024.md" >}}).

# Vulnerability Metadata

**Vulnerability identifier:** P1IB-LABAN-002

**Summary:** Cross-Site Request Forgery.

**CWE:** [CWE-352: Cross-Site Request Forgery (CSRF)](https://cwe.mitre.org/data/definitions/352.html)

**CVE:** None. A CVE was requested from the [MITRE CNA-LR](https://cveform.mitre.org/) without any response.

**CVSS:** 9.3 / Critical [CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:P/VC:H/VI:H/VA:H/SC:H/SI:H/SA:N/AU:Y/R:U](https://www.first.org/cvss/calculator/4.0#CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:P/VC:H/VI:H/VA:H/SC:H/SI:H/SA:N/AU:Y/R:U)

### MITRE Submission

The following information was [submitted](https://cveform.mitre.org/) to the MITRE CNA-LR in *CVE Request 1610270 for CVE ID Request* the 24th of February 2024. No response was given.

**Vulnerability type:** Cross Site Request Forgery (CSRF)

**Vendor of the product(s):** [Remne Technologies AB](https://remne.tech/)

**Product:** P1IB - P1 Interface Bridge - https://github.com/remne/p1ib

**Version:** Found in stable version 9c2ad9a (build date 2023-SEP-22). Not fixed.

**Has vendor confirmed or acknowledged the vulnerability?** Yes

**Attack type:** Remote

**Impact:** Code Execution, Denial of Service, Escalation of Privileges

**Attack vector(s):** Drive-by or phishing required. If the web interface of
the device is password protected, the victim must be authenticated in the same
browser.

**Suggested description of the vulnerability for use in the CVE:**
A Cross-Site Request Forgery (CSRF) vulnerability in the web interface of smart
meter reader P1IB by Remne Technologies AB allows a remote attacker to reboot
the device, factory reset the device or initiate update of arbitrary firmware.

**Discoverer(s)/Credits:** Laban Sköllermark

**Reference(s):**

* https://github.com/remne/p1ib

**Additional information:**

* Coordinated disclosure deadline: 2024-APR-23
* CWE-352: Cross-Site Request Forgery (CSRF)
