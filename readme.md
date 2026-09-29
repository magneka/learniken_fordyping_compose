# oppgaver_compose01

## Eksempler

- [Documents/terminal01.md](Documents/terminal01.md) — Terminal01 example: Dockerfile/compose explained, how to run and debug it.

- [Documents/compose05.md](Documents/compose05.md) — Compose05 example: .env/Dockerfile/compose explained, building/running in VS Code, and attaching to the running container to debug.

## Documents

- [Documents/compose-syntax.md](Documents/compose-syntax.md) — Docker Compose syntax reference.

## Tips til Oppggaver
Studer eksemplet Compose05 some er et GO api mot end MsSql server.
Se på readme, der alt er beskrevet.

Begynn med databasen, be om en dockerfile
Så kan du legge til at den skal bruke .env file
Så kan du be om at den skal persisteres i et volum
Så kan du be om at den skal seedes ved første kjøring, pek på init sql.
Kan du nå nå databasen med bat filer med select?
Kan du be ai om å kjøre select inni databasen?

Når du er sikker på at databasen virker, kan du se på dockerfilen til applikasjonen.

Begynn med en enkel dockerfile for å bygge applikasjonen.
Du må mappe porter så du når den fra utsiden, har du mye oppe kan du få portkonflikt.
Du skal ikke kopiere kildekoden inn i containeren, men mappe opp foldere.
Så kan du gjøre denne til ett trinns for debugging.
Det er viktig at compose har stdin_open og tty, ellers stenges den ned før du vet ordet av det.  dockerfilen skal heller ikke starte applikasjonen, men en tail av konsollet holder lenge, bash også.

Det er kanskje foldere som finnes inni containeren som ikke skal blø ut? (bin/obj)
Du kan bruke healthcheck til å vente med å starte rest api containeren til databasen er oppe.

Se nøye på filene i .vscode folderen. Disse vil du kanskje ta vare på, for ingen modeller klarer å produsere disse uten timesvis med halisunasjoner...
Microsoft har endret spesifikasjoner på Launch filen, og det er kombinasjoner med launch og extensions som gjør at det fungerer, og det har ikke modellene fått med seg fordi man ofte ikke har en extensions file sjekket inn, men har installert extensions globalt.


## Oppggaver
### Oppgave 1
Banalt eksempel, bygg og kjør en C# applikasjon.
To trinn i dockerfile, bygg og kjør

### Oppgave 2 C# produksjon
Vi skal bruke MySql, bruke .ENV file til hemmeligheter. 
Databasen skal seedes initielt med en customerstabell med data.
Databasen skal ha et eget persistert volum til data.
(Bruk bat filene til å sjekke mot database, om data er på plass)

I source folderen ligger et minimalt C# program som kjører mot databasen.
Lag en totrinns dockerfile for kjøring i produksjon,

Du skal lage docker-compose.yml og Dockerfile for bygging av C#


### Oppgave 3 C# Debug
Som forrige eksempel,  bruk MySql, bruke .ENV file til hemmeligheter. 
Databasen skal seedes initielt med en customerstabell med data.
Databasen skal ha et eget persistert volum til data.
(Bruk bat filene til å sjekke mot database, om data er på plass)

I source folderen ligger et minimalt C# program som kjører mot databasen.
Lag et trinns dockerfile for debugging

Du skal lage docker-compose.yml og Dockerfile for debugging av C#


### Oppgave 4
Bruk Postgres databse, skal seedes initielt med customertabell, sql filer ligger der.  Bruk .env file.  Map folders for source inn i container.
Husk persisten folder

Det ligger et Java Spring Boot restapi, som skal debugges.

Du skal lage docker-compose.yml og Dockerfile for debugging av java.


