# AI Agent Infrastructure Setup - Guide

Dokument opisuje proces migracji na nowy tenant GCP oraz kroki niezbędne do przygotowania środowiska administracyjnego (`admin-project`). Wykonanie tych kroków jest warunkiem koniecznym (Prerequisites) do poprawnego uruchomienia automatyzacji Terraform, która automatycznie powoła docelową infrastrukturę pod Agenta AI.

---

## 📋 Wymagania wstępne (Prerequisites)

Przed przystąpieniem do konfiguracji upewnij się, że posiadasz:
* ID konta rozliczeniowego (**Billing Account ID**).
* ID organizacji GCP (**Organization ID**).
* Dostęp typu `Owner` lub `Folder Creator` / `Folder Admin` na poziomie root organizacji.

---

## 🛠️ Instrukcja krok po kroku

### Krok 1: Struktura Folderów (GOM)
1. Przypisz uprawnienia `Folder Creator` oraz `Folder Admin` dla konta właściciela (Owner) na poziomie organizacji.
2. Utwórz strukturę folderów zgodnie z architekturą projektu (w tym folder główny **GOM**).
3. Utwórz projekt administracyjny `admin-project` wewnątrz dedykowanego folderu zarządzania.
4. Pobierz wygenerowane `folder_id` dla folderu GOM (będzie potrzebne do konfiguracji Secret Managera).

### Krok 2: Aktywacja API w `admin-project`
Uruchom poniższe polecenia w Cloud Shell, aby włączyć wymagane usługi Google Cloud (w tym silniki AI i bazy danych pod Agenta):

```bash
# Krok 2: Aktywacja API w `admin-project`
# Uruchom poniższe polecenia w Cloud Shell, aby włączyć wymagane usługi Google Cloud:

gcloud services enable iam.googleapis.com --project=admin-project
gcloud services enable cloudresourcemanager.googleapis.com --project=admin-project
gcloud services enable cloudbilling.googleapis.com --project=admin-project
gcloud services enable secretmanager.googleapis.com --project=admin-project
gcloud services enable discoveryengine.googleapis.com --project=admin-project
gcloud services enable aiplatform.googleapis.com --project=admin-project
gcloud services enable sqladmin.googleapis.com --project=admin-project

```

### Krok 3: Konfiguracja State Backend (Cloud Storage)
1. Utwórz zabezpieczony bucket na stan Terraform: `ump-tf-state-prod`.
2. **Krytyczne:** Włącz wersjonowanie obiektów (Object Versioning) na buckecie, aby zabezpieczyć stan przed przypadkowym nadpisaniem:
   ```bash
   gcloud storage buckets update gs://ump-tf-state-prod --versioning
   ```
3. Zapewnij strukturę katalogów pod klucz stanu: `terraform/state/default.tfstate`.
4. Nadaj uprawnienia `Storage Object Admin` dla konta serwisowego Terraform (szczegóły w Kroku 5).

**Konfiguracja w kodzie (`backend.tf`):**
```hcl
terraform {
  backend "gcs" {
    bucket  = "ump-tf-state-prod"
    prefix  = "terraform/state"
  }
}
```

### Krok 4: Zarządzanie Zmiennymi Wrażliwymi (Secret Manager)
1. W `admin-project` utwórz sekret o nazwie `terraform_pmo_projects` pod ścieżką: `projects/1234567/secrets/terraform_pmo_projects`.
2. Umieść w sekrecie konfigurację JSON (wartości dopasuj do nowego tenanta):
```json
{
  "billing_account": "123-456-789",
  "org_id": "123456789",
  "folder_id": "YOUR_GOM_FOLDER_ID",
  "region": "europe-central2"
}
```
3. Zaktualizuj referencję do nazwy sekretu w pliku `provider.tf`.
4. Wyłącz dziedziczenie uprawnień dla tego sekretu i nadaj rolę `Secret Manager Admin` bezpośrednio dla konta serwisowego Terraform (brak dziedziczenia = *No inheritance*).

### Krok 5: Konta Serwisowe i Uprawnienia IAM

#### A. Rola na poziomie Konta Rozliczeniowego (Billing Account)
Aby Terraform mógł automatycznie przypisywać nowo tworzone projekty pod rozliczenia, konto serwisowe wdrożeniowe musi posiadać uprawnienia na poziomie samego Billing Account:
* Konto `terraform@://gserviceaccount.com` -> rola **`Billing User`** (`roles/billing.user`) nadana bezpośrednio na koncie rozliczeniowym.

#### B. Konto GitHub Actions (`github@://gserviceaccount.com`)
Odpowiada za autoryzację OIDC z GitHub. Przypisz role na poziomie **`admin-project`**:
* `roles/iam.serviceAccountAdmin` (Zarządzanie kontami serwisowymi w projekcie admin)
* `roles/storage.objectAdmin` (Dostęp do bucketu stanu)
* `roles/iam.workloadIdentityUser` (Uwierzytelnianie przez federację tożsamości)

#### C. Konto Terraform Deployment (`terraform@://gserviceaccount.com`)
Główne konto wykonawcze wykonujące `terraform apply`. 

1. Przypisz role na poziomie **folderu GOM**:
   * `roles/resourcemanager.folderAdmin`
   * `roles/resourcemanager.projectMover`
   * `roles/resourcemanager.projectCreator`
   * `roles/resourcemanager.folderIamAdmin`
   * `roles/iam.workforcePoolAdmin`
   * `roles/iam.workloadIdentityUser`
   * `roles/iam.serviceAccountTokenCreator`
   * `roles/serviceusage.serviceUsageAdmin`
   * `roles/artifactregistry.reader`
   * `roles/artifactregistry.admin`
   * `roles/bigquery.admin`
   * `roles/storage.admin`

2. **Impersonacja:** Aby konto `github@` mogło wygenerować token dla konta `terraform@` podczas deploymentu, nadaj kontu `github@` rolę **`Service Account Token Creator`** (`roles/iam.serviceAccountTokenCreator`) bezpośrednio na zasobie konta serwisowego `terraform@`.

#### Podczepienie tożsamości GitHub pod SA za pomocą WIF
Wykonaj powiązanie Workload Identity Federation (WIF) w CLI:

```bash
gcloud iam service-accounts add-iam-policy-binding \
  terraform-admin@://gserviceaccount.com \
  --project="admin-project-123456" \
  --member="principalSet://://googleapis.com/projects/123456789/locations/global/workloadIdentityPools/git-hub/attribute.repository/AsiaWasik/repo_ump_terraform" \
  --role="roles/iam.serviceAccountTokenCreator"
```

### Krok 6: Konfiguracja Workload Identity Federation (WIF)
1. Skonfiguruj Identity Pool oraz Identity Provider dla GitHub w konsoli GCP lub za pomocą CLI.
2. Sparuj repozytorium `AsiaWasik/repo_ump_terraform` z odpowiednimi atrybutami (jak w komendzie powyżej).

### Krok 7: Pipeline GitHub Actions (.github/workflows/*.yaml)
Wdrożenie automatyczne wymaga barier bezpieczeństwa chroniących środowisko produkcyjne przed niekontrolowanym `terraform apply`. Zastosuj jedno z dwóch rozwiązań:
1. **GitHub Environments (Zalecane):** Skonfiguruj środowisko (np. `production`) w opcjach repozytorium i dodaj regułę **Required reviewers**. Pipeline zatrzyma się przed fazą `apply` do momentu manualnej akceptacji wskazanych osób.
2. **Manual Workflow / Input:** Dodaj krok `workflow_dispatch` w pliku YAML lub wymuś krok weryfikacji blokujący automatyczne wykonanie flagi `-auto-approve`.

---

## 👥 Zarządzanie Dostępem Użytkowników (Google Groups)

Dostęp dla członków zespołu realizowany jest poprzez grupy Google, co pozwala na centralne zarządzanie uprawnieniami bez nadawania ich na konta imienne.

### 1. Grupa: `ump-storage-viewer`
* **Członkowie:** Marcel, Ola
* **Zastosowanie:** Wyłącznie podgląd i odczyt danych w Cloud Storage.
* **Role IAM:**
  * `roles/storage.objectViewer` (Storage Object Viewer)
  * `roles/storage.viewer` (Storage Viewer)

### 2. Grupa: `ump-agent-creator`
* **Członkowie:** Janek
* **Zastosowanie:** Pełna deweloperka, utrzymanie oraz zarządzanie komponentami platformy AI Agent.
* **Role IAM:**
  * `roles/discoveryengine.admin` (Agent Platform / Discovery Engine Administrator)
  * `roles/cloudsql.admin` (Cloud SQL Admin)
  * `roles/bigquery.jobUser` (BigQuery Job User)
  * `roles/bigquery.dataEditor` (BigQuery Data Editor)
  * `roles/storage.objectCreator` (Storage Object Creator)
  * `roles/storage.objectViewer` (Storage Object Viewer)
  * `roles/iam.serviceAccountAdmin` (Service Account Admin - pozwala na tworzenie kont serwisowych dla komponentów aplikacji)
  * `roles/iam.serviceAccountUser` (Service Account User)
