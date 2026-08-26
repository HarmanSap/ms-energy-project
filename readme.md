# MS Energy Project – POC

CAP + Fiori Elements V4 proof of concept for Microsoft.

## Apps

**energy-project-poc** – the main demo  
Energy project with a Phases tab. Add a phase and it shows up in the DCEP dropdown straight away — no save needed.

**project-list-search** – DCEP projects list  - WIP. 
Simple list of DCEP projects with live filters.

## Run
npm run watch

- POC app: http://localhost:4004/energy-project-poc/webapp/index.html

## Notes
- SQLite in-memory — data resets on every restart
- Phases added in the POC app also appear in the list search phase filter