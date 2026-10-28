# MS Energy Project – POC

CAP + Fiori Elements V4 proof of concept for Microsoft.

## Apps

**energy-project-poc** – the main demo  
Energy project with a Phases tab. Add a phase and it shows up in the DCEP dropdown straight away — no save needed.

**project-list-search** – DCEP projects list  - WIP. 
Simple list of DCEP projects with live filters.

**sort-test** – sorting proof of concept  
Proves that `@UI.presentationVariant` sorting works on the `abp_creation_tstmpl` field type — the same type used for `created_at` in the client's system.

## Run
cds watch

- POC app: http://localhost:4004/energy-project-poc/webapp/index.html
- Sort test: http://localhost:4004/sorttest/index.html

## Notes
- SQLite in-memory — data resets on every restart
- Phases added in the POC app also appear in the list search phase filter

---

## How to test the sort-test app

> **Requires access to the SAP BTP ABAP Cloud system:**  
> `e5c973fa-1b0a-475f-9998-0e4c8f1d054a.abap.us10.hana.ondemand.com`  
> You need a user account on this system. When prompted, log in with your SAP BTP credentials.

1. Run `cds watch`
2. Open http://localhost:4004/sorttest/index.html
3. Log in with your SAP BTP credentials when prompted
4. The table loads with data from ABAP Cloud (table `ZADT_PRV_TEST`, CDS view `ZI_ADT_PRV_TEST`)
5. Records should appear sorted by **Created At** descending — newest row first, oldest last
6. No need to click any column header — the sort is applied automatically by the `@UI.presentationVariant` annotation on the ABAP side

**What this proves:** if the rows are newest-first on load, the annotation is working correctly on `abp_creation_tstmpl` fields.
