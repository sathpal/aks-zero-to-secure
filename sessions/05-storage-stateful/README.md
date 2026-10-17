# Session 05: Storage and Stateful Workloads

**Sat 13 Mar 2027 · 10:00–12:00 IST · live on Microsoft Teams** · recording and slides: see the session pack post in the session channel, or the [YouTube playlist](../../README.md#recordings)

> **Status: outline.** The full step-by-step lab is published here one week before the session. The outcome and topics are fixed; exact commands may change.

<!-- instructor: no existing lab covers Azure Disk/Files on AKS. Write new material and add the app's DATA_DIR store (see aks-series-ops/instructor-notes.md). -->

| | |
|---|---|
| **Outcome** | Keep the app's payments across pod restarts and replacements on an Azure Disk, and know when to use Azure Files instead |
| **Cost** | Course cluster plus a small managed disk and file share, a few cents. Deleting the PVC deletes the disk |
| **Builds on** | Session 1 (the 404) and Session 3 |

## What you'll learn

- Why containers lose data, and the 404 from Session 1 explained.
- Volumes, PersistentVolumes, PersistentVolumeClaims and StorageClasses, and the CSI drivers AKS installs (`managed-csi`, `azurefile-csi`).
- Access modes: ReadWriteOnce (Azure Disk) vs ReadWriteMany (Azure Files), and the `Multi-Attach` error.
- Zones and disks: zonal LRS vs ZRS, and why a pod can get stuck `Pending` after its zone fails.
- StatefulSets and `volumeClaimTemplates`, plus snapshots and backups (VolumeSnapshot, Azure Backup for AKS).
- When to use a managed database (Azure Database for PostgreSQL) instead of running one yourself.

## Agenda

| Time (IST) | Block |
|---|---|
| 10:00 | Recap of last session and your questions (10 min) |
| 10:10 | Concepts (30 min) |
| 10:40 | Live demo and guided lab (50 min) |
| 11:30 | Troubleshooting and Q&A (25 min) |
| 11:55 | Assignment and what's next (5 min) |

## Demo and lab flow

1. Reproduce the data loss: create a payment, delete the pod, and the payment is gone.
2. Turn on the app's file store (`DATA_DIR`) on a PVC backed by Azure Disk. Delete the pod; the payment survives.
3. Scale to 2 replicas and hit the ReadWriteOnce limit (`Multi-Attach` or `Pending`). Discuss why.
4. Convert to a StatefulSet with a disk per pod, and see stable pod names and their disks.
5. Mount an Azure Files share ReadWriteMany for comparison.
6. Snapshot a disk, restore it into a new PVC, and check the `reclaimPolicy` before cleaning up.

## How the app grows

The app gains an optional file-backed store (`DATA_DIR`), so payments survive restarts.

## Assignment (draft)

Show a payment that survives `kubectl delete pod`, and explain in two sentences why 2 replicas don't share it.
