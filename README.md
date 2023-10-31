# Movie Journal App

## Beschreibung
Move Journal App soll dem User die Möglichkeit geben, gesehene Filme abzuspeichern oder Filme zur Watchlist hinzuzufügen. 
Auf dem Dashboard werden Filme vorgeschlagen, wie nach Beliebtheit oder Genre. Hinzu ist es möglich über ein Keyword nach Filmen zu suchen.
Alle Filme haben eine Detailansicht, indem diese zur Watchlist hinzugefügt, als gesehen markiert oder bewertet werden können. 

## Zielsetzung
Mit dieser App wollte ich die Architektur von TCA in Kombination mit der Realm Datenbank ausprobieren.

## Herausforderungen
Ich hatte Herausforderungen, Datenbankoperationen wie Speichern oder Erstellen als Effekt im Reducer einzubauen, weil diese keine Publisher zurückgeben, die als Effekt umgewandelt werden konnten. Es war notwendig, die Write Transaction in einem Future Combine Objekt zu wrappen, damit bei Erfolg oder Misserfolg ein AnyPublisher als Effect zurückgegeben werden kann. 
Ein Effect erwartet darüber hinaus von einem AnyPublisher keinen Failure (publisher(AnyPublisher<Action, Never>)>), was das Error Handling erschwert, weil bei einer Datenbankoperation Fehler passieren können. Hierfür habe ich ein Signal Enum, welches als Action in einem Effect zurückgegeben werden kann. Das Signal Enum hat dann wie ein Result die Cases success und failure. Über diese Enum kann nun das Error Handling passieren. Ob diese Lösung optimal ist, muss noch evaluiert werden, weil es keine schöne Lösung darstellt. 

## Vorraussetzungen

- Xcode 15
- iOS 16.0
- API Key von TMDB
Verwendete REST API: [Movies REST API von TMDB](https://developer.themoviedb.org/reference/intro/getting-started)

## Verwendete Technologien (Tech Stack)
- SwiftUI
- The Composable Architecture
- Realm Database
- Combine
- Async/Await

## Package Manager
- Swift Package Manager (SPM)

## Features
- Übersicht von gesehenen Filme
- Watchlist
- Filtern nach Bewertung, Name, Jahr (aufsteigend und absteigend)
- Suche nach Filmen
- Filmvorschläge nach Beliebtheit oder Genre
- Filme in der Datenbank gespeichern
- Film Detailansicht (Cover, Bewertung, Beschreibung, Veröffentlichungsdatum)
- Filme als gesehen markieren
- Filme zur Watchlist hinzufügen
- Filme bewerten auf einer Skala von 0-10
- Unit Tests

## Kommende Features
- Notizen zum Filmen abspeichern
- Mehr Filme anzeigen bei den Filmvorschlägen mit Pagination
- Pagination bei den Suchergebnissen
- User friendly Error Handling
- Mehr Informationen zum Film anzeigen wie Schauspieler, Dauer, usw.
