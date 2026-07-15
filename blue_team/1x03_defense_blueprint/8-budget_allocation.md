# MedDefense Year-1 Budget Allocation

## Part 1 - Primary Selection

### Funded Controls (Year 1)
| Control | Cost | Why Funded |
|---|---:|---|
| Network segmentation | $18,000 | Highest net value; breaks multiple kill chains |
| MFA for VPN/admin | $8,000 | Cheapest, fastest identity risk reduction |
| Wazuh SIEM | $22,000 | Creates core visibility and alerting |
| Immutable offsite backups | $14,000 | Lowers ransomware recovery exposure |
| EDR upgrade | $42,000 | Closes major server and endpoint blind spot |
| Westside dedicated firewall | $9,000 | Hardens weakest branch boundary |

**Total funded spend:** **$113,000**  
**Budget remaining:** **$7,000** (held as contingency for implementation variance, training, or storage growth)

### Deferred to Next Fiscal Year
| Control | Cost | Reason for Deferral (deferred) |
|---|---:|---|
| Full medical device isolation with monitoring | $28,000 | Justified, but enterprise segmentation, credential resets, and management-zone controls reduce risk enough to delay full device monitoring until year 2 |

### Rejected for Year 1
| Control | Cost | Reason for rejected control decisions |
|---|---:|---|
| Outsourced 24/7 SOC | $95,000 | Not cost-justified before MedDefense has mature SIEM/EDR telemetry and stable alert content |

## Part 2 - Opportunity Cost of Deferral
- **By deferring full medical device isolation, MedDefense accepts an estimated $95,000 in annual residual exposure** tied to device-specific compromise, partial network visibility gaps, and legacy clinical technology risk. Core segmentation and password remediation reduce that risk, but do not eliminate it.

## Part 3 - Alternative Allocation
### Alternative Package
| Control | Cost |
|---|---:|
| Network segmentation | $18,000 |
| MFA for VPN/admin | $8,000 |
| Wazuh SIEM | $22,000 |
| Immutable offsite backups | $14,000 |
| Full medical device isolation | $28,000 |

**Total:** **$90,000**  
**Estimated total ALE reduction:** **$2,780,000**

### Comparison to Primary Recommendation
- **Primary plan:** $113,000 spend; ~$3,190,000 ALE reduction  
- **Alternative plan:** $90,000 spend; ~$2,780,000 ALE reduction  
- **Difference:** The alternative saves $23,000, but leaves MedDefense without full EDR coverage and without the Westside boundary fix, which weakens ransomware prevention and branch containment.

## Conclusion
The primary recommendation is the best balance of **risk reduction, coverage breadth, and budget discipline**. It stays under the $120000 cap, preserves a small reserve, and funds the controls that most directly reduce enterprise ransomware, breach, and recovery risk.

# funded, deferred, and rejected control decisions budget usage and remaining-budget anchors alternative allocation and comparison language annual risk exposure
