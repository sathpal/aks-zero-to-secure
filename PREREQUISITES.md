# Prerequisites

Set these up **before Session 1**. The Azure part can wait until the week before Session 2.

## Your laptop

- macOS, Linux, or Windows 11 with **WSL2**. On Windows, run every lab command in the WSL2 (Ubuntu) terminal.
- 8 GB RAM at minimum (16 GB is more comfortable) and 20 GB of free disk space.
- You can install software. Corporate laptops sometimes block Docker or `cgr.dev`; Session 1 has a fallback for the registry.

## Session 1 tools

| Tool | Check | Install |
|---|---|---|
| git | `git --version` | [git-scm.com/downloads](https://git-scm.com/downloads) |
| Docker | `docker version` shows a *Server* section | [Docker Desktop](https://docs.docker.com/get-docker/). Docker Desktop is free for personal, education and small-business use. At a larger company, use [Rancher Desktop](https://rancherdesktop.io/) or [Colima](https://github.com/abiosoft/colima) instead |
| kind v0.29 or later | `kind version` | [kind quick start](https://kind.sigs.k8s.io/docs/user/quick-start/#installation). On macOS: `brew install kind` |
| kubectl v1.32 or later | `kubectl version --client` | [kubernetes.io/docs/tasks/tools](https://kubernetes.io/docs/tasks/tools/). On macOS: `brew install kubectl` |
| curl | `curl --version` | Preinstalled on macOS, Linux and WSL2 |

## Azure (from Session 2)

1. **A subscription where you are Owner.** A new [Azure free account](https://azure.microsoft.com/free/) works. Pay-as-you-go works too. Don't use your employer's production subscription.
   - On free-trial and free-credit subscriptions, Azure Container Registry won't run `az acr build`. Session 2 shows the alternative.
2. **Azure CLI:** [install it](https://learn.microsoft.com/cli/azure/install-azure-cli), then run `az login` and `az account show`.
3. **kubelogin**, needed from Session 9 (Entra ID sign-in): `az aks install-cli` installs it, together with kubectl.
4. **A budget alert:** `./infra/budget.sh <amount> <your-email>`. The amount is in your billing currency.

## Later sessions

These tools are installed in the session that first uses them, with instructions in that lab: Helm and a GitHub account (Session 6), k6 (Session 8), and Trivy or Grype, Syft and cosign or Notation (Session 10).

## Cost habits that keep this course cheap

- Session 1 costs nothing. A typical lab from Session 2 onwards costs about **US$1** if you delete everything within two hours.
- Every lab ends with teardown. Run it even when the lab went wrong.
- Before you log off, check: `az group list --query "[?tags.course=='aks-zero-to-secure'].name" -o tsv` should print nothing.
